extends SceneTree

# 阶段 2 测试：技能系统重构

func _init():
	print("\n========================================")
	print("开始阶段 2 测试：技能系统重构")
	print("========================================\n")
	
	var all_passed = true
	
	all_passed = test_skill_registry() and all_passed
	all_passed = test_ice_spear_refactor() and all_passed
	all_passed = test_tornado_refactor() and all_passed
	all_passed = test_javelin_refactor() and all_passed
	
	print("\n========================================")
	print("测试结果汇总")
	print("========================================")
	
	if all_passed:
		print("\n✓ 阶段 2 所有测试通过！")
		quit(0)
	else:
		print("\n✗ 阶段 2 有测试失败")
		quit(1)

func test_skill_registry() -> bool:
	print("测试 1: SkillRegistry 技能注册系统")
	
	var registry_script = load("res://Skills/skill_registry.gd")
	if registry_script == null:
		print("  ✗ 无法加载 skill_registry.gd")
		return false
	
	var registry = registry_script.new()
	registry._register_default_skills()
	
	# 测试技能是否已注册
	var required_skills = ["IceSpear", "Tornado", "Javelin"]
	for skill_id in required_skills:
		if not registry.has_skill(skill_id):
			print("  ✗ 技能未注册: %s" % skill_id)
			return false
	
	# 测试获取技能场景
	var ice_spear_scene = registry.get_skill_scene("IceSpear")
	if ice_spear_scene == null:
		print("  ✗ 无法获取 IceSpear 场景")
		return false
	
	print("  ✓ SkillRegistry 测试通过")
	return true

func test_ice_spear_refactor() -> bool:
	print("测试 2: IceSpear 重构验证")
	
	var ice_spear_script = load("res://Skills/ice_spear.gd")
	if ice_spear_script == null:
		print("  ✗ 无法加载 ice_spear.gd")
		return false
	
	# 验证继承关系
	var base_script = ice_spear_script.get_base_script()
	if base_script == null:
		print("  ✗ IceSpear 未继承基类")
		return false
	
	if base_script.get_global_name() != "BaseSkill":
		print("  ✗ IceSpear 未继承 BaseSkill")
		return false
	
	print("  ✓ IceSpear 重构验证通过")
	return true

func test_tornado_refactor() -> bool:
	print("测试 3: Tornado 重构验证")
	
	var tornado_script = load("res://Skills/tornado.gd")
	if tornado_script == null:
		print("  ✗ 无法加载 tornado.gd")
		return false
	
	# 验证继承关系
	var base_script = tornado_script.get_base_script()
	if base_script == null:
		print("  ✗ Tornado 未继承基类")
		return false
	
	if base_script.get_global_name() != "BaseSkill":
		print("  ✗ Tornado 未继承 BaseSkill")
		return false
	
	print("  ✓ Tornado 重构验证通过")
	return true

func test_javelin_refactor() -> bool:
	print("测试 4: Javelin 重构验证")
	
	var javelin_script = load("res://Skills/javelin.gd")
	if javelin_script == null:
		print("  ✗ 无法加载 javelin.gd")
		return false
	
	# 验证继承关系
	var base_script = javelin_script.get_base_script()
	if base_script == null:
		print("  ✗ Javelin 未继承基类")
		return false
	
	if base_script.get_global_name() != "BaseSkill":
		print("  ✗ Javelin 未继承 BaseSkill")
		return false
	
	print("  ✓ Javelin 重构验证通过")
	return true
