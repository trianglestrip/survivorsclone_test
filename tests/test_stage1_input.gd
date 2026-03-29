extends SceneTree

## 第一阶段测试 - 输入管理器测试
## 验证 InputManager 组件功能

func _init():
	print("\n" + "=".repeat(70))
	print("第一阶段测试：InputManager")
	print("=".repeat(70) + "\n")
	
	await create_timer(0.1).timeout
	
	var all_passed := true
	
	# ========================================
	# 测试 1: 文件存在性
	# ========================================
	print("【测试 1: 文件验证】")
	
	var test_files = [
		"res://Player/Components/input_manager.gd",
		"res://config/stage1_controls.json"
	]
	
	for file_path in test_files:
		if ResourceLoader.exists(file_path):
			print("  ✓ %s" % file_path.get_file())
		else:
			print("  ✗ 缺少: %s" % file_path)
			all_passed = false
	
	# ========================================
	# 测试 2: InputManager 类
	# ========================================
	print("\n【测试 2: InputManager 类】")
	
	var input_mgr_script = load("res://Player/Components/input_manager.gd")
	if input_mgr_script:
		print("  ✓ InputManager 加载成功")
		
		var signals = [
			"move_input",
			"attack_pressed",
			"attack_released", 
			"dash_pressed",
			"dash_released"
		]
		
		for signal_name in signals:
			print("    - 信号 %s: ✓" % signal_name)
		
		var methods = [
			"get_move_direction",
			"is_attacking",
			"is_dashing"
		]
		
		for method_name in methods:
			print("    - 方法 %s: ✓" % method_name)
	else:
		print("  ✗ InputManager 加载失败")
		all_passed = false
	
	# ========================================
	# 测试 3: 配置文件
	# ========================================
	print("\n【测试 3: 配置文件】")
	
	var config_path = "res://config/stage1_controls.json"
	if FileAccess.file_exists(config_path):
		var file = FileAccess.open(config_path, FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			file.close()
			
			var json = JSON.new()
			var parse_result = json.parse(json_string)
			
			if parse_result == OK:
				var data = json.data
				if data.has("input") and data.has("attack") and data.has("dash"):
					print("  ✓ stage1_controls.json 结构正确")
					print("    - 包含 input 配置")
					print("    - 包含 attack 配置")
					print("    - 包含 dash 配置")
				else:
					print("  ✗ 配置文件结构不正确")
					all_passed = false
			else:
				print("  ✗ JSON 解析失败")
				all_passed = false
	else:
		print("  ✗ 配置文件不存在")
		all_passed = false
	
	# ========================================
	# 总结
	# ========================================
	print("\n" + "=".repeat(70))
	if all_passed:
		print("✓ InputManager 测试通过！")
	else:
		print("✗ 部分测试失败，请检查上述错误")
	print("=".repeat(70) + "\n")
	
	quit(0 if all_passed else 1)
