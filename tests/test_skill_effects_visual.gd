extends SceneTree

## 技能特效可视化测试
## 验证Q/E/R技能的特效节点是否正确创建和显示

const GameConstants = preload("res://Utility/game_constants.gd")

var test_results = []
var world_scene = null
var player = null

func _init():
	print("\n========================================")
	print("技能特效可视化测试")
	print("========================================\n")
	
	await _run_tests()
	
	print("\n========================================")
	print("测试完成")
	print("========================================")
	_print_summary()
	
	quit()

func _run_tests():
	await _test_q_skill_effect()
	await _test_e_skill_effect()
	await _test_r_skill_effect()

## 测试1: Q技能特效
func _test_q_skill_effect():
	print("\n[测试1] Q技能特效检查")
	
	await _setup_world()
	
	if not player:
		_log_result("测试1", false, "Player不存在")
		return
	
	for i in range(30):
		await process_frame
	
	var initial_children = _count_world_children()
	print("  初始世界子节点数: ", initial_children)
	
	# 释放Q技能
	print("  释放Q技能...")
	Input.action_press("skill_q")
	for i in range(5):
		await process_frame
	Input.action_release("skill_q")
	
	# 等待技能生成并检查多次
	var max_children = initial_children
	for i in range(120):
		await process_frame
		var current_children = _count_world_children()
		if current_children > max_children:
			max_children = current_children
		if i % 30 == 0:
			print("  等待中... (%d帧), 当前子节点: %d, 最大: %d" % [i, current_children, max_children])
	
	var after_cast_children = _count_world_children()
	print("  最终世界子节点数: ", after_cast_children)
	print("  峰值世界子节点数: ", max_children)
	
	# 列出所有子节点
	_list_world_children()
	
	# 检查是否有新增节点（使用峰值）
	if max_children > initial_children:
		_log_result("测试1", true, "Q技能创建了特效节点 (峰值+%d个)" % (max_children - initial_children))
	else:
		_log_result("测试1", false, "Q技能未创建特效节点")
	
	_cleanup_world()

## 测试2: E技能特效
func _test_e_skill_effect():
	print("\n[测试2] E技能特效检查")
	
	await _setup_world()
	
	if not player:
		_log_result("测试2", false, "Player不存在")
		return
	
	for i in range(30):
		await process_frame
	
	var initial_children = _count_world_children()
	print("  初始世界子节点数: ", initial_children)
	
	# 释放E技能
	print("  释放E技能...")
	Input.action_press("skill_e")
	for i in range(5):
		await process_frame
	Input.action_release("skill_e")
	
	# 等待技能生成
	for i in range(30):
		await process_frame
	
	var after_cast_children = _count_world_children()
	print("  释放后世界子节点数: ", after_cast_children)
	
	# 列出所有子节点
	_list_world_children()
	
	# 检查是否有新增节点
	if after_cast_children > initial_children:
		_log_result("测试2", true, "E技能创建了特效节点 (+%d个)" % (after_cast_children - initial_children))
	else:
		_log_result("测试2", false, "E技能未创建特效节点")
	
	_cleanup_world()

## 测试3: R技能特效
func _test_r_skill_effect():
	print("\n[测试3] R技能特效检查")
	
	await _setup_world()
	
	if not player:
		_log_result("测试3", false, "Player不存在")
		return
	
	for i in range(30):
		await process_frame
	
	var initial_children = _count_world_children()
	print("  初始世界子节点数: ", initial_children)
	
	# 释放R技能
	print("  释放R技能...")
	Input.action_press("skill_r")
	for i in range(5):
		await process_frame
	Input.action_release("skill_r")
	
	# 等待技能生成
	for i in range(30):
		await process_frame
	
	var after_cast_children = _count_world_children()
	print("  释放后世界子节点数: ", after_cast_children)
	
	# 列出所有子节点
	_list_world_children()
	
	# 检查是否有新增节点
	if after_cast_children > initial_children:
		_log_result("测试3", true, "R技能创建了特效节点 (+%d个)" % (after_cast_children - initial_children))
	else:
		_log_result("测试3", false, "R技能未创建特效节点")
	
	_cleanup_world()

## 辅助函数

func _setup_world():
	world_scene = load("res://World/world.tscn").instantiate()
	root.add_child(world_scene)
	
	for i in range(20):
		await process_frame
	
	player = world_scene.get_node_or_null("Player")

func _count_world_children() -> int:
	if not world_scene:
		return 0
	return world_scene.get_child_count()

func _list_world_children():
	if not world_scene:
		return
	
	print("  世界子节点列表:")
	for i in range(world_scene.get_child_count()):
		var child = world_scene.get_child(i)
		print("    [%d] %s (类型: %s)" % [i, child.name, child.get_class()])

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
