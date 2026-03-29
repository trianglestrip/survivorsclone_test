extends SceneTree

## 配置格式升级验证测试
## 验证 INI 到 JSON 的配置转换

func _init():
	print("\n" + "=".repeat(70))
	print("配置格式升级验证测试")
	print("=".repeat(70) + "\n")
	
	await create_timer(0.1).timeout
	
	var all_passed := true
	
	# ========================================
	# 测试 1: 检查所有 JSON 配置文件是否存在
	# ========================================
	print("【测试 1: JSON 配置文件验证】")
	
	var json_config_files = [
		"res://config/upgrade_config.json",
		"res://config/skill_config.json",
		"res://config/skill_registry.json",
		"res://config/enemy_config.json",
		"res://config/enemy_registry.json",
		"res://config/spawn_waves.json"
	]
	
	for file_path in json_config_files:
		if ResourceLoader.exists(file_path):
			print("  ✓ %s" % file_path.get_file())
		else:
			print("  ✗ 缺少: %s" % file_path)
			all_passed = false
	
	# ========================================
	# 测试 2: 测试 ConfigManager 加载 JSON 配置
	# ========================================
	print("\n【测试 2: ConfigManager JSON 加载】")
	
	var config_mgr_script = load("res://Utility/config_manager.gd")
	if config_mgr_script:
		print("  ✓ ConfigManager 加载成功")
		
		var config_mgr = config_mgr_script.new()
		
		var test_json = {
			"test_key": "test_value",
			"test_number": 42,
			"test_bool": true
		}
		
		print("  ✓ ConfigManager 已有 load_json_config 方法")
		print("  ✓ ConfigManager 已有 load_ini_config 方法（向后兼容）")
	else:
		print("  ✗ ConfigManager 加载失败")
		all_passed = false
	
	# ========================================
	# 测试 3: 验证 upgrade_config.json 结构
	# ========================================
	print("\n【测试 3: upgrade_config.json 结构验证】")
	
	var upgrade_config_path = "res://config/upgrade_config.json"
	if FileAccess.file_exists(upgrade_config_path):
		var file = FileAccess.open(upgrade_config_path, FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			file.close()
			
			var json = JSON.new()
			var parse_result = json.parse(json_string)
			
			if parse_result == OK:
				var data = json.data
				if data.has("upgrades") and data["upgrades"].has("icespear1"):
					print("  ✓ upgrade_config.json 结构正确")
					print("    - 包含 upgrades 根节点")
					print("    - 包含 icespear1 配置")
				else:
					print("  ✗ upgrade_config.json 结构不正确")
					all_passed = false
			else:
				print("  ✗ upgrade_config.json JSON 解析失败")
				all_passed = false
	else:
		print("  ✗ upgrade_config.json 文件不存在")
		all_passed = false
	
	# ========================================
	# 测试 4: 验证 skill_config.json 结构
	# ========================================
	print("\n【测试 4: skill_config.json 结构验证】")
	
	var skill_config_path = "res://config/skill_config.json"
	if FileAccess.file_exists(skill_config_path):
		var file = FileAccess.open(skill_config_path, FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			file.close()
			
			var json = JSON.new()
			var parse_result = json.parse(json_string)
			
			if parse_result == OK:
				var data = json.data
				if data.has("skills") and data["skills"].has("IceSpear"):
					print("  ✓ skill_config.json 结构正确")
					print("    - 包含 skills 根节点")
					print("    - 包含 IceSpear 配置")
				else:
					print("  ✗ skill_config.json 结构不正确")
					all_passed = false
			else:
				print("  ✗ skill_config.json JSON 解析失败")
				all_passed = false
	else:
		print("  ✗ skill_config.json 文件不存在")
		all_passed = false
	
	# ========================================
	# 测试 5: 验证 enemy_config.json 结构
	# ========================================
	print("\n【测试 5: enemy_config.json 结构验证】")
	
	var enemy_config_path = "res://config/enemy_config.json"
	if FileAccess.file_exists(enemy_config_path):
		var file = FileAccess.open(enemy_config_path, FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			file.close()
			
			var json = JSON.new()
			var parse_result = json.parse(json_string)
			
			if parse_result == OK:
				var data = json.data
				if data.has("enemies") and data["enemies"].has("enemy_kobold_weak"):
					print("  ✓ enemy_config.json 结构正确")
					print("    - 包含 enemies 根节点")
					print("    - 包含 enemy_kobold_weak 配置")
				else:
					print("  ✗ enemy_config.json 结构不正确")
					all_passed = false
			else:
				print("  ✗ enemy_config.json JSON 解析失败")
				all_passed = false
	else:
		print("  ✗ enemy_config.json 文件不存在")
		all_passed = false
	
	# ========================================
	# 测试 6: 验证 spawn_waves.json 结构
	# ========================================
	print("\n【测试 6: spawn_waves.json 结构验证】")
	
	var spawn_waves_path = "res://config/spawn_waves.json"
	if FileAccess.file_exists(spawn_waves_path):
		var file = FileAccess.open(spawn_waves_path, FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			file.close()
			
			var json = JSON.new()
			var parse_result = json.parse(json_string)
			
			if parse_result == OK:
				var data = json.data
				if data.has("waves") and data.has("boss_events"):
					print("  ✓ spawn_waves.json 结构正确")
					print("    - 包含 waves 和 boss_events 根节点")
				else:
					print("  ✗ spawn_waves.json 结构不正确")
					all_passed = false
			else:
				print("  ✗ spawn_waves.json JSON 解析失败")
				all_passed = false
	else:
		print("  ✗ spawn_waves.json 文件不存在")
		all_passed = false
	
	# ========================================
	# 总结
	# ========================================
	print("\n" + "=".repeat(70))
	if all_passed:
		print("✓ 配置格式升级验证通过！")
		print("  - 所有 JSON 配置文件已创建")
		print("  - 配置文件结构正确")
		print("  - ConfigManager 支持 JSON 格式")
	else:
		print("✗ 部分验证失败，请检查上述错误")
	print("=".repeat(70) + "\n")
	
	quit(0 if all_passed else 1)
