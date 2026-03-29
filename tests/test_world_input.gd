extends SceneTree

## 测试主游戏场景的按键输入处理

const GameConstants = preload("res://Utility/game_constants.gd")

var test_results = []
var world_scene = null
var player = null

func _init():
	print("\n========================================")
	print("主游戏场景输入测试")
	print("========================================\n")
	
	await _run_tests()
	
	print("\n========================================")
	print("测试完成")
	print("========================================")
	_print_summary()
	
	quit()

func _run_tests():
	await _test_world_script_loaded()
	await _test_sect_switch_via_input()
	await _test_weapon_switch_via_input()

## 测试1: World脚本加载
func _test_world_script_loaded():
	print("\n[测试1] World脚本加载检查")
	
	world_scene = load("res://World/world.tscn").instantiate()
	root.add_child(world_scene)
	
	for i in range(60):
		await process_frame
	
	if world_scene.get_script():
		print("  ✓ World脚本已加载")
		_log_result("测试1", true, "World脚本正确加载")
	else:
		_log_result("测试1", false, "World脚本未加载")
	
	world_scene.queue_free()
	world_scene = null
	await process_frame

## 测试2: 通过输入切换宗派
func _test_sect_switch_via_input():
	print("\n[测试2] 通过按键切换宗派")
	
	world_scene = load("res://World/world.tscn").instantiate()
	root.add_child(world_scene)
	
	for i in range(60):
		await process_frame
	
	player = world_scene.get_node_or_null("Player")
	if not player:
		_log_result("测试2", false, "Player未找到")
		world_scene.queue_free()
		return
	
	var sect_manager = null
	for child in player.get_children():
		if child.get_script() and child.get_script().get_global_name() == "SectManager":
			sect_manager = child
			break
	
	if not sect_manager:
		_log_result("测试2", false, "SectManager未找到")
		world_scene.queue_free()
		return
	
	var initial_sect = sect_manager.current_sect_id
	print("  初始宗派: %s" % initial_sect)
	
	# 模拟按键2（切换到雷鸣宗）
	var key_event = InputEventKey.new()
	key_event.keycode = KEY_2
	key_event.pressed = true
	Input.parse_input_event(key_event)
	
	for i in range(30):
		await process_frame
	
	var new_sect = sect_manager.current_sect_id
	print("  按键2后宗派: %s" % new_sect)
	
	if new_sect == "thunder":
		_log_result("测试2", true, "按键切换宗派成功: %s → %s" % [initial_sect, new_sect])
	else:
		_log_result("测试2", false, "按键切换失败，当前: %s" % new_sect)
	
	world_scene.queue_free()
	world_scene = null
	await process_frame

## 测试3: 通过输入切换武器
func _test_weapon_switch_via_input():
	print("\n[测试3] 通过按键切换武器")
	
	world_scene = load("res://World/world.tscn").instantiate()
	root.add_child(world_scene)
	
	for i in range(60):
		await process_frame
	
	player = world_scene.get_node_or_null("Player")
	if not player:
		_log_result("测试3", false, "Player未找到")
		world_scene.queue_free()
		return
	
	var weapon_registry = player.weapon_registry
	if not weapon_registry:
		_log_result("测试3", false, "WeaponRegistry未找到")
		world_scene.queue_free()
		return
	
	var initial_weapon = weapon_registry.current_weapon_id
	print("  初始武器: %s" % initial_weapon)
	
	# 模拟按键6（切换到霜寒剑）
	var key_event = InputEventKey.new()
	key_event.keycode = KEY_6
	key_event.pressed = true
	Input.parse_input_event(key_event)
	
	for i in range(30):
		await process_frame
	
	var new_weapon = weapon_registry.current_weapon_id
	print("  按键6后武器: %s" % new_weapon)
	
	if new_weapon == "sword_frost":
		_log_result("测试3", true, "按键切换武器成功: %s → %s" % [initial_weapon, new_weapon])
	else:
		_log_result("测试3", false, "按键切换失败，当前: %s" % new_weapon)
	
	world_scene.queue_free()
	world_scene = null
	await process_frame

## 辅助函数

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
