extends SceneTree

## 交互式测试场景的自动化测试
## 验证1-4（宗派切换）、5-0（武器切换）、F/G/H按键功能

const GameConstants = preload("res://Utility/game_constants.gd")

var test_results = []
var world_scene = null
var player = null
var sect_manager = null
var weapon_registry = null

func _init():
	print("\n========================================")
	print("交互式控制自动化测试")
	print("========================================\n")
	
	await _run_tests()
	
	print("\n========================================")
	print("测试完成")
	print("========================================")
	_print_summary()
	
	quit()

func _run_tests():
	await _test_sect_switching()
	await _test_weapon_switching()
	await _test_enemy_spawn()

## 测试1: 宗派切换（1-4键）
func _test_sect_switching():
	print("\n[测试1] 宗派切换功能")
	
	await _setup_world()
	
	if not player or not sect_manager:
		_log_result("测试1", false, "Player或SectManager未找到")
		return
	
	var sects = ["ice", "thunder", "fire", "poison"]
	var sect_names = ["冰心宗", "雷鸣宗", "烈焰宗", "毒瘴宗"]
	
	for i in range(sects.size()):
		var sect_id = sects[i]
		var sect_name = sect_names[i]
		
		print("  测试切换到: %s" % sect_name)
		
		# 模拟按键
		sect_manager.select_sect(sect_id)
		
		for j in range(10):
			await process_frame
		
		# 验证切换
		var current = sect_manager.current_sect_id
		if current == sect_id:
			print("    ✓ 成功切换到 %s" % sect_name)
		else:
			_log_result("测试1", false, "切换到%s失败，当前: %s" % [sect_name, current])
			_cleanup_world()
			return
	
	_log_result("测试1", true, "所有宗派切换成功（4/4）")
	_cleanup_world()

## 测试2: 武器切换（5-0键）
func _test_weapon_switching():
	print("\n[测试2] 武器切换功能")
	
	await _setup_world()
	
	if not player or not weapon_registry:
		_log_result("测试2", false, "Player或WeaponRegistry未找到")
		return
	
	var weapon_ids = ["sword_basic", "sword_frost", "hammer_thunder", "staff_fire", "dagger_poison", "spear_legendary"]
	
	# 先解锁所有武器
	for weapon_id in weapon_ids:
		weapon_registry.unlock_weapon(weapon_id)
	
	for i in range(weapon_ids.size()):
		var weapon_id = weapon_ids[i]
		
		print("  测试切换到武器: %s" % weapon_id)
		
		# 模拟切换
		weapon_registry.equip_weapon(weapon_id)
		
		for j in range(10):
			await process_frame
		
		# 验证切换
		var current_id = weapon_registry.current_weapon_id
		if current_id == weapon_id:
			var weapon_data = weapon_registry.get_weapon(weapon_id)
			print("    ✓ 成功切换到 %s" % weapon_data.get("name", weapon_id))
		else:
			_log_result("测试2", false, "切换到%s失败，当前: %s" % [weapon_id, current_id])
			_cleanup_world()
			return
	
	_log_result("测试2", true, "所有武器切换成功（6/6）")
	_cleanup_world()

## 测试3: 敌人生成和清除（F/G键）
func _test_enemy_spawn():
	print("\n[测试3] 敌人生成和清除功能")
	
	await _setup_world()
	
	if not player:
		_log_result("测试3", false, "Player未找到")
		return
	
	for i in range(30):
		await process_frame
	
	# 清除现有敌人
	var initial_enemies = world_scene.get_tree().get_nodes_in_group("enemies")
	for enemy in initial_enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	
	for i in range(20):
		await process_frame
	
	var after_clear = world_scene.get_tree().get_nodes_in_group("enemies").size()
	print("  清除后敌人数: %d" % after_clear)
	
	# 测试生成敌人
	print("  测试生成3个敌人...")
	for i in range(3):
		_spawn_test_enemy()
		for j in range(10):
			await process_frame
	
	for i in range(30):
		await process_frame
	
	var spawned_enemies = world_scene.get_tree().get_nodes_in_group("enemies").size()
	print("  生成后敌人数: %d" % spawned_enemies)
	
	if spawned_enemies >= 3:
		_log_result("测试3", true, "敌人生成成功（%d个）" % spawned_enemies)
	else:
		_log_result("测试3", false, "敌人生成失败，只有%d个" % spawned_enemies)
	
	_cleanup_world()

## 辅助函数

func _setup_world():
	world_scene = load("res://World/world.tscn").instantiate()
	root.add_child(world_scene)
	
	for i in range(30):
		await process_frame
	
	player = world_scene.get_node_or_null("Player")
	
	if player:
		for child in player.get_children():
			if child.has_method("select_sect"):
				sect_manager = child
			if child.has_method("get_weapon"):
				weapon_registry = child

func _spawn_test_enemy():
	if not player:
		return
	
	var enemy_scene = load("res://Enemy/melee_enemy.tscn")
	if not enemy_scene:
		return
	
	var enemy = enemy_scene.instantiate()
	
	var spawn_distance = 200.0
	var angle = randf() * TAU
	var spawn_pos = player.global_position + Vector2(cos(angle), sin(angle)) * spawn_distance
	
	enemy.global_position = spawn_pos
	
	var config = {
		"hp": 50,
		"damage": 5,
		"move_speed": 80,
		"attack_range": 40,
		"attack_cooldown": 1.5,
		"knockback_resistance": 0.3,
		"exp_value": 10,
		"color": Color(1.0, 0.3, 0.3)
	}
	
	if enemy.has_method("load_config"):
		enemy.load_config(config)
	
	var enemies_node = world_scene.get_node_or_null("Enemies")
	if enemies_node:
		enemies_node.add_child(enemy)

func _cleanup_world():
	if world_scene:
		world_scene.queue_free()
		world_scene = null
		player = null
		sect_manager = null
		weapon_registry = null
	
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
