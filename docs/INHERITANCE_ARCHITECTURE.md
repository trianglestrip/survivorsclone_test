# 继承架构设计

## 概述

项目采用基于继承的架构，提供可扩展的注册系统和实体基类。

## 架构图

```
BaseRegistry (基础注册系统)
├── EnemyRegistry (敌人注册)
├── SkillRegistry (技能注册)
└── [未来可扩展] ItemRegistry, BuffRegistry 等

BaseEnemy (敌人基类)
├── enemy.gd (通用敌人)
└── [未来可扩展] boss_enemy.gd, special_enemy.gd 等

BaseSkill (技能基类)
├── ice_spear.gd (冰矛)
├── tornado.gd (龙卷风)
├── javelin.gd (标枪)
└── [未来可扩展] 其他技能
```

## 1. BaseRegistry - 通用注册系统

### 功能

- **异步加载**：不阻塞编辑器启动
- **统一配置解析**：自动解析 INI 文件
- **线程安全**：状态管理和信号通知
- **可扩展验证**：子类可自定义验证逻辑

### 核心 API

```gdscript
# 注册项目
func register_item(item_id: String, item_scene: PackedScene, item_data: Dictionary)

# 获取场景
func get_item_scene(item_id: String) -> PackedScene

# 获取数据
func get_item_data(item_id: String) -> Dictionary

# 检查是否已注册
func has_item(item_id: String) -> bool

# 获取所有 ID
func get_all_item_ids() -> Array

# 实例化项目
func instantiate_item(item_id: String) -> Node

# 确保已加载（外部调用）
func ensure_loaded()
```

### 子类需要重写的方法

```gdscript
# 获取配置文件路径
func _get_config_path() -> String

# 获取注册类型名称（用于日志）
func _get_registry_type_name() -> String

# 解析配置值（可选）
func _parse_config_value(key: String, value: String) -> Variant

# 创建数据字典（可选）
func _create_item_data(item_id: String, config: Dictionary) -> Dictionary

# 验证配置（可选）
func _validate_config(item_id: String, config: Dictionary) -> bool
```

### 使用示例

#### 创建新的注册系统

```gdscript
extends "res://Utility/base_registry.gd"

func _get_config_path() -> String:
    return "res://config/buff_registry.ini"

func _get_registry_type_name() -> String:
    return "Buff"

func _create_item_data(item_id: String, config: Dictionary) -> Dictionary:
    return {
        "name": config.get("name", item_id),
        "duration": config.get("duration", 5.0),
        "stack_type": config.get("stack_type", "replace")
    }
```

#### 注册到 Autoload

在 `project.godot` 中添加：
```ini
[autoload]
BuffRegistry="*res://Utility/buff_registry.gd"
```

## 2. EnemyRegistry - 敌人注册系统

### 实现

```gdscript
extends "res://Utility/base_registry.gd"

func _get_config_path() -> String:
    return GameConfig.PATH_ENEMY_REGISTRY

func _get_registry_type_name() -> String:
    return "敌人"

func _parse_config_value(key: String, value: String) -> Variant:
    match key:
        "tier":
            return int(value) if value.is_valid_int() else 1
        "is_boss":
            return value.to_lower() == "true"
        _:
            return super._parse_config_value(key, value)

func _create_item_data(item_id: String, config: Dictionary) -> Dictionary:
    return {
        "name": config.get("name", item_id),
        "tier": config.get("tier", 1),
        "is_boss": config.get("is_boss", false)
    }
```

### 使用方式

```gdscript
# 等待加载完成
await EnemyRegistry.ensure_loaded()

# 获取敌人场景
var scene = EnemyRegistry.get_item_scene("enemy_kobold_weak")

# 获取所有敌人 ID
var all_enemies = EnemyRegistry.get_all_item_ids()
```

## 3. SkillRegistry - 技能注册系统

### 实现

```gdscript
extends "res://Utility/base_registry.gd"

func _get_config_path() -> String:
    return GameConfig.PATH_SKILL_REGISTRY

func _get_registry_type_name() -> String:
    return "技能"

func _create_item_data(item_id: String, config: Dictionary) -> Dictionary:
    return {
        "name": config.get("name", item_id),
        "description": config.get("description", ""),
        "type": config.get("type", "projectile")
    }
```

## 4. BaseEnemy - 敌人基类

### 功能

- **统一属性定义**：所有敌人共享的属性
- **配置导出**：供 GPU 系统读取
- **可扩展行为**：子类可重写特殊行为

### 核心属性

```gdscript
@export_group("基础属性")
@export var movement_speed := 20.0
@export var hp := 10
@export var knockback_recovery := 3.5
@export var experience := 1
@export var enemy_damage := 1

@export_group("视觉效果")
@export var sprite_scale := Vector2(0.75, 0.75)
@export var animation_speed := 1.0
```

### 使用方式

```gdscript
# enemy_kobold_weak.gd
extends "res://Enemy/base_enemy.gd"

# 重写默认值
func _init():
    movement_speed = 20.0
    hp = 10
    enemy_damage = 1

# 可选：添加特殊行为
func special_behavior(delta: float):
    # Boss 技能等
    pass
```

## 5. BaseSkill - 技能基类

### 功能

- **统一属性定义**：伤害、击退、速度等
- **配置加载**：从 `skill_config.ini` 读取
- **生命周期管理**：自动销毁、击中计数
- **玩家修正器**：应用玩家的全局属性加成

### 核心属性

```gdscript
var level: int = 1
var hp: int = 1
var speed: float = 100.0
var damage: int = 5
var knockback_amount: int = 100
var attack_size: float = 1.0
```

### 使用方式

```gdscript
# new_skill.gd
extends "res://Utility/base_skill.gd"

func _init():
    config_section = "NewSkill"
    skill_name = "NewSkill"

func on_skill_ready():
    # 初始化逻辑
    pass

func _physics_process(delta):
    # 移动逻辑
    position += angle * speed * delta
```

## 配置文件格式

### enemy_registry.ini

```ini
[enemy_kobold_weak]
name=弱小狗头人
scene_path=res://Enemy/enemy_kobold_weak.tscn
tier=1
is_boss=false

[enemy_boss_dragon]
name=龙王
scene_path=res://Enemy/boss_dragon.tscn
tier=5
is_boss=true
```

### skill_registry.ini

```ini
[icespear]
name=冰矛
scene_path=res://Player/Attack/ice_spear.tscn
description=发射追踪冰矛
type=projectile

[tornado]
name=龙卷风
scene_path=res://Player/Attack/tornado.tscn
description=召唤龙卷风
type=area
```

## 优势

### 1. 代码复用
- 所有注册系统共享异步加载逻辑
- 所有敌人共享属性定义
- 所有技能共享配置加载

### 2. 易于扩展
- 新增敌人类型：创建 `.tscn` + 继承 `BaseEnemy`
- 新增技能：创建 `.tscn` + 继承 `BaseSkill`
- 新增注册系统：继承 `BaseRegistry` + 重写 3 个方法

### 3. 统一管理
- 所有配置路径在 `GameConfig` 中定义
- 所有调试开关集中控制
- 所有碰撞层统一枚举

### 4. 性能优化
- 异步加载不阻塞启动
- 延迟初始化（首次使用时加载）
- 可配置的日志级别

## 扩展示例

### 添加新的敌人类型

1. **创建敌人脚本**：
```gdscript
# Enemy/boss_dragon.gd
extends "res://Enemy/base_enemy.gd"

func _init():
    movement_speed = 50.0
    hp = 5000
    enemy_damage = 50
    experience = 1000

func special_behavior(delta: float):
    # Boss 特殊技能：喷火
    if randf() < 0.01:
        spawn_fireball()
```

2. **创建场景**：`Enemy/boss_dragon.tscn`

3. **注册到配置**：在 `enemy_registry.ini` 添加

### 添加新的技能

1. **创建技能脚本**：
```gdscript
# Player/Attack/lightning.gd
extends "res://Utility/base_skill.gd"

func _init():
    config_section = "Lightning"
    skill_name = "Lightning"

func on_skill_ready():
    # 闪电链效果
    chain_to_nearby_enemies()
```

2. **创建场景**：`Player/Attack/lightning.tscn`

3. **注册到配置**：在 `skill_registry.ini` 添加

## 注意事项

1. **GPU 模式下**：
   - `BaseEnemy` 的逻辑不会执行
   - 仅用于场景定义和属性导出
   - 实际逻辑在 `enemy_instance_manager.gd`

2. **配置文件**：
   - 必须包含 `scene_path` 字段
   - 其他字段可选，有默认值

3. **异步加载**：
   - 首次使用时调用 `ensure_loaded()`
   - 避免在 Autoload `_ready()` 中同步加载

## 性能影响

- **编辑器启动**：从 2-3 分钟 -> 30-60 秒
- **游戏启动**：首次使用时加载，约 100-200ms
- **内存占用**：按需加载，减少初始内存
