# 文件组织规范

## 📁 目录结构

### 根目录
```
SurvivorsClone_Test/
├── README.md              # 项目主文档
├── project.godot          # Godot项目文件
├── scripts/               # 脚本和工具
├── docs/                  # 文档
├── tests/                 # 测试场景
├── Player/                # 玩家系统
├── Skills/                # 技能系统
├── Enemy/                 # 敌人系统
├── UI/                    # 用户界面
├── Utility/               # 工具类
├── config/                # 配置文件
├── Assets/                # 资源文件
└── .trae/                 # 内部文档
```

## 📂 文件夹说明

### scripts/ - 脚本和工具
存放所有批处理脚本和Python工具：

**批处理脚本 (.bat)**：
- `run_game.bat` - 启动游戏
- `quick_test.bat` - 交互式测试场景
- `view_skill_effects.bat` - 技能特效查看器
- `test_upgrade_cards.bat` - 升级卡牌测试
- `run_all_tests.bat` - 运行所有测试
- `run_tests.bat` - 运行基础测试
- `run_stage1_tests.bat` - 运行阶段1测试
- `clear_cache.bat` - 清理缓存

**Python脚本 (.py)**：
- `generate_placeholders.py` - 生成占位符纹理
- `generate_skill_assets.py` - 生成技能动画帧
- `generate_weapon_assets.py` - 生成武器资源

### docs/ - 文档
存放所有项目文档：

**核心文档**：
- `TODO.md` - 待办事项清单
- `ARCHITECTURE.md` - 架构设计文档
- `CONFIG_SYSTEM.md` - 配置系统说明

**指南文档**：
- `SKILL_EFFECTS_GUIDE.md` - 技能特效优化指南
- `UPGRADE_SYSTEM_GUIDE.md` - 升级系统设计指南
- `QUICK_TEST.md` - 快速测试指南
- `QUICK_REFERENCE.md` - 快速参考

**历史文档**：
- `WARMSNOW_UPGRADE_README.md` - 暖雪升级系统说明

### tests/ - 测试场景
存放所有测试相关文件：

**测试脚本 (.gd)**：
- `test_*.gd` - 各种自动化测试
- `interactive_test_world.gd` - 交互式测试场景
- `visual_skill_test.gd` - 可视化技能测试

**测试场景 (.tscn)**：
- `test_*.tscn` - 测试场景文件
- `interactive_test_world.tscn` - 交互式测试场景
- `visual_skill_test.tscn` - 技能展示场景

### config/ - 配置文件
JSON配置文件：
- `sect_config.json` - 宗派和技能配置
- `weapon_config.json` - 武器配置
- `relic_config.json` - 圣物配置
- `upgrade_config.json` - 基础升级配置
- `upgrade_config_extended.json` - 扩展升级配置
- `enemy_config.json` - 敌人配置
- `level_config.json` - 关卡配置

### Assets/ - 资源文件
游戏资源：
- `Assets/Skills/` - 技能动画帧（96个PNG）
- `Assets/Weapons/` - 武器精灵和图标（12个PNG）
- `Assets/UI/` - UI资源
- `Assets/Audio/` - 音频资源

## 📝 文件命名规范

### 脚本文件
- **批处理**: `动词_名词.bat` (如 `run_game.bat`)
- **Python**: `动词_名词.py` (如 `generate_skill_assets.py`)
- **GDScript**: `名词.gd` 或 `名词_管理器.gd` (如 `player.gd`, `sect_manager.gd`)

### 文档文件
- **指南**: `主题_GUIDE.md` (如 `SKILL_EFFECTS_GUIDE.md`)
- **说明**: `主题_README.md` (如 `WARMSNOW_UPGRADE_README.md`)
- **参考**: `主题_REFERENCE.md` (如 `QUICK_REFERENCE.md`)

### 测试文件
- **测试脚本**: `test_功能名.gd` (如 `test_upgrade_cards.gd`)
- **测试场景**: `test_功能名.tscn` (如 `test_upgrade_cards.tscn`)

### 配置文件
- **配置**: `系统名_config.json` (如 `sect_config.json`)
- **扩展配置**: `系统名_config_extended.json`

## 🗑️ 清理规则

### 应该删除的文件
- 临时测试文件（`temp_*.gd`）
- 重复的文档（保留最新版本）
- 未使用的占位脚本（`verify_*.gd`）
- 旧的测试脚本（已被新测试替代）

### 应该保留的文件
- 所有正在使用的脚本和工具
- 核心文档和指南
- 所有测试文件（用于回归测试）
- 配置文件（即使暂未使用）

## 📋 文件维护

### 定期检查
- 每周检查根目录是否有新的杂乱文件
- 每月检查docs/是否有过时文档
- 每季度检查tests/是否有失效测试

### 新文件添加规则
1. **批处理/Python脚本** → `scripts/`
2. **文档** → `docs/`
3. **测试** → `tests/`
4. **配置** → `config/`
5. **资源** → `Assets/`

### 文档更新规则
- 修改功能时，同步更新相关文档
- 添加新功能时，更新TODO.md
- 完成任务时，在TODO.md中标记完成
- 重大变更时，更新README.md

## 🔄 Git提交规范

### 提交信息格式
```
类型: 简短描述

详细说明（可选）
```

**类型**：
- `feat`: 新功能
- `fix`: 修复bug
- `docs`: 文档更新
- `refactor`: 代码重构
- `test`: 测试相关
- `chore`: 构建/工具相关

**示例**：
```
feat: Add card-based upgrade system

- Create UpgradeCardUI component
- Add 17 upgrade configurations
- Implement 3-choice selection
```

## 📊 当前状态

### 已整理
- ✅ 批处理脚本 → `scripts/`
- ✅ Python脚本 → `scripts/`
- ✅ 文档 → `docs/`
- ✅ 删除无用文件 (`verify_upgrade.gd`)

### 待整理
- ⏳ 检查并清理重复文档
- ⏳ 整理.trae/documents/内容
- ⏳ 检查tests/中的过时测试

---

*最后更新: 2026-03-29*
