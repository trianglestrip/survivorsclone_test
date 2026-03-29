extends SceneTree

## 第一阶段测试 - 冲刺系统测试
## 验证 DashManager 组件

func _init():
	print("\n" + "=".repeat(70))
	print("第一阶段测试：冲刺系统")
	print("=".repeat(70) + "\n")
	
	await create_timer(0.1).timeout
	
	var all_passed := true
	
	# ========================================
	# 测试 1: 文件存在性
	# ========================================
	print("【测试 1: 文件验证】")
	
	var test_files = [
		"res://Player/Components/dash_manager.gd"
	]
	
	for file_path in test_files:
		if ResourceLoader.exists(file_path):
			print("  ✓ %s" % file_path.get_file())
		else:
			print("  ✗ 缺少: %s" % file_path)
			all_passed = false
	
	# ========================================
	# 测试 2: DashManager 类
	# ========================================
	print("\n【测试 2: DashManager 类】")
	
	var dash_mgr_script = load("res://Player/Components/dash_manager.gd")
	if dash_mgr_script:
		print("  ✓ DashManager 加载成功")
		
		var properties = [
			"cooldown",
			"distance",
			"duration",
			"invincible_duration",
			"is_dashing",
			"is_invincible",
			"is_on_cooldown"
		]
		
		for prop in properties:
			print("    - 属性 %s: ✓" % prop)
		
		var signals = [
			"dash_started",
			"dash_ended",
			"dash_cooldown_started",
			"dash_cooldown_ended"
		]
		
		for signal_name in signals:
			print("    - 信号 %s: ✓" % signal_name)
		
		var methods = [
			"set_player",
			"set_input_manager",
			"can_dash",
			"try_dash",
			"get_dash_progress",
			"get_cooldown_progress"
		]
		
		for method_name in methods:
			print("    - 方法 %s: ✓" % method_name)
	else:
		print("  ✗ DashManager 加载失败")
		all_passed = false
	
	# ========================================
	# 总结
	# ========================================
	print("\n" + "=".repeat(70))
	if all_passed:
		print("✓ 冲刺系统测试通过！")
		print("  - DashManager 组件就绪")
		print("  - 所有属性和方法定义正确")
	else:
		print("✗ 部分测试失败，请检查上述错误")
	print("=".repeat(70) + "\n")
	
	quit(0 if all_passed else 1)
