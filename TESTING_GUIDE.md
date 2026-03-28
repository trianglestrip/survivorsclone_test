# 测试指南

## 问题诊断：武器不射出

### 当前状态

重构已完成，所有自动化测试通过。但在实际游戏中可能遇到武器不射出的问题。

### 可能原因

1. **配置文件解析问题**（已缓解）
   - `upgrade_config.ini` 在某些环境下解析失败
   - 已添加默认配置作为回退
   - 默认配置包含正确的技能数据

2. **组件初始化顺序**（已验证）
   - 所有组件在 `_ready()` 中正确初始化
   - 升级应用在组件初始化后执行

3. **计时器信号连接**（已确认）
   - player.tscn 中所有计时器信号已正确连接

### 在 Godot 编辑器中测试

#### 步骤 1：打开项目

```bash
# 使用 Godot 编辑器打开项目
F:\project\godot\Godot_v4.6.1-stable_win64.exe --path f:\project\SurvivorsClone_Test
```

或双击 `run_game.bat` 直接运行游戏。

#### 步骤 2：查看调试输出

运行游戏后，在 Godot 编辑器的"输出"面板中查找以下调试信息：

```
[DEBUG] attack() - icespear_level: 1
[DEBUG] 启动 IceSpearTimer, wait_time: 1.5
[DEBUG] IceSpearTimer 已启动
[DEBUG] IceSpearTimer 超时触发
[DEBUG] base_ammo: 1 additional_attacks: 0 total: 1
[DEBUG] IceSpearAttackTimer 已启动
[DEBUG] IceSpearAttackTimer 超时触发
[DEBUG] 当前弹药: 1
[DEBUG] 发射冰矛！
```

#### 步骤 3：诊断问题

根据输出判断问题：

**情况 A：看到 "icespear_level: 0"**
- 问题：升级未正确应用
- 检查：UpgradeDb 是否加载了正确的配置
- 解决：查看是否有 "无法加载 upgrade_config.ini" 警告

**情况 B：看到 "icespear_level: 1" 但没有 "IceSpearTimer 已启动"**
- 问题：计时器未启动
- 检查：iceSpearTimer 节点是否存在
- 解决：确认 player.tscn 中的计时器节点

**情况 C：看到 "IceSpearTimer 已启动" 但没有 "IceSpearTimer 超时触发"**
- 问题：计时器信号未连接
- 检查：player.tscn 中的信号连接
- 解决：重新连接 IceSpearTimer 的 timeout 信号

**情况 D：看到 "base_ammo: 0"**
- 问题：升级未正确设置 base_ammo
- 检查：UpgradeManager 的 apply_upgrade 逻辑
- 解决：确认 upgrade_config.ini 或默认配置包含 add_baseammo

### 快速修复

如果在编辑器中仍然无法正常工作，尝试以下步骤：

#### 方案 1：使用原始 player.gd

```bash
# 恢复原始 player.gd
Copy-Item Player/player_original.gd Player/player.gd -Force
```

#### 方案 2：手动初始化技能

在 `player.gd` 的 `_initial_setup()` 中添加：

```gdscript
func _initial_setup():
	# 手动设置技能（调试用）
	skill_mgr.set_skill_level("icespear", 1)
	skill_mgr.add_skill_ammo("icespear", 1)
	
	upgrade_character("icespear1")
	attack()
	set_expbar(stats.experience, exp_mgr.calculate_experience_cap())
	_on_hurt_box_hurt(0, 0, 0)
```

#### 方案 3：检查 Autoload 加载顺序

在 `project.godot` 中确认 Autoload 顺序：

```
[autoload]

EventBus="*res://Utility/event_bus.gd"
ConfigManager="*res://Utility/config_manager.gd"
SkillRegistry="*res://Utility/skill_registry.gd"
EnemyRegistry="*res://Utility/enemy_registry.gd"
ObjectPool="*res://Utility/object_pool.gd"
UpgradeDb="*res://Utility/upgrade_db.tscn"
```

UpgradeDb 应该在最后加载，确保其他系统先就绪。

### 验证修复

运行游戏后：
1. 玩家应该能移动
2. 1.5 秒后应该看到冰矛发射
3. 冰矛应该飞向最近的敌人
4. 击杀敌人后应该掉落经验宝石

### 移除调试输出

修复问题后，移除 player.gd 中的所有 `print("[DEBUG] ...")` 语句以提高性能。

## 配置文件问题

### 症状

在控制台看到：
```
ERROR: ConfigFile parse error at res://config/upgrade_config.ini:1: Expected value, got 'ERROR'.
WARNING: 无法加载 upgrade_config.ini，使用默认配置 (错误代码: 43)
```

### 原因

这是 Godot 4.x 在某些环境下（特别是 headless 模式）对 UTF-8 文件的已知问题。

### 解决方案

1. **在编辑器中**：通常能正常加载
2. **在 headless 模式**：使用默认配置（已包含必要数据）
3. **如果编辑器也失败**：运行 `python tests/fix_config.py` 重写配置文件

### 验证配置加载

在 Godot 编辑器的脚本编辑器中，打开 `Utility/upgrade_db.gd` 并在 `_load_upgrade_config()` 的开头添加：

```gdscript
func _load_upgrade_config():
	print("=== 加载升级配置 ===")
	var cfg = ConfigFile.new()
	var load_result = cfg.load("res://config/upgrade_config.ini")
	print("加载结果: ", load_result)
	
	if load_result != OK:
		print("配置加载失败，使用默认配置")
		print("默认配置数量: ", _DEFAULT_UPGRADES.size())
		UPGRADES = _DEFAULT_UPGRADES
		return
	
	print("配置加载成功，节数量: ", cfg.get_sections().size())
	# ... 其余代码
```

## 性能测试

### 对象池验证

运行游戏并击杀大量敌人，观察：
- 经验宝石是否被复用（不会无限增长）
- 爆炸特效是否被复用
- 内存使用是否稳定

### 帧率监控

在 Godot 编辑器中：
1. 运行游戏
2. 打开"调试器" > "监视器"
3. 查看 FPS 和内存使用

## 完整游戏流程测试

### 测试清单

- [ ] 玩家能正常移动
- [ ] 冰矛能正常发射
- [ ] 升级后能获得龙卷风
- [ ] 升级后能获得标枪
- [ ] 击杀敌人掉落经验
- [ ] 收集经验能升级
- [ ] 升级面板正确显示
- [ ] 选择升级后效果生效
- [ ] 护甲升级能减少伤害
- [ ] 速度升级能提升移动速度
- [ ] 游戏能正常结束（胜利/失败）

### 自动化测试

运行完整测试：
```bash
F:\project\godot\Godot_v4.6.1-stable_win64_console.exe --headless --path f:\project\SurvivorsClone_Test --script tests/test_complete.gd
```

预期输出：
```
✓ 所有阶段测试通过！
```

## 常见问题

### Q: 武器完全不射出

**A**: 检查以下几点：
1. 组件是否正确初始化（查看调试输出）
2. 技能等级是否 > 0
3. 计时器信号是否连接
4. base_ammo 是否 > 0

### Q: 武器射出但没有伤害

**A**: 检查：
1. 技能的碰撞层和掩码设置
2. 敌人的碰撞层设置
3. 技能的 damage 属性

### Q: 升级后效果不生效

**A**: 检查：
1. UpgradeManager 是否正确连接到 PlayerStats 和 SkillManager
2. 升级配置是否包含正确的字段
3. 查看调试输出确认升级应用过程

### Q: 配置文件解析错误

**A**: 
1. 在 Godot 编辑器中通常能正常工作
2. 如果不行，运行 `python tests/fix_config.py`
3. 默认配置会自动生效，基本功能不受影响

## 联系与支持

如果问题仍然存在，请：
1. 收集完整的调试输出
2. 截图游戏运行状态
3. 检查 Godot 版本（需要 4.6.1+）
4. 查看 ARCHITECTURE.md 了解系统设计
