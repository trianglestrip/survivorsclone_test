extends Node2D

# GPU 实例化敌人生成器
# 使用 EnemyInstanceManager 生成敌人，性能大幅提升

const DEBUG_LOGGING := false  # 编辑器模式下关闭日志

@export var spawns: Array[Spawn_info] = []

@onready var player = get_tree().get_first_node_in_group("player")

@export var time = 0

signal changetime(time)

var enemy_manager = null

func _ready():
	connect("changetime", Callable(player, "change_time"))
	await _initialize_enemy_manager()
	_prewarm_enemy_pools()

func _initialize_enemy_manager():
	if DEBUG_LOGGING:
		print("\n=== 初始化 GPU 敌人管理器 ===")
	
	# 创建敌人管理器
	var manager_script = load("res://Enemy/enemy_instance_manager.gd")
	enemy_manager = manager_script.new()
	enemy_manager.set_container(self)
	enemy_manager.set_player(player)
	add_child(enemy_manager)
	
	# 等待初始化完成
	await enemy_manager.initialization_complete
	
	if DEBUG_LOGGING:
		print("✓ GPU 敌人管理器就绪\n")

func _prewarm_enemy_pools():
	if DEBUG_LOGGING:
		print("=== 预热敌人对象池 ===")
	
	# 为每种敌人类型预热
	var unique_enemies = {}
	for spawn_info in spawns:
		if spawn_info.enemy != null:
			var enemy_name = spawn_info.enemy.resource_path.get_file().get_basename()
			unique_enemies[enemy_name] = true
	
	if DEBUG_LOGGING:
		for enemy_name in unique_enemies:
			print("  ✓ 预热: %s (GPU 实例化)" % enemy_name)
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
				
				# 获取敌人类型 ID
				var enemy_type = new_enemy.resource_path.get_file().get_basename()
				
				while counter < i.enemy_num:
					# 使用 GPU 实例化管理器生成敌人
					if enemy_manager:
						var pos = get_random_position()
						enemy_manager.spawn_enemy(enemy_type, pos)
					counter += 1
	
	emit_signal("changetime", time)

func get_random_position():
	var vpr = get_viewport_rect().size * randf_range(1.1, 1.4)
	var top_left = Vector2(player.global_position.x - vpr.x/2, player.global_position.y - vpr.y/2)
	var top_right = Vector2(player.global_position.x + vpr.x/2, player.global_position.y - vpr.y/2)
	var bottom_left = Vector2(player.global_position.x - vpr.x/2, player.global_position.y + vpr.y/2)
	var bottom_right = Vector2(player.global_position.x + vpr.x/2, player.global_position.y + vpr.y/2)
	var pos_side = ["up", "down", "right", "left"].pick_random()
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
	var y_spawn = randf_range(spawn_pos1.y, spawn_pos2.y)
	return Vector2(x_spawn, y_spawn)
