extends SceneTree

## 测试玩家死亡信号和UI层级

const GameConstants = preload("res://Utility/game_constants.gd")

var test_results = []

func _init():
	print("\n========================================")
	print("玩家死亡系统测试")
	print("========================================\n")
	
	await _run_tests()
	
	print("\n========================================")
	print("测试完成")
	print("========================================")
	_print_summary()
	
	quit()

func _run_tests():
	await _test_player_died_signal()
	await _test_ui_z_index()

func _test_player_died_signal():
	print("[测试] player_died信号")
	
	# 加载EventBus脚本检查信号定义
	var event_bus_script = load("res://Utility/event_bus.gd")
	var event_bus_instance = event_bus_script.new()
	
	var has_signal = event_bus_instance.has_signal("player_died")
	print("  EventBus.player_died信号定义: %s" % ("存在" if has_signal else "不存在"))
	
	if not has_signal:
		_log_result("player_died信号", false, "信号未定义")
		event_bus_instance.free()
		return
	
	# 检查是否有emit方法
	var has_emit_method = event_bus_instance.has_method("emit_player_died")
	print("  EventBus.emit_player_died方法: %s" % ("存在" if has_emit_method else "不存在"))
	
	var test_passed = has_signal and has_emit_method
	_log_result("player_died信号", test_passed, "信号定义%s，方法%s" % [
		"✓" if has_signal else "✗",
		"✓" if has_emit_method else "✗"
	])
	
	event_bus_instance.free()

func _test_ui_z_index():
	print("\n[测试] UI层级（z_index）")
	
	var player_scene = load("res://Player/player.tscn")
	var player = player_scene.instantiate()
	root.add_child(player)
	
	await _wait_frames(10)
	
	# 查找DeathPanel和LevelUp
	var death_panel = player.get_node_or_null("%DeathPanel")
	var level_up = player.get_node_or_null("%LevelUp")
	
	if not death_panel:
		_log_result("DeathPanel", false, "节点未找到")
		player.queue_free()
		return
	
	if not level_up:
		_log_result("LevelUp", false, "节点未找到")
		player.queue_free()
		return
	
	var death_z = death_panel.z_index if "z_index" in death_panel else 0
	var level_z = level_up.z_index if "z_index" in level_up else 0
	
	print("  DeathPanel z_index: %d" % death_z)
	print("  LevelUp z_index: %d" % level_z)
	
	var correct_order = death_z > level_z
	print("  层级关系: DeathPanel %s LevelUp" % (">" if correct_order else "<="))
	
	_log_result("UI层级", correct_order, "DeathPanel(z:%d) %s LevelUp(z:%d)" % [
		death_z,
		">" if correct_order else "<=",
		level_z
	])
	
	player.queue_free()

func _wait_frames(count: int):
	for i in range(count):
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
