# 项目结构说明

## 目录组织

```
SurvivorsClone_Test/
├── Enemy/                      # 敌人系统
│   ├── base_enemy.gd          # 敌人基类
│   ├── enemy.gd               # 通用敌人实现
│   ├── enemy_instance_manager.gd  # 敌人 GPU 实例管理器
│   ├── enemy_registry.gd      # 敌人注册系统
│   ├── enemy_*.tscn           # 各类敌人场景
│   └── ...
│
├── Skills/                     # 技能系统
│   ├── base_skill.gd          # 技能基类
│   ├── skill_instance_manager.gd  # 技能 GPU 实例管理器
│   ├── skill_registry.gd      # 技能注册系统
│   ├── skill_manager.gd       # 技能状态管理（等级、弹药）
│   ├── ice_spear.gd           # 冰矛行为逻辑
│   ├── tornado.gd             # 龙卷风行为逻辑
│   ├── javelin.gd             # 标枪行为逻辑
│   ├── *.tscn                 # 技能场景
│   └── ...
│
├── Player/                     # 玩家系统
│   ├── player.gd              # 玩家主脚本
│   ├── player.tscn            # 玩家场景
│   ├── Components/            # 玩家组件
│   │   ├── player_stats.gd    # 属性管理
│   │   ├── upgrade_manager.gd # 升级管理
│   │   └── experience_manager.gd  # 经验管理
│   └── GUI/                   # 玩家 UI
│
├── Utility/                    # 通用工具
│   ├── game_config.gd         # 全局配置（Autoload）
│   ├── base_registry.gd       # 注册系统基类
│   ├── event_bus.gd           # 事件总线
│   ├── config_manager.gd      # 配置管理器
│   ├── upgrade_db.gd          # 升级数据库
│   ├── object_pool.gd         # 对象池
│   └── ...
│
├── config/                     # 配置文件
│   ├── enemy_config.ini       # 敌人属性配置
│   ├── enemy_registry.ini     # 敌人注册配置
│   ├── skill_config.ini       # 技能属性配置
│   ├── skill_registry.ini     # 技能注册配置
│   └── upgrade_config.ini     # 升级配置
│
├── tests/                      # 测试脚本
│   ├── test_inheritance.gd    # 继承架构测试
│   ├── test_skill_gpu.gd      # 技能 GPU 测试
│   └── ...
│
└── docs/                       # 文档
    ├── INHERITANCE_ARCHITECTURE.md  # 继承架构说明
    ├── SKILL_GPU_ARCHITECTURE.md    # 技能 GPU 架构
    ├── GPU_ANIMATION_SYSTEM.md      # GPU 动画系统
    └── PROJECT_STRUCTURE.md         # 本文档
```

## 核心系统

### 1. GPU 实例化系统

**敌人**：
- `Enemy/enemy_instance_manager.gd`：管理所有敌人的渲染、碰撞、AI
- `Enemy/base_enemy.gd`：敌人基类，定义属性
- `Enemy/enemy_registry.gd`：敌人注册，继承 `BaseRegistry`

**技能**：
- `Skills/skill_instance_manager.gd`：管理所有技能的渲染、碰撞
- `Skills/base_skill.gd`：技能基类，定义行为逻辑
- `Skills/skill_registry.gd`：技能注册，继承 `BaseRegistry`

### 2. 注册系统

**基类**：
- `Utility/base_registry.gd`：通用注册系统，提供异步加载

**子类**：
- `Enemy/enemy_registry.gd`：敌人注册
- `Skills/skill_registry.gd`：技能注册

### 3. 配置系统

**全局配置**：
- `Utility/game_config.gd`：所有全局常量（Autoload）

**INI 配置**：
- `config/*.ini`：各系统的配置文件

## 文件命名规范

### 脚本文件
- **基类**：`base_*.gd`（如 `base_enemy.gd`, `base_skill.gd`）
- **管理器**：`*_manager.gd`（如 `skill_manager.gd`, `enemy_instance_manager.gd`）
- **注册系统**：`*_registry.gd`（如 `enemy_registry.gd`, `skill_registry.gd`）
- **实体**：小写下划线（如 `ice_spear.gd`, `enemy_kobold_weak.gd`）

### 场景文件
- **实体场景**：与脚本同名（如 `ice_spear.tscn`, `enemy_kobold_weak.tscn`）
- **UI 场景**：描述性名称（如 `menu.tscn`, `death_panel.tscn`）

### 配置文件
- **格式**：INI 格式（`.ini`）
- **命名**：`*_config.ini` 或 `*_registry.ini`

## Autoload 顺序

在 `project.godot` 中的加载顺序很重要：

```ini
[autoload]
GameConfig="*res://Utility/game_config.gd"        # 1. 全局配置（最先）
EventBus="*res://Utility/event_bus.gd"            # 2. 事件总线
ConfigManager="*res://Utility/config_manager.gd"  # 3. 配置管理
SkillRegistry="*res://Skills/skill_registry.gd"   # 4. 技能注册
EnemyRegistry="*res://Enemy/enemy_registry.gd"    # 5. 敌人注册
ObjectPool="*res://Utility/object_pool.gd"        # 6. 对象池
UpgradeDb="*res://Utility/upgrade_db.tscn"        # 7. 升级数据库
AudioManager="*res://Utility/audio_manager.gd"    # 8. 音频管理
```

**原则**：
1. 配置类最先（`GameConfig`）
2. 注册系统其次（`*Registry`）
3. 管理器最后（依赖注册系统）

## 职责划分

### Player (玩家)
- **触发时机**：决定何时发射技能
- **状态管理**：HP、经验、等级
- **输入处理**：移动、升级选择
- **不负责**：技能具体行为、敌人 AI

### BaseSkill (技能子类)
- **行为定义**：如何移动、如何追踪
- **参数生成**：`get_spawn_params()`
- **行为更新**：`update_skill_instance()`
- **不负责**：渲染、碰撞检测

### SkillInstanceManager (技能管理器)
- **批量渲染**：MultiMesh + Shader
- **碰撞检测**：HitBox 创建和同步
- **生命周期**：超时销毁、穿透计数
- **不负责**：技能具体行为逻辑

### BaseEnemy (敌人基类)
- **属性定义**：HP、速度、伤害
- **配置导出**：供 GPU 系统读取
- **不负责**：AI 逻辑（由 Manager 管理）

### EnemyInstanceManager (敌人管理器)
- **批量渲染**：MultiMesh + Shader
- **AI 逻辑**：追踪玩家、受击反馈
- **碰撞检测**：HurtBox + HitBox
- **不负责**：敌人属性定义

## 数据流

### 技能发射流程

```
1. Player 定时器触发
   └─> _on_ice_spear_timer_timeout()

2. 获取技能行为脚本
   └─> skill_behaviors["icespear"]

3. 调用行为脚本获取生成参数
   └─> skill_behavior.get_spawn_params()
       返回: { position, velocity, rotation, target }

4. 调用 SkillInstanceManager 生成实例
   └─> skill_instance_mgr.spawn_skill(...)

5. SkillInstanceManager 创建：
   - SkillInstance（数据）
   - MultiMesh 实例（渲染）
   - HitBox（碰撞）

6. 每帧更新：
   └─> SkillInstanceManager._update_skill_type()
       └─> skill_behavior.update_skill_instance()
           └─> 更新 position, velocity, rotation
```

### 敌人生成流程

```
1. EnemySpawnerGPU 定时器触发
   └─> spawn_enemy()

2. 调用 EnemyInstanceManager
   └─> enemy_manager.spawn_enemy(type, position)

3. EnemyInstanceManager 创建：
   - EnemyInstance（数据）
   - MultiMesh 实例（渲染）
   - HurtBox + HitBox（碰撞）

4. 每帧更新：
   └─> EnemyInstanceManager._update_enemy_type()
       └─> AI 逻辑（追踪玩家）
       └─> 更新 position, velocity
```

## 碰撞层配置

| 层级 | 名称 | 用途 | Layer | Mask |
|------|------|------|-------|------|
| 1 | World | 世界静态物体 | 1 | - |
| 2 | Player | 玩家 | 1 | 2 |
| 3 | Enemy | 敌人 | 4 | 4 |
| 4 | Weapon | 武器 | 4 | 4 |
| 5 | Loot | 拾取物 | 8 | 1 |

**交互关系**：
- 玩家 HurtBox (Layer 1) ← 敌人 HitBox (Mask 1)
- 敌人 HurtBox (Layer 3) ← 武器 HitBox (Mask 3)
- 拾取物 (Layer 4) ← 玩家 (Mask 4)

## 性能指标

### 编辑器启动
- **优化前**：2-3 分钟
- **优化后**：30-60 秒
- **优化手段**：异步加载 + 禁用调试日志

### 游戏运行
- **1000 敌人 + 100 技能**：
  - FPS: 60（稳定）
  - CPU: ~30%
  - 内存: ~200MB

- **对比旧架构**（节点实例化）：
  - FPS: 15-20
  - CPU: ~80%
  - 内存: ~500MB

## 扩展指南

### 添加新敌人类型

1. 创建 `Enemy/enemy_new_type.gd`：
```gdscript
extends "res://Enemy/base_enemy.gd"
# 设置属性
```

2. 创建 `Enemy/enemy_new_type.tscn`

3. 在 `config/enemy_registry.ini` 注册

### 添加新技能

1. 创建 `Skills/new_skill.gd`：
```gdscript
extends "res://Skills/base_skill.gd"

func _init():
    skill_id = "newskill"

func get_spawn_params() -> Dictionary:
    # 定义生成参数
    pass

func update_skill_instance(inst: Dictionary, delta: float) -> Dictionary:
    # 定义行为逻辑
    return inst
```

2. 创建 `Skills/new_skill.tscn`

3. 在 `config/skill_registry.ini` 注册

4. 在 `Player/player.gd` 添加触发逻辑

## 调试技巧

### 启用调试模式

```gdscript
# Utility/game_config.gd
const DEBUG_LOGGING := true
const DEBUG_COLLISION := true
const SHOW_PERFORMANCE_STATS := true
```

### 查看实例数

```gdscript
# 在控制台
print("敌人数: ", EnemyInstanceManager.get_active_enemy_count())
print("技能数: ", SkillInstanceManager.get_active_skill_count())
```

### 检查碰撞层

```gdscript
# 在编辑器中选中节点，查看 Inspector 面板
# Collision -> Layer 和 Mask
```

## 最佳实践

1. **不要在 `_ready()` 中同步加载**：
   - 使用 `await Registry.ensure_loaded()`
   - 避免阻塞编辑器启动

2. **使用 GameConfig 常量**：
   - 不要硬编码数值
   - 集中管理配置

3. **继承基类**：
   - 敌人继承 `BaseEnemy`
   - 技能继承 `BaseSkill`
   - 注册系统继承 `BaseRegistry`

4. **行为与渲染分离**：
   - 行为逻辑在子类中
   - 渲染逻辑在 Manager 中

5. **配置驱动**：
   - 数值从 INI 文件读取
   - 便于平衡调整
