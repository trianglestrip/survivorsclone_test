extends SceneTree

## 简化的技能消失测试
## 直接测试技能实例的生命周期

const GameConstants = preload("res://Utility/game_constants.gd")

var test_results = []

func _init():
	print("\n========================================")
	print("技能消失机制测试")
	print("========================================\n")
	
	await _run_tests()
	
	print("\n========================================")
	print("测试完成")
	print("========================================")
	_print_summary()
	
	quit()

func _run_tests():
	await _test_ice_field_disappear()
	await _test_ice_storm_disappear()

## 测试1: E技能（冰霜领域）消失
func _test_ice_field_disappear():
	print("\n[测试1] 冰霜领域消失机制")
	
	# 创建测试玩家
	var player = CharacterBody2D.new()
	player.name = "TestPlayer"
	root.add_child(player)
	
	# 创建E技能实例
	var skill_script = load("res://Skills/ActiveSkills/ice_field.gd")
	var skill = skill_script.new()
	skill.player = player
	player.add_child(skill)
	
	# 初始化技能配置
	var config = {
		"damage": 30,
		"radius": 200,
		"duration": 2.0,  # 缩短测试时间
		"slow_percent": 0.5,
		"tick_interval": 0.5
	}
	skill._load_skill_config(config)
	
	print("  释放技能...")
	skill.cast(Vector2.ZERO, Vector2.RIGHT)
	
	# 等待技能创建
	for i in range(30):
		await process_frame
	
	var field_node = skill.field_node
	if not is_instance_valid(field_node):
		_log_result("测试1", false, "技能节点未创建")
		player.queue_free()
		return
	
	print("  技能节点已创建: %s" % field_node.name)
	print("  等待持续时间（2秒）...")
	
	# 等待持续时间 + 淡出时间
	var timer = Timer.new()
	root.add_child(timer)
	timer.wait_time = 2.5
	timer.one_shot = true
	timer.start()
	await timer.timeout
	timer.queue_free()
	
	# 检查节点是否已被清理
	if not is_instance_valid(field_node):
		_log_result("测试1", true, "技能正确消失")
	else:
		_log_result("测试1", false, "技能未消失，节点仍存在")
	
	player.queue_free()
	await process_frame

## 测试2: R技能（冰霜风暴）消失
func _test_ice_storm_disappear():
	print("\n[测试2] 冰霜风暴消失机制")
	
	# 创建测试玩家
	var player = CharacterBody2D.new()
	player.name = "TestPlayer"
	root.add_child(player)
	
	# 创建R技能实例
	var skill_script = load("res://Skills/ActiveSkills/ice_storm.gd")
	var skill = skill_script.new()
	skill.player = player
	skill.name = "IceStormSkill"  # 给技能命名，防止被自动清理
	player.add_child(skill)
	
	# 初始化技能配置
	var config = {
		"damage": 50,
		"radius": 300,
		"duration": 2.0,  # 缩短测试时间
		"freeze_duration": 2.0,
		"tick_interval": 0.3
	}
	skill._load_skill_config(config)
	
	print("  释放技能...")
	skill.cast(Vector2.ZERO, Vector2.RIGHT)
	
	# 等待技能创建
	for i in range(30):
		await process_frame
	
	var storm_node = skill.storm_node
	if not is_instance_valid(storm_node):
		_log_result("测试2", false, "技能节点未创建")
		player.queue_free()
		return
	
	print("  技能节点已创建: %s" % storm_node.name)
	print("  技能is_active: %s, elapsed_time: %.2f, duration: %.2f" % [skill.is_active, skill.elapsed_time, skill.duration])
	print("  等待持续时间（2秒）...")
	
	# 等待持续时间 + 淡出时间
	var timer = Timer.new()
	root.add_child(timer)
	timer.wait_time = 2.7
	timer.one_shot = true
	timer.start()
	await timer.timeout
	timer.queue_free()
	
	# 额外等待一些帧
	for i in range(30):
		await process_frame
	
	# 检查节点是否已被清理
	if not is_instance_valid(storm_node):
		_log_result("测试2", true, "技能正确消失")
	else:
		print("  调试：storm_node仍存在，父节点: %s" % (storm_node.get_parent().name if storm_node.get_parent() else "无"))
		print("  调试：技能实例有效: %s" % is_instance_valid(skill))
		if is_instance_valid(skill):
			print("  调试：技能is_active: %s, elapsed_time: %.2f" % [skill.is_active, skill.elapsed_time])
		_log_result("测试2", false, "技能未消失，节点仍存在")
	
	player.queue_free()
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
