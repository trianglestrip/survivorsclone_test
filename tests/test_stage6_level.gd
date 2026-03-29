extends SceneTree

## 阶段6关卡系统测试

const GameConstants = preload("res://Utility/game_constants.gd")

var test_results = []
var level_manager = null

func _init():
	print("\n========================================")
	print("阶段6：关卡系统测试")
	print("========================================\n")
	
	await _run_tests()
	
	print("\n========================================")
	print("测试完成")
	print("========================================")
	_print_summary()
	
	quit()

func _run_tests():
	await _test_level_manager_init()
	await _test_level_data()
	await _test_boss_data()
	await _test_room_progression()
	await _test_boss_creation()

## 测试1: 关卡管理器初始化
func _test_level_manager_init():
	print("\n[测试1] 关卡管理器初始化")
	
	level_manager = Node.new()
	var script = load("res://Utility/level_manager.gd")
	level_manager.set_script(script)
	root.add_child(level_manager)
	
	for i in range(10):
		await process_frame
	
	var level_count = level_manager.levels.size()
	var boss_count = level_manager.bosses.size()
	
	print("  关卡数量: ", level_count)
	print("  Boss数量: ", boss_count)
	
	if level_count >= 2 and boss_count >= 2:
		_log_result("测试1", true, "关卡管理器初始化成功 (%d关卡, %dBoss)" % [level_count, boss_count])
	else:
		_log_result("测试1", false, "关卡配置不完整")
	
	_cleanup_level_manager()

## 测试2: 关卡数据
func _test_level_data():
	print("\n[测试2] 关卡数据")
	
	level_manager = Node.new()
	var script = load("res://Utility/level_manager.gd")
	level_manager.set_script(script)
	root.add_child(level_manager)
	
	for i in range(10):
		await process_frame
	
	var level1 = level_manager.get_level("level_1")
	
	if level1.is_empty():
		_log_result("测试2", false, "关卡1数据不存在")
		_cleanup_level_manager()
		return
	
	var level_name = level1.get("name", "")
	var rooms = level1.get("rooms", [])
	
	print("  关卡名称: ", level_name)
	print("  房间数量: ", rooms.size())
	
	if rooms.size() >= 3:
		_log_result("测试2", true, "关卡数据配置正确 (%d个房间)" % rooms.size())
	else:
		_log_result("测试2", false, "房间配置不足")
	
	_cleanup_level_manager()

## 测试3: Boss数据
func _test_boss_data():
	print("\n[测试3] Boss数据")
	
	level_manager = Node.new()
	var script = load("res://Utility/level_manager.gd")
	level_manager.set_script(script)
	root.add_child(level_manager)
	
	for i in range(10):
		await process_frame
	
	var boss = level_manager.get_boss("frost_lord")
	
	if boss.is_empty():
		_log_result("测试3", false, "Boss数据不存在")
		_cleanup_level_manager()
		return
	
	var boss_name = boss.get("name", "")
	var boss_hp = boss.get("hp", 0)
	var phases = boss.get("phases", [])
	
	print("  Boss名称: ", boss_name)
	print("  Boss HP: ", boss_hp)
	print("  阶段数: ", phases.size())
	
	if boss_hp >= 500 and phases.size() >= 2:
		_log_result("测试3", true, "Boss数据配置正确 (HP: %d, %d阶段)" % [boss_hp, phases.size()])
	else:
		_log_result("测试3", false, "Boss配置不完整")
	
	_cleanup_level_manager()

## 测试4: 房间进度
func _test_room_progression():
	print("\n[测试4] 房间进度")
	
	level_manager = Node.new()
	var script = load("res://Utility/level_manager.gd")
	level_manager.set_script(script)
	root.add_child(level_manager)
	
	for i in range(10):
		await process_frame
	
	# 开始关卡1
	var success = level_manager.start_level("level_1")
	
	if not success:
		_log_result("测试4", false, "关卡启动失败")
		_cleanup_level_manager()
		return
	
	for i in range(10):
		await process_frame
	
	var current_room = level_manager.get_current_room()
	var room_name = current_room.get("name", "")
	
	print("  当前房间: ", room_name)
	print("  房间索引: ", level_manager.current_room_index)
	
	if level_manager.current_room_index == 0 and not room_name.is_empty():
		_log_result("测试4", true, "房间进度系统正常")
	else:
		_log_result("测试4", false, "房间进度异常")
	
	_cleanup_level_manager()

## 测试5: Boss创建
func _test_boss_creation():
	print("\n[测试5] Boss创建")
	
	var world_scene = load("res://World/world.tscn").instantiate()
	root.add_child(world_scene)
	
	for i in range(20):
		await process_frame
	
	var player = world_scene.get_node_or_null("Player")
	
	if not player:
		_log_result("测试5", false, "Player不存在")
		world_scene.queue_free()
		return
	
	# 创建Boss
	var boss = await _spawn_boss("frost_lord", player.global_position + Vector2(200, 0), world_scene)
	
	if not boss:
		_log_result("测试5", false, "Boss创建失败")
		world_scene.queue_free()
		return
	
	for i in range(10):
		await process_frame
	
	var boss_hp = boss.hp
	var boss_max_hp = boss.max_hp
	
	print("  Boss HP: %d/%d" % [boss_hp, boss_max_hp])
	
	if boss_hp >= 500:
		_log_result("测试5", true, "Boss创建成功 (HP: %d)" % boss_hp)
	else:
		_log_result("测试5", false, "Boss HP不正确")
	
	world_scene.queue_free()
	
	for i in range(10):
		await process_frame

## 辅助函数

func _spawn_boss(boss_id: String, pos: Vector2, world: Node) -> Node:
	level_manager = Node.new()
	var script = load("res://Utility/level_manager.gd")
	level_manager.set_script(script)
	root.add_child(level_manager)
	
	for i in range(10):
		await process_frame
	
	var boss_config = level_manager.get_boss(boss_id)
	if boss_config.is_empty():
		print("  Boss配置不存在: ", boss_id)
		return null
	
	var boss_scene = load("res://Enemy/boss_enemy.tscn")
	var boss = boss_scene.instantiate()
	boss.global_position = pos
	
	var enemies_container = world.get_node_or_null("Enemies")
	if enemies_container:
		enemies_container.add_child(boss)
	else:
		world.add_child(boss)
	
	for i in range(10):
		await process_frame
	
	if boss.has_method("load_config"):
		boss.load_config(boss_config)
	
	return boss

func _cleanup_level_manager():
	if level_manager:
		level_manager.queue_free()
		level_manager = null
	
	for i in range(10):
		await process_frame

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
