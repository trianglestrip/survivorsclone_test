extends SceneTree

## 测试所有技能是否正确显示
## 验证节点创建、场景树添加、生命周期

const GameConstants = preload("res://Utility/game_constants.gd")

var test_results = []

func _init():
	print("\n========================================")
	print("技能显示完整性测试")
	print("========================================\n")
	
	await _run_tests()
	
	print("\n========================================")
	print("测试完成")
	print("========================================")
	_print_summary()
	
	quit()

func _run_tests():
	await _test_sect_skills("ice", "冰心宗")
	await _test_sect_skills("thunder", "雷鸣宗")
	await _test_sect_skills("fire", "烈焰宗")
	await _test_sect_skills("poison", "毒瘴宗")

func _test_sect_skills(sect_id: String, sect_name: String):
	print("\n[测试] %s 技能显示" % sect_name)
	
	var player = await _create_test_player(sect_id)
	var skill_mgr = _get_skill_manager(player)
	
	if not skill_mgr:
		_log_result(sect_name, false, "ActiveSkillManager未找到")
		player.queue_free()
		return
	
	var world = player.get_parent()
	var initial_children = world.get_child_count()
	
	# 测试Q技能
	print("  测试Q技能...")
	skill_mgr.try_cast_skill("q")
	await _wait_frames(20)
	var q_children = world.get_child_count()
	var q_created = q_children > initial_children
	print("    节点数: %d → %d (%s)" % [initial_children, q_children, "✓" if q_created else "✗"])
	
	# 等待Q技能结束
	await _wait_frames(30)
	
	# 测试E技能
	print("  测试E技能...")
	var e_initial = world.get_child_count()
	skill_mgr.try_cast_skill("e")
	await _wait_frames(20)
	var e_children = world.get_child_count()
	var e_created = e_children > e_initial
	print("    节点数: %d → %d (%s)" % [e_initial, e_children, "✓" if e_created else "✗"])
	
	# 检查E技能节点
	if e_created:
		var e_node = _find_skill_node(world, sect_id, "E")
		if e_node:
			print("    节点名称: %s" % e_node.name)
			print("    子节点数: %d" % e_node.get_child_count())
			_print_node_tree(e_node, "      ")
	
	# 等待E技能结束
	await _wait_frames(30)
	
	# 测试R技能
	print("  测试R技能...")
	var r_initial = world.get_child_count()
	skill_mgr.try_cast_skill("r")
	await _wait_frames(20)
	var r_children = world.get_child_count()
	var r_created = r_children > r_initial
	print("    节点数: %d → %d (%s)" % [r_initial, r_children, "✓" if r_created else "✗"])
	
	# 检查R技能节点
	if r_created:
		var r_node = _find_skill_node(world, sect_id, "R")
		if r_node:
			print("    节点名称: %s" % r_node.name)
			print("    子节点数: %d" % r_node.get_child_count())
			_print_node_tree(r_node, "      ")
	
	var all_displayed = q_created and e_created and r_created
	_log_result(sect_name, all_displayed, "Q:%s E:%s R:%s" % [
		"✓" if q_created else "✗",
		"✓" if e_created else "✗",
		"✓" if r_created else "✗"
	])
	
	player.queue_free()
	await _wait_frames(10)

func _find_skill_node(world: Node, sect_id: String, skill_key: String) -> Node2D:
	var skill_names = {
		"ice": {"E": "IceField", "R": "IceStorm"},
		"thunder": {"E": "ThunderField", "R": "ThunderGod"},
		"fire": {"E": "FireWall", "R": "FireMeteor"},
		"poison": {"E": "PoisonCloud", "R": "PoisonPlague"}
	}
	
	if not skill_names.has(sect_id) or not skill_names[sect_id].has(skill_key):
		return null
	
	var node_name = skill_names[sect_id][skill_key]
	
	for child in world.get_children():
		if child.name == node_name:
			return child
	
	return null

func _print_node_tree(node: Node, indent: String = ""):
	for child in node.get_children():
		var type_info = child.get_class()
		if child.get_script():
			var script_path = child.get_script().get_path()
			type_info += " (%s)" % script_path.get_file()
		print("%s- %s [%s]" % [indent, child.name, type_info])
		if child.get_child_count() > 0:
			_print_node_tree(child, indent + "  ")

func _create_test_player(sect_id: String) -> CharacterBody2D:
	var player_scene = load("res://Player/player.tscn")
	var player = player_scene.instantiate()
	root.add_child(player)
	
	for i in range(120):
		await process_frame
	
	# 切换宗派
	for child in player.get_children():
		if child.get_script() and child.get_script().get_global_name() == "SectManager":
			child.select_sect(sect_id)
			break
	
	for i in range(60):
		await process_frame
	
	return player

func _get_skill_manager(player: CharacterBody2D) -> Node:
	for child in player.get_children():
		if child.has_method("try_cast_skill"):
			return child
	return null

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
	
	print("\n总计: %d 个宗派" % total)
	print("通过: %d" % passed)
	print("失败: %d" % failed)
	print("通过率: %.1f%%" % pass_rate)
