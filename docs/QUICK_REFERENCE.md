# 快速参考指南

## Godot 可执行文件

```powershell
# Godot 编辑器
F:\project\godot\Godot_v4.6.1-stable_win64.exe

# Godot 控制台（用于测试）
F:\project\godot\Godot_v4.6.1-stable_win64_console.exe
```

---

## 常用命令

### 运行游戏

```powershell
# 方法 1：使用编辑器
F:\project\godot\Godot_v4.6.1-stable_win64.exe --path .

# 方法 2：直接运行场景
F:\project\godot\Godot_v4.6.1-stable_win64_console.exe --path . World/world.tscn
```

### 运行测试

```powershell
# 配置加载测试
F:\project\godot\Godot_v4.6.1-stable_win64_console.exe --headless --path . --script tests/test_config_loading.gd

# 完整测试套件
F:\project\godot\Godot_v4.6.1-stable_win64_console.exe --headless --path . --script tests/test_complete.gd

# 升级池测试
F:\project\godot\Godot_v4.6.1-stable_win64_console.exe --headless --path . --script tests/test_upgrade_count.gd
```

---

## 配置文件

### 升级配置

**文件**: `config/upgrade_config.ini`

```ini
[upgrade_id]
displayname=显示名称
details=详细描述
level=等级：X
prerequisite=前置条件1,前置条件2
type=weapon/upgrade/item
icon=res://path/to/icon.png

# 武器特有字段
spell=SkillClassName
set_level=1
add_baseammo=1

# 属性升级字段
add_armor=1
add_movement_speed=20.0
add_spell_size=0.10
add_spell_cooldown=0.05
add_additional_attacks=1

# 道具字段
heal=20
```

### 波次配置

**文件**: `config/spawn_waves.ini`

```ini
[wave_1]
time=0
enemy_type=kobold_weak
count=5
interval=2.0
```

---

## 项目结构

```
SurvivorsClone_Test/
├── Player/
│   ├── player.gd                    # 玩家主脚本（组件化）
│   ├── Components/                  # 玩家组件
│   │   ├── player_stats.gd         # 属性管理
│   │   ├── skill_manager.gd        # 技能管理
│   │   ├── experience_manager.gd   # 经验系统
│   │   └── upgrade_manager.gd      # 升级管理
│   └── Attack/                      # 技能脚本
│       ├── ice_spear.gd
│       ├── tornado.gd
│       └── javelin.gd
├── Enemy/                           # 敌人
├── Utility/                         # 工具类
│   ├── event_bus.gd                # 事件总线
│   ├── config_manager.gd           # 配置管理器
│   ├── skill_registry.gd           # 技能注册
│   ├── enemy_registry.gd           # 敌人注册
│   ├── object_pool.gd              # 对象池
│   ├── upgrade_db.gd               # 升级数据库 ⭐
│   ├── base_skill.gd               # 技能基类
│   └── Effects/                    # 效果系统
│       ├── base_effect.gd
│       ├── stat_modifier_effect.gd
│       ├── skill_unlock_effect.gd
│       ├── heal_effect.gd
│       └── skill_modifier_effect.gd
├── config/                          # 配置文件 ⭐
│   ├── upgrade_config.ini          # 升级配置
│   └── spawn_waves.ini             # 波次配置
└── tests/                           # 测试脚本
    ├── test_config_loading.gd      # 配置加载测试 ⭐
    ├── test_complete.gd            # 完整测试
    └── test_upgrade_count.gd       # 升级池测试
```

---

## 核心系统

### Autoload 单例

| 名称 | 路径 | 用途 |
|------|------|------|
| EventBus | Utility/event_bus.gd | 事件总线 |
| ConfigManager | Utility/config_manager.gd | 配置管理 |
| SkillRegistry | Utility/skill_registry.gd | 技能注册 |
| EnemyRegistry | Utility/enemy_registry.gd | 敌人注册 |
| ObjectPool | Utility/object_pool.gd | 对象池 |
| UpgradeDb | Utility/upgrade_db.gd | 升级数据库 ⭐ |

### 玩家组件

| 组件 | 职责 |
|------|------|
| PlayerStats | HP、护甲、移动速度、法术属性 |
| SkillManager | 技能等级、弹药、攻击速度 |
| ExperienceManager | 经验值、等级、升级触发 |
| UpgradeManager | 升级选项生成、效果应用 |

---

## 调试技巧

### 查看配置加载

游戏启动时会显示：

```
=== 加载升级配置 ===
配置文件: res://config/upgrade_config.ini
✓ 成功解析 31 个升级配置

=== 升级配置验证 ===
总升级数: 31
  武器: 12
  属性升级: 18
  道具: 1
  可选升级数: 30
  ✓ 升级池丰富（支持 30+ 级）
  ✓ 配置验证通过
```

### 常见问题

**Q: 游戏启动后立即退出？**  
A: 检查控制台输出，可能是配置文件加载失败。

**Q: 武器不射出？**  
A: 检查 `upgrade_config.ini` 中武器的 `spell` 和 `set_level` 字段。

**Q: 升级面板为空？**  
A: 检查升级池大小，确保有足够的升级选项。

**Q: 游戏崩溃？**  
A: 运行 `test_config_loading.gd` 验证配置完整性。

---

## Git 工作流

```powershell
# 查看状态
git status

# 查看改动
git diff

# 提交改动
git add .
git commit -m "描述改动"

# 推送到远程
git push
```

---

## 文档索引

| 文档 | 用途 |
|------|------|
| `README.md` | 项目概述 |
| `ARCHITECTURE.md` | 架构设计 |
| `CONFIG_SYSTEM.md` | 配置系统详解 ⭐ |
| `CONFIG_REFACTORING_SUMMARY.md` | 配置重构总结 ⭐ |
| `REFACTORING_PLAN.md` | 重构计划 |
| `TASKS.md` | 任务清单 |
| `BUGFIX_SUMMARY.md` | Bug 修复记录 |
| `STATUS.md` | 当前状态 |
| `FINAL_STATUS.md` | 最终状态报告 |
| `TESTING_GUIDE.md` | 测试指南 |
| `QUICK_REFERENCE.md` | 快速参考（本文档） |

---

**最后更新**: 2026-03-28  
**项目状态**: ✅ 完全可运行  
**配置系统**: ✅ 完全数据分离
