# 注册系统重构文档

## 概述

将技能和敌人的注册从硬编码改为配置驱动，实现完全数据分离。

## 架构变更

### 之前（硬编码）

```gdscript
# skill_registry.gd
func _register_default_skills():
    register_skill("IceSpear", preload("res://Player/Attack/ice_spear.tscn"), {
        "name": "冰矛",
        "description": "向随机敌人投掷冰矛",
        "type": "projectile"
    })
    # ... 更多硬编码
```

**问题**：
- 技能和敌人数据硬编码在代码中
- 扩展新内容需要修改代码
- 违背配置驱动原则
- 不便于策划调整

### 之后（配置驱动）

```gdscript
# skill_registry.gd
func _load_skills_from_config():
    var file = FileAccess.open("res://config/skill_config.ini", FileAccess.READ)
    # 解析 INI 配置
    # 动态注册技能
    for skill_id in skill_configs:
        var scene = load(config["scene_path"])
        register_skill(skill_id, scene, skill_data)
```

**优势**：
- 所有技能和敌人数据在配置文件中
- 添加新内容只需修改 INI 文件
- 完全数据驱动
- 便于扩展和维护

## 配置文件

### 1. 技能配置 (`config/skill_config.ini`)

```ini
[IceSpear]
name=冰矛
description=向随机敌人投掷冰矛
type=projectile
scene_path=res://Player/Attack/ice_spear.tscn

[Tornado]
name=龙卷风
description=生成龙卷风并在玩家方向上随机移动
type=projectile
scene_path=res://Player/Attack/tornado.tscn

[Javelin]
name=标枪
description=魔法标枪会沿直线跟随你攻击敌人
type=orbital
scene_path=res://Player/Attack/javelin.tscn
```

**字段说明**：
- `name`: 技能显示名称
- `description`: 技能描述
- `type`: 技能类型（projectile/orbital）
- `scene_path`: 技能场景路径

### 2. 敌人配置 (`config/enemy_config.ini`)

```ini
[enemy_kobold_weak]
name=弱小狗头人
tier=1
is_boss=false
scene_path=res://Enemy/enemy_kobold_weak.tscn

[enemy_kobold_strong]
name=强壮狗头人
tier=2
is_boss=false
scene_path=res://Enemy/enemy_kobold_strong.tscn

[enemy_cyclops]
name=独眼巨人
tier=3
is_boss=false
scene_path=res://Enemy/enemy_cyclops.tscn

[enemy_juggernaut]
name=主宰者
tier=4
is_boss=true
scene_path=res://Enemy/enemy_juggernaut.tscn

[enemy_super]
name=超级敌人
tier=5
is_boss=true
scene_path=res://Enemy/enemy_super.tscn
```

**字段说明**：
- `name`: 敌人显示名称
- `tier`: 敌人等级（1-5）
- `is_boss`: 是否为 Boss
- `scene_path`: 敌人场景路径

## 实现细节

### SkillRegistry 加载流程

1. **打开配置文件**：使用 `FileAccess.open()` 读取 `skill_config.ini`
2. **解析 INI 格式**：逐行解析，提取节名和键值对
3. **类型转换**：自动处理字符串/整数/布尔值
4. **动态加载场景**：使用 `load()` 加载 `scene_path` 指定的场景
5. **注册技能**：调用 `register_skill()` 完成注册
6. **验证**：检查必需字段，失败时退出游戏

### EnemyRegistry 加载流程

与 `SkillRegistry` 类似，但额外处理：
- `tier` 字段（整数）
- `is_boss` 字段（布尔值）
- Boss 标记显示

### 错误处理

- **配置文件不存在**：`push_error()` 并 `get_tree().quit(1)`
- **配置为空**：退出游戏
- **缺少必需字段**：跳过该项并记录错误
- **场景加载失败**：跳过该项并记录错误

## 扩展指南

### 添加新技能

1. 创建技能场景（如 `res://Player/Attack/new_skill.tscn`）
2. 在 `config/skill_config.ini` 中添加：

```ini
[NewSkill]
name=新技能
description=技能描述
type=projectile
scene_path=res://Player/Attack/new_skill.tscn
```

3. 重启游戏，技能自动注册

### 添加新敌人

1. 创建敌人场景（如 `res://Enemy/enemy_new.tscn`）
2. 在 `config/enemy_config.ini` 中添加：

```ini
[enemy_new]
name=新敌人
tier=3
is_boss=false
scene_path=res://Enemy/enemy_new.tscn
```

3. 重启游戏，敌人自动注册

## 测试

运行注册系统测试：

```bash
F:\project\godot\Godot_v4.6.1-stable_win64_console.exe --headless --script tests/test_registry_loading.gd
```

测试覆盖：
- 技能配置文件解析
- 敌人配置文件解析
- 必需字段验证
- 场景路径有效性

## 优势总结

1. **完全数据驱动**：技能和敌人完全由配置文件定义
2. **易于扩展**：添加新内容无需修改代码
3. **策划友好**：配置文件格式简单，易于编辑
4. **启动验证**：游戏启动时验证配置完整性
5. **统一架构**：与 `upgrade_config.ini` 保持一致的设计理念
