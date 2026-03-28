extends Node2D


@export var spawns: Array[Spawn_info] = []

@onready var player = get_tree().get_first_node_in_group("player")

@export var time = 0

signal changetime(time)

func _ready():
	connect("changetime",Callable(player,"change_time"))
	_prewarm_enemy_pools()

# 预热敌人对象池
func _prewarm_enemy_pools():
	print("\n=== 预热敌人对象池 ===")
	
	# 为每种敌人类型预热对象池
	var unique_enemies = {}
	for spawn_info in spawns:
		if spawn_info.enemy != null:
			var enemy_path = spawn_info.enemy.resource_path
			unique_enemies[enemy_path] = spawn_info.enemy
	
	for enemy_path in unique_enemies:
		var enemy_scene = unique_enemies[enemy_path]
		var pool_name = "enemy_" + enemy_scene.resource_path.get_file().get_basename()
		# 预热 20 个实例
		ObjectPool.prewarm_pool(pool_name, enemy_scene, 20)
		print("  ✓ 预热对象池: %s (20 个实例)" % pool_name)
	
	print("✓ 对象池预热完成\n")

func _on_timer_timeout():
	time += 1
	var enemy_spawns = spawns
	for i in enemy_spawns:
		if time >= i.time_start and time <= i.time_end:
			if i.spawn_delay_counter < i.enemy_spawn_delay:
				i.spawn_delay_counter += 1
			else:
				i.spawn_delay_counter = 0
				var new_enemy = i.enemy
				var counter = 0
				while  counter < i.enemy_num:
					# 使用对象池获取敌人实例
					var pool_name = "enemy_" + new_enemy.resource_path.get_file().get_basename()
					var enemy_spawn = ObjectPool.get_object(pool_name, new_enemy)
					enemy_spawn.global_position = get_random_position()
					add_child(enemy_spawn)
					counter += 1
	emit_signal("changetime",time)

func get_random_position():
	var vpr = get_viewport_rect().size * randf_range(1.1,1.4)
	var top_left = Vector2(player.global_position.x - vpr.x/2, player.global_position.y - vpr.y/2)
	var top_right = Vector2(player.global_position.x + vpr.x/2, player.global_position.y - vpr.y/2)
	var bottom_left = Vector2(player.global_position.x - vpr.x/2, player.global_position.y + vpr.y/2)
	var bottom_right = Vector2(player.global_position.x + vpr.x/2, player.global_position.y + vpr.y/2)
	var pos_side = ["up","down","right","left"].pick_random()
	var spawn_pos1 = Vector2.ZERO
	var spawn_pos2 = Vector2.ZERO
	
	match pos_side:
		"up":
			spawn_pos1 = top_left
			spawn_pos2 = top_right
		"down":
			spawn_pos1 = bottom_left
			spawn_pos2 = bottom_right
		"right":
			spawn_pos1 = top_right
			spawn_pos2 = bottom_right
		"left":
			spawn_pos1 = top_left
			spawn_pos2 = bottom_left
	
	var x_spawn = randf_range(spawn_pos1.x, spawn_pos2.x)
	var y_spawn = randf_range(spawn_pos1.y,spawn_pos2.y)
	return Vector2(x_spawn,y_spawn)
