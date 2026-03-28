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
	_register_default_enemies()

func _register_default_enemies():
	# 注册弱小狗头人
	register_enemy("enemy_kobold_weak", 
		preload("res://Enemy/enemy_kobold_weak.tscn"), {
		"name": "弱小狗头人",
		"tier": 1,
		"is_boss": false
	})
	
	# 注册强壮狗头人
	register_enemy("enemy_kobold_strong", 
		preload("res://Enemy/enemy_kobold_strong.tscn"), {
		"name": "强壮狗头人",
		"tier": 2,
		"is_boss": false
	})
	
	# 注册独眼巨人
	register_enemy("enemy_cyclops", 
		preload("res://Enemy/enemy_cyclops.tscn"), {
		"name": "独眼巨人",
		"tier": 3,
		"is_boss": false
	})
	
	# 注册主宰者
	register_enemy("enemy_juggernaut", 
		preload("res://Enemy/enemy_juggernaut.tscn"), {
		"name": "主宰者",
		"tier": 4,
		"is_boss": true
	})
	
	# 注册超级敌人
	register_enemy("enemy_super", 
		preload("res://Enemy/enemy_super.tscn"), {
		"name": "超级敌人",
		"tier": 5,
		"is_boss": true
	})
