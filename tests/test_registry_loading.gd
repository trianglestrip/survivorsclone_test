extends SceneTree

# 简化的配置文件解析测试
func _init():
	var sep = "============================================================"
	print("\n" + sep)
	print("测试：技能和敌人配置文件解析")
	print(sep)
	
	var all_passed = true
	
	# 测试 1: 技能注册配置文件解析
	print("\n[测试 1] 技能注册配置文件解析")
	var skill_configs = _parse_ini("res://config/skill_registry.ini")
	
	if skill_configs.size() == 0:
		print("  ❌ 失败: 技能配置为空")
		all_passed = false
	else:
		print("  ✓ 解析到 %d 个技能配置" % skill_configs.size())
		
		var expected_skills = ["IceSpear", "Tornado", "Javelin"]
		for skill_id in expected_skills:
			if skill_configs.has(skill_id):
				var config = skill_configs[skill_id]
				var name_val = ""
				if config.has("name"):
					name_val = config["name"]
				else:
					name_val = "未命名"
				
				var type_val = ""
				if config.has("type"):
					type_val = config["type"]
				else:
					type_val = "未知"
				
				print("    ✓ %s: %s (%s)" % [skill_id, name_val, type_val])
				
				if not config.has("scene_path"):
					print("      ❌ 缺少 scene_path")
					all_passed = false
			else:
				print("    ❌ 缺少技能: %s" % skill_id)
				all_passed = false
	
	# 测试 2: 敌人注册配置文件解析
	print("\n[测试 2] 敌人注册配置文件解析")
	var enemy_configs = _parse_ini("res://config/enemy_registry.ini")
	
	if enemy_configs.size() == 0:
		print("  ❌ 失败: 敌人配置为空")
		all_passed = false
	else:
		print("  ✓ 解析到 %d 个敌人配置" % enemy_configs.size())
		
		var expected_enemies = ["enemy_kobold_weak", "enemy_kobold_strong", "enemy_cyclops", "enemy_juggernaut", "enemy_super"]
		for enemy_id in expected_enemies:
			if enemy_configs.has(enemy_id):
				var config = enemy_configs[enemy_id]
				var name_val = ""
				if config.has("name"):
					name_val = config["name"]
				else:
					name_val = "未命名"
				
				var tier_val = 0
				if config.has("tier"):
					tier_val = config["tier"]
				
				print("    ✓ %s: %s (Tier %d)" % [enemy_id, name_val, tier_val])
				
				if not config.has("scene_path"):
					print("      ❌ 缺少 scene_path")
					all_passed = false
			else:
				print("    ❌ 缺少敌人: %s" % enemy_id)
				all_passed = false
	
	# 总结
	print("\n" + sep)
	if all_passed:
		print("✅ 所有测试通过")
		print(sep)
		quit(0)
	else:
		print("❌ 部分测试失败")
		print(sep)
		quit(1)

func _parse_ini(path: String) -> Dictionary:
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	
	var current_section = ""
	var configs = {}
	
	while not file.eof_reached():
		var line = file.get_line().strip_edges()
		
		if line == "" or line.begins_with("#") or line.begins_with(";"):
			continue
		
		if line.begins_with("[") and line.ends_with("]"):
			current_section = line.substr(1, line.length() - 2)
			configs[current_section] = {}
			continue
		
		if current_section != "" and line.contains("="):
			var parts = line.split("=", true, 1)
			if parts.size() == 2:
				var key = parts[0].strip_edges()
				var value = parts[1].strip_edges()
				
				if key == "tier":
					if value.is_valid_int():
						configs[current_section][key] = int(value)
					else:
						configs[current_section][key] = 1
				elif key == "is_boss":
					configs[current_section][key] = value.to_lower() == "true"
				else:
					configs[current_section][key] = value
	
	file.close()
	return configs
