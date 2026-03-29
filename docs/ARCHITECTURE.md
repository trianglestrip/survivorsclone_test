# 项目架构

## 概述

本项目采用**组件化、配置驱动、继承架构**的设计模式。

## 核心设计原则

### 1. 继承架构
- **基类简单** - 只定义接口和通用方法
- **子类独立** - 每个技能/敌人在自己的文件中实现逻辑
- **易于扩展** - 添加新类型只需继承基类

### 2. 配置驱动
- 所有游戏数据从 `config/` 目录加载
- 无硬编码数值
- 修改平衡无需重新编译

### 3. 组件化
- Player 拆分为独立组件
- 单一职责原则
- 易于测试和维护

### 4. 事件驱动
- EventBus 解耦系统通信
- 避免直接依赖

---

## 目录结构

```
SurvivorsClone_Test/
├── Player/                    # 玩家系统
│   ├── player.gd             # 玩家主类
│   └── Components/           # 玩家组件
│       ├── player_stats.gd   # 属性管理
│       ├── experience_manager.gd
│       ├── upgrade_manager.gd
│       └── attack_manager.gd # 攻击逻辑（新增）
├── Enemy/                     # 敌人系统
│   ├── base_enemy.gd         # 敌人基类
│   ├── enemy.gd              # 通用敌人实现
│   ├── enemy_registry.gd     # 敌人注册
│   └── enemy_instance_manager.gd  # GPU 实例管理
├── Skills/                    # 技能系统
│   ├── base_skill.gd         # 技能基类
│   ├── ice_spear.gd          # 冰矛（独立实现）
│   ├── tornado.gd            # 龙卷风（独立实现）
│   ├── javelin.gd            # 标枪（独立实现）
│   ├── skill_registry.gd     # 技能注册
│   └── skill_instance_manager.gd  # GPU 实例管理
├── Utility/                   # 工具和系统
│   ├── base_registry.gd      # 注册系统基类
│   ├── event_bus.gd          # 事件总线
│   ├── config_manager.gd     # 配置管理
│   ├── object_pool.gd        # 对象池
│   └── Effects/              # 效果系统
├── config/                    # 配置文件
│   ├── skill_registry.ini
│   ├── skill_config.ini
│   ├── enemy_registry.ini
│   ├── enemy_config.ini
│   ├── upgrade_config.ini
│   └── spawn_waves.ini
└── docs/                      # 文档
```

---

## 系统详解

### 技能系统架构

```
BaseSkill (基类)
    ├── get_spawn_params()      # 获取生成参数
    └── update_skill_instance() # 更新实例行为
        ↑
        ├─ IceSpear (ice_spear.gd)
        ├─ Tornado (tornado.gd)
        └─ Javelin (javelin.gd)
```

**职责划分**:
- **BaseSkill** - 定义接口，保持简单
- **子类** - 独立实现技能行为逻辑
- **SkillInstanceManager** - GPU 实例化管理
- **AttackManager** - 计时器和攻击触发

### 敌人系统架构

```
BaseEnemy (基类)
    ├── get_enemy_config()
    ├── special_behavior()
    └── on_death()
        ↑
        └─ Enemy (enemy.gd) - 通用实现
```

**职责划分**:
- **BaseEnemy** - 定义接口
- **Enemy** - 通用实现
- **EnemyInstanceManager** - GPU 实例化管理

### 玩家组件架构

```
Player (player.gd)
    ├── PlayerStats (player_stats.gd)
    ├── ExperienceManager (experience_manager.gd)
    ├── UpgradeManager (upgrade_manager.gd)
    └── AttackManager (attack_manager.gd) ← 新增
```

**职责划分**:
- **Player** - 核心逻辑和协调
- **各组件** - 独立职责，可测试

---

## 数据与逻辑分离

所有游戏数据都在 `config/` 目录：

| 配置文件 | 用途 |
|---------|------|
| `skill_registry.ini` | 技能注册信息 |
| `skill_config.ini` | 技能属性配置 |
| `enemy_registry.ini` | 敌人注册信息 |
| `enemy_config.ini` | 敌人属性配置 |
| `upgrade_config.ini` | 升级和武器配置 |
| `spawn_waves.ini` | 敌人生成波次 |

---

## 性能优化

- **GPU 实例化** - MultiMesh 批量渲染
- **对象池** - 复用频繁创建的对象
- **异步加载** - 不阻塞启动
- **分帧初始化** - 避免卡顿

---

## 添加新内容

### 添加新技能

1. 创建 `Skills/new_skill.gd`，继承 `BaseSkill`
2. 实现 `get_spawn_params()` 和 `update_skill_instance()`
3. 在 `config/skill_registry.ini` 注册
4. 在 `config/skill_config.ini` 配置属性
5. 在 `config/upgrade_config.ini` 添加升级

### 添加新敌人

1. 创建敌人场景，继承 `BaseEnemy`
2. 在 `config/enemy_registry.ini` 注册
3. 在 `config/enemy_config.ini` 配置属性
4. 在 `config/spawn_waves.ini` 配置生成

---

## 核心 Autoload 系统

| 系统 | 路径 | 用途 |
|------|------|------|
| EventBus | `Utility/event_bus.gd` | 事件总线 |
| ConfigManager | `Utility/config_manager.gd` | 配置管理 |
| SkillRegistry | `Skills/skill_registry.gd` | 技能注册 |
| EnemyRegistry | `Enemy/enemy_registry.gd` | 敌人注册 |
| ObjectPool | `Utility/object_pool.gd` | 对象池 |
| UpgradeDb | `Utility/upgrade_db.tscn` | 升级数据库 |
| AudioManager | `Utility/audio_manager.gd` | 音频管理 |
| GameConfig | `Utility/game_config.gd` | 游戏配置 |
