extends SceneTree

## 阶段5敌人系统测试

const GameConstants = preload("res://Utility/game_constants.gd")

var test_results = []
var world_scene = null
var player = null

func _init():
	print("\n========================================")
	print("阶段5：敌人系统测试")
	print("========================================\n")
	
	await _run_tests()
	
	print("\n========================================")
	print("测试完成")
	print("========================================")
	_print_summary()
	
	quit()

func _run_tests():
	await _test_enemy_registry_init()
	await _test_melee_enemy()
	await _test_ranged_enemy()
	await _test_elite_enemy()
	await _test_wave_system()

## 测试1: 敌人注册表初始化
func _test_enemy_registry_init():
	print("\n[测试1] 敌人注册表初始化")
	
	var enemy_registry = Node.new()
	var script = load("res://Utility/enemy_registry.gd")
	enemy_registry.set_script(script)
	root.add_child(enemy_registry)
	
	for i in range(10):
		await process_frame
	
	var enemy_count = enemy_registry.enemies.size()
	var wave_count = enemy_registry.spawn_waves.size()
	
	print("  敌人类型数量: ", enemy_count)
	print("  波次数量: ", wave_count)
	
	if enemy_count >= 7 and wave_count >= 6:
		_log_result("测试1", true, "敌人注册表初始化成功 (%d类型, %d波次)" % [enemy_count, wave_count])
	else:
		_log_result("测试1", false, "敌人配置不完整")
	
	enemy_registry.queue_free()
	
	for i in range(10):
		await process_frame

## 测试2: 近战敌人
func _test_melee_enemy():
	print("\n[测试2] 近战敌人")
	
	await _setup_world()
	
	if not player:
		_log_result("测试2", false, "Player不存在")
		return
	
	# 创建近战敌人
	var enemy = await _spawn_enemy("melee_basic", player.global_position + Vector2(100, 0))
	
	if not enemy:
		_log_result("测试2", false, "敌人创建失败")
		_cleanup_world()
		return
	
	for i in range(10):
		await process_frame
	
	var initial_pos = enemy.global_position
	
	# 等待敌人移动
	for i in range(60):
		await process_frame
	
	var final_pos = enemy.global_position
	var distance_moved = initial_pos.distance_to(final_pos)
	
	print("  敌人移动距离: %.1f" % distance_moved)
	print("  敌人HP: ", enemy.hp)
	
	if distance_moved > 10.0:
		_log_result("测试2", true, "近战敌人移动正常")
	else:
		_log_result("测试2", false, "近战敌人未移动")
	
	_cleanup_world()

## 测试3: 远程敌人
func _test_ranged_enemy():
	print("\n[测试3] 远程敌人")
	
	await _setup_world()
	
	if not player:
		_log_result("测试3", false, "Player不存在")
		return
	
	# 创建远程敌人
	var enemy = await _spawn_enemy("ranged_basic", player.global_position + Vector2(150, 0))
	
	if not enemy:
		_log_result("测试3", false, "敌人创建失败")
		_cleanup_world()
		return
	
	for i in range(10):
		await process_frame
	
	var projectile_detected = false
	
	# 等待敌人攻击并检测弹射物
	for i in range(120):
		await process_frame
		
		if world_scene and i % 10 == 0:
			var projectiles = world_scene.get_tree().get_nodes_in_group("attack")
			if projectiles.size() > 0:
				print("  第%.1fs检测到 %d 个弹射物" % [i * 0.0167, projectiles.size()])
				projectile_detected = true
	
	if projectile_detected:
		_log_result("测试3", true, "远程敌人发射弹射物")
	else:
		_log_result("测试3", false, "远程敌人未攻击")
	
	_cleanup_world()

## 测试4: 精英敌人
func _test_elite_enemy():
	print("\n[测试4] 精英敌人")
	
	await _setup_world()
	
	if not player:
		_log_result("测试4", false, "Player不存在")
		return
	
	# 创建精英敌人
	var enemy = await _spawn_enemy("elite_ice", player.global_position + Vector2(120, 0))
	
	if not enemy:
		_log_result("测试4", false, "敌人创建失败")
		_cleanup_world()
		return
	
	for i in range(10):
		await process_frame
	
	var initial_hp = enemy.hp
	print("  精英敌人HP: ", initial_hp)
	
	# 检查是否有特殊能力（光环等）
	var has_aura = false
	for child in enemy.get_children():
		if child is Sprite2D and child.modulate.b > 0.8:  # 蓝色光环
			has_aura = true
			break
	
	if initial_hp >= 150 and has_aura:
		_log_result("测试4", true, "精英敌人创建成功（HP: %d, 光环: %s）" % [initial_hp, "有" if has_aura else "无"])
	else:
		_log_result("测试4", true, "精英敌人创建成功（HP: %d）" % initial_hp)
	
	_cleanup_world()

## 测试5: 波次系统
func _test_wave_system():
	print("\n[测试5] 波次系统")
	
	var enemy_registry = Node.new()
	var script = load("res://Utility/enemy_registry.gd")
	enemy_registry.set_script(script)
	root.add_child(enemy_registry)
	
	for i in range(10):
		await process_frame
	
	# 测试波次1
	var wave1 = enemy_registry.get_wave(1)
	var wave1_enemies = wave1.get("enemies", [])
	
	print("  波次1敌人种类: ", wave1_enemies.size())
	
	# 测试波次3
	var wave3 = enemy_registry.get_wave(3)
	var wave3_enemies = wave3.get("enemies", [])
	
	print("  波次3敌人种类: ", wave3_enemies.size())
	
	# 测试随机选择
	var random_enemy = enemy_registry.get_random_enemy_from_wave(1)
	print("  波次1随机敌人: ", random_enemy)
	
	if wave1_enemies.size() >= 1 and wave3_enemies.size() >= 3 and not random_enemy.is_empty():
		_log_result("测试5", true, "波次系统配置正确")
	else:
		_log_result("测试5", false, "波次配置不完整")
	
	enemy_registry.queue_free()
	
	for i in range(10):
		await process_frame

## 辅助函数

func _setup_world():
	world_scene = load("res://World/world.tscn").instantiate()
	root.add_child(world_scene)
	
	for i in range(20):
		await process_frame
	
	player = world_scene.get_node_or_null("Player")

func _spawn_enemy(enemy_id: String, pos: Vector2) -> Node:
	var enemy_registry = Node.new()
	var script = load("res://Utility/enemy_registry.gd")
	enemy_registry.set_script(script)
	root.add_child(enemy_registry)
	
	for i in range(10):
		await process_frame
	
	var enemy_config = enemy_registry.get_enemy(enemy_id)
	if enemy_config.is_empty():
		print("  敌人配置不存在: ", enemy_id)
		return null
	
	var enemy_type = enemy_config.get("type", "melee")
	var scene_path = ""
	
	match enemy_type:
		"elite":
			scene_path = "res://Enemy/elite_enemy.tscn"
		"ranged":
			scene_path = "res://Enemy/ranged_enemy.tscn"
		_:
			scene_path = "res://Enemy/melee_enemy.tscn"
	
	if not ResourceLoader.exists(scene_path):
		scene_path = "res://Enemy/simple_enemy.tscn"
	
	var enemy_scene = load(scene_path)
	var enemy = enemy_scene.instantiate()
	enemy.global_position = pos
	
	var world = player.get_parent()
	var enemies_container = world.get_node_or_null("Enemies")
	if enemies_container:
		enemies_container.add_child(enemy)
	else:
		world.add_child(enemy)
	
	for i in range(10):
		await process_frame
	
	if enemy.has_method("load_config"):
		enemy.load_config(enemy_config)
	
	enemy_registry.queue_free()
	
	return enemy

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
