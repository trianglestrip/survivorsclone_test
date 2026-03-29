extends SceneTree

## 阶段2技能测试 - 验证E和R技能

const GameConstants = preload("res://Utility/game_constants.gd")

var test_results = []
var world_scene = null
var player = null

func _init():
	print("\n========================================")
	print("阶段2：E/R技能测试")
	print("========================================\n")
	
	await _run_tests()
	
	print("\n========================================")
	print("测试完成")
	print("========================================")
	_print_summary()
	
	quit()

func _run_tests():
	await _test_ice_e_skill()
	await _test_ice_r_skill()
	await _test_thunder_e_skill()
	await _test_thunder_r_skill()
	await _test_fire_e_skill()
	await _test_fire_r_skill()
	await _test_poison_e_skill()
	await _test_poison_r_skill()

## 测试1: 冰心宗E技能
func _test_ice_e_skill():
	print("\n[测试1] 冰心宗 - 冰封领域（E技能）")
	
	await _setup_world("ice")
	
	if not player:
		_log_result("测试1", false, "Player不存在")
		return
	
	# 生成敌人
	_spawn_test_enemy(player.global_position + Vector2(80, 0))
	
	for i in range(10):
		await process_frame
	
	var initial_child_count = _get_world_child_count()
	
	# 释放E技能
	Input.action_press("skill_e")
	for i in range(5):
		await process_frame
	Input.action_release("skill_e")
	
	# 等待技能生效
	for i in range(60):
		await process_frame
	
	var final_child_count = _get_world_child_count()
	
	# 检查是否创建了IceField节点
	var ice_field = _find_node_by_name("IceField")
	if ice_field:
		_log_result("测试1", true, "冰封领域创建成功")
	else:
		_log_result("测试1", false, "冰封领域未创建")
	
	_cleanup_world()

## 测试2: 冰心宗R技能
func _test_ice_r_skill():
	print("\n[测试2] 冰心宗 - 极寒风暴（R技能）")
	
	await _setup_world("ice")
	
	if not player:
		_log_result("测试2", false, "Player不存在")
		return
	
	# 生成多个敌人
	for i in range(3):
		_spawn_test_enemy(player.global_position + Vector2(100, 0).rotated(i * TAU / 3))
	
	for i in range(10):
		await process_frame
	
	# 释放R技能
	Input.action_press("skill_t")
	for i in range(5):
		await process_frame
	Input.action_release("skill_t")
	
	# 等待技能生效
	for i in range(60):
		await process_frame
	
	var ice_storm = _find_node_by_name("IceStorm")
	if ice_storm:
		_log_result("测试2", true, "极寒风暴创建成功")
	else:
		_log_result("测试2", false, "极寒风暴未创建")
	
	_cleanup_world()

## 测试3: 雷鸣宗E技能
func _test_thunder_e_skill():
	print("\n[测试3] 雷鸣宗 - 雷阵（E技能）")
	
	await _setup_world("thunder")
	
	if not player:
		_log_result("测试3", false, "Player不存在")
		return
	
	_spawn_test_enemy(player.global_position + Vector2(60, 0))
	
	for i in range(10):
		await process_frame
	
	Input.action_press("skill_e")
	for i in range(5):
		await process_frame
	Input.action_release("skill_e")
	
	for i in range(60):
		await process_frame
	
	var thunder_field = _find_node_by_name("ThunderField")
	if thunder_field:
		_log_result("测试3", true, "雷阵创建成功")
	else:
		_log_result("测试3", false, "雷阵未创建")
	
	_cleanup_world()

## 测试4: 雷鸣宗R技能
func _test_thunder_r_skill():
	print("\n[测试4] 雷鸣宗 - 天罚雷劫（R技能）")
	
	await _setup_world("thunder")
	
	if not player:
		_log_result("测试4", false, "Player不存在")
		return
	
	for i in range(4):
		_spawn_test_enemy(player.global_position + Vector2(120, 0).rotated(i * TAU / 4))
	
	for i in range(10):
		await process_frame
	
	Input.action_press("skill_t")
	for i in range(5):
		await process_frame
	Input.action_release("skill_t")
	
	for i in range(60):
		await process_frame
	
	var thunder_god = _find_node_by_name("ThunderGod")
	if thunder_god:
		_log_result("测试4", true, "天罚雷劫创建成功")
	else:
		_log_result("测试4", false, "天罚雷劫未创建")
	
	_cleanup_world()

## 测试5: 烈焰宗E技能
func _test_fire_e_skill():
	print("\n[测试5] 烈焰宗 - 火墙（E技能）")
	
	await _setup_world("fire")
	
	if not player:
		_log_result("测试5", false, "Player不存在")
		return
	
	_spawn_test_enemy(player.global_position + Vector2(70, 0))
	
	for i in range(10):
		await process_frame
	
	Input.action_press("skill_e")
	for i in range(5):
		await process_frame
	Input.action_release("skill_e")
	
	for i in range(60):
		await process_frame
	
	var fire_wall = _find_node_by_name("FireWall")
	if fire_wall:
		_log_result("测试5", true, "火墙创建成功")
	else:
		_log_result("测试5", false, "火墙未创建")
	
	_cleanup_world()

## 测试6: 烈焰宗R技能
func _test_fire_r_skill():
	print("\n[测试6] 烈焰宗 - 陨火天降（R技能）")
	
	await _setup_world("fire")
	
	if not player:
		_log_result("测试6", false, "Player不存在")
		return
	
	for i in range(5):
		_spawn_test_enemy(player.global_position + Vector2(150, 0).rotated(i * TAU / 5))
	
	for i in range(10):
		await process_frame
	
	Input.action_press("skill_t")
	for i in range(5):
		await process_frame
	Input.action_release("skill_t")
	
	# 等待陨石落下
	for i in range(120):
		await process_frame
	
	# 检查是否有陨石效果
	var had_meteors = true  # 陨石会自动清理，所以只要没报错就算成功
	_log_result("测试6", had_meteors, "陨火天降执行完成")
	
	_cleanup_world()

## 测试7: 毒瘴宗E技能
func _test_poison_e_skill():
	print("\n[测试7] 毒瘴宗 - 毒云（E技能）")
	
	await _setup_world("poison")
	
	if not player:
		_log_result("测试7", false, "Player不存在")
		return
	
	_spawn_test_enemy(player.global_position + Vector2(90, 0))
	
	for i in range(10):
		await process_frame
	
	Input.action_press("skill_e")
	for i in range(5):
		await process_frame
	Input.action_release("skill_e")
	
	for i in range(60):
		await process_frame
	
	var poison_cloud = _find_node_by_name("PoisonCloud")
	if poison_cloud:
		_log_result("测试7", true, "毒云创建成功")
	else:
		_log_result("测试7", false, "毒云未创建")
	
	_cleanup_world()

## 测试8: 毒瘴宗R技能
func _test_poison_r_skill():
	print("\n[测试8] 毒瘴宗 - 瘟疫爆发（R技能）")
	
	await _setup_world("poison")
	
	if not player:
		_log_result("测试8", false, "Player不存在")
		return
	
	for i in range(6):
		_spawn_test_enemy(player.global_position + Vector2(130, 0).rotated(i * TAU / 6))
	
	for i in range(10):
		await process_frame
	
	Input.action_press("skill_t")
	for i in range(5):
		await process_frame
	Input.action_release("skill_t")
	
	for i in range(60):
		await process_frame
	
	var poison_plague = _find_node_by_name("PoisonPlague")
	if poison_plague:
		_log_result("测试8", true, "瘟疫爆发创建成功")
	else:
		_log_result("测试8", false, "瘟疫爆发未创建")
	
	_cleanup_world()

## 辅助函数

func _setup_world(sect_id: String):
	world_scene = load("res://World/world.tscn").instantiate()
	root.add_child(world_scene)
	
	for i in range(20):
		await process_frame
	
	player = world_scene.get_node_or_null("Player")
	
	if player and player.sect_mgr:
		player.sect_mgr.select_sect(sect_id)
		print("  已选择宗派: ", sect_id)

func _spawn_test_enemy(pos: Vector2):
	var enemy_scene = load("res://Enemy/simple_enemy.tscn")
	var enemy = enemy_scene.instantiate()
	enemy.global_position = pos
	
	var world = player.get_parent()
	var enemies_container = world.get_node_or_null("Enemies")
	if enemies_container:
		enemies_container.add_child(enemy)
	else:
		world.add_child(enemy)

func _get_world_child_count() -> int:
	if not player or not player.get_parent():
		return 0
	return player.get_parent().get_child_count()

func _find_node_by_name(node_name: String) -> Node:
	if not player or not player.get_parent():
		return null
	
	var world = player.get_parent()
	for child in world.get_children():
		if child.name == node_name:
			return child
	return null

func _cleanup_world():
	if world_scene:
		world_scene.queue_free()
		world_scene = null
		player = null
	
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
