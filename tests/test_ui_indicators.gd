extends SceneTree

## UI指示器测试
## 测试宗派和武器UI的显示和高亮功能

const GameConstants = preload("res://Utility/game_constants.gd")

var test_results = []
var world_scene = null
var player = null
var sect_ui = null
var weapon_ui = null

func _init():
	print("\n========================================")
	print("UI Indicator Test")
	print("========================================\n")
	
	await _run_tests()
	
	print("\n========================================")
	print("Test Complete")
	print("========================================")
	_print_summary()
	
	quit()

func _run_tests():
	await _test_ui_creation()
	await _test_sect_ui_highlight()
	await _test_weapon_ui_highlight()

## 测试1: UI创建
func _test_ui_creation():
	print("\n[Test 1] UI Creation")
	
	await _setup_world()
	
	if not world_scene:
		_log_result("Test 1", false, "World scene not loaded")
		return
	
	# 查找UI节点
	var canvas_layer = world_scene.get_node_or_null("CanvasLayer")
	if not canvas_layer:
		_log_result("Test 1", false, "CanvasLayer not found")
		return
	
	sect_ui = canvas_layer.get_node_or_null("SectIndicatorUI")
	weapon_ui = canvas_layer.get_node_or_null("WeaponIndicatorUI")
	
	if not sect_ui:
		_log_result("Test 1", false, "SectIndicatorUI not found")
		return
	
	if not weapon_ui:
		_log_result("Test 1", false, "WeaponIndicatorUI not found")
		return
	
	# 等待UI初始化
	for i in range(30):
		await process_frame
	
	# 检查宗派UI子节点
	var sect_container = sect_ui.get_node_or_null("SectContainer")
	if not sect_container:
		_log_result("Test 1", false, "SectContainer not found")
		return
	
	var sect_buttons = sect_container.get_children().filter(func(n): return n.name.begins_with("Sect_"))
	print("  Sect buttons: %d" % sect_buttons.size())
	
	# 检查武器UI子节点
	var weapon_container = weapon_ui.get_node_or_null("WeaponContainer")
	if not weapon_container:
		_log_result("Test 1", false, "WeaponContainer not found")
		return
	
	var weapon_buttons = weapon_container.get_children().filter(func(n): return n.name.begins_with("Weapon_"))
	print("  Weapon buttons: %d" % weapon_buttons.size())
	
	if sect_buttons.size() >= 4 and weapon_buttons.size() >= 6:
		_log_result("Test 1", true, "UI created successfully (4 sects, 6 weapons)")
	else:
		_log_result("Test 1", false, "Insufficient UI elements")

## 测试2: 宗派UI高亮
func _test_sect_ui_highlight():
	print("\n[Test 2] Sect UI Highlight")
	
	if not sect_ui or not player:
		_log_result("Test 2", false, "UI or Player not available")
		return
	
	# 查找SectManager
	var sect_manager = null
	for child in player.get_children():
		if child.has_method("select_sect"):
			sect_manager = child
			break
	
	if not sect_manager:
		_log_result("Test 2", false, "SectManager not found")
		return
	
	var sects = ["ice", "thunder", "fire", "poison"]
	var highlight_count = 0
	
	for sect_id in sects:
		# 切换宗派
		sect_manager.select_sect(sect_id)
		
		# 等待UI更新
		for i in range(20):
			await process_frame
		
		# 检查高亮状态
		var sect_container = sect_ui.get_node_or_null("SectContainer")
		if sect_container:
			var target_btn = sect_container.get_node_or_null("Sect_" + sect_id)
			if target_btn:
				var style = target_btn.get_theme_stylebox("panel") as StyleBoxFlat
				if style and style.bg_color.a > 0.9:
					print("  [OK] %s highlighted" % sect_id)
					highlight_count += 1
				else:
					print("  [FAIL] %s not highlighted (alpha: %.2f)" % [sect_id, style.bg_color.a if style else 0.0])
	
	if highlight_count >= 4:
		_log_result("Test 2", true, "All sect highlights working (%d/4)" % highlight_count)
	else:
		_log_result("Test 2", false, "Some highlights failed (%d/4)" % highlight_count)

## 测试3: 武器UI高亮
func _test_weapon_ui_highlight():
	print("\n[Test 3] Weapon UI Highlight")
	
	if not weapon_ui or not player:
		_log_result("Test 3", false, "UI or Player not available")
		return
	
	# 查找WeaponRegistry
	var weapon_registry = null
	for child in player.get_children():
		if child.has_method("get_weapon"):
			weapon_registry = child
			break
	
	if not weapon_registry:
		_log_result("Test 3", false, "WeaponRegistry not found")
		return
	
	var weapon_ids = ["sword_basic", "sword_frost", "hammer_thunder"]
	var highlight_count = 0
	
	# 解锁所有武器
	for weapon_id in weapon_ids:
		weapon_registry.unlock_weapon(weapon_id)
	
	for weapon_id in weapon_ids:
		# 切换武器
		weapon_registry.equip_weapon(weapon_id)
		
		# 等待UI更新
		for i in range(20):
			await process_frame
		
		# 检查高亮状态
		var weapon_container = weapon_ui.get_node_or_null("WeaponContainer")
		if weapon_container:
			var target_btn = weapon_container.get_node_or_null("Weapon_" + weapon_id)
			if target_btn:
				var style = target_btn.get_theme_stylebox("panel") as StyleBoxFlat
				if style and style.bg_color.a > 0.9:
					print("  [OK] %s highlighted" % weapon_id)
					highlight_count += 1
				else:
					print("  [FAIL] %s not highlighted (alpha: %.2f)" % [weapon_id, style.bg_color.a if style else 0.0])
	
	if highlight_count >= 3:
		_log_result("Test 3", true, "Weapon highlights working (%d/3)" % highlight_count)
	else:
		_log_result("Test 3", false, "Some highlights failed (%d/3)" % highlight_count)

## 辅助函数

func _setup_world():
	world_scene = load("res://World/world.tscn").instantiate()
	root.add_child(world_scene)
	
	for i in range(30):
		await process_frame
	
	player = world_scene.get_node_or_null("Player")

func _log_result(test_name: String, passed: bool, message: String = ""):
	test_results.append({
		"test": test_name,
		"passed": passed,
		"message": message
	})
	var status = "[OK]" if passed else "[FAIL]"
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
	
	print("\nTotal: %d tests" % total)
	print("Passed: %d" % passed)
	print("Failed: %d" % failed)
	print("Pass rate: %.1f%%" % pass_rate)
