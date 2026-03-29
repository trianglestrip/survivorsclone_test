extends SceneTree

## 输入系统测试
## 验证QER技能和左右键攻击

func _init():
	print("\n" + "=".repeat(70))
	print("输入系统测试")
	print("=".repeat(70) + "\n")
	
	await create_timer(0.1).timeout
	
	var all_passed = true
	
	all_passed = _test_input_mappings() and all_passed
	all_passed = _test_input_manager() and all_passed
	all_passed = _test_active_skill_manager() and all_passed
	all_passed = _test_config() and all_passed
	
	print("\n" + "=".repeat(70))
	if all_passed:
		print("✓ 所有测试通过！")
		print("\n操作说明：")
		print("  WASD - 移动")
		print("  左键/空格 - 近战攻击")
		print("  右键 - 远程攻击（待实现）")
		print("  Shift - 冲刺闪避")
		print("  Q - 宗派技能1（需解锁）")
		print("  E - 宗派技能2（需解锁）")
		print("  T - 必杀技（需解锁）")
		print("  R - 召回飞剑")
	else:
		print("✗ 部分测试失败")
	print("=".repeat(70) + "\n")
	
	quit(0 if all_passed else 1)

func _test_input_mappings() -> bool:
	print("【测试 1: 输入映射】")
	
	var required_actions = [
		"up", "down", "left", "right",
		"click", "attack", "right_click",
		"shift", "skill_q", "skill_e", "skill_t", "recall_sword"
	]
	
	var all_ok = true
	for action in required_actions:
		if InputMap.has_action(action):
			print("  ✓ 输入动作存在: %s" % action)
		else:
			print("  ✗ 缺少输入动作: %s" % action)
			all_ok = false
	
	return all_ok

func _test_input_manager() -> bool:
	print("\n【测试 2: 输入管理器】")
	
	var input_mgr_script = load("res://Player/Components/input_manager.gd")
	if not input_mgr_script:
		print("  ✗ InputManager脚本加载失败")
		return false
	
	var input_mgr = input_mgr_script.new()
	
	var required_signals = [
		"move_input",
		"attack_pressed",
		"secondary_attack_pressed",
		"dash_pressed",
		"skill_q_pressed",
		"skill_e_pressed",
		"skill_t_pressed",
		"recall_sword"
	]
	
	var all_ok = true
	for sig_name in required_signals:
		if input_mgr.has_signal(sig_name):
			print("  ✓ 信号存在: %s" % sig_name)
		else:
			print("  ✗ 缺少信号: %s" % sig_name)
			all_ok = false
	
	var required_methods = [
		"get_move_direction",
		"is_attacking",
		"is_secondary_attacking",
		"is_dashing"
	]
	
	for method_name in required_methods:
		if input_mgr.has_method(method_name):
			print("  ✓ 方法存在: %s" % method_name)
		else:
			print("  ✗ 缺少方法: %s" % method_name)
			all_ok = false
	
	input_mgr.free()
	return all_ok

func _test_active_skill_manager() -> bool:
	print("\n【测试 3: 主动技能管理器】")
	
	var skill_mgr_path = "res://Player/Components/active_skill_manager.gd"
	if not ResourceLoader.exists(skill_mgr_path):
		print("  ✗ ActiveSkillManager脚本不存在")
		return false
	
	var skill_mgr_script = load(skill_mgr_path)
	if not skill_mgr_script:
		print("  ✗ ActiveSkillManager脚本加载失败")
		return false
	
	var skill_mgr = skill_mgr_script.new()
	
	var required_methods = [
		"try_cast_skill",
		"unlock_skill",
		"is_skill_unlocked",
		"is_skill_on_cooldown",
		"get_skill_cooldown_progress"
	]
	
	var all_ok = true
	for method_name in required_methods:
		if skill_mgr.has_method(method_name):
			print("  ✓ 方法存在: %s" % method_name)
		else:
			print("  ✗ 缺少方法: %s" % method_name)
			all_ok = false
	
	var required_signals = [
		"skill_cast",
		"skill_cooldown_started",
		"skill_cooldown_updated",
		"skill_ready"
	]
	
	for sig_name in required_signals:
		if skill_mgr.has_signal(sig_name):
			print("  ✓ 信号存在: %s" % sig_name)
		else:
			print("  ✗ 缺少信号: %s" % sig_name)
			all_ok = false
	
	skill_mgr.free()
	return all_ok

func _test_config() -> bool:
	print("\n【测试 4: 配置文件】")
	
	var config = _load_json("res://config/stage1_controls.json")
	if not config:
		print("  ✗ 配置文件加载失败")
		return false
	
	var all_ok = true
	
	if config.has("primary_attack"):
		print("  ✓ 主攻击配置存在（左键/空格）")
	else:
		print("  ✗ 缺少主攻击配置")
		all_ok = false
	
	if config.has("secondary_attack"):
		print("  ✓ 副攻击配置存在（右键）")
	else:
		print("  ✗ 缺少副攻击配置")
		all_ok = false
	
	if config.has("skills"):
		var skills = config["skills"]
		for key in ["q", "e", "r"]:
			if skills.has(key):
				print("  ✓ 技能配置存在: %s" % key.to_upper())
			else:
				print("  ✗ 缺少技能配置: %s" % key.to_upper())
				all_ok = false
	else:
		print("  ✗ 缺少技能配置")
		all_ok = false
	
	return all_ok

func _load_json(path: String) -> Dictionary:
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		return {}
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	if json.parse(json_string) == OK:
		return json.data
	return {}
