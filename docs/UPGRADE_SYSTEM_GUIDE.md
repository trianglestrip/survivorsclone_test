# 升级系统设计指南

## 暖雪风格升级系统

按照暖雪的设计，升级系统分为以下几个部分：

### 1. 卡牌式升级选择（3选1）✅

**触发时机**：
- 玩家升级时
- 击败Boss后
- 特定事件触发

**实现**：
- `UI/upgrade_card_ui.gd` - 卡牌UI组件
- `UI/upgrade_card_ui.tscn` - 卡牌UI场景
- 支持键盘快捷键（1/2/3）快速选择
- 暂停游戏，强制选择

**卡牌内容**：
- 图标
- 稀有度（普通/优秀/稀有/史诗/传说）
- 名称
- 描述
- 效果详情

### 2. 圣物系统

圣物获取方式分为三种：

#### A. 战斗掉落 ✅
- 敌人死亡时掉落
- 自动拾取或靠近拾取
- 已实现：`Utility/relic_drop.gd`

#### B. 卡牌选择 ⏳
- 在升级卡牌中作为选项出现
- 稀有度：传说级
- 配置：`upgrade_config_extended.json` 中的 `type: "relic"`

#### C. 商店购买（可选）⏳
- 特殊房间中的商店NPC
- 使用金币购买
- 待实现

### 3. 属性升级

**类型**：
- **基础属性**：生命、移动速度、攻击伤害、护甲
- **战斗属性**：暴击率、暴击伤害、攻击速度
- **技能属性**：技能伤害、技能冷却
- **特殊属性**：近战伤害、防御

**升级层级**：
- I级（普通）：小幅提升
- II级（优秀）：中等提升，需要I级前置
- III级（稀有）：大幅提升，需要II级前置

## 配置文件

### upgrade_config_extended.json

扩展的升级配置，包含17种升级：

```json
{
  "upgrades": {
    "hp_boost1": {
      "id": "hp_boost1",
      "name": "生命强化",
      "displayname": "生命强化 I",
      "details": "提升最大生命值，增加生存能力",
      "level": "1",
      "prerequisite": [],
      "type": "upgrade",
      "rarity": "common",
      "icon": "res://icon.svg",
      "effects": {
        "max_hp": 20
      }
    }
  }
}
```

**字段说明**：
- `id`: 唯一标识符
- `name`: 基础名称
- `displayname`: 显示名称（包含等级）
- `details`: 详细描述
- `level`: 升级等级
- `prerequisite`: 前置条件（升级ID数组）
- `type`: 类型（"upgrade" 或 "relic"）
- `rarity`: 稀有度（common/uncommon/rare/epic/legendary）
- `icon`: 图标路径
- `effects`: 效果字典

## 使用方法

### 1. 测试卡牌UI

```bash
test_upgrade_cards.bat
```

或直接运行：
```bash
godot tests/test_upgrade_cards.tscn
```

**操作**：
- 按 **SPACE** 显示升级选择
- 按 **1/2/3** 快捷选择卡牌
- 按 **ESC** 退出

### 2. 集成到游戏

#### A. 在World场景中添加UI

```gdscript
# 在world.tscn中添加
var upgrade_ui = preload("res://UI/upgrade_card_ui.tscn").instantiate()
upgrade_ui.card_selected.connect(_on_upgrade_selected)
add_child(upgrade_ui)
```

#### B. 玩家升级时触发

```gdscript
# 在ExperienceManager中
func _on_level_up():
    var options = _get_random_upgrades(3)
    upgrade_ui.show_upgrade_options(options)

func _get_random_upgrades(count: int) -> Array:
    var upgrade_db = get_node("/root/UpgradeDb")
    var available = []
    
    for upgrade_id in upgrade_db.UPGRADES:
        var upgrade = upgrade_db.UPGRADES[upgrade_id]
        # 检查前置条件、稀有度等
        if _check_prerequisites(upgrade):
            available.append(upgrade)
    
    # 随机选择
    available.shuffle()
    return available.slice(0, count)
```

#### C. 应用升级

```gdscript
func _on_upgrade_selected(upgrade_id: String):
    var upgrade_manager = player.get_node("UpgradeManager")
    upgrade_manager.apply_upgrade(upgrade_id)
```

## 当前状态

### ✅ 已完成

1. **卡牌UI系统**
   - 3张卡牌布局
   - 稀有度颜色编码
   - 鼠标悬停效果
   - 键盘快捷键支持
   - 暂停游戏机制

2. **扩展升级配置**
   - 17种升级选项
   - 5个稀有度等级
   - 前置条件系统
   - 圣物集成

3. **测试场景**
   - 独立测试场景
   - 随机升级生成
   - 实时效果显示

### ⏳ 待完成

1. **游戏集成**
   - 将卡牌UI添加到主游戏场景
   - 连接经验系统和升级触发
   - 实现升级效果应用

2. **圣物卡牌**
   - 在卡牌池中添加圣物选项
   - 实现圣物特殊效果
   - 圣物图标和视觉效果

3. **商店系统**（可选）
   - 商店NPC
   - 金币系统
   - 购买界面

4. **平衡性调整**
   - 升级出现概率
   - 稀有度权重
   - 数值平衡

## 升级池配置

当前配置的17种升级：

| 类型 | 名称 | 稀有度 | 效果 |
|------|------|--------|------|
| 基础 | 生命强化 I/II/III | 普通/优秀/稀有 | 生命+20/40/60 |
| 基础 | 迅捷步伐 I/II | 普通/优秀 | 速度+10/20 |
| 基础 | 力量强化 I/II | 普通/优秀 | 伤害+5/10 |
| 防御 | 坚韧护甲 I | 普通 | 护甲+5 |
| 暴击 | 致命一击 I | 优秀 | 暴击率+10% |
| 暴击 | 暴击强化 I | 稀有 | 暴击伤害+50% |
| 技能 | 技能精通 I | 优秀 | 技能伤害+15% |
| 技能 | 急速冷却 I | 稀有 | 技能冷却-10% |
| 战斗 | 疾风连击 I | 优秀 | 攻击速度+15% |
| 战斗 | 近战大师 I | 优秀 | 近战伤害+20% |
| 综合 | 全能强化 | 史诗 | 全属性提升 |
| 圣物 | 白虎之魂 | 传说 | 35%追击+近战强化 |
| 圣物 | 青龙之魂 | 传说 | 技能强化+冷却缩短 |

## 下一步计划

1. **立即**：将卡牌UI集成到主游戏
2. **短期**：完善升级池（目标30+种升级）
3. **中期**：添加商店系统
4. **长期**：平衡性测试和调整

## 设计原则

按照暖雪的设计理念：

1. **选择即奖励**：每次升级都是正向增益
2. **策略深度**：不同build路线（近战/技能/平衡）
3. **稀有度差异**：高稀有度=强力效果
4. **前置条件**：形成升级链，鼓励专精
5. **视觉反馈**：清晰的UI和效果展示
