extends Node2D

# GPU 实例化性能测试 - 使用 MultiMesh 渲染大量敌人

@onready var enemy_container = $EnemyContainer
@onready var info_label = $CanvasLayer/InfoLabel
@onready var camera = $Camera2D
@onready var perf_monitor = $PerformanceMonitor
@onready var player = $Player

# 每种敌人生成数量
var enemies_per_type = 100  # 5 种 x 100 = 500

# 敌人实例管理器
var enemy_manager = null

# 统计
var total_enemies = 0

func _ready():
	print("\n=== GPU 实例化性能测试 ===")
	print("每种敌人: %d 个" % enemies_per_type)
	print("提示: 按 ESC 退出并查看性能总结\n")
	
	# 等待注册系统初始化
	await get_tree().process_frame
	
	# 加载并初始化敌人管理器
	var manager_script = load("res://Utility/enemy_instance_manager.gd")
	enemy_manager = manager_script.new()
	enemy_manager.set_container(enemy_container)
	enemy_manager.set_player(player)
	add_child(enemy_manager)
	
	# 等待管理器初始化
	await get_tree().process_frame
	await get_tree().process_frame
	
	_spawn_enemies()
	_update_info()
	
	print("场景运行中... 按 ESC 退出")

func _spawn_enemies():
	print("\n直接生成 500 个敌人...")
	
	var enemy_types = EnemyRegistry.get_all_enemy_ids()
	var spawn_positions = []
	
	# 预先计算所有生成位置
	for enemy_type in enemy_types:
		for i in range(enemies_per_type):
			var angle = randf() * TAU
			var distance = randf_range(100, 500)
			var pos = camera.global_position + Vector2(cos(angle), sin(angle)) * distance
			spawn_positions.append({"type": enemy_type, "pos": pos})
	
	# 批量生成（一次性）
	for spawn_data in spawn_positions:
		enemy_manager.spawn_enemy(spawn_data["type"], spawn_data["pos"])
		total_enemies += 1
	
	print("  ✓ 已生成 %d 个敌人（所有类型）" % total_enemies)
	print("=== 场景就绪 ===\n")

func _update_info():
	var info_text = "GPU 实例化测试\n"
	info_text += "总敌人数: %d\n" % total_enemies
	info_text += "渲染方式: MultiMesh\n"
	info_label.text = info_text

func _process(_delta):
	# 每秒更新一次
	if Engine.get_frames_drawn() % 60 == 0:
		var stats = perf_monitor.get_stats()
		var enemy_stats = enemy_manager.get_stats() if enemy_manager else {}
		
		var info_text = "GPU 实例化测试\n"
		info_text += "总敌人数: %d\n" % total_enemies
		info_text += "渲染方式: MultiMesh (GPU)\n"
		info_text += "\n性能数据:\n"
		info_text += "  平均 FPS: %.1f\n" % stats.get("avg_fps", 0)
		info_text += "  最低 FPS: %.1f\n" % stats.get("min_fps", 0)
		info_text += "  最高 FPS: %.1f\n" % stats.get("max_fps", 0)
		info_text += "  帧时间: %.2f ms\n" % stats.get("frame_time_ms", 0)
		info_text += "  内存: %.1f MB\n" % stats.get("memory_mb", 0)
		
		if enemy_stats.has("total_active"):
			info_text += "\n敌人状态:\n"
			info_text += "  活跃: %d\n" % enemy_stats["total_active"]
			info_text += "  池化: %d\n" % enemy_stats["total_pooled"]
		
		info_label.text = info_text

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		perf_monitor.print_summary()
		if enemy_manager:
			var stats = enemy_manager.get_stats()
			print("\n=== 敌人统计 ===")
			print("活跃敌人: %d" % stats["total_active"])
			print("池化敌人: %d" % stats["total_pooled"])
			print("================\n")
		get_tree().quit()
