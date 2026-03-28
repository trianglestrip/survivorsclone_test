extends Node2D

# 性能测试场景 - 生成大量敌人测试帧率

@onready var enemy_container = $EnemyContainer
@onready var info_label = $CanvasLayer/InfoLabel
@onready var camera = $Camera2D
@onready var perf_monitor = $PerformanceMonitor

# 每种敌人生成数量（总共 500 个敌人）
var enemies_per_type = 100  # 5 种敌人 x 100 = 500

# 统计信息
var total_enemies = 0
var enemy_counts = {}

func _ready():
	print("\n=== 性能测试开始 ===")
	print("每种敌人生成数量: %d" % enemies_per_type)
	
	# 等待一帧确保 EnemyRegistry 已初始化
	await get_tree().process_frame
	
	# 预热对象池
	_prewarm_pools()
	
	_spawn_test_enemies()
	_update_info_label()

func _prewarm_pools():
	print("\n预热对象池...")
	var enemy_types = EnemyRegistry.get_all_enemy_ids()
	
	for enemy_id in enemy_types:
		var scene = EnemyRegistry.get_enemy_scene(enemy_id)
		if scene:
			var pool_name = "enemy_" + enemy_id
			# 预热每种敌人 50 个实例
			ObjectPool.prewarm_pool(pool_name, scene, 50)
			print("  ✓ 预热 %s: 50 个实例" % enemy_id)
	
	print("✓ 对象池预热完成\n")

func _spawn_test_enemies():
	var enemy_types = EnemyRegistry.get_all_enemy_ids()
	print("\n可用敌人类型: %d" % enemy_types.size())
	
	for enemy_id in enemy_types:
		var scene = EnemyRegistry.get_enemy_scene(enemy_id)
		if scene == null:
			push_warning("跳过敌人: %s (场景为 null)" % enemy_id)
			continue
		
		var pool_name = "enemy_" + enemy_id
		enemy_counts[enemy_id] = 0
		
		print("生成敌人: %s" % enemy_id)
		
		for i in range(enemies_per_type):
			# 使用对象池获取敌人
			var enemy = ObjectPool.get_object(pool_name, scene)
			
			# 设置随机位置（在相机周围）
			var angle = randf() * TAU
			var distance = randf_range(100, 500)
			enemy.global_position = camera.global_position + Vector2(cos(angle), sin(angle)) * distance
			
			enemy_container.add_child(enemy)
			enemy_counts[enemy_id] += 1
			total_enemies += 1
		
		print("  ✓ 已生成 %d 个 %s" % [enemies_per_type, enemy_id])
	
	print("\n总敌人数: %d" % total_enemies)
	print("=== 性能测试场景就绪 ===\n")

func _update_info_label():
	var info_text = "性能测试场景\n"
	info_text += "总敌人数: %d\n" % total_enemies
	info_text += "\n敌人分布:\n"
	
	for enemy_id in enemy_counts:
		var enemy_data = EnemyRegistry.get_enemy_data(enemy_id)
		var name_text = enemy_data.get("name", enemy_id)
		info_text += "  %s: %d\n" % [name_text, enemy_counts[enemy_id]]
	
	info_label.text = info_text

func _process(_delta):
	# 每秒更新一次信息
	if Engine.get_frames_drawn() % 60 == 0:
		var info_text = "性能测试场景\n"
		info_text += "总敌人数: %d\n" % total_enemies
		
		# 性能统计
		var stats = perf_monitor.get_stats()
		info_text += "\n性能数据:\n"
		info_text += "  平均 FPS: %.1f\n" % stats["avg_fps"]
		info_text += "  最低 FPS: %.1f\n" % stats["min_fps"]
		info_text += "  最高 FPS: %.1f\n" % stats["max_fps"]
		info_text += "  帧时间: %.2f ms\n" % stats["frame_time_ms"]
		info_text += "  内存: %.1f MB\n" % stats["memory_mb"]
		
		# 对象池统计
		info_text += "\n对象池状态:\n"
		for enemy_id in enemy_counts:
			var pool_name = "enemy_" + enemy_id
			var pool_size = ObjectPool.get_pool_size(pool_name)
			var available = ObjectPool.get_available_count(pool_name)
			info_text += "  %s: 池=%d, 可用=%d\n" % [enemy_id.substr(6, 10), pool_size, available]
		
		info_label.text = info_text

func _input(event):
	# 按 ESC 退出并打印总结
	if event.is_action_pressed("ui_cancel"):
		perf_monitor.print_summary()
		get_tree().quit()
