extends SceneTree

## 测试技能纹理加载和显示

const SkillTextureLoader = preload("res://Utility/skill_texture_loader.gd")

var test_results = []
var texture_loader = null

func _init():
	print("\n========================================")
	print("Skill Texture Loading Test")
	print("========================================\n")
	
	await _run_tests()
	
	print("\n========================================")
	print("Test Complete")
	print("========================================")
	_print_summary()
	
	quit()

func _run_tests():
	await _test_texture_loading()
	await _test_skill_integration()

## 测试1: 纹理加载
func _test_texture_loading():
	print("\n[Test 1] Texture Loading")
	
	texture_loader = SkillTextureLoader.new()
	
	var skills = [
		{"name": "ice_shard", "frames": 4},
		{"name": "ice_field", "frames": 8},
		{"name": "ice_storm", "frames": 12},
		{"name": "thunder_strike", "frames": 4},
		{"name": "fire_ball", "frames": 4},
		{"name": "poison_dart", "frames": 4}
	]
	
	var total_loaded = 0
	var total_expected = 0
	
	for skill in skills:
		var frames = texture_loader.load_skill_frames(skill["name"], skill["frames"])
		total_expected += skill["frames"]
		total_loaded += frames.size()
		
		if frames.size() == skill["frames"]:
			print("  [OK] %s: %d/%d frames" % [skill["name"], frames.size(), skill["frames"]])
		else:
			print("  [WARN] %s: %d/%d frames (missing %d)" % [
				skill["name"], 
				frames.size(), 
				skill["frames"],
				skill["frames"] - frames.size()
			])
	
	if total_loaded == total_expected:
		_log_result("Test 1", true, "All textures loaded (%d/%d)" % [total_loaded, total_expected])
	else:
		_log_result("Test 1", false, "Some textures missing (%d/%d)" % [total_loaded, total_expected])

## 测试2: 技能集成测试
func _test_skill_integration():
	print("\n[Test 2] Skill Integration")
	
	# 加载world场景
	var world_scene = load("res://World/world.tscn").instantiate()
	root.add_child(world_scene)
	
	for i in range(30):
		await process_frame
	
	var player = world_scene.get_node_or_null("Player")
	if not player:
		_log_result("Test 2", false, "Player not found")
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
	
	# 测试冰心宗技能
	sect_manager.select_sect("ice")
	
	for i in range(20):
		await process_frame
	
	# 模拟Q技能释放
	var active_skill_mgr = null
	for child in player.get_children():
		if child.has_method("try_cast_skill"):
			active_skill_mgr = child
			break
	
	if active_skill_mgr:
		# 尝试释放Q技能
		var q_skill = active_skill_mgr.get_node_or_null("Q")
		if q_skill and q_skill.has_method("cast"):
			q_skill.cast(player.global_position, Vector2.RIGHT)
			
			for i in range(30):
				await process_frame
			
			# 检查是否生成了IceShard节点
			var ice_shards = world_scene.get_tree().get_nodes_in_group("projectiles")
			var found_animated = false
			
			for node in ice_shards:
				if node.name == "IceShard":
					var sprite = node.get_node_or_null("AnimatedSkillSprite")
					if sprite and sprite.has_method("load_from_skill"):
						found_animated = true
						break
			
			if found_animated or ice_shards.size() > 0:
				_log_result("Test 2", true, "Skill effects spawned (%d projectiles)" % ice_shards.size())
			else:
				_log_result("Test 2", false, "No skill effects found")
		else:
			_log_result("Test 2", false, "Q skill not found")
	else:
		_log_result("Test 2", false, "ActiveSkillManager not found")
	
	world_scene.queue_free()

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
