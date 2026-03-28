extends SceneTree

# 验证重构 - 检查所有新文件是否正确创建和可加载

func _init():
	print("\n========================================")
	print("重构验证测试")
	print("========================================\n")
	
	var all_passed = true
	
	# 阶段 1 验证
	print("阶段 1: 基础架构组件")
	all_passed = check_file("res://Utility/event_bus.gd", "EventBus") and all_passed
	all_passed = check_file("res://Utility/config_manager.gd", "ConfigManager") and all_passed
	all_passed = check_file("res://Skills/base_skill.gd", "BaseSkill") and all_passed
	all_passed = check_file("res://Utility/Effects/base_effect.gd", "BaseEffect") and all_passed
	all_passed = check_file("res://Utility/Effects/stat_modifier_effect.gd", "StatModifierEffect") and all_passed
	all_passed = check_file("res://Utility/Effects/skill_unlock_effect.gd", "SkillUnlockEffect") and all_passed
	all_passed = check_file("res://Utility/Effects/heal_effect.gd", "HealEffect") and all_passed
	all_passed = check_file("res://Utility/Effects/skill_modifier_effect.gd", "SkillModifierEffect") and all_passed
	
	# 阶段 2 验证
	print("\n阶段 2: 技能系统重构")
	all_passed = check_file("res://Skills/skill_registry.gd", "SkillRegistry") and all_passed
	all_passed = check_skill_inheritance("res://Skills/ice_spear.gd", "IceSpear") and all_passed
	all_passed = check_skill_inheritance("res://Skills/tornado.gd", "Tornado") and all_passed
	all_passed = check_skill_inheritance("res://Skills/javelin.gd", "Javelin") and all_passed
	
	# 阶段 3 验证
	print("\n阶段 3: 玩家组件")
	all_passed = check_file("res://Player/Components/player_stats.gd", "PlayerStats") and all_passed
	all_passed = check_file("res://Skills/skill_instance_manager.gd", "SkillInstanceManager") and all_passed
	all_passed = check_file("res://Player/Components/experience_manager.gd", "ExperienceManager") and all_passed
	all_passed = check_file("res://Player/Components/upgrade_manager.gd", "UpgradeManager") and all_passed
	
	print("\n========================================")
	print("验证结果")
	print("========================================")
	
	if all_passed:
		print("\n✓ 所有重构文件验证通过！")
		quit(0)
	else:
		print("\n✗ 部分验证失败")
		quit(1)

func check_file(path: String, expected_name: String = "") -> bool:
	var script = load(path)
	if script == null:
		print("  ✗ 无法加载: %s" % path)
		return false
	
	if expected_name != "":
		print("  ✓ %s 加载成功" % expected_name)
	else:
		print("  ✓ %s 加载成功" % path)
	
	return true

func check_skill_inheritance(path: String, skill_name: String) -> bool:
	var script = load(path)
	if script == null:
		print("  ✗ 无法加载: %s" % path)
		return false
	
	var base_script = script.get_base_script()
	if base_script == null:
		print("  ✗ %s 未继承基类" % skill_name)
		return false
	
	if base_script.get_global_name() != "BaseSkill":
		print("  ✗ %s 未继承 BaseSkill" % skill_name)
		return false
	
	print("  ✓ %s 正确继承 BaseSkill" % skill_name)
	return true
