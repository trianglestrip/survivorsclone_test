extends SceneTree

## 综合系统测试
## 验证所有6个阶段的系统集成

const GameConstants = preload("res://Utility/game_constants.gd")

var test_results = []

func _init():
	print("\n============================================================")
	print("暖雪改造计划 - 综合系统测试")
	print("============================================================\n")
	
	await _run_all_tests()
	
	print("\n============================================================")
	print("综合测试完成")
	print("============================================================")
	_print_final_summary()
	
	quit()

func _run_all_tests():
	print("【阶段1】操作控制系统")
	await _test_stage1()
	
	print("\n【阶段2】宗派系统")
	await _test_stage2()
	
	print("\n【阶段3】武器系统")
	await _test_stage3()
	
	print("\n【阶段4】圣物系统")
	await _test_stage4()
	
	print("\n【阶段5】敌人系统")
	await _test_stage5()
	
	print("\n【阶段6】关卡系统")
	await _test_stage6()

func _test_stage1():
	var world_scene = load("res://World/world.tscn").instantiate()
	root.add_child(world_scene)
	
	for i in range(20):
		await process_frame
	
	var player = world_scene.get_node_or_null("Player")
	
	if player and player.input_mgr and player.dash_mgr:
		_log_result("阶段1", true, "操作控制系统正常")
	else:
		_log_result("阶段1", false, "操作控制系统异常")
	
	world_scene.queue_free()
	for i in range(10):
		await process_frame

func _test_stage2():
	var world_scene = load("res://World/world.tscn").instantiate()
	root.add_child(world_scene)
	
	for i in range(20):
		await process_frame
	
	var player = world_scene.get_node_or_null("Player")
	
	if player and player.sect_mgr and player.active_skill_mgr:
		var has_sect = player.sect_mgr.has_selected_sect()
		_log_result("阶段2", has_sect, "宗派系统正常（已选择宗派）")
	else:
		_log_result("阶段2", false, "宗派系统异常")
	
	world_scene.queue_free()
	for i in range(10):
		await process_frame

func _test_stage3():
	var world_scene = load("res://World/world.tscn").instantiate()
	root.add_child(world_scene)
	
	for i in range(20):
		await process_frame
	
	var player = world_scene.get_node_or_null("Player")
	
	if player and player.weapon_registry:
		var weapon = player.weapon_registry.get_current_weapon()
		_log_result("阶段3", not weapon.is_empty(), "武器系统正常（已装备武器）")
	else:
		_log_result("阶段3", false, "武器系统异常")
	
	world_scene.queue_free()
	for i in range(10):
		await process_frame

func _test_stage4():
	var world_scene = load("res://World/world.tscn").instantiate()
	root.add_child(world_scene)
	
	for i in range(20):
		await process_frame
	
	var player = world_scene.get_node_or_null("Player")
	
	if player and player.relic_mgr:
		var relic_registry = _find_relic_registry(player)
		_log_result("阶段4", relic_registry != null, "圣物系统正常")
	else:
		_log_result("阶段4", false, "圣物系统异常")
	
	world_scene.queue_free()
	for i in range(10):
		await process_frame

func _test_stage5():
	var enemy_registry = Node.new()
	var script = load("res://Utility/enemy_registry.gd")
	enemy_registry.set_script(script)
	root.add_child(enemy_registry)
	
	for i in range(10):
		await process_frame
	
	var enemy_count = enemy_registry.enemies.size()
	var wave_count = enemy_registry.spawn_waves.size()
	
	_log_result("阶段5", enemy_count >= 7 and wave_count >= 6, "敌人系统正常（%d类型，%d波次）" % [enemy_count, wave_count])
	
	enemy_registry.queue_free()
	for i in range(10):
		await process_frame

func _test_stage6():
	var level_manager = Node.new()
	var script = load("res://Utility/level_manager.gd")
	level_manager.set_script(script)
	root.add_child(level_manager)
	
	for i in range(10):
		await process_frame
	
	var level_count = level_manager.levels.size()
	var boss_count = level_manager.bosses.size()
	
	_log_result("阶段6", level_count >= 2 and boss_count >= 2, "关卡系统正常（%d关卡，%dBoss）" % [level_count, boss_count])
	
	level_manager.queue_free()
	for i in range(10):
		await process_frame

func _find_relic_registry(player: Node) -> Node:
	for child in player.get_children():
		if child.has_method("get_relic"):
			return child
	return null

func _log_result(stage: String, passed: bool, message: String = ""):
	test_results.append({
		"stage": stage,
		"passed": passed,
		"message": message
	})
	var status = "✅" if passed else "❌"
	print("  %s %s: %s" % [status, stage, message])

func _print_final_summary():
	var passed = 0
	var failed = 0
	
	for result in test_results:
		if result.passed:
			passed += 1
		else:
			failed += 1
	
	var total = passed + failed
	var pass_rate = (float(passed) / total * 100.0) if total > 0 else 0.0
	
	print("\n============================================================")
	print("最终结果")
	print("============================================================")
	print("总阶段: %d" % total)
	print("通过: %d" % passed)
	print("失败: %d" % failed)
	print("通过率: %.1f%%" % pass_rate)
	
	if pass_rate == 100.0:
		print("\n✅ 所有系统集成测试通过！暖雪改造计划成功完成！")
	else:
		print("\n⚠️ 部分系统需要修复")
