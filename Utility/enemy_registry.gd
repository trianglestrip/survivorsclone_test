extends Node

# 敌人注册系统 - 管理所有敌人类型

var registered_enemies = {}

# 注册敌人
func register_enemy(enemy_id: String, enemy_scene: PackedScene, enemy_data: Dictionary = {}):
	registered_enemies[enemy_id] = {
		"scene": enemy_scene,
		"data": enemy_data
	}

# 获取敌人场景
func get_enemy_scene(enemy_id: String) -> PackedScene:
	if registered_enemies.has(enemy_id):
		return registered_enemies[enemy_id]["scene"]
	return null

# 获取敌人数据
func get_enemy_data(enemy_id: String) -> Dictionary:
	if registered_enemies.has(enemy_id):
		return registered_enemies[enemy_id]["data"]
	return {}

# 检查敌人是否已注册
func has_enemy(enemy_id: String) -> bool:
	return registered_enemies.has(enemy_id)

# 获取所有已注册的敌人 ID
func get_all_enemy_ids() -> Array:
	return registered_enemies.keys()

# 实例化敌人
func instantiate_enemy(enemy_id: String) -> Node:
	var scene = get_enemy_scene(enemy_id)
	if scene:
		var enemy = scene.instantiate()
		# 设置敌人名称为 ID，这样配置文件可以正确加载
		enemy.name = enemy_id
		return enemy
	return null

func _ready():
	_load_enemies_from_config()

func _load_enemies_from_config():
	print("\n=== 加载敌人注册配置 ===")
	print("配置文件: res://config/enemy_registry.ini")
	
	var file = FileAccess.open("res://config/enemy_registry.ini", FileAccess.READ)
	
	if file == null:
		push_error("❌ 无法打开敌人注册配置文件: res://config/enemy_registry.ini")
		push_error("游戏无法继续，请确保配置文件存在！")
		get_tree().quit(1)
		return
	
	var current_section = ""
	var enemy_configs = {}
	
	while not file.eof_reached():
		var line = file.get_line().strip_edges()
		
		if line == "" or line.begins_with("#") or line.begins_with(";"):
			continue
		
		if line.begins_with("[") and line.ends_with("]"):
			current_section = line.substr(1, line.length() - 2)
			enemy_configs[current_section] = {}
			continue
		
		if current_section != "" and line.contains("="):
			var parts = line.split("=", true, 1)
			if parts.size() == 2:
				var key = parts[0].strip_edges()
				var value = parts[1].strip_edges()
				
				if key == "tier":
					enemy_configs[current_section][key] = int(value) if value.is_valid_int() else 1
				elif key == "is_boss":
					enemy_configs[current_section][key] = value.to_lower() == "true"
				else:
					enemy_configs[current_section][key] = value
	
	file.close()
	
	if enemy_configs.size() == 0:
		push_error("❌ 敌人配置为空！")
		get_tree().quit(1)
		return
	
	# 动态注册敌人
	for enemy_id in enemy_configs:
		var config = enemy_configs[enemy_id]
		
		if not config.has("scene_path"):
			push_error("❌ 敌人 '%s' 缺少 scene_path" % enemy_id)
			continue
		
		var scene = load(config["scene_path"])
		if scene == null:
			push_error("❌ 无法加载敌人场景: %s" % config["scene_path"])
			continue
		
		var enemy_data = {
			"name": config.get("name", enemy_id),
			"tier": config.get("tier", 1),
			"is_boss": config.get("is_boss", false)
		}
		
		register_enemy(enemy_id, scene, enemy_data)
		print("  ✓ 注册敌人: %s (%s) [Tier %d%s]" % [
			enemy_id, 
			enemy_data["name"], 
			enemy_data["tier"],
			" BOSS" if enemy_data["is_boss"] else ""
		])
	
	print("✓ 成功注册 %d 个敌人\n" % registered_enemies.size())
