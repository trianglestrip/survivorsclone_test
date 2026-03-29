extends SceneTree

## 测试敌人生成和技能特效清理

const GameConstants = preload("res://Utility/game_constants.gd")

var test_results = []
var world_scene = null
var player = null

func _init():
	print("\n========================================")
	print("敌人生成和特效清理测试")
	print("========================================\n")
	
	await _run_tests()
	
	print("\n========================================")
	print("测试完成")
	print("========================================")
	_print_summary()
	
	quit()

func _run_tests():
	await _test_enemy_spawning()
	await _test_q_skill_effect_cleanup()
	await _test_q_skill_with_enemies()

## 测试1: 敌人生成器初始化
func _test_enemy_spawning():
	print("\n[测试1] 敌人生成器初始化")
	
	world_scene = load("res://World/world.tscn").instantiate()
	root.add_child(world_scene)
	
	# 等待初始化
	for i in range(10):
		await process_frame
	
	player = world_scene.get_node_or_null("Player")
	var spawner = world_scene.get_node_or_null("EnemySpawner")
	
	if not spawner:
		_log_result("测试1", false, "找不到EnemySpawner节点")
		return
	
	print("  EnemySpawner配置:")
	print("    spawn_interval: ", spawner.spawn_interval)
	print("    max_enemies: ", spawner.max_enemies)
	print("    spawn_distance: ", spawner.spawn_distance)
	
	_log_result("测试1", true, "EnemySpawner初始化成功")

## 测试2: Q技能特效清理（无敌人）
func _test_q_skill_effect_cleanup():
	print("\n[测试2] Q技能特效清理（无敌人，测试弹射物清理）")
	
	if not player:
		_log_result("测试2", false, "玩家节点不存在")
		return
	
	# 获取初始子节点数量
	var world = player.get_parent()
	var initial_child_count = world.get_child_count()
	print("  初始世界子节点数: ", initial_child_count)
	
	# 模拟按下Q键
	Input.action_press("skill_q")
	for i in range(5):
		await process_frame
	Input.action_release("skill_q")
	
	# 等待技能释放
	for i in range(10):
		await process_frame
	
	var after_cast_count = world.get_child_count()
	print("  释放Q技能后子节点数: ", after_cast_count)
	
	# 等待弹射物飞行并自动清理（最多5秒）
	var max_wait_frames = 300
	var current_frame = 0
	var projectile_cleaned = false
	
	print("  等待弹射物清理...")
	while current_frame < max_wait_frames:
		await process_frame
		current_frame += 1
		
		var current_count = world.get_child_count()
		if current_count <= initial_child_count + 1:
			projectile_cleaned = true
			print("  弹射物已清理，当前子节点数: ", current_count)
			break
		
		if current_frame % 60 == 0:
			print("  等待中... 当前子节点数: ", current_count)
	
	if projectile_cleaned:
		_log_result("测试2", true, "Q技能弹射物正确清理")
	else:
		var final_count = world.get_child_count()
		_log_result("测试2", false, "弹射物未清理，最终子节点数: %d (初始: %d)" % [final_count, initial_child_count])

## 测试3: Q技能命中敌人后的特效清理
func _test_q_skill_with_enemies():
	print("\n[测试3] Q技能命中敌人特效清理")
	
	if not player:
		_log_result("测试3", false, "玩家节点不存在")
		return
	
	var world = player.get_parent()
	
	# 手动生成一个敌人在玩家附近
	var enemy_scene = load("res://Enemy/simple_enemy.tscn")
	var enemy = enemy_scene.instantiate()
	enemy.global_position = player.global_position + Vector2(100, 0)
	
	var enemies_container = world.get_node_or_null("Enemies")
	if enemies_container:
		enemies_container.add_child(enemy)
	else:
		world.add_child(enemy)
	
	print("  已生成测试敌人于: ", enemy.global_position)
	
	# 等待敌人初始化
	for i in range(10):
		await process_frame
	
	var initial_child_count = world.get_child_count()
	print("  初始世界子节点数: ", initial_child_count)
	
	# 释放Q技能
	Input.action_press("skill_q")
	for i in range(5):
		await process_frame
	Input.action_release("skill_q")
	
	# 等待技能命中
	for i in range(60):
		await process_frame
	
	var after_hit_count = world.get_child_count()
	print("  命中后子节点数: ", after_hit_count)
	
	# 等待命中特效清理（最多3秒）
	var max_wait_frames = 180
	var current_frame = 0
	var effect_cleaned = false
	
	print("  等待命中特效清理...")
	while current_frame < max_wait_frames:
		await process_frame
		current_frame += 1
		
		var current_count = world.get_child_count()
		if current_count <= initial_child_count:
			effect_cleaned = true
			print("  命中特效已清理，当前子节点数: ", current_count)
			break
		
		if current_frame % 60 == 0:
			print("  等待中... 当前子节点数: ", current_count)
	
	if effect_cleaned:
		_log_result("测试3", true, "Q技能命中特效正确清理")
	else:
		var final_count = world.get_child_count()
		_log_result("测试3", false, "命中特效未清理，最终子节点数: %d (初始: %d)" % [final_count, initial_child_count])

func _log_result(test_name: String, passed: bool, message: String = ""):
	test_results.append({
		"test": test_name,
		"passed": passed,
		"message": message
	})
	var status = "✓ 通过" if passed else "✗ 失败"
	print("  %s: %s" % [status, message if message else test_name])

func _print_summary():
	var passed = 0
	var failed = 0
	
	for result in test_results:
		if result.passed:
			passed += 1
		else:
			failed += 1
	
	var total = passed + failed
	var pass_rate = (float(passed) / total * 100.0) if total > 0 else 0.0
	
	print("\n总计: %d 个测试" % total)
	print("通过: %d" % passed)
	print("失败: %d" % failed)
	print("通过率: %.1f%%" % pass_rate)
