# 阶段1暖雪风格升级说明

## 升级日期

2026-03-29

## 升级目标

按照暖雪的操作手感和UI标准，全面优化阶段1的操作控制系统，确保流畅的游戏体验和清晰的视觉反馈。

---

## 核心改进

### 1. 操作手感优化

#### 近战攻击系统
- **响应速度提升**：攻击冷却从 0.4s 降低到 0.3s，实现更快的连击节奏
- **攻击范围扩大**：从 80 扩大到 90，提升打击覆盖范围
- **伤害提升**：基础伤害从 10 提升到 12
- **击退增强**：击退力度从 150 提升到 180
- **打击停顿**：添加 0.05s 的打击停顿效果，增强打击感
- **屏幕震动**：攻击时触发轻微震动（强度 0.2），命中时触发明显震动（强度 0.4）
- **特效缩放**：斩击特效随帧数递增放大，视觉冲击力更强

#### 冲刺闪避系统
- **冷却优化**：从 1.0s 降低到 0.8s，提升机动性
- **距离调整**：从 180 调整到 160，更精准的位移控制
- **速度提升**：持续时间从 0.15s 降低到 0.12s，更快速的闪避
- **无敌时间保持**：0.3s 无敌帧，确保安全闪避
- **残影效果**：冲刺过程中生成半透明蓝色残影，视觉反馈更清晰
- **缓动曲线**：使用 ease(-2.0) 实现加速后减速的自然运动
- **屏幕震动**：冲刺启动时触发震动（强度 0.3）

#### 受击反馈系统
- **屏幕震动增强**：受击时触发强烈震动（强度 0.6），8次衰减
- **角色闪烁**：受击瞬间变红（1.5, 0.5, 0.5），持续 0.1s
- **特效增强**：受击特效随帧数放大，视觉冲击更强
- **特效加速**：帧间隔从 0.04s 降低到 0.035s

### 2. UI系统升级

#### 技能栏UI（暖雪风格）
- **发光边框**：每个技能槽添加彩色发光边框
- **脉冲效果**：技能就绪时发光边框呼吸脉冲（0.2 ~ 0.5 透明度）
- **冷却数字**：冷却期间显示倒计时数字（24号字体，白色描边）
- **就绪闪烁**：技能冷却完成时触发 0.6s 的闪烁动画（0.8 → 0.3 透明度）
- **颜色主题**：
  - Q技能：蓝色系 (0.4, 0.7, 1.0)
  - E技能：紫色系 (0.7, 0.4, 1.0)
  - R技能：红色系 (1.0, 0.4, 0.6)
  - Shift：绿色系 (0.4, 1.0, 0.6)
- **边框装饰**：深色边框（0.2, 0.2, 0.25）增强立体感

#### 增强血条组件
- **平滑过渡**：血量变化使用 lerp 平滑过渡（速度 5.0）
- **双层显示**：
  - 红色层：当前血量（即时）
  - 深红层：延迟血量（平滑跟随）
- **颜色渐变**：
  - 高血量（>60%）：绿色 (0.2, 0.8, 0.3)
  - 中血量（30-60%）：黄色 (0.9, 0.7, 0.2)
  - 低血量（<30%）：红色 (0.9, 0.2, 0.2)
- **低血量警告**：血量低于 30% 时红色发光边框脉冲闪烁
- **受击闪烁**：受击瞬间血条变白 0.1s
- **数字显示**：当前血量 / 最大血量（16号字体，白色描边）

### 3. 资源热重载系统

#### 功能特性
- **自动监控**：监控 UI、特效、配置文件的变化
- **实时重载**：检测到文件修改后自动重载资源
- **缓存清除**：提供手动清除 Godot 资源缓存的接口
- **开发友好**：避免因缓存导致的界面不刷新问题

#### 监控路径
- `res://Textures/UI/` - UI贴图
- `res://Textures/Placeholder/Effects/` - 特效贴图
- `res://config/` - 配置文件

#### 使用方法
```gdscript
# 自动模式（默认启用）
# 每秒自动检查资源变化

# 手动强制重载单个资源
ResourceHotReload.force_reload("res://Textures/UI/skill_slot_q.png")

# 手动强制重载所有资源
ResourceHotReload.force_reload_all()

# 清除Godot资源缓存
ResourceHotReload.clear_godot_cache()
```

---

## 技术细节

### 屏幕震动实现

```gdscript
func _shake_camera(camera: Camera2D, intensity: float):
	var original_offset = camera.offset
	var shake_amount = intensity * 10.0
	
	for i in range(8):
		var shake_x = randf_range(-shake_amount, shake_amount)
		var shake_y = randf_range(-shake_amount, shake_amount)
		camera.offset = original_offset + Vector2(shake_x, shake_y)
		await get_tree().create_timer(0.02).timeout
		shake_amount *= 0.75
	
	camera.offset = original_offset
```

### 冲刺残影实现

```gdscript
func _create_trail_effect(position: Vector2):
	var trail = Sprite2D.new()
	trail.texture = player.get_node("Sprite2D").texture
	trail.frame = player.get_node("Sprite2D").frame
	trail.flip_h = player.get_node("Sprite2D").flip_h
	trail.position = position
	trail.modulate = Color(0.5, 0.8, 1.0, 0.6)
	trail.z_index = player.z_index - 1
	
	player.get_parent().add_child(trail)
	_fade_out_trail(trail)
```

### 打击停顿实现

```gdscript
func _trigger_hit_pause():
	Engine.time_scale = 0.1
	await get_tree().create_timer(_hit_pause_duration * 0.1).timeout
	Engine.time_scale = 1.0
```

---

## 测试验证

运行自动化测试：

```bash
godot --headless --script tests/test_stage1_warmsnow_upgrade.gd
```

测试覆盖：
1. ✅ 攻击配置优化验证
2. ✅ 冲刺配置优化验证
3. ✅ 近战攻击增强功能验证
4. ✅ 冲刺管理器增强功能验证
5. ✅ 技能栏UI增强验证
6. ✅ 增强血条组件验证
7. ✅ 资源热重载系统验证

**测试结果：7/7 通过**

---

## 配置文件变更

### `config/stage1_controls.json`

```json
{
  "attack": {
    "base_cooldown": 0.3,        // 原 0.4
    "base_range": 90,            // 原 80
    "base_damage": 12,           // 原 10
    "base_knockback": 180,       // 原 150
    "animation_speed": 1.5,      // 新增
    "hit_pause_duration": 0.05   // 新增
  },
  "dash": {
    "cooldown": 0.8,             // 原 1.0
    "distance": 160,             // 原 180
    "duration": 0.12,            // 原 0.15
    "invincible_frames": 0.3,    // 保持
    "trail_effect": true,        // 新增
    "screen_shake_intensity": 0.3 // 新增
  }
}
```

---

## 避免缓存问题

### 问题描述
Godot编辑器会缓存资源文件，导致修改后的UI和特效不刷新。

### 解决方案

1. **使用资源热重载系统**（已自动启用）
   - 自动检测资源变化
   - 实时重载更新的文件
   - 无需重启编辑器

2. **手动清除缓存**
   ```gdscript
   # 在控制台或脚本中执行
   ResourceHotReload.clear_godot_cache()
   ```

3. **强制重新导入**
   - 删除 `.godot/imported/` 文件夹
   - 重启 Godot 编辑器

4. **使用 CACHE_MODE_IGNORE**
   ```gdscript
   var texture = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE)
   ```

---

## 下一步计划

阶段1暖雪风格升级已完成，可以开始阶段2：

**阶段2：宗派系统基础框架**
- 创建宗派数据结构（JSON配置）
- 创建宗派注册表（SectRegistry）
- 创建宗派选择界面（简化占位）
- 实现宗派属性应用
- 创建宗派测试场景（console测试）

---

## 文件清单

### 修改的文件
- `config/stage1_controls.json` - 优化攻击和冲刺参数
- `Player/player.gd` - 添加受击震动和闪烁
- `Player/Components/melee_attack.gd` - 添加打击停顿和震动
- `Player/Components/dash_manager.gd` - 添加残影和震动
- `Player/GUI/skill_bar_ui.gd` - 升级UI显示效果
- `project.godot` - 添加ResourceHotReload自动加载

### 新增的文件
- `Player/GUI/enhanced_health_bar.gd` - 暖雪风格血条组件
- `Utility/resource_hot_reload.gd` - 资源热重载管理器
- `tests/test_stage1_warmsnow_upgrade.gd` - 暖雪风格升级测试
- `.trae/documents/stage1_warmsnow_upgrade.md` - 本文档

---

## 性能影响

所有优化都经过性能考虑：
- 残影效果使用轻量级Sprite2D，自动淡出清理
- 屏幕震动使用简单的offset动画，无额外节点
- 发光效果使用ColorRect，GPU友好
- 热重载系统默认1秒检查间隔，可调整

---

## 已知问题

无

---

## 致谢

本次升级参考了《暖雪》的操作手感设计：
- 快速响应的攻击系统
- 流畅的冲刺闪避
- 强烈的打击反馈
- 清晰的UI状态显示
