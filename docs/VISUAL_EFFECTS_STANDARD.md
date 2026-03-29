# 技能视觉效果标准

## JSON 配置与 `VisualEffectsStandard` 单例

- **配置文件**: `config/visual_effects_standard.json`（`skill_types`: `projectile` / `area` / `ultimate`；`sect_colors`: 各门派主色/辅色/光晕）。
- **运行时**: `project.godot` 的 `[autoload]` 中注册为 `VisualEffectsStandard`（脚本 `Utility/visual_effects_standard.gd`）。
- **`BaseActiveSkill.create_skill_node()`** 会在创建节点前自动调用 `VisualEffectsStandard.apply_to_skill_node_config()`；可用 `SkillNodeConfig.skip_visual_standard` 关闭。大招请在配置中设置 `visual_category = "ultimate"`。
- **自定义弹射物**（未走 `create_skill_node`）在设置好精灵后调用 `apply_standard_to_skill_visual(节点, "projectile"|"area"|"ultimate")`。
- **API**: `get_skill_visual_config`、`get_sect_color_scheme`、`apply_standard_modulate`、`apply_standard_visual_node`、`reload`。
- **调试**: 改 JSON 后可在运行时调用 `VisualEffectsStandard.reload()`，或重启游戏。

---

## 📐 统一视觉规范

本文档定义了所有宗派技能的视觉效果标准，确保游戏画面清晰、协调、不遮挡视野。

---

## 🎯 设计原则

### 1. 尺寸控制
- **Q技能（弹射物）**: scale 1.0-1.5
- **E技能（区域）**: scale 0.8-0.9
- **R技能（大招）**: scale 0.8-1.0（基础），爆炸/冲击 1.5-2.0

### 2. 透明度控制
- **Q技能**: alpha 0.8-0.9（清晰可见）
- **E技能**: alpha 0.4-0.6（半透明）
- **R技能**: alpha 0.5-0.7（中等透明）

### 3. 层次控制
- **弹射物**: z_index 5
- **区域效果**: z_index 1-3
- **闪光/爆炸**: z_index 10-11

### 4. 动画控制
- **展开时间**: 0.2-0.6秒
- **淡出时间**: 0.5-0.8秒
- **脉冲周期**: 0.4-1.0秒

---

## 📊 各宗派技能标准

### ❄️ 冰心宗

| 技能 | 类型 | 尺寸 | 透明度 | 持续时间 |
|------|------|------|--------|----------|
| **Q - 冰刺** | 弹射物 | scale 1.5 | alpha 0.9 | 瞬时 |
| **E - 冰封领域** | 圆形区域 | radius/128 | alpha 0.6 | 4秒 |
| **R - 冰霜风暴** | 圆形区域 | radius/192 | alpha 0.7 | 5秒 |

**视觉特点**:
- 冰蓝色调（#4DA6FF）
- 半透明，不遮挡敌人
- 区域技能使用动画帧

**代码示例**:
```gdscript
# 冰封领域
node_config.animation_scale = Vector2(radius / 128.0, radius / 128.0)
node_config.animation_modulate = Color(1.0, 1.0, 1.0, 0.6)
```

---

### ⚡ 雷鸣宗

| 技能 | 类型 | 尺寸 | 透明度 | 持续时间 |
|------|------|------|--------|----------|
| **Q - 雷霆一击** | 瞬发 | flash 2.0 | alpha 0.8 | 瞬时 |
| **E - 雷阵** | 圆形区域 | scale 0.8 | alpha 0.4 | 6秒 |
| **R - 天罚雷劫** | 圆形区域 | scale 0.8 | alpha 0.5 | 6秒 |

**视觉特点**:
- 雷电紫色（#9D4DFF）
- 闪光效果短暂强烈
- 区域技能持续脉冲

**代码示例**:
```gdscript
# 雷阵
sprite.modulate.a = 0.25
tween.tween_property(sprite, "scale", Vector2(0.8, 0.8), 0.2)
tween.tween_property(sprite, "modulate:a", 0.4, 0.2)
```

---

### 🔥 烈焰宗

| 技能 | 类型 | 尺寸 | 透明度 | 持续时间 |
|------|------|------|--------|----------|
| **Q - 火球术** | 弹射物 | scale 1.5 | alpha 0.9 | 瞬时 |
| | 爆炸 | radius/48 | alpha 0.7 | 0.4秒 |
| **E - 火墙** | 矩形区域 | scale 0.85 | alpha 0.6 | 5秒 |
| **R - 陨火天降** | 多弹 | meteor 1.5 | alpha 0.9 | 3秒 |
| | 爆炸 | scale 2.0 | alpha 0.7 | 0.6秒 |

**视觉特点**:
- 火焰橙红色（#FF6B35）
- 多层火焰效果
- 爆炸扩散动画

**代码示例**:
```gdscript
# 火墙（多层）
for i in range(3):
    sprite.scale = Vector2(0.85, 0.85)
    sprite.modulate.a = 0.6 - i * 0.15
```

---

### ☠️ 毒瘴宗

| 技能 | 类型 | 尺寸 | 透明度 | 持续时间 |
|------|------|------|--------|----------|
| **Q - 毒镖** | 弹射物 | scale 1.0 | alpha 0.9 | 瞬时 |
| | 命中效果 | scale 1.2 | alpha 0.7 | 0.3秒 |
| **E - 毒云** | 圆形区域 | scale 0.9 | alpha 0.5 | 6秒 |
| **R - 瘟疫爆发** | 圆形区域 | scale 0.8 | alpha 0.2 | 8秒 |

**视觉特点**:
- 毒绿色调（#7FFF00）
- 多层毒雾飘动
- 低透明度，营造氛围

**代码示例**:
```gdscript
# 瘟疫爆发（4层）
for i in range(4):
    sprite.modulate.a = 0.2 - i * 0.03
    tween.tween_property(sprite, "scale", Vector2(0.8, 0.8), 0.6 + i * 0.1)
```

---

## 🔧 实现指南

### 基础模板

```gdscript
# 1. 创建精灵
var sprite = Sprite2D.new()
sprite.texture = VisualEffectsHelper.create_placeholder_texture(Vector2(64, 64))
sprite.modulate = GameConstants.Colors.SECT_XXX
sprite.modulate.a = 0.6  # 透明度
sprite.scale = Vector2(0.8, 0.8)  # 尺寸

# 2. 添加动画
var tween = create_tween()
tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.3)
tween.tween_property(sprite, "modulate:a", 0.8, 0.3)

# 3. 自动清理
var cleanup_script = load("res://Utility/auto_cleanup_node.gd")
node.set_script(cleanup_script)
node.set("lifetime", 5.0)
node.set("fade_duration", 0.6)
```

### 使用BaseActiveSkill配置系统

```gdscript
# 推荐方式：使用SkillNodeConfig
var node_config = SkillNodeConfig.new()
node_config.skill_animation_name = "ice_field"
node_config.animation_scale = Vector2(0.8, 0.8)
node_config.animation_modulate = Color(1.0, 1.0, 1.0, 0.6)
node_config.animation_fps = 8.0
node_config.lifetime = 5.0
node_config.fade_duration = 0.6

var skill_node = await create_skill_node(node_config)
```

---

## 📏 尺寸计算公式

### 圆形区域技能
```gdscript
# 小型区域（E技能）
animation_scale = Vector2(radius / 128.0, radius / 128.0)

# 大型区域（R技能）
animation_scale = Vector2(radius / 192.0, radius / 192.0)

# 固定尺寸
sprite.scale = Vector2(0.8, 0.8)
```

### 弹射物技能
```gdscript
# Q技能弹射物
sprite.scale = Vector2(1.0, 1.5)  # 根据技能类型调整

# 爆炸效果
effect.scale = Vector2(radius / 48.0, radius / 48.0)
```

---

## 🎨 颜色标准

### 宗派颜色（来自GameConstants）
```gdscript
SECT_ICE     = Color(0.302, 0.651, 1.0)    # #4DA6FF 冰蓝
SECT_THUNDER = Color(0.616, 0.302, 1.0)    # #9D4DFF 雷紫
SECT_FIRE    = Color(1.0, 0.420, 0.208)    # #FF6B35 火橙
SECT_POISON  = Color(0.498, 1.0, 0.0)      # #7FFF00 毒绿
```

### 透明度层级
```gdscript
# 强调效果（闪光、爆炸）
modulate.a = 0.8 - 0.9

# 中等效果（弹射物、小区域）
modulate.a = 0.6 - 0.7

# 背景效果（大区域、持续效果）
modulate.a = 0.2 - 0.5
```

---

## ✅ 验证清单

### 新技能检查
- [ ] 尺寸不超过标准（Q≤1.5, E≤0.9, R≤1.0）
- [ ] 透明度适中（不完全遮挡敌人）
- [ ] z_index正确（不遮挡重要UI）
- [ ] 有自动清理机制（不泄漏节点）
- [ ] 动画流畅（展开/淡出）

### 测试验证
```bash
# 运行视觉效果测试
godot --headless --script tests/test_all_sects_visual.gd

# 运行完整测试套件
scripts\test_all_fixes.bat
```

---

## 🔍 调试技巧

### 查看实际尺寸
```gdscript
# 在技能中添加调试输出
print("技能节点尺寸: ", skill_node.scale)
print("精灵尺寸: ", sprite.scale)
print("最终尺寸: ", skill_node.scale * sprite.scale)
```

### 可视化范围
```gdscript
# 添加范围指示器
var circle = VisualEffectsHelper.create_range_indicator(
    radius, 
    GameConstants.Colors.SECT_XXX, 
    null
)
circle.modulate.a = 0.3
```

---

## 📈 性能考虑

### 填充率优化
- ✅ 减小特效尺寸 → 减少像素填充
- ✅ 降低透明度 → 减少混合计算
- ✅ 使用简单纹理 → 减少纹理采样

### 内存优化
- ✅ 自动清理节点 → 防止内存泄漏
- ✅ 复用纹理 → 减少资源加载
- ✅ 对象池（未来） → 减少GC压力

---

## 🎮 玩家体验

### 视觉清晰度
- ✅ 技能效果可见但不遮挡
- ✅ 敌人位置清晰可辨
- ✅ 重要UI始终可见

### 视觉反馈
- ✅ 技能释放有明显反馈
- ✅ 伤害区域清晰标识
- ✅ 状态效果易于识别

### 性能流畅
- ✅ 60 FPS稳定运行
- ✅ 多个技能同时存在不卡顿
- ✅ 大量敌人时仍流畅

---

## 📝 修改历史

### 2026-03-29 - 初始标准化
- ✅ 冰心宗：缩小25-50%
- ✅ 雷鸣宗：缩小20-33%
- ✅ 烈焰宗：缩小15-33%
- ✅ 毒瘴宗：缩小17-25%

**测试结果**: 100% 通过 ✅

---

## 🔮 未来改进

### 可选优化
- [ ] 添加视觉质量设置（低/中/高）
- [ ] 实现粒子效果系统
- [ ] 添加技能预览模式
- [ ] 实现动态LOD（距离相机远时简化）

### 高级特效
- [ ] 后处理效果（辉光、模糊）
- [ ] 屏幕空间反射
- [ ] 动态光照
- [ ] 实时阴影

---

*文档创建时间: 2026-03-29 22:20*
