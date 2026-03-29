extends SceneTree

## 阶段1暖雪风格升级测试
## 验证所有操作优化和UI改进

var test_results = {
	"passed": 0,
	"failed": 0,
	"total": 0
}

func _init():
	print("\n" + "=".repeat(80))
	print("阶段1暖雪风格升级测试")
	print("=".repeat(80) + "\n")
	
	await create_timer(0.1).timeout
	
	_test_attack_config()
	_test_dash_config()
	_test_melee_attack_enhancements()
	_test_dash_manager_enhancements()
	_test_skill_bar_ui_enhancements()
	_test_health_bar_component()
	_test_resource_hot_reload()
	
	_print_summary()
	
	quit(0 if test_results["failed"] == 0 else 1)

func _test_attack_config():
	print("【测试 1: 攻击配置优化】")
	test_results["total"] += 1
	
	var config = _load_json_file("res://config/stage1_controls.json")
	if not config:
		_fail("配置文件加载失败")
		return
	
	var attack_config = config.get("primary_attack", config.get("attack", {}))
	if attack_config.is_empty():
		_fail("攻击配置不存在")
		return
	
	var checks = [
		["base_cooldown", 0.3, "攻击冷却"],
		["base_range", 90, "攻击范围"],
		["base_damage", 12, "基础伤害"],
		["base_knockback", 180, "击退力度"],
		["animation_speed", 1.5, "动画速度"],
		["hit_pause_duration", 0.05, "打击停顿"]
	]
	
	var all_ok = true
	for check in checks:
		var key = check[0]
		var expected = check[1]
		var name = check[2]
		
		if attack_config.has(key):
			var value = attack_config[key]
			if abs(value - expected) < 0.01:
				print("  ✓ %s: %.2f" % [name, value])
			else:
				print("  ✗ %s: 期望 %.2f, 实际 %.2f" % [name, expected, value])
				all_ok = false
		else:
			print("  ✗ 缺少配置: %s" % name)
			all_ok = false
	
	if all_ok:
		_pass("攻击配置优化正确")
	else:
		_fail("攻击配置存在问题")

func _test_dash_config():
	print("\n【测试 2: 冲刺配置优化】")
	test_results["total"] += 1
	
	var config = _load_json_file("res://config/stage1_controls.json")
	if not config or not config.has("dash"):
		_fail("配置文件加载失败")
		return
	
	var dash_config = config["dash"]
	
	var checks = [
		["cooldown", 0.8, "冲刺冷却"],
		["distance", 160, "冲刺距离"],
		["duration", 0.12, "冲刺持续"],
		["invincible_frames", 0.3, "无敌时间"],
		["trail_effect", true, "残影效果"],
		["screen_shake_intensity", 0.3, "震动强度"]
	]
	
	var all_ok = true
	for check in checks:
		var key = check[0]
		var expected = check[1]
		var name = check[2]
		
		if dash_config.has(key):
			var value = dash_config[key]
			if typeof(expected) == TYPE_BOOL:
				if value == expected:
					print("  ✓ %s: %s" % [name, value])
				else:
					print("  ✗ %s: 期望 %s, 实际 %s" % [name, expected, value])
					all_ok = false
			else:
				if abs(value - expected) < 0.01:
					print("  ✓ %s: %.2f" % [name, value])
				else:
					print("  ✗ %s: 期望 %.2f, 实际 %.2f" % [name, expected, value])
					all_ok = false
		else:
			print("  ✗ 缺少配置: %s" % name)
			all_ok = false
	
	if all_ok:
		_pass("冲刺配置优化正确")
	else:
		_fail("冲刺配置存在问题")

func _test_melee_attack_enhancements():
	print("\n【测试 3: 近战攻击增强功能】")
	test_results["total"] += 1
	
	var melee_script = load("res://Player/Components/melee_attack.gd")
	if not melee_script:
		_fail("MeleeAttack脚本加载失败")
		return
	
	var melee = melee_script.new()
	
	var required_vars = [
		"_hit_pause_duration",
		"_animation_speed"
	]
	
	var all_ok = true
	for var_name in required_vars:
		if var_name in melee:
			print("  ✓ 变量存在: %s" % var_name)
		else:
			print("  ✗ 缺少变量: %s" % var_name)
			all_ok = false
	
	var required_methods = [
		"_trigger_hit_pause",
		"_trigger_screen_shake",
		"_shake_camera"
	]
	
	for method_name in required_methods:
		if melee.has_method(method_name):
			print("  ✓ 方法存在: %s" % method_name)
		else:
			print("  ✗ 缺少方法: %s" % method_name)
			all_ok = false
	
	melee.free()
	
	if all_ok:
		_pass("近战攻击增强功能完整")
	else:
		_fail("近战攻击增强功能不完整")

func _test_dash_manager_enhancements():
	print("\n【测试 4: 冲刺管理器增强功能】")
	test_results["total"] += 1
	
	var dash_script = load("res://Player/Components/dash_manager.gd")
	if not dash_script:
		_fail("DashManager脚本加载失败")
		return
	
	var dash = dash_script.new()
	
	var required_vars = [
		"trail_effect",
		"screen_shake_intensity",
		"_trail_nodes"
	]
	
	var all_ok = true
	for var_name in required_vars:
		if var_name in dash:
			print("  ✓ 变量存在: %s" % var_name)
		else:
			print("  ✗ 缺少变量: %s" % var_name)
			all_ok = false
	
	var required_methods = [
		"_create_trail_effect",
		"_fade_out_trail",
		"_clear_old_trails",
		"_trigger_screen_shake",
		"_shake_camera"
	]
	
	for method_name in required_methods:
		if dash.has_method(method_name):
			print("  ✓ 方法存在: %s" % method_name)
		else:
			print("  ✗ 缺少方法: %s" % method_name)
			all_ok = false
	
	dash.free()
	
	if all_ok:
		_pass("冲刺管理器增强功能完整")
	else:
		_fail("冲刺管理器增强功能不完整")

func _test_skill_bar_ui_enhancements():
	print("\n【测试 5: 技能栏UI增强】")
	test_results["total"] += 1
	
	var ui_script = load("res://Player/GUI/skill_bar_ui.gd")
	if not ui_script:
		_fail("SkillBarUI脚本加载失败")
		return
	
	var ui = ui_script.new()
	
	var required_vars = [
		"_glow_time"
	]
	
	var all_ok = true
	for var_name in required_vars:
		if var_name in ui:
			print("  ✓ 变量存在: %s" % var_name)
		else:
			print("  ✗ 缺少变量: %s" % var_name)
			all_ok = false
	
	var required_methods = [
		"_trigger_ready_glow",
		"_update_idle_glow"
	]
	
	for method_name in required_methods:
		if ui.has_method(method_name):
			print("  ✓ 方法存在: %s" % method_name)
		else:
			print("  ✗ 缺少方法: %s" % method_name)
			all_ok = false
	
	var skill_keys = ["q", "e", "r", "shift"]
	for key in skill_keys:
		if ui._skills.has(key):
			var skill = ui._skills[key]
			if skill.has("glow_color"):
				print("  ✓ 技能 %s 有发光颜色配置" % key.to_upper())
			else:
				print("  ✗ 技能 %s 缺少发光颜色" % key.to_upper())
				all_ok = false
		else:
			print("  ✗ 缺少技能配置: %s" % key.to_upper())
			all_ok = false
	
	ui.free()
	
	if all_ok:
		_pass("技能栏UI增强功能完整")
	else:
		_fail("技能栏UI增强功能不完整")

func _test_health_bar_component():
	print("\n【测试 6: 增强血条组件】")
	test_results["total"] += 1
	
	var health_bar_path = "res://Player/GUI/enhanced_health_bar.gd"
	if not ResourceLoader.exists(health_bar_path):
		_fail("EnhancedHealthBar脚本不存在")
		return
	
	var health_bar_script = load(health_bar_path)
	if not health_bar_script:
		_fail("EnhancedHealthBar脚本加载失败")
		return
	
	var health_bar = health_bar_script.new()
	
	var required_methods = [
		"set_health",
		"_update_health_bar",
		"_get_health_color",
		"_trigger_damage_flash",
		"_update_glow_pulse"
	]
	
	var all_ok = true
	for method_name in required_methods:
		if health_bar.has_method(method_name):
			print("  ✓ 方法存在: %s" % method_name)
		else:
			print("  ✗ 缺少方法: %s" % method_name)
			all_ok = false
	
	health_bar.free()
	
	if all_ok:
		_pass("增强血条组件功能完整")
	else:
		_fail("增强血条组件功能不完整")

func _test_resource_hot_reload():
	print("\n【测试 7: 资源热重载系统】")
	test_results["total"] += 1
	
	var reload_path = "res://Utility/resource_hot_reload.gd"
	if not ResourceLoader.exists(reload_path):
		_fail("ResourceHotReload脚本不存在")
		return
	
	var reload_script = load(reload_path)
	if not reload_script:
		_fail("ResourceHotReload脚本加载失败")
		return
	
	var reload_mgr = reload_script.new()
	
	var required_methods = [
		"force_reload",
		"force_reload_all",
		"clear_godot_cache"
	]
	
	var all_ok = true
	for method_name in required_methods:
		if reload_mgr.has_method(method_name):
			print("  ✓ 方法存在: %s" % method_name)
		else:
			print("  ✗ 缺少方法: %s" % method_name)
			all_ok = false
	
	reload_mgr.free()
	
	if all_ok:
		_pass("资源热重载系统功能完整")
	else:
		_fail("资源热重载系统功能不完整")

func _pass(message: String):
	print("  ✓ 通过: %s" % message)
	test_results["passed"] += 1

func _fail(message: String):
	print("  ✗ 失败: %s" % message)
	test_results["failed"] += 1

func _load_json_file(path: String) -> Dictionary:
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		return {}
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(json_string)
	
	if error == OK:
		return json.data
	else:
		push_error("JSON解析错误: %s" % json.get_error_message())
		return {}

func _print_summary():
	print("\n" + "=".repeat(80))
	print("测试总结")
	print("=".repeat(80))
	print("总测试数: %d" % test_results["total"])
	print("通过: %d" % test_results["passed"])
	print("失败: %d" % test_results["failed"])
	
	if test_results["failed"] == 0:
		print("\n✓ 所有测试通过！阶段1暖雪风格升级完成")
		print("\n改进内容：")
		print("  1. 攻击响应速度提升 (0.4s → 0.3s)")
		print("  2. 攻击范围扩大 (80 → 90)")
		print("  3. 添加打击停顿效果 (0.05s)")
		print("  4. 添加屏幕震动反馈")
		print("  5. 冲刺距离优化 (180 → 160)")
		print("  6. 冲刺速度提升 (0.15s → 0.12s)")
		print("  7. 添加冲刺残影效果")
		print("  8. 技能栏添加发光和边框")
		print("  9. 技能栏显示冷却数字")
		print("  10. 增强血条组件（平滑过渡、颜色渐变）")
		print("  11. 资源热重载系统（避免缓存问题）")
	else:
		print("\n✗ 部分测试失败，请检查上述错误")
	
	print("=".repeat(80) + "\n")
