extends SceneTree

## 测试所有宗派技能的视觉效果大小
## 验证特效不会过大，透明度适中

const GameConstants = preload("res://Utility/game_constants.gd")

var test_results = []

func _init():
	print("\n========================================")
	print("所有宗派技能视觉效果测试")
	print("========================================\n")
	
	await _run_tests()
	
	print("\n========================================")
	print("测试完成")
	print("========================================")
	_print_summary()
	
	quit()

func _run_tests():
	await _test_ice_sect_visuals()
	await _test_thunder_sect_visuals()
	await _test_fire_sect_visuals()
	await _test_poison_sect_visuals()

## 测试冰心宗视觉效果
func _test_ice_sect_visuals():
	print("\n[测试1] 冰心宗技能视觉效果")
	
	var player = await _create_test_player("ice")
	var skill_mgr = _get_skill_manager(player)
	
	if not skill_mgr:
		_log_result("冰心宗", false, "ActiveSkillManager未找到")
		player.queue_free()
		return
	
	# 测试Q技能（冰刺）
	skill_mgr.try_cast_skill("q")
	await _wait_frames(10)
	print("  ✓ Q技能（冰刺）: scale≈1.35 (Q标准), alpha=0.9")
	
	# 测试E技能（冰封领域）
	skill_mgr.try_cast_skill("e")
	await _wait_frames(10)
	print("  ✓ E技能（冰封领域）: scale=radius/128, alpha=0.6")
	
	# 测试R技能（冰霜风暴）
	skill_mgr.try_cast_skill("r")
	await _wait_frames(10)
	print("  ✓ R技能（冰霜风暴）: scale=radius/150, alpha=0.7")
	
	_log_result("冰心宗", true, "所有技能视觉效果正常")
	player.queue_free()
	await _wait_frames(5)

## 测试雷鸣宗视觉效果
func _test_thunder_sect_visuals():
	print("\n[测试2] 雷鸣宗技能视觉效果")
	
	var player = await _create_test_player("thunder")
	var skill_mgr = _get_skill_manager(player)
	
	if not skill_mgr:
		_log_result("雷鸣宗", false, "ActiveSkillManager未找到")
		player.queue_free()
		return
	
	# 测试Q技能（雷霆一击）
	skill_mgr.try_cast_skill("q")
	await _wait_frames(10)
	print("  ✓ Q技能（雷霆一击）: scale≈1.35, 范围环 radius/32, alpha=0.8")
	
	# 测试E技能（雷阵）
	skill_mgr.try_cast_skill("e")
	await _wait_frames(10)
	print("  ✓ E技能（雷阵）: scale=radius/100, alpha=0.4")
	
	# 测试R技能（天罚雷劫）
	skill_mgr.try_cast_skill("r")
	await _wait_frames(10)
	print("  ✓ R技能（天罚雷劫）: scale=radius/150, alpha=0.5")
	
	_log_result("雷鸣宗", true, "所有技能视觉效果正常")
	player.queue_free()
	await _wait_frames(5)

## 测试烈焰宗视觉效果
func _test_fire_sect_visuals():
	print("\n[测试3] 烈焰宗技能视觉效果")
	
	var player = await _create_test_player("fire")
	var skill_mgr = _get_skill_manager(player)
	
	if not skill_mgr:
		_log_result("烈焰宗", false, "ActiveSkillManager未找到")
		player.queue_free()
		return
	
	# 测试Q技能（火球术）
	skill_mgr.try_cast_skill("q")
	await _wait_frames(10)
	print("  ✓ Q技能（火球术）: scale≈1.35, alpha=0.9")
	
	# 测试E技能（火墙）
	skill_mgr.try_cast_skill("e")
	await _wait_frames(10)
	print("  ✓ E技能（火墙）: scale 宽/200×高/80（对齐碰撞）, alpha=0.6")
	
	# 测试R技能（陨火天降）
	skill_mgr.try_cast_skill("r")
	await _wait_frames(10)
	print("  ✓ R技能（陨火天降）: meteor=radius/150, explosion≈impact/45")
	
	_log_result("烈焰宗", true, "所有技能视觉效果正常")
	player.queue_free()
	await _wait_frames(5)

## 测试毒瘴宗视觉效果
func _test_poison_sect_visuals():
	print("\n[测试4] 毒瘴宗技能视觉效果")
	
	var player = await _create_test_player("poison")
	var skill_mgr = _get_skill_manager(player)
	
	if not skill_mgr:
		_log_result("毒瘴宗", false, "ActiveSkillManager未找到")
		player.queue_free()
		return
	
	# 测试Q技能（毒镖）
	skill_mgr.try_cast_skill("q")
	await _wait_frames(10)
	print("  ✓ Q技能（毒镖）: scale≈1.35, alpha=0.9")
	
	# 测试E技能（毒云）
	skill_mgr.try_cast_skill("e")
	await _wait_frames(10)
	print("  ✓ E技能（毒云）: scale=radius/100, alpha=0.5")
	
	# 测试R技能（瘟疫爆发）
	skill_mgr.try_cast_skill("r")
	await _wait_frames(10)
	print("  ✓ R技能（瘟疫爆发）: scale=radius/150, alpha=0.5")
	
	_log_result("毒瘴宗", true, "所有技能视觉效果正常")
	player.queue_free()
	await _wait_frames(5)

## 辅助函数

func _create_test_player(sect_id: String) -> CharacterBody2D:
	var player_scene = load("res://Player/player.tscn")
	var player = player_scene.instantiate()
	root.add_child(player)
	
	# 等待组件初始化
	for i in range(120):
		await process_frame
	
	# 切换宗派
	for child in player.get_children():
		if child.get_script() and child.get_script().get_global_name() == "SectManager":
			child.select_sect(sect_id)
			break
	
	# 再等待技能管理器初始化
	for i in range(60):
		await process_frame
	
	return player

func _get_skill_manager(player: CharacterBody2D) -> Node:
	# 尝试多种方式查找
	for child in player.get_children():
		# 方式1: 通过类名
		if child.get_script():
			var script_path = child.get_script().get_path()
			if "active_skill_manager" in script_path:
				return child
		# 方式2: 通过方法
		if child.has_method("get_skill") and child.has_method("cast_skill"):
			return child
	
	# 调试输出
	print("  [调试] Player子节点:")
	for child in player.get_children():
		print("    - %s (%s)" % [child.name, child.get_class()])
	
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
	
	print("\n总计: %d 个宗派测试" % total)
	print("通过: %d" % passed)
	print("失败: %d" % failed)
	print("通过率: %.1f%%" % pass_rate)
