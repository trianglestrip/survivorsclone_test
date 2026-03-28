# 技能 GPU 实例化架构

## 概述

技能系统采用与敌人相同的 GPU 实例化 + Shader 动画架构，实现高性能批量渲染。

## 架构设计

### 职责划分

```
┌─────────────────────────────────────────────────────────────┐
│                         Player                              │
│  - 决定何时发射技能（定时器、触发条件）                      │
│  - 调用技能子类的 get_spawn_params() 获取生成参数            │
│  - 调用 SkillInstanceManager.spawn_skill()                  │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    BaseSkill (子类)                         │
│  - 定义技能的行为逻辑（如何移动、如何追踪）                  │
│  - get_spawn_params(): 返回初始位置、速度、旋转、目标        │
│  - update_skill_instance(): 每帧更新技能实例的行为           │
│  - 从配置文件加载技能属性                                    │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│              SkillInstanceManager (GPU)                     │
│  - MultiMesh 批量渲染                                        │
│  - Shader 动画播放                                           │
│  - 碰撞检测（HitBox）                                        │
│  - 生命周期管理                                              │
│  - 调用技能子类的 update_skill_instance() 更新行为           │
└─────────────────────────────────────────────────────────────┘
```

## 实现示例

### 1. 技能子类定义行为

```gdscript
# Skills/ice_spear.gd
extends "res://Skills/base_skill.gd"

@export var tracking_speed := 200.0
@export var rotation_offset := 135.0

func _init():
    skill_id = "icespear"

func get_spawn_params() -> Dictionary:
    var target = player.get_random_target() if player else Vector2.ZERO
    var angle = player.position.direction_to(target)
    
    return {
        "position": player.position,
        "velocity": angle * speed,
        "rotation": angle.angle() + deg_to_rad(rotation_offset),
        "target": target
    }

func update_skill_instance(inst: Dictionary, delta: float) -> Dictionary:
    # 追踪目标
    if inst.target != Vector2.ZERO:
        var dir = inst.position.direction_to(inst.target)
        inst.velocity = dir * tracking_speed
        inst.rotation = dir.angle() + deg_to_rad(rotation_offset)
    
    return inst
```

### 2. Player 触发技能

```gdscript
# Player/player.gd

func _on_ice_spear_timer_timeout():
    var ammo = skill_mgr.get_skill_ammo("icespear")
    if ammo > 0:
        # 获取技能行为逻辑
        var skill_behavior = skill_behaviors["icespear"]
        var params = skill_behavior.get_spawn_params()
        
        # 生成技能实例（GPU）
        skill_instance_mgr.spawn_skill(
            "icespear",
            params.position,
            params.velocity,
            params.rotation,
            params.target
        )
        
        skill_mgr.set_skill_ammo("icespear", ammo - 1)
```

### 3. SkillInstanceManager 管理渲染

```gdscript
# Skills/skill_instance_manager.gd

func _update_skill_type(type_data: SkillTypeData, delta: float):
    for inst in type_data.instances:
        if not inst.active:
            continue
        
        # 调用技能子类的行为逻辑
        if type_data.behavior_script:
            var updated = type_data.behavior_script.update_skill_instance({
                "position": inst.position,
                "velocity": inst.velocity,
                "rotation": inst.rotation,
                "scale": inst.scale,
                "lifetime": inst.lifetime,
                "target": inst.target
            }, delta)
            
            inst.position = updated.position
            inst.velocity = updated.velocity
            inst.rotation = updated.rotation
        else:
            # 默认行为：直线移动
            inst.position += inst.velocity * delta
        
        # 更新碰撞体、生命周期等
        # ...
```

## 技能类型示例

### 冰矛 (IceSpear) - 追踪型

**行为特点**：
- 发射时指向目标
- 持续追踪目标位置
- 直线飞行，速度快

**实现**：
```gdscript
func update_skill_instance(inst: Dictionary, delta: float) -> Dictionary:
    if inst.target != Vector2.ZERO:
        var dir = inst.position.direction_to(inst.target)
        inst.velocity = dir * tracking_speed
        inst.rotation = dir.angle() + deg_to_rad(rotation_offset)
    return inst
```

### 龙卷风 (Tornado) - 曲线型

**行为特点**：
- 根据玩家移动方向生成
- 之字形移动轨迹
- 速度逐渐加快

**实现**：
```gdscript
var direction_timer := 0.0
var current_angle := Vector2.ZERO
var target_angle := Vector2.ZERO

func update_skill_instance(inst: Dictionary, delta: float) -> Dictionary:
    direction_timer += delta
    
    # 每 2 秒切换方向
    if direction_timer >= 2.0:
        direction_timer = 0.0
        target_angle = -current_angle  # 反转方向
    
    # 平滑过渡到目标角度
    current_angle = current_angle.lerp(target_angle, delta * 2.0)
    inst.velocity = current_angle * inst.get("current_speed", speed)
    
    # 速度逐渐增加
    inst["current_speed"] = min(inst.get("current_speed", speed * 0.2) + delta * 50, speed)
    
    return inst
```

### 标枪 (Javelin) - 环绕型

**行为特点**：
- 环绕玩家周围
- 定期向敌人发起攻击
- 攻击后返回玩家身边

**实现**：
```gdscript
var orbit_angle := 0.0
var attack_targets := []
var is_attacking := false

func update_skill_instance(inst: Dictionary, delta: float) -> Dictionary:
    if is_attacking and attack_targets.size() > 0:
        # 攻击模式：飞向目标
        var target = attack_targets[0]
        var dir = inst.position.direction_to(target)
        inst.velocity = dir * speed
        inst.rotation = dir.angle() + deg_to_rad(135)
        
        # 到达目标，切换下一个
        if inst.position.distance_to(target) < 10:
            attack_targets.remove_at(0)
            if attack_targets.size() == 0:
                is_attacking = false
    else:
        # 环绕模式：围绕玩家
        orbit_angle += delta * 2.0
        var offset = Vector2(cos(orbit_angle), sin(orbit_angle)) * orbit_radius
        var target_pos = player.position + offset
        inst.velocity = (target_pos - inst.position) * 5.0
        inst.rotation = inst.velocity.angle() + deg_to_rad(135)
    
    return inst

func start_attack():
    # 由定时器触发
    is_attacking = true
    attack_targets = []
    for i in range(paths):
        attack_targets.append(player.get_random_target())
```

## 配置文件

### skill_config.ini

```ini
[IceSpear]
base_damage=5
base_speed=200
base_knockback_amount=100
base_attack_size=1.0
base_lifetime=5.0
base_pierce=1

[Tornado]
base_damage=10
base_speed=100
base_knockback_amount=50
base_attack_size=1.5
base_lifetime=12.0
base_pierce=-1

[Javelin]
base_damage=8
base_speed=150
base_knockback_amount=120
base_attack_size=1.0
base_lifetime=999.0
base_pierce=3
```

## 优势

### 1. 性能提升
- **批量渲染**：同类型技能共享 MultiMesh，减少 Draw Call
- **Shader 动画**：GPU 计算动画帧，CPU 零开销
- **减少节点数**：1000 个技能 = 1 个 MultiMeshInstance2D（vs 1000 个 Area2D）

### 2. 代码清晰
- **Player**：只管触发时机
- **技能子类**：只管行为逻辑
- **SkillInstanceManager**：只管渲染和碰撞

### 3. 易于扩展
- 新增技能：继承 `BaseSkill` + 重写 `get_spawn_params()` 和 `update_skill_instance()`
- 新增行为：在子类中实现特殊逻辑
- 配置驱动：所有数值从 INI 文件读取

## 与敌人系统的对比

| 特性 | 敌人系统 | 技能系统 |
|------|---------|---------|
| **渲染** | MultiMesh + Shader | MultiMesh + Shader |
| **碰撞** | HurtBox + HitBox | HitBox |
| **移动** | 追踪玩家（统一） | 各技能自定义 |
| **生命周期** | 被击杀 | 超时/穿透耗尽 |
| **行为逻辑** | 在 Manager 中 | 在子类中 |

## 迁移指南

### 从旧架构迁移

**旧架构**（每个技能是独立的 Area2D 节点）：
```gdscript
# 旧代码
var icespear_attack = iceSpear.instantiate()
icespear_attack.position = position
icespear_attack.target = get_random_target()
add_child(icespear_attack)
```

**新架构**（GPU 实例化）：
```gdscript
# 新代码
var skill_behavior = skill_behaviors["icespear"]
var params = skill_behavior.get_spawn_params()
skill_instance_mgr.spawn_skill("icespear", params.position, params.velocity, params.rotation, params.target)
```

### 技能脚本迁移

**旧脚本**（`extends Area2D`，包含完整逻辑）：
```gdscript
extends Area2D

var target = Vector2.ZERO
var angle = Vector2.ZERO

func _ready():
    angle = global_position.direction_to(target)
    rotation = angle.angle() + deg_to_rad(135)

func _physics_process(delta):
    position += angle * speed * delta
```

**新脚本**（`extends BaseSkill`，只定义行为）：
```gdscript
extends "res://Skills/base_skill.gd"

@export var rotation_offset := 135.0

func _init():
    skill_id = "icespear"

func get_spawn_params() -> Dictionary:
    var target = player.get_random_target()
    var angle = player.position.direction_to(target)
    return {
        "position": player.position,
        "velocity": angle * speed,
        "rotation": angle.angle() + deg_to_rad(rotation_offset),
        "target": target
    }

func update_skill_instance(inst: Dictionary, delta: float) -> Dictionary:
    # 追踪逻辑
    if inst.target != Vector2.ZERO:
        var dir = inst.position.direction_to(inst.target)
        inst.velocity = dir * speed
        inst.rotation = dir.angle() + deg_to_rad(rotation_offset)
    return inst
```

## 性能对比

### 旧架构（节点实例化）
- 100 个技能 = 100 个 Area2D 节点
- 100 次 `_physics_process()` 调用
- 100 个独立的碰撞检测
- 100 次 Draw Call

### 新架构（GPU 实例化）
- 100 个技能 = 1 个 MultiMeshInstance2D
- 1 次 `_physics_process()` 调用（在 Manager 中）
- 100 个碰撞检测（但批量处理）
- 1 次 Draw Call（每种技能类型）

**预期性能提升**：
- CPU 使用率：↓ 70-80%
- 内存占用：↓ 60%
- FPS：↑ 50-100%（在大量技能场景下）

## 注意事项

1. **技能场景文件**：
   - 仍需要 `.tscn` 文件（用于编辑器预览）
   - 必须包含 `Sprite2D` 和 `CollisionShape2D`
   - 脚本只定义行为，不执行逻辑

2. **碰撞层配置**：
   - 技能 HitBox：Layer 3 (武器), Mask 3 (敌人)
   - 敌人 HurtBox：Layer 3 (敌人), Mask 3 (武器)

3. **行为逻辑**：
   - 简单技能（直线）：不需要重写 `update_skill_instance()`
   - 复杂技能（追踪、环绕）：在子类中实现更新逻辑

4. **性能优化**：
   - 同类型技能共享 Shader Material
   - 动画在 GPU 中计算
   - 碰撞体按需创建

## 未来扩展

### 添加新技能

1. **创建技能脚本**：
```gdscript
# Skills/fireball.gd
extends "res://Skills/base_skill.gd"

@export var explosion_radius := 50.0

func _init():
    skill_id = "fireball"

func get_spawn_params() -> Dictionary:
    var angle = player.last_movement
    return {
        "position": player.position,
        "velocity": angle * speed,
        "rotation": angle.angle(),
        "target": Vector2.ZERO
    }

func update_skill_instance(inst: Dictionary, delta: float) -> Dictionary:
    # 抛物线轨迹
    inst.velocity.y += 100 * delta  # 重力
    inst.rotation = inst.velocity.angle()
    return inst
```

2. **创建场景**：`Skills/fireball.tscn`

3. **注册到配置**：
```ini
# config/skill_registry.ini
[fireball]
name=火球术
scene_path=res://Skills/fireball.tscn
description=发射火球
type=projectile
```

4. **在 Player 中添加触发**：
```gdscript
func _on_fireball_timer_timeout():
    var skill_behavior = skill_behaviors["fireball"]
    var params = skill_behavior.get_spawn_params()
    skill_instance_mgr.spawn_skill("fireball", params.position, params.velocity, params.rotation)
```

## 调试

### 启用调试日志

```gdscript
# Utility/game_config.gd
const DEBUG_LOGGING := true
const DEBUG_COLLISION := true
```

### 查看技能实例

```gdscript
# 在 Player 或测试脚本中
print("活跃冰矛数: ", skill_instance_mgr.get_active_skill_count("icespear"))
print("总技能数: ", skill_instance_mgr.get_active_skill_count())
```

### 检查 MultiMesh

```gdscript
var type_data = skill_instance_mgr.skill_types["icespear"]
print("MultiMesh 实例数: ", type_data.multimesh_instance.multimesh.instance_count)
print("实际实例数: ", type_data.instances.size())
```

## 常见问题

### Q: 技能不显示？
A: 检查：
1. `SkillInstanceManager.set_container()` 是否调用
2. MultiMesh 是否添加到场景树
3. 纹理是否正确加载

### Q: 技能不移动？
A: 检查：
1. `get_spawn_params()` 是否返回正确的 velocity
2. `update_skill_instance()` 是否正确更新位置
3. `_physics_process()` 是否被调用

### Q: 碰撞不生效？
A: 检查：
1. 碰撞层/掩码配置（Layer 3, Mask 3）
2. `CollisionShape2D` 是否存在于场景中
3. HitBox 是否添加到场景树

## 性能监控

```gdscript
# 在 Player._physics_process() 中
if GameConfig.SHOW_PERFORMANCE_STATS:
    print("技能实例数: %d" % skill_instance_mgr.get_active_skill_count())
    print("MultiMesh 数: %d" % skill_instance_mgr.skill_types.size())
```
