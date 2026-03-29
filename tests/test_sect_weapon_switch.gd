extends SceneTree

## 测试宗派和武器切换功能

const GameConstants = preload("res://Utility/game_constants.gd")

var test_results = []
var world_scene = null
var player = null

func _init():
	print("\n========================================")
	print("宗派/武器切换测试")
	print("========================================\n")
	
	await _run_tests()
	
	print("\n========================================")
	print("测试完成")
	print("========================================")
	_print_summary()
	
	quit()

func _run_tests():
	await _test_sect_switch()
	await _test_weapon_switch()

## 测试1: 宗派切换
func _test_sect_switch():
	print("\n[测试1] 宗派切换功能")
	
	await _setup_world()
	
	if not player:
		_log_result("测试1", false, "Player未找到")
		return
	
	# 查找SectManager
	var sect_mgr = null
	for child in player.get_children():
		if child.get_script() and child.get_script().get_global_name() == "SectManager":
			sect_mgr = child
			break
	
	if not sect_mgr:
		_log_result("测试1", false, "SectManager未找到")
		_cleanup_world()
		return
	
	print("  初始宗派: %s" % sect_mgr.current_sect_id)
	
	# 切换到雷鸣宗
	print("  切换到雷鸣宗...")
	var success = sect_mgr.select_sect("thunder")
	
	await process_frame
	
	if success and sect_mgr.current_sect_id == "thunder":
		_log_result("测试1", true, "宗派切换成功: ice → thunder")
	else:
		_log_result("测试1", false, "宗派切换失败，当前: %s" % sect_mgr.current_sect_id)
	
	_cleanup_world()

## 测试2: 武器切换
func _test_weapon_switch():
	print("\n[测试2] 武器切换功能")
	
	await _setup_world()
	
	if not player:
		_log_result("测试2", false, "Player未找到")
		return
	
	# 查找WeaponRegistry - 它是player的成员变量，不是子节点
	var weapon_registry = player.weapon_registry
	
	if not weapon_registry:
		_log_result("测试2", false, "WeaponRegistry未找到")
		_cleanup_world()
		return
	
	print("  初始武器: %s" % weapon_registry.current_weapon_id)
	
	# 解锁并切换到霜寒剑
	print("  切换到霜寒剑...")
	weapon_registry.unlock_weapon("sword_frost")
	var success = weapon_registry.equip_weapon("sword_frost")
	
	await process_frame
	
	if success and weapon_registry.current_weapon_id == "sword_frost":
		_log_result("测试2", true, "武器切换成功: nameless → sword_frost")
	else:
		_log_result("测试2", false, "武器切换失败，当前: %s" % weapon_registry.current_weapon_id)
	
	_cleanup_world()

## 辅助函数

func _setup_world():
	world_scene = load("res://World/world.tscn").instantiate()
	root.add_child(world_scene)
	
	# 等待场景完全初始化
	for i in range(60):
		await process_frame
	
	player = world_scene.get_node_or_null("Player")
	
	# 等待Player组件初始化
	if player:
		for i in range(30):
			await process_frame

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
