# SurvivorsClone_Test

这是一个基于 Godot 的生存类克隆游戏项目，采用组件化、配置驱动的架构设计。

## 项目简介

- 使用 Godot 4.6 引擎开发
- 采用组件化架构，易于扩展和维护
- 配置驱动的游戏设计，支持快速调整平衡
- 包含玩家、敌人、升级系统和完整的 UI
- 全中文界面和文本

## 运行方式

### 使用 Godot 编辑器
1. 使用 Godot 打开本项目目录 `f:\project\SurvivorsClone_Test`
2. 选择 `project.godot` 项目文件
3. 运行场景或直接启动主场景

### 使用命令行
```powershell
# 运行游戏
F:\project\godot\Godot_v4.6.1-stable_win64.exe --path .

# 运行测试
F:\project\godot\Godot_v4.6.1-stable_win64_console.exe --headless --path . --script tests/test_config_loading.gd
```

## 架构特性

### 组件化设计
- **PlayerStats**: 玩家属性管理
- **SkillManager**: 技能管理
- **ExperienceManager**: 经验值系统
- **UpgradeManager**: 升级系统

### 核心系统
- **EventBus**: 事件总线，解耦系统通信
- **ConfigManager**: 统一配置管理
- **SkillRegistry**: 技能注册系统
- **ObjectPool**: 对象池优化性能
- **BaseSkill**: 技能基类，统一技能行为
- **AudioManager**: 音频管理器，控制声音开关（默认关闭）

### 配置驱动（完全数据分离）
- `config/upgrade_config.ini` - 升级和武器配置（31 个升级）
- `config/spawn_waves.ini` - 敌人波次配置
- **无硬编码默认值** - 所有数据从配置文件加载
- **启动时验证** - 确保配置完整性
- **失败即退出** - 防止不完整配置进入游戏

详细配置系统说明请查看 [CONFIG_SYSTEM.md](CONFIG_SYSTEM.md)  
详细架构说明请查看 [ARCHITECTURE.md](ARCHITECTURE.md)  
音频系统说明请查看 [AUDIO_SYSTEM.md](AUDIO_SYSTEM.md)

## 提交与编码设置

- 添加了 `.gitattributes`，强制文本文件使用 UTF-8 编码并统一换行格式
- 添加了 `.gitignore`，忽略 Godot 编辑器缓存和临时文件

## 重构进度

### ✅ 已完成（100%）

#### 阶段 1: 基础架构组件 ✅
- [x] EventBus 事件总线系统
- [x] ConfigManager 配置管理器
- [x] BaseSkill 技能基类
- [x] 效果系统基类（BaseEffect 及 4 个子类）

#### 阶段 2: 技能系统重构 ✅
- [x] SkillRegistry 技能注册系统
- [x] IceSpear 继承 BaseSkill
- [x] Tornado 继承 BaseSkill
- [x] Javelin 继承 BaseSkill

#### 阶段 3: 玩家组件化 ✅
- [x] PlayerStats 组件
- [x] SkillManager 组件
- [x] ExperienceManager 组件
- [x] UpgradeManager 组件

#### 阶段 4: 升级系统重构 ✅
- [x] UpgradeDbEnhanced 支持效果解析
- [x] UpgradeManagerV2 使用效果系统
- [x] 效果驱动的升级应用

#### 阶段 5: 敌人系统优化 ✅
- [x] EnemyRegistry 敌人注册系统
- [x] EnemySpawnerEnhanced 增强生成器
- [x] spawn_waves.ini 波次配置
- [x] Boss 事件支持

#### 阶段 6: 性能优化 ✅
- [x] ObjectPool 对象池系统
- [x] Explosion 支持对象池
- [x] ExperienceGem 支持对象池

#### 阶段 7: 集成和测试 ✅
- [x] player.gd 已集成组件化架构
- [x] 完整测试通过
- [x] 所有阶段验证通过

### 🎉 重构完成

所有 7 个阶段已完成，项目已成功重构为组件化、配置驱动的架构！

## 测试

### 运行验证测试
```bash
F:\project\godot\Godot_v4.6.1-stable_win64_console.exe --headless --path . --script tests/validate_refactoring.gd
```

### 测试覆盖
- 基础架构组件测试
- 技能系统重构验证
- 玩家组件验证

## 扩展指南

### 添加新技能
1. 创建继承 `BaseSkill` 的脚本
2. 在 `SkillRegistry` 中注册
3. 在 `skill_config.ini` 中添加配置
4. 在 `upgrade_config.ini` 中添加解锁升级

### 添加新敌人
1. 创建继承 `enemy.gd` 的场景
2. 在 `enemy_config.ini` 中添加配置
3. 在生成器中配置生成规则

详细说明请参考 [ARCHITECTURE.md](ARCHITECTURE.md)

## 技术栈

- **引擎**: Godot 4.6.1
- **语言**: GDScript
- **架构模式**: 组件模式、事件驱动、对象池

## 备注

### 编码问题
如果在不同操作系统上打开项目时出现编码或换行问题，请确保：
- Git 的 `core.autocrlf` 设置正确
- 已启用 `.gitattributes`
- 配置文件使用 UTF-8 编码

### 重构完成
项目已完成架构重构：
- `player.gd` - 已集成组件化架构
- `player_backup.gd` / `player_original.gd` - 原始版本备份

重构详情请查看：
- [REFACTORING_PLAN.md](REFACTORING_PLAN.md) - 重构计划
- [TASKS.md](TASKS.md) - 任务清单
- [FINAL_STATUS.md](FINAL_STATUS.md) - 最终状态报告
- [BUGFIX_SUMMARY.md](BUGFIX_SUMMARY.md) - Bug 修复记录
