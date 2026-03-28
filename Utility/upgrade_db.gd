extends Node

var UPGRADES = {}

func _ready():
	_load_upgrade_config()
	_validate_upgrades()

func _load_upgrade_config():
	print("\n=== 加载升级配置 ===")
	print("配置文件: res://config/upgrade_config.ini")
	
	# 使用 FileAccess 直接读取文件以避免编码问题
	var file = FileAccess.open("res://config/upgrade_config.ini", FileAccess.READ)
	
	if file == null:
		push_error("❌ 无法打开配置文件: res://config/upgrade_config.ini")
		push_error("文件不存在或无法访问！")
		push_error("游戏无法继续，请确保配置文件存在！")
		get_tree().quit(1)
		return
	
	# 手动解析 INI
	var current_section = ""
	var parsed_sections = 0
	
	while not file.eof_reached():
		var line = file.get_line().strip_edges()
		
		# 跳过空行和注释
		if line == "" or line.begins_with("#") or line.begins_with(";"):
			continue
		
		# 检查是否是节标题
		if line.begins_with("[") and line.ends_with("]"):
			current_section = line.substr(1, line.length() - 2)
			UPGRADES[current_section] = {
				"prerequisite": []
			}
			parsed_sections += 1
			continue
		
		# 解析键值对
		if current_section != "" and line.contains("="):
			var parts = line.split("=", true, 1)
			if parts.size() == 2:
				var key = parts[0].strip_edges()
				var value = parts[1].strip_edges()
				
				# 处理 prerequisite 特殊情况
				if key == "prerequisite":
					if value != "":
						UPGRADES[current_section]["prerequisite"] = value.split(",", false)
					else:
						UPGRADES[current_section]["prerequisite"] = []
				# 处理数值类型
				elif key in ["set_level", "add_baseammo", "set_ammo", "add_armor", "add_additional_attacks", "heal"]:
					if value.is_valid_int():
						UPGRADES[current_section][key] = int(value)
					else:
						UPGRADES[current_section][key] = value
				elif key in ["set_tornado_attackspeed", "add_movement_speed", "add_spell_size", "add_spell_cooldown"]:
					if value.is_valid_float():
						UPGRADES[current_section][key] = float(value)
					else:
						UPGRADES[current_section][key] = value
				else:
					UPGRADES[current_section][key] = value
	
	file.close()
	
	if parsed_sections == 0:
		push_error("❌ INI 解析失败！未找到任何配置节")
		push_error("游戏无法继续，请检查配置文件格式！")
		get_tree().quit(1)
		return
	
	print("✓ 成功解析 %d 个升级配置" % parsed_sections)

# 验证升级配置的完整性
func _validate_upgrades():
	print("\n=== 升级配置验证 ===")
	print("总升级数: ", UPGRADES.size())
	
	if UPGRADES.size() == 0:
		push_error("❌ 升级配置为空！")
		get_tree().quit(1)
		return
	
	var weapons = 0
	var upgrades = 0
	var items = 0
	var errors = []
	
	for upgrade_id in UPGRADES:
		var data = UPGRADES[upgrade_id]
		
		# 检查必需字段
		var required_fields = ["displayname", "details", "level", "type", "icon"]
		for field in required_fields:
			if not data.has(field) or data[field] == "":
				errors.append("升级 '%s' 缺少字段: %s" % [upgrade_id, field])
		
		# 统计类型
		var type = data.get("type", "")
		match type:
			"weapon":
				weapons += 1
				# 武器必须有 spell 字段
				if not data.has("spell"):
					errors.append("武器 '%s' 缺少 spell 字段" % upgrade_id)
			"upgrade":
				upgrades += 1
			"item":
				items += 1
			_:
				errors.append("升级 '%s' 类型无效: %s" % [upgrade_id, type])
	
	print("  武器: ", weapons)
	print("  属性升级: ", upgrades)
	print("  道具: ", items)
	
	# 检查升级池是否足够
	var available_for_selection = weapons + upgrades
	print("  可选升级数: ", available_for_selection)
	
	if available_for_selection < 15:
		push_warning("⚠️ 升级池较小（%d 个），建议至少 20-30 个" % available_for_selection)
	elif available_for_selection < 30:
		print("  ✓ 升级池充足（支持 %d+ 级）" % available_for_selection)
	else:
		print("  ✓ 升级池丰富（支持 %d+ 级）" % available_for_selection)
	
	# 报告错误
	if errors.size() > 0:
		push_error("❌ 发现 %d 个配置错误:" % errors.size())
		for error in errors:
			push_error("  - " + error)
		push_error("请修复配置文件！")
		get_tree().quit(1)
	else:
		print("  ✓ 配置验证通过")
	
	var sep = "============================================================"
	print(sep + "\n")
