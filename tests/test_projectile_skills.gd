extends SceneTree

## 测试弹射物技能（Q技能）的显示
## 专门检查快速移动的弹射物

const GameConstants = preload("res://Utility/game_constants.gd")

var test_results = []

func _init():
	print("\n========================================")
	print("弹射物技能显示测试")
	print("========================================\n")
	
	await _run_tests()
	
	print("\n========================================")
	print("测试完成")
	print("========================================")
	_print_summary()
	
	quit()

func _run_tests():
	await _test_projectile("ice", "冰心宗", "IceShard")
	await _test_projectile("thunder", "雷鸣宗", "ThunderStrike")
	await _test_projectile("fire", "烈焰宗", "FireBall")
	await _test_projectile("poison", "毒瘴宗", "PoisonDart")

func _test_projectile(sect_id: String, sect_name: String, expected_node: String):
	print("\n[测试] %s Q技能弹射物" % sect_name)
	
	var player = await _create_test_player(sect_id)
	var skill_mgr = _get_skill_manager(player)
	
	if not skill_mgr:
		_log_result(sect_name, false, "ActiveSkillManager未找到")
		player.queue_free()
		return
	
	var world = player.get_parent()
	var initial_count = world.get_child_count()
	
	print("  释放Q技能...")
	skill_mgr.try_cast_skill("q")
	
	# 立即检查（弹射物应该马上创建）
	await _wait_frames(3)
	var after_cast = world.get_child_count()
	var created = after_cast > initial_count
	
	print("    立即检查: %d → %d (%s)" % [initial_count, after_cast, "✓" if created else "✗"])
	
	if created:
		# 查找弹射物节点
		var projectile = null
		for child in world.get_children():
			if expected_node.to_lower() in child.name.to_lower():
				projectile = child
				break
		
		if projectile:
			print("    找到弹射物: %s" % projectile.name)
			print("    位置: %s" % projectile.global_position)
			print("    子节点: %d" % projectile.get_child_count())
			
			# 检查是否有Sprite2D
			var has_sprite = false
			for child in projectile.get_children():
				if child is Sprite2D:
					has_sprite = true
					print("    精灵: scale=%s, alpha=%.2f" % [child.scale, child.modulate.a])
					break
			
			if not has_sprite:
				print("    ⚠️ 警告：没有Sprite2D子节点")
		else:
			print("    ⚠️ 警告：未找到预期节点 '%s'" % expected_node)
			print("    当前World子节点:")
			for child in world.get_children():
				if child != player:
					print("      - %s" % child.name)
	
	# 等待弹射物飞行
	await _wait_frames(30)
	var final_count = world.get_child_count()
	print("    飞行后: %d 个节点" % final_count)
	
	_log_result(sect_name, created, "弹射物%s" % ("正常创建" if created else "未创建"))
	
	player.queue_free()
	await _wait_frames(10)

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
	
	print("\n总计: %d 个弹射物技能" % total)
	print("通过: %d" % passed)
	print("失败: %d" % failed)
	print("通过率: %.1f%%" % pass_rate)
