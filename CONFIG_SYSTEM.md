# 配置系统说明

## 概述

本项目采用**完全配置驱动**的设计理念，所有游戏数据（升级、武器、敌人、波次等）都从外部配置文件加载，**不使用硬编码的默认值**。

## 设计原则

### 1. 数据与代码分离
- **所有游戏数据必须在配置文件中定义**
- 代码只负责加载、验证和应用配置
- 不在代码中硬编码任何游戏内容数据

### 2. 启动时验证
- 游戏启动时立即加载并验证所有配置
- 如果配置缺失或格式错误，游戏会报错并退出
- 确保配置完整性，避免运行时错误

### 3. 明确的错误报告
- 配置加载失败时提供清晰的错误信息
- 指出具体的问题（缺失字段、无效类型等）
- 帮助开发者快速定位和修复问题

## 配置文件

### upgrade_config.ini
**路径**: `config/upgrade_config.ini`  
**格式**: INI  
**用途**: 定义所有升级、武器和道具

#### 结构示例

```ini
[icespear1]
displayname=冰矛
details=向随机敌人投掷冰矛
level=等级：1
prerequisite=
type=weapon
icon=res://Textures/Items/Weapons/ice_spear.png
spell=IceSpear
set_level=1
add_baseammo=1

[armor1]
displayname=护甲
details=减少1点伤害
level=等级：1
prerequisite=
type=upgrade
icon=res://Textures/Items/Upgrades/helmet_1.png
add_armor=1

[food]
displayname=食物
details=恢复20点生命值
level=无
prerequisite=
type=item
icon=res://Textures/Items/Upgrades/chunk.png
heal=20
```

#### 必需字段
所有升级必须包含：
- `displayname` - 显示名称
- `details` - 详细描述
- `level` - 等级文本
- `type` - 类型（weapon/upgrade/item）
- `icon` - 图标路径
- `prerequisite` - 前置条件（逗号分隔，可为空）

#### 武器特有字段
- `spell` - 技能类名（必需）
- `set_level` - 设置技能等级
- `add_baseammo` - 增加弹药数
- `set_ammo` - 设置弹药数
- `set_tornado_attackspeed` - 设置龙卷风攻击速度

#### 属性升级字段
- `add_armor` - 增加护甲
- `add_movement_speed` - 增加移动速度
- `add_spell_size` - 增加法术大小
- `add_spell_cooldown` - 减少法术冷却
- `add_additional_attacks` - 增加额外攻击次数

#### 道具字段
- `heal` - 恢复生命值

### spawn_waves.ini
**路径**: `config/spawn_waves.ini`  
**格式**: INI  
**用途**: 定义敌人波次和刷新规则

## 实现细节

### UpgradeDb (Autoload)
**路径**: `Utility/upgrade_db.gd`

#### 加载流程

1. **文件读取**: 使用 `FileAccess.open()` 直接读取 INI 文件
   - 避免 `ConfigFile` 在某些环境下的编码问题
   - 支持 UTF-8 编码（带或不带 BOM）

2. **手动解析**: 逐行解析 INI 格式
   - 识别节标题 `[section]`
   - 解析键值对 `key=value`
   - 自动类型转换（int、float、string）
   - 处理前置条件数组

3. **数据验证**: `_validate_upgrades()` 检查
   - 配置数量（不能为空）
   - 必需字段完整性
   - 武器必须有 `spell` 字段
   - 升级链完整性（前置条件存在）
   - 升级池大小（建议 20-30+ 个）

4. **错误处理**:
   - 配置文件不存在 → 游戏退出
   - 解析失败 → 游戏退出
   - 验证失败 → 游戏退出
   - 提供详细的错误信息

#### 关键代码

```gdscript
func _ready():
    _load_upgrade_config()
    _validate_upgrades()

func _load_upgrade_config():
    var file = FileAccess.open("res://config/upgrade_config.ini", FileAccess.READ)
    
    if file == null:
        push_error("❌ 无法打开配置文件")
        get_tree().quit(1)
        return
    
    # 手动解析 INI...
    # 自动类型转换...
    # 填充 UPGRADES 字典...
```

### 配置验证输出示例

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

## 优势

### 1. 真正的数据驱动
- 策划可以直接编辑 INI 文件，无需修改代码
- 支持热更新（重启游戏即可应用配置更改）
- 便于平衡性调整和内容扩展

### 2. 早期错误检测
- 启动时验证配置，避免运行时崩溃
- 明确的错误信息，快速定位问题
- 防止不完整的配置进入游戏

### 3. 可维护性
- 配置文件易于阅读和编辑
- 版本控制友好（文本格式）
- 便于团队协作

### 4. 可扩展性
- 添加新升级只需编辑 INI 文件
- 支持任意数量的升级和等级
- 灵活的前置条件系统

## 测试

运行配置系统测试：

```powershell
F:\project\godot\Godot_v4.6.1-stable_win64_console.exe --headless --path . --script tests/test_config_loading.gd
```

测试内容：
- UpgradeDb Autoload 是否加载
- 配置数据是否成功解析
- 初始武器配置是否完整
- 属性升级是否存在
- 升级链完整性（前置条件）
- 升级类型统计

## 故障排除

### 配置文件无法加载
1. 检查文件是否存在：`config/upgrade_config.ini`
2. 检查文件编码：必须是 UTF-8（推荐无 BOM）
3. 检查 INI 格式：节标题 `[name]`，键值对 `key=value`

### 配置验证失败
1. 查看控制台错误信息
2. 检查缺失的必需字段
3. 确保武器有 `spell` 字段
4. 验证前置条件存在

### 升级池不足
- 建议至少配置 20-30 个不同的升级
- 确保有足够的升级选项供玩家选择
- 每个武器至少 4 个等级
- 每个属性至少 4 个等级

## 未来扩展

可以使用相同的模式扩展其他配置：
- `enemy_config.ini` - 敌人属性和行为
- `skill_config.ini` - 技能参数和效果
- `balance_config.ini` - 全局平衡参数

所有配置都应遵循相同的原则：
1. 完全从文件加载
2. 启动时验证
3. 失败时明确报错
4. 不使用硬编码默认值
