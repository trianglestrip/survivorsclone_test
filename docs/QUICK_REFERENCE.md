# 暖雪风格升级 - 快速参考

## 🎮 操作控制

| 按键 | 功能 | 冷却 | 状态 |
|------|------|------|------|
| **WASD** | 移动 | - | ✅ 已实现 |
| **左键/空格** | 近战攻击 | 0.3s | ✅ 已实现 |
| **右键** | 远程攻击/副武器 | 0.5s | 🔴 待实现 |
| **Shift** | 冲刺闪避 | 0.8s | ✅ 已实现 |
| **Q** | 宗派技能1 | 3.0s | 🟡 输入已支持 |
| **E** | 宗派技能2 | 5.0s | 🟡 输入已支持 |
| **R** | 必杀技 | 10.0s | 🟡 输入已支持 |

### 特效说明
- **近战攻击**：斩击特效 + 屏幕震动 + 打击停顿
- **冲刺闪避**：蓝色残影 + 屏幕震动 + 0.3s无敌
- **QER技能**：需要先选择宗派解锁

## 📊 核心数值

### 攻击系统
- 冷却：0.3s（每秒3.3次）
- 范围：90
- 伤害：12
- 击退：180
- 停顿：0.05s

### 冲刺系统
- 冷却：0.8s
- 距离：160
- 速度：0.12s
- 无敌：0.3s

### 玩家属性
- 移动速度：50
- 最大血量：100
- 护甲：0

## 🎨 视觉效果

### 特效列表
- ⚔️ 斩击特效：8帧蓝色斩击
- 💨 冲刺特效：8帧蓝色冲击波
- 💥 受击特效：8帧红色爆发
- 👻 残影效果：半透明蓝色残影

### UI元素
- 🎯 技能栏：4个技能槽（Q/E/R/Shift）
- ❤️ 血条：顶部，颜色渐变
- 📊 经验条：底部
- ⏱️ 计时器：右上角

## 🔧 常用命令

### 清除缓存
```bash
clear_cache.bat
```

### 运行测试
```bash
godot --headless --script tests/test_stage1_warmsnow_upgrade.gd
```

### 验证升级
```bash
godot --headless --script verify_upgrade.gd
```

### 强制重载资源
```gdscript
# 在Godot控制台执行
ResourceHotReload.force_reload_all()
```

## 📁 重要文件

### 配置文件
- `config/stage1_controls.json` - 操作参数

### 核心组件
- `Player/player.gd` - 玩家主类
- `Player/Components/melee_attack.gd` - 近战攻击
- `Player/Components/dash_manager.gd` - 冲刺管理
- `Player/GUI/skill_bar_ui.gd` - 技能栏UI
- `Player/GUI/enhanced_health_bar.gd` - 血条组件

### 系统组件
- `Utility/resource_hot_reload.gd` - 热重载系统

### 测试文件
- `tests/test_stage1_warmsnow_upgrade.gd` - 自动化测试
- `verify_upgrade.gd` - 验证脚本

## 🐛 调试技巧

### 查看日志
- 打开 Godot 编辑器
- 查看输出面板（Output）
- 搜索 `[ResourceHotReload]` 查看热重载日志

### 性能分析
- 按 F3 显示 FPS
- 查看内存占用
- 监控CPU使用率

### 测试特定功能
```gdscript
# 测试攻击
var melee = MeleeAttack.new()
melee.try_attack()

# 测试冲刺
var dash = DashManager.new()
dash.try_dash()

# 测试血条
var health_bar = EnhancedHealthBar.new()
health_bar.set_health(50, 100)
```

## 📞 快速帮助

### UI不刷新？
→ 运行 `clear_cache.bat`

### 特效不显示？
→ 检查 `Textures/Placeholder/Effects/` 文件夹

### 震动太强/太弱？
→ 修改 `config/stage1_controls.json` 中的 `screen_shake_intensity`

### 残影不显示？
→ 确保配置中 `trail_effect: true`

### 测试失败？
→ 运行 `verify_upgrade.gd` 检查缺失文件

---

## 🎯 暖雪风格核心特点

1. **快速响应** - 输入即时反馈，无延迟感
2. **流畅连击** - 短冷却，可连续攻击
3. **强打击感** - 震动+停顿+特效三重反馈
4. **精准控制** - 适中距离，可精确定位
5. **清晰反馈** - 发光+数字+颜色多重提示

---

**版本**：阶段1暖雪风格升级  
**日期**：2026-03-29  
**状态**：✅ 完成
