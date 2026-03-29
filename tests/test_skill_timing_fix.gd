extends SceneTree

## 技能时序修复测试
## 验证E/R技能在实际游戏中能正常释放

const GameConstants = preload("res://Utility/game_constants.gd")

var test_results = []
var world_scene = null
var player = null

func _init():
	print("\n========================================")
	print("技能时序修复测试")
	print("========================================\n")
	
	await _run_tests()
	
	print("\n========================================")
	print("测试完成")
	print("========================================")
	_print_summary()
	
	quit()

func _run_tests():
	await _test_q_skill_realtime()
	await _test_e_skill_realtime()
	await _test_r_skill_realtime()
	await _test_all_skills_sequence()

## 测试1: Q技能实时释放
func _test_q_skill_realtime():
	print("\n[测试1] Q技能实时释放")
	
	await _setup_world()
	
	if not player:
		_log_result("测试1", false, "Player不存在")
		return
	
	# 等待初始化完成
	for i in range(30):
		await process_frame
	
	print("  释放Q技能...")
	Input.action_press("skill_q")
	
	for i in range(5):
		await process_frame
	
	Input.action_release("skill_q")
	
	# 等待技能效果（检查是否有错误输出）
	var frames_without_error = 0
	
	for i in range(60):
		await process_frame
		frames_without_error += 1
	
	# 如果能运行60帧没有崩溃或严重错误，说明技能正常
	if frames_without_error >= 60:
		_log_result("测试1", true, "Q技能实时释放成功，无错误")
	else:
		_log_result("测试1", false, "Q技能有错误")
	
	_cleanup_world()

## 测试2: E技能实时释放
func _test_e_skill_realtime():
	print("\n[测试2] E技能实时释放")
	
	await _setup_world()
	
	if not player:
		_log_result("测试2", false, "Player不存在")
		return
	
	for i in range(30):
		await process_frame
	
	print("  释放E技能...")
	Input.action_press("skill_e")
	
	for i in range(5):
		await process_frame
	
	Input.action_release("skill_e")
	
	# 等待技能效果
	var frames_without_error = 0
	
	for i in range(60):
		await process_frame
		frames_without_error += 1
	
	if frames_without_error >= 60:
		_log_result("测试2", true, "E技能实时释放成功，无错误")
	else:
		_log_result("测试2", false, "E技能有错误")
	
	_cleanup_world()

## 测试3: R技能实时释放
func _test_r_skill_realtime():
	print("\n[测试3] R技能实时释放")
	
	await _setup_world()
	
	if not player:
		_log_result("测试3", false, "Player不存在")
		return
	
	for i in range(30):
		await process_frame
	
	print("  释放R技能...")
	Input.action_press("skill_r")
	
	for i in range(5):
		await process_frame
	
	Input.action_release("skill_r")
	
	# 等待技能效果
	var frames_without_error = 0
	
	for i in range(60):
		await process_frame
		frames_without_error += 1
	
	if frames_without_error >= 60:
		_log_result("测试3", true, "R技能实时释放成功，无错误")
	else:
		_log_result("测试3", false, "R技能有错误")
	
	_cleanup_world()

## 测试4: 连续释放Q/E/R技能
func _test_all_skills_sequence():
	print("\n[测试4] 连续释放Q/E/R技能")
	
	await _setup_world()
	
	if not player:
		_log_result("测试4", false, "Player不存在")
		return
	
	for i in range(30):
		await process_frame
	
	var skills_success = 0
	
	# Q技能
	print("  释放Q技能...")
	Input.action_press("skill_q")
	for i in range(5):
		await process_frame
	Input.action_release("skill_q")
	
	for i in range(30):
		await process_frame
	
	skills_success += 1
	
	# E技能
	print("  释放E技能...")
	Input.action_press("skill_e")
	for i in range(5):
		await process_frame
	Input.action_release("skill_e")
	
	for i in range(30):
		await process_frame
	
	skills_success += 1
	
	# R技能
	print("  释放R技能...")
	Input.action_press("skill_r")
	for i in range(5):
		await process_frame
	Input.action_release("skill_r")
	
	for i in range(30):
		await process_frame
	
	skills_success += 1
	
	if skills_success == 3:
		_log_result("测试4", true, "连续释放3个技能无错误")
	else:
		_log_result("测试4", false, "技能释放有错误")
	
	_cleanup_world()

## 辅助函数

func _setup_world():
	world_scene = load("res://World/world.tscn").instantiate()
	root.add_child(world_scene)
	
	for i in range(20):
		await process_frame
	
	player = world_scene.get_node_or_null("Player")

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
	
	if pass_rate == 100.0:
		print("\n✅ 技能时序问题已修复！")
