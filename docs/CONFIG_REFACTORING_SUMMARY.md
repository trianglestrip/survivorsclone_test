# 配置系统重构总结

**日期**: 2026-03-28  
**版本**: v2.1  
**提交**: 8a7a62b

---

## 问题背景

### 原有问题

之前的 `upgrade_db.gd` 包含 318 行硬编码的 `_DEFAULT_UPGRADES` 字典：

```gdscript
const _DEFAULT_UPGRADES = {
    "icespear1": {
        "icon": "res://...",
        "displayname": "冰矛",
        // ... 31 个升级的完整定义
    },
    // ... 更多硬编码数据
}
```

**问题**:
1. **数据与代码未分离** - 游戏数据硬编码在脚本中
2. **维护困难** - 修改升级需要编辑代码
3. **违背架构原则** - 配置驱动设计不彻底
4. **策划无法独立工作** - 必须修改 GDScript 代码

### 为什么之前使用默认值？

这是为了应对 Godot 在 headless 模式下 `ConfigFile.load()` 解析 UTF-8 INI 文件失败的问题。但这种"安全网"实际上违背了配置驱动的核心理念。

---

## 解决方案

### 核心思路

**完全依赖配置文件，失败即退出**

- 不使用任何硬编码默认值
- 配置文件必须存在且格式正确
- 启动时验证配置完整性
- 任何问题都立即报错并退出

### 技术实现

#### 1. 使用 FileAccess 直接读取

```gdscript
var file = FileAccess.open("res://config/upgrade_config.ini", FileAccess.READ)

if file == null:
    push_error("❌ 无法打开配置文件")
    get_tree().quit(1)
    return
```

**优势**:
- 绕过 `ConfigFile` 的编码问题
- 直接控制文件读取过程
- 支持 UTF-8（带或不带 BOM）

#### 2. 手动解析 INI 格式

```gdscript
while not file.eof_reached():
    var line = file.get_line().strip_edges()
    
    # 跳过空行和注释
    if line == "" or line.begins_with("#"):
        continue
    
    # 解析节标题 [section]
    if line.begins_with("[") and line.ends_with("]"):
        current_section = line.substr(1, line.length() - 2)
        UPGRADES[current_section] = {"prerequisite": []}
        continue
    
    # 解析键值对 key=value
    if line.contains("="):
        var parts = line.split("=", true, 1)
        var key = parts[0].strip_edges()
        var value = parts[1].strip_edges()
        
        # 自动类型转换
        if key in ["set_level", "add_baseammo", ...]:
            UPGRADES[current_section][key] = int(value)
        elif key in ["add_movement_speed", "add_spell_size", ...]:
            UPGRADES[current_section][key] = float(value)
        else:
            UPGRADES[current_section][key] = value
```

**优势**:
- 完全控制解析逻辑
- 自动类型转换（int/float/string）
- 处理特殊字段（prerequisite 数组）

#### 3. 启动时验证

```gdscript
func _validate_upgrades():
    if UPGRADES.size() == 0:
        push_error("❌ 升级配置为空！")
        get_tree().quit(1)
        return
    
    var errors = []
    
    # 检查必需字段
    for upgrade_id in UPGRADES:
        var data = UPGRADES[upgrade_id]
        for field in ["displayname", "details", "level", "type", "icon"]:
            if not data.has(field) or data[field] == "":
                errors.append("升级 '%s' 缺少字段: %s" % [upgrade_id, field])
    
    # 检查武器的 spell 字段
    if data["type"] == "weapon" and not data.has("spell"):
        errors.append("武器 '%s' 缺少 spell 字段" % upgrade_id)
    
    # 检查升级链完整性
    for prereq in data.get("prerequisite", []):
        if not UPGRADES.has(prereq):
            errors.append("前置条件 '%s' 不存在" % prereq)
    
    # 报告错误
    if errors.size() > 0:
        push_error("❌ 发现 %d 个配置错误" % errors.size())
        for error in errors:
            push_error("  - " + error)
        get_tree().quit(1)
```

**验证内容**:
- 配置数量（不能为空）
- 必需字段完整性
- 武器必须有 `spell` 字段
- 升级链完整性（前置条件存在）
- 升级池大小（建议 20-30+ 个）

---

## 改进效果

### 代码简化

**之前**: 381 行（318 行硬编码数据 + 63 行逻辑）  
**现在**: 140 行（纯逻辑，无硬编码数据）  
**减少**: 241 行（-63%）

### 架构改进

| 方面 | 之前 | 现在 |
|------|------|------|
| 数据位置 | 代码中 | 配置文件中 |
| 修改方式 | 编辑 GDScript | 编辑 INI |
| 策划参与 | 需要程序员 | 可独立工作 |
| 错误检测 | 运行时 | 启动时 |
| 失败处理 | 使用默认值 | 退出并报错 |

### 测试结果

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

---

## 使用指南

### 修改升级配置

1. 打开 `config/upgrade_config.ini`
2. 编辑现有升级或添加新升级
3. 保存文件（确保 UTF-8 编码）
4. 重启游戏

### 添加新升级

```ini
[new_upgrade_id]
displayname=新升级
details=升级描述
level=等级：1
prerequisite=
type=upgrade
icon=res://Textures/Items/Upgrades/icon.png
add_armor=5
```

### 添加新武器

```ini
[new_weapon1]
displayname=新武器
details=武器描述
level=等级：1
prerequisite=
type=weapon
icon=res://Textures/Items/Weapons/icon.png
spell=NewWeapon
set_level=1
add_baseammo=1
```

### 验证配置

运行测试：
```powershell
F:\project\godot\Godot_v4.6.1-stable_win64_console.exe --headless --path . --script tests/test_config_loading.gd
```

---

## 错误处理

### 配置文件不存在

```
❌ 无法打开配置文件: res://config/upgrade_config.ini
文件不存在或无法访问！
游戏无法继续，请确保配置文件存在！
```

**解决**: 确保 `config/upgrade_config.ini` 文件存在

### 配置格式错误

```
❌ INI 解析失败！未找到任何配置节
游戏无法继续，请检查配置文件格式！
```

**解决**: 检查 INI 格式，确保有 `[section]` 和 `key=value`

### 配置不完整

```
❌ 发现 3 个配置错误:
  - 升级 'icespear1' 缺少字段: spell
  - 升级 'armor1' 缺少字段: icon
  - 升级 'icespear2' 的前置条件 'icespear1' 不存在
请修复配置文件！
```

**解决**: 根据错误信息补充缺失的字段

---

## 设计理念

### 配置驱动的三个层次

1. **Level 1 - 部分配置** ❌
   - 有配置文件，但也有硬编码默认值
   - 配置失败时回退到默认值
   - 数据仍然散落在代码中

2. **Level 2 - 配置优先** ⚠️
   - 优先使用配置文件
   - 有默认值作为后备
   - 配置失败时警告但继续运行

3. **Level 3 - 完全配置驱动** ✅ **(当前实现)**
   - **只使用配置文件**
   - **无硬编码默认值**
   - **配置失败时退出**
   - **启动时验证完整性**

### 为什么选择 Level 3？

1. **强制数据分离** - 没有"后门"可以绕过配置
2. **早期错误检测** - 启动时就发现问题，而不是运行时崩溃
3. **明确的责任** - 配置文件是唯一的数据来源
4. **更好的协作** - 策划和程序员职责清晰

---

## 未来扩展

### 可以应用相同模式的配置

1. **敌人配置** (`enemy_config.ini`)
   - 敌人属性（HP、速度、伤害）
   - 掉落物品
   - AI 行为参数

2. **技能配置** (`skill_config.ini`)
   - 技能参数（伤害、冷却、范围）
   - 技能效果
   - 升级曲线

3. **平衡配置** (`balance_config.ini`)
   - 全局参数
   - 难度系数
   - 经验曲线

### 扩展建议

所有新配置都应遵循相同原则：
1. 完全从文件加载
2. 启动时验证
3. 失败时明确报错
4. 不使用硬编码默认值

---

## 总结

通过这次重构，我们实现了：

✅ **真正的数据与代码分离**  
✅ **配置文件是唯一的数据来源**  
✅ **启动时强制验证配置完整性**  
✅ **明确的错误报告和处理**  
✅ **代码简化 63%（381 行 → 140 行）**  
✅ **策划可以独立编辑配置**

这是一个更加健壮、可维护、可扩展的配置系统，为未来的内容扩展奠定了坚实的基础。
