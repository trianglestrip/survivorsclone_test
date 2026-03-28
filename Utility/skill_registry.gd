extends Node

# 技能注册系统 - 管理所有技能的注册和查询

var registered_skills = {}

# 注册技能
func register_skill(skill_id: String, skill_scene: PackedScene, skill_data: Dictionary = {}):
	registered_skills[skill_id] = {
		"scene": skill_scene,
		"data": skill_data
	}

# 获取技能场景
func get_skill_scene(skill_id: String) -> PackedScene:
	if registered_skills.has(skill_id):
		return registered_skills[skill_id]["scene"]
	return null

# 获取技能数据
func get_skill_data(skill_id: String) -> Dictionary:
	if registered_skills.has(skill_id):
		return registered_skills[skill_id]["data"]
	return {}

# 检查技能是否已注册
func has_skill(skill_id: String) -> bool:
	return registered_skills.has(skill_id)

# 获取所有已注册的技能 ID
func get_all_skill_ids() -> Array:
	return registered_skills.keys()

# 实例化技能
func instantiate_skill(skill_id: String) -> Node:
	var scene = get_skill_scene(skill_id)
	if scene:
		return scene.instantiate()
	return null

func _ready():
	_load_skills_from_config()

func _load_skills_from_config():
	print("\n=== 加载技能配置 ===")
	print("配置文件: res://config/skill_config.ini")
	
	var file = FileAccess.open("res://config/skill_config.ini", FileAccess.READ)
	
	if file == null:
		push_error("❌ 无法打开技能配置文件: res://config/skill_config.ini")
		push_error("游戏无法继续，请确保配置文件存在！")
		get_tree().quit(1)
		return
	
	var current_section = ""
	var skill_configs = {}
	
	while not file.eof_reached():
		var line = file.get_line().strip_edges()
		
		if line == "" or line.begins_with("#") or line.begins_with(";"):
			continue
		
		if line.begins_with("[") and line.ends_with("]"):
			current_section = line.substr(1, line.length() - 2)
			skill_configs[current_section] = {}
			continue
		
		if current_section != "" and line.contains("="):
			var parts = line.split("=", true, 1)
			if parts.size() == 2:
				var key = parts[0].strip_edges()
				var value = parts[1].strip_edges()
				
				if key == "tier":
					skill_configs[current_section][key] = int(value) if value.is_valid_int() else 1
				elif key == "is_boss":
					skill_configs[current_section][key] = value.to_lower() == "true"
				else:
					skill_configs[current_section][key] = value
	
	file.close()
	
	if skill_configs.size() == 0:
		push_error("❌ 技能配置为空！")
		get_tree().quit(1)
		return
	
	# 动态注册技能
	for skill_id in skill_configs:
		var config = skill_configs[skill_id]
		
		if not config.has("scene_path"):
			push_error("❌ 技能 '%s' 缺少 scene_path" % skill_id)
			continue
		
		var scene = load(config["scene_path"])
		if scene == null:
			push_error("❌ 无法加载技能场景: %s" % config["scene_path"])
			continue
		
		var skill_data = {
			"name": config.get("name", skill_id),
			"description": config.get("description", ""),
			"type": config.get("type", "projectile")
		}
		
		register_skill(skill_id, scene, skill_data)
		print("  ✓ 注册技能: %s (%s)" % [skill_id, skill_data["name"]])
	
	print("✓ 成功注册 %d 个技能\n" % registered_skills.size())
