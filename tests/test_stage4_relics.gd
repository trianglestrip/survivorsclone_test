extends SceneTree

## 阶段4圣物系统测试

const GameConstants = preload("res://Utility/game_constants.gd")

var test_results = []
var world_scene = null
var player = null

func _init():
	print("\n========================================")
	print("阶段4：圣物系统测试")
	print("========================================\n")
	
	await _run_tests()
	
	print("\n========================================")
	print("测试完成")
	print("========================================")
	_print_summary()
	
	quit()

func _run_tests():
	await _test_relic_registry_init()
	await _test_relic_acquisition()
	await _test_relic_stat_bonuses()
	await _test_relic_drop()

## 测试1: 圣物注册表初始化
func _test_relic_registry_init():
	print("\n[测试1] 圣物注册表初始化")
	
	await _setup_world()
	
	if not player:
		_log_result("测试1", false, "Player不存在")
		return
	
	var relic_registry = _get_relic_registry()
	if not relic_registry:
		_log_result("测试1", false, "RelicRegistry不存在")
		_cleanup_world()
		return
	
	var relic_count = relic_registry.relics.size()
	print("  圣物数量: ", relic_count)
	
	if relic_count >= 8:
		_log_result("测试1", true, "圣物注册表初始化成功 (%d个圣物)" % relic_count)
	else:
		_log_result("测试1", false, "圣物配置不足")
	
	_cleanup_world()

## 测试2: 圣物获取
func _test_relic_acquisition():
	print("\n[测试2] 圣物获取")
	
	await _setup_world()
	
	if not player or not player.relic_mgr:
		_log_result("测试2", false, "RelicManager不存在")
		return
	
	var relic_registry = _get_relic_registry()
	if not relic_registry:
		_log_result("测试2", false, "RelicRegistry不存在")
		_cleanup_world()
		return
	
	var initial_count = relic_registry.owned_relics.size()
	print("  初始圣物数: ", initial_count)
	
	# 获得圣物
	player.relic_mgr.acquire_relic("white_tiger")
	
	for i in range(10):
		await process_frame
	
	var final_count = relic_registry.owned_relics.size()
	print("  获得后圣物数: ", final_count)
	
	if final_count > initial_count:
		_log_result("测试2", true, "圣物获取成功")
	else:
		_log_result("测试2", false, "圣物未添加")
	
	_cleanup_world()

## 测试3: 圣物属性加成
func _test_relic_stat_bonuses():
	print("\n[测试3] 圣物属性加成")
	
	await _setup_world()
	
	if not player or not player.relic_mgr:
		_log_result("测试3", false, "RelicManager不存在")
		return
	
	var initial_hp = player.stats.maxhp
	var initial_speed = player.stats.movement_speed
	
	print("  初始最大HP: ", initial_hp)
	print("  初始移动速度: ", initial_speed)
	
	# 获得圣物（应该提升属性）
	player.relic_mgr.acquire_relic("black_tortoise")  # 玄武之魂：+30 HP
	
	for i in range(10):
		await process_frame
	
	var final_hp = player.stats.maxhp
	var final_speed = player.stats.movement_speed
	
	print("  获得圣物后最大HP: ", final_hp)
	print("  获得圣物后移动速度: ", final_speed)
	
	if final_hp > initial_hp:
		_log_result("测试3", true, "圣物属性加成生效 (HP: %d -> %d)" % [initial_hp, final_hp])
	else:
		_log_result("测试3", false, "圣物属性加成未生效")
	
	_cleanup_world()

## 测试4: 圣物掉落
func _test_relic_drop():
	print("\n[测试4] 圣物掉落物")
	
	await _setup_world()
	
	if not player:
		_log_result("测试4", false, "Player不存在")
		return
	
	# 创建圣物掉落
	var relic_drop_script = load("res://Objects/relic_drop.gd")
	var relic_drop = Area2D.new()
	relic_drop.set_script(relic_drop_script)
	relic_drop.global_position = player.global_position + Vector2(100, 0)
	
	var world = player.get_parent()
	world.call_deferred("add_child", relic_drop)
	
	await relic_drop.tree_entered
	relic_drop.setup("ice_heart", "冰心")
	
	for i in range(10):
		await process_frame
	
	var initial_relic_count = _get_owned_relic_count()
	print("  初始圣物数: ", initial_relic_count)
	
	# 等待圣物吸引到玩家
	print("  圣物位置: ", relic_drop.global_position)
	print("  玩家位置: ", player.global_position)
	
	for i in range(120):
		await process_frame
		if i % 20 == 0 and is_instance_valid(relic_drop):
			print("  %.1fs 圣物距离: %.1f" % [i * 0.0167, relic_drop.global_position.distance_to(player.global_position)])
		if not is_instance_valid(relic_drop):
			print("  圣物已被拾取")
			break
	
	var final_relic_count = _get_owned_relic_count()
	print("  拾取后圣物数: ", final_relic_count)
	
	if final_relic_count > initial_relic_count:
		_log_result("测试4", true, "圣物掉落和拾取成功")
	else:
		_log_result("测试4", false, "圣物未被拾取")
	
	_cleanup_world()

## 辅助函数

func _setup_world():
	world_scene = load("res://World/world.tscn").instantiate()
	root.add_child(world_scene)
	
	for i in range(20):
		await process_frame
	
	player = world_scene.get_node_or_null("Player")

func _get_relic_registry() -> Node:
	if not player:
		return null
	
	# RelicRegistry是player的子节点
	for child in player.get_children():
		if child.get_script() and child.get_script().get_global_name() == "":
			# 检查是否有relics属性
			if child.has_method("get_relic"):
				return child
	return null

func _get_owned_relic_count() -> int:
	var relic_registry = _get_relic_registry()
	if relic_registry:
		return relic_registry.owned_relics.size()
	return 0

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
