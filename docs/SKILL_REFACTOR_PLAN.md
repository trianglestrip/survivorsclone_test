# 技能系统重构方案

## 当前问题分析

通过分析所有技能实现，发现了大量重复代码和可抽象的通用模式：

### 重复代码模式

#### 1. 持续性技能节点创建（E/R技能）
所有E/R技能都有相似的模式：
```gdscript
# 创建节点
skill_node = Node2D.new()
skill_node.name = "SkillName"
skill_node.global_position = pos
skill_node.z_index = X

# 创建动画精灵
var animated_sprite = preload("res://Utility/animated_skill_sprite.gd").new()
animated_sprite.scale = Vector2(...)
animated_sprite.modulate = Color(...)
animated_sprite.fps = X
animated_sprite.loop = true

# 加载动画帧
if animated_sprite.load_from_skill("skill_name"):
    skill_node.add_child(animated_sprite)
else:
    # 回退到占位纹理...

# 创建伤害区域
var damage_area = Area2D.new()
var shape = CollisionShape2D.new()
var circle/rect = CircleShape2D/RectangleShape2D.new()
# ...设置碰撞...

# 添加自动清理
var cleanup_script = load("res://Utility/auto_cleanup_node.gd")
skill_node.set_script(cleanup_script)
skill_node.set("lifetime", duration)

# 添加到场景
if player and player.get_parent():
    player.get_parent().add_child(skill_node)
    await get_tree().process_frame
```

**重复次数**: 至少8次（ice_field, ice_storm, fire_wall, fire_meteor, thunder_field, thunder_god, poison_cloud, poison_plague）

---

#### 2. 弹射物创建（Q技能）
所有Q技能都有相似的弹射物创建：
```gdscript
var projectile = Node2D.new()
projectile.name = "ProjectileName"
projectile.position = pos
projectile.z_index = 5

var sprite = preload("res://Utility/animated_skill_sprite.gd").new()
sprite.rotation = dir.angle()
sprite.scale = Vector2(...)
sprite.modulate = Color(...)
sprite.fps = X
sprite.loop = true

if not sprite.load_from_skill("skill_name"):
    sprite.texture = VisualEffectsHelper.create_placeholder_texture(...)

projectile.add_child(sprite)

var projectile_script = load("res://Utility/auto_projectile.gd")
projectile.set_script(projectile_script)
projectile.set("direction", dir)
projectile.set("speed", speed)
projectile.set("max_range", range)
```

**重复次数**: 至少4次（ice_shard, fire_ball, thunder_strike, poison_dart）

---

#### 3. 周期性伤害逻辑（Tick Damage）
```gdscript
var tick_timer: float = 0.0
var tick_interval: float = 0.3

func _process(delta: float):
    if not is_active or not is_instance_valid(skill_node):
        return
    
    elapsed_time += delta
    tick_timer += delta
    
    if tick_timer >= tick_interval:
        tick_timer = 0.0
        _deal_damage()
    
    if elapsed_time >= duration:
        is_active = false
```

**重复次数**: 至少8次（所有E/R技能）

---

#### 4. 状态效果应用
```gdscript
func _apply_slow(enemy: Node):
    if enemy and enemy.has_method("apply_slow"):
        enemy.apply_slow(slow_percent, slow_duration)

func _apply_freeze(enemy: Node):
    if enemy and enemy.has_method("apply_freeze"):
        enemy.apply_freeze(freeze_duration)

func _apply_burn(enemy: Node):
    if enemy and enemy.has_method("apply_burn"):
        enemy.apply_burn(burn_damage, burn_duration)
```

**重复次数**: 每个技能都有类似的状态效果应用

---

## 重构方案

### 阶段1：抽象持续性技能节点创建

在`BaseActiveSkill`中添加：

```gdscript
## 技能节点类型枚举
enum SkillNodeType {
    PROJECTILE,    # 弹射物（Q技能）
    AREA_CIRCLE,   # 圆形区域（E/R技能）
    AREA_RECT,     # 矩形区域（火墙等）
}

## 创建技能节点的配置
class SkillNodeConfig:
    var node_name: String
    var node_type: SkillNodeType
    var position: Vector2
    var z_index: int = 2
    
    # 动画配置
    var skill_animation_name: String
    var animation_scale: Vector2
    var animation_modulate: Color
    var animation_fps: float = 10.0
    var animation_loop: bool = true
    
    # 碰撞配置
    var collision_radius: float = 0.0  # 圆形
    var collision_size: Vector2 = Vector2.ZERO  # 矩形
    
    # 生命周期
    var lifetime: float = 0.0
    var fade_duration: float = 0.5
    
    # 弹射物特定
    var projectile_direction: Vector2 = Vector2.RIGHT
    var projectile_speed: float = 400.0
    var projectile_range: float = 300.0

## 通用技能节点创建方法
func create_skill_node(config: SkillNodeConfig) -> Node2D:
    var skill_node = Node2D.new()
    skill_node.name = config.node_name
    skill_node.global_position = config.position
    skill_node.z_index = config.z_index
    
    # 创建动画精灵
    _add_animated_sprite(skill_node, config)
    
    # 创建碰撞区域
    _add_damage_area(skill_node, config)
    
    # 添加生命周期管理
    if config.lifetime > 0:
        _add_auto_cleanup(skill_node, config.lifetime, config.fade_duration)
    
    # 弹射物特定逻辑
    if config.node_type == SkillNodeType.PROJECTILE:
        _add_projectile_behavior(skill_node, config)
    
    # 添加到场景
    if player and player.get_parent():
        player.get_parent().add_child(skill_node)
        if skill_node.is_inside_tree():
            await skill_node.get_tree().process_frame
    
    return skill_node
```

---

### 阶段2：抽象周期性伤害系统

```gdscript
## 周期性伤害配置
class TickDamageConfig:
    var enabled: bool = false
    var interval: float = 0.5
    var damage_callback: Callable  # 子类提供的伤害逻辑

var tick_damage_config: TickDamageConfig = null
var tick_timer: float = 0.0

## 启用周期性伤害
func enable_tick_damage(interval: float, callback: Callable):
    tick_damage_config = TickDamageConfig.new()
    tick_damage_config.enabled = true
    tick_damage_config.interval = interval
    tick_damage_config.damage_callback = callback
    set_process(true)

## 基类的_process处理周期性伤害
func _process(delta: float):
    if not is_active:
        return
    
    elapsed_time += delta
    
    # 处理周期性伤害
    if tick_damage_config and tick_damage_config.enabled:
        tick_timer += delta
        if tick_timer >= tick_damage_config.interval:
            tick_timer = 0.0
            tick_damage_config.damage_callback.call()
    
    # 持续时间结束
    if duration > 0 and elapsed_time >= duration:
        is_active = false
    
    _on_skill_update(delta)
```

---

### 阶段3：抽象状态效果系统

```gdscript
## 状态效果类型
enum StatusEffect {
    SLOW,
    FREEZE,
    BURN,
    POISON,
    STUN,
}

## 状态效果配置
class StatusEffectConfig:
    var effect_type: StatusEffect
    var value: float  # slow_percent, burn_damage等
    var duration: float

var status_effects: Array[StatusEffectConfig] = []

## 添加状态效果
func add_status_effect(effect_type: StatusEffect, value: float, duration: float):
    var config = StatusEffectConfig.new()
    config.effect_type = effect_type
    config.value = value
    config.duration = duration
    status_effects.append(config)

## 应用所有状态效果到敌人
func apply_status_effects(enemy: Node):
    for effect in status_effects:
        match effect.effect_type:
            StatusEffect.SLOW:
                if enemy.has_method("apply_slow"):
                    enemy.apply_slow(effect.value, effect.duration)
            StatusEffect.FREEZE:
                if enemy.has_method("apply_freeze"):
                    enemy.apply_freeze(effect.duration)
            StatusEffect.BURN:
                if enemy.has_method("apply_burn"):
                    enemy.apply_burn(effect.value, effect.duration)
            StatusEffect.POISON:
                if enemy.has_method("apply_poison"):
                    enemy.apply_poison(effect.value, effect.duration)
```

---

### 阶段4：抽象视觉效果创建

```gdscript
## 视觉效果配置
class VisualEffectConfig:
    var texture_path: String = ""
    var position_offset: Vector2 = Vector2.ZERO
    var scale: Vector2 = Vector2.ONE
    var modulate: Color = Color.WHITE
    var rotation: float = 0.0
    var z_index: int = 10
    var fade_duration: float = 0.5

## 快速创建并添加视觉效果
func create_visual_effect(config: VisualEffectConfig) -> Sprite2D:
    var effect = Sprite2D.new()
    effect.global_position = player.global_position + config.position_offset
    effect.scale = config.scale
    effect.modulate = config.modulate
    effect.rotation = config.rotation
    effect.z_index = config.z_index
    effect.texture = VisualEffectsHelper.load_texture_or_placeholder(
        config.texture_path, Vector2(64, 64)
    )
    
    # 添加自动淡出
    var fade_script = load("res://Utility/auto_fade_sprite.gd")
    effect.set_script(fade_script)
    effect.set("fade_duration", config.fade_duration)
    
    if player and player.get_parent():
        player.get_parent().add_child(effect)
    
    return effect
```

---

## 重构后的子类示例

### 重构前：ice_field.gd (169行)

### 重构后：ice_field.gd (约50行)

```gdscript
class_name IceFieldSkill
extends BaseActiveSkill

var radius: float = 0.0
var slow_percent: float = 0.0
var slow_duration: float = 0.0
var field_node: Node2D = null

func _load_skill_config(cfg: Dictionary):
    radius = cfg.get("radius", 150.0)
    duration = cfg.get("duration", 4.0)
    slow_percent = cfg.get("slow_percent", 0.5)
    slow_duration = duration
    
    # 配置状态效果
    add_status_effect(StatusEffect.SLOW, slow_percent, slow_duration)

func _on_skill_cast(cast_position: Vector2, _cast_direction: Vector2):
    trigger_screen_shake(GameConstants.Values.SHAKE_ATTACK * 0.5)
    
    # 使用基类方法创建技能节点
    var node_config = SkillNodeConfig.new()
    node_config.node_name = "IceField"
    node_config.node_type = SkillNodeType.AREA_CIRCLE
    node_config.position = cast_position
    node_config.z_index = 1
    node_config.skill_animation_name = "ice_field"
    node_config.animation_scale = Vector2(radius / 128.0, radius / 128.0)
    node_config.animation_modulate = Color(1.0, 1.0, 1.0, 0.6)
    node_config.animation_fps = 8.0
    node_config.animation_loop = true
    node_config.collision_radius = radius
    node_config.lifetime = duration
    node_config.fade_duration = 0.5
    
    field_node = await create_skill_node(node_config)
    
    # 启用周期性伤害
    enable_tick_damage(0.5, _deal_damage)

func _deal_damage():
    var enemies = get_enemies_in_range(field_node.global_position, radius)
    for enemy in enemies:
        damage_enemy(enemy, damage)
        apply_status_effects(enemy)
```

**代码减少**: 169行 → 约50行 (减少70%)

---

## 实施计划

### 优先级1：核心抽象（立即实施）
1. ✅ 持续性技能节点创建（`create_skill_node`）
2. ✅ 周期性伤害系统（`enable_tick_damage`）
3. ✅ 状态效果系统（`add_status_effect`, `apply_status_effects`）
4. ✅ 自动清理集成（统一使用`auto_cleanup_node`）

### 优先级2：辅助功能（后续优化）
1. 视觉效果快速创建（`create_visual_effect`）
2. 弹射物行为配置化
3. 多层效果生成器
4. 动画效果模板

### 优先级3：高级特性（未来扩展）
1. 技能链式反应系统
2. 技能组合效果
3. 动态技能升级
4. 技能AI提示系统

---

## 预期收益

### 代码质量
- **代码减少**: 平均每个技能减少60-70%代码
- **可维护性**: 修改一处，所有技能受益
- **一致性**: 统一的行为模式和错误处理

### 开发效率
- **新技能开发**: 从2小时降低到30分钟
- **Bug修复**: 集中修复，无需逐个技能调整
- **测试覆盖**: 基类测试覆盖所有子类

### 性能
- **内存优化**: 统一的对象池和缓存管理
- **CPU优化**: 减少重复的节点创建和查询
- **可预测性**: 统一的生命周期管理

---

## 技术要点

### 1. 配置驱动设计
所有技能行为都通过配置对象定义，而不是硬编码：
```gdscript
# 不好的做法
func create_field():
    var node = Node2D.new()
    node.name = "IceField"
    node.z_index = 1
    # ...

# 好的做法
func create_field():
    var config = SkillNodeConfig.new()
    config.node_name = "IceField"
    config.z_index = 1
    return create_skill_node(config)
```

### 2. 回调机制
使用`Callable`让子类提供特定逻辑：
```gdscript
# 基类提供框架
func enable_tick_damage(interval: float, callback: Callable)

# 子类提供具体逻辑
enable_tick_damage(0.5, func():
    var enemies = get_enemies_in_range(...)
    for enemy in enemies:
        damage_enemy(enemy, damage)
)
```

### 3. 组合优于继承
使用配置对象组合功能，而不是创建多层继承：
```gdscript
# 不好：多层继承
class AreaSkill extends BaseActiveSkill
class CircleAreaSkill extends AreaSkill
class IceFieldSkill extends CircleAreaSkill

# 好：配置组合
class IceFieldSkill extends BaseActiveSkill:
    func _on_skill_cast():
        var config = SkillNodeConfig.new()
        config.node_type = SkillNodeType.AREA_CIRCLE
        # ...
```

---

## 风险评估

### 低风险
- ✅ 新增基类方法（不影响现有代码）
- ✅ 配置对象创建（纯新增）

### 中风险
- ⚠️ 修改现有技能实现（需要充分测试）
- ⚠️ 改变节点生命周期管理（可能影响性能）

### 高风险
- ❌ 修改基类核心方法（会影响所有技能）

### 缓解策略
1. **渐进式重构**: 一次重构一个技能，验证后再继续
2. **保留原有代码**: 使用Git分支，保留回退路径
3. **完整测试**: 每次重构后运行完整测试套件
4. **性能监控**: 对比重构前后的性能指标

---

## 实施步骤

### Step 1: 扩展基类（不破坏现有代码）
- [ ] 在`base_active_skill.gd`中添加新的辅助类和方法
- [ ] 创建配置对象类（`SkillNodeConfig`等）
- [ ] 实现`create_skill_node`方法
- [ ] 实现`enable_tick_damage`方法
- [ ] 实现状态效果系统

### Step 2: 重构冰心宗技能（验证方案）
- [ ] 重构`ice_field.gd`
- [ ] 重构`ice_storm.gd`
- [ ] 重构`ice_shard.gd`
- [ ] 运行测试验证功能正常

### Step 3: 应用到其他宗派
- [ ] 重构雷鸣宗技能（3个）
- [ ] 重构烈焰宗技能（3个）
- [ ] 重构毒瘴宗技能（3个）

### Step 4: 文档和优化
- [ ] 更新技能开发指南
- [ ] 创建技能模板
- [ ] 性能优化和测试

---

## 时间估算

- **阶段1（基类扩展）**: 2-3小时
- **阶段2（冰心宗重构）**: 1-2小时
- **阶段3（其他宗派）**: 2-3小时
- **阶段4（文档优化）**: 1小时

**总计**: 6-9小时

---

*文档创建时间: 2026-03-29 21:50*
