extends SceneTree

# 阶段 3 测试：玩家类拆分

func _init():
	print("\n========================================")
	print("开始阶段 3 测试：玩家类拆分")
	print("========================================\n")
	
	var all_passed = true
	
	all_passed = test_player_stats() and all_passed
	all_passed = test_skill_manager() and all_passed
	all_passed = test_experience_manager() and all_passed
	all_passed = test_upgrade_manager() and all_passed
	all_passed = test_player_refactored() and all_passed
	
	print("\n========================================")
	print("测试结果汇总")
	print("========================================")
	
	if all_passed:
		print("\n✓ 阶段 3 所有测试通过！")
		quit(0)
	else:
		print("\n✗ 阶段 3 有测试失败")
		quit(1)

func test_player_stats() -> bool:
	print("测试 1: PlayerStats 组件")
	
	var stats_script = load("res://Player/Components/player_stats.gd")
	if stats_script == null:
		print("  ✗ 无法加载 player_stats.gd")
		return false
	
	var stats = stats_script.new()
	
	# 测试基础属性
	if stats.hp != 80 or stats.maxhp != 80:
		print("  ✗ PlayerStats 初始属性不正确")
		return false
	
	# 测试治疗
	stats.hp = 50
	var healed = stats.heal(20)
	if stats.hp != 70 or healed != 20:
		print("  ✗ PlayerStats heal 方法失败")
		return false
	
	# 测试受伤
	stats.armor = 5
	var actual_damage = stats.take_damage(10)
	if actual_damage != 5 or stats.hp != 65:
		print("  ✗ PlayerStats take_damage 方法失败")
		return false
	
	# 测试存活检查
	if not stats.is_alive():
		print("  ✗ PlayerStats is_alive 方法失败")
		return false
	
	print("  ✓ PlayerStats 测试通过")
	return true

func test_skill_manager() -> bool:
	print("测试 2: SkillManager 组件")
	
	var skill_mgr_script = load("res://Player/Components/skill_manager.gd")
	if skill_mgr_script == null:
		print("  ✗ 无法加载 skill_manager.gd")
		return false
	
	var skill_mgr = skill_mgr_script.new()
	
	# 测试技能等级
	skill_mgr.set_skill_level("icespear", 3)
	if skill_mgr.get_skill_level("icespear") != 3:
		print("  ✗ SkillManager 技能等级设置失败")
		return false
	
	# 测试技能弹药
	skill_mgr.add_skill_ammo("icespear", 5)
	if skill_mgr.get_skill_base_ammo("icespear") != 5:
		print("  ✗ SkillManager 弹药添加失败")
		return false
	
	# 测试技能解锁检查
	if not skill_mgr.is_skill_unlocked("icespear"):
		print("  ✗ SkillManager 技能解锁检查失败")
		return false
	
	print("  ✓ SkillManager 测试通过")
	return true

func test_experience_manager() -> bool:
	print("测试 3: ExperienceManager 组件")
	
	var exp_mgr_script = load("res://Player/Components/experience_manager.gd")
	if exp_mgr_script == null:
		print("  ✗ 无法加载 experience_manager.gd")
		return false
	
	var stats_script = load("res://Player/Components/player_stats.gd")
	var stats = stats_script.new()
	
	var exp_mgr = exp_mgr_script.new()
	exp_mgr.set_player_stats(stats)
	
	# 测试经验值上限计算
	var exp_cap = exp_mgr.calculate_experience_cap()
	if exp_cap != 5:  # 等级 1，应该是 1*5 = 5
		print("  ✗ ExperienceManager 经验值上限计算错误: %d" % exp_cap)
		return false
	
	# 测试添加经验值
	var level_up_triggered = false
	exp_mgr.level_up.connect(func(_level): level_up_triggered = true)
	
	exp_mgr.add_experience(5)  # 应该升级
	
	if not level_up_triggered:
		print("  ✗ ExperienceManager 升级事件未触发")
		return false
	
	if stats.experience_level != 2:
		print("  ✗ ExperienceManager 等级未正确更新")
		return false
	
	print("  ✓ ExperienceManager 测试通过")
	return true

func test_upgrade_manager() -> bool:
	print("测试 4: UpgradeManager 组件")
	
	var upgrade_mgr_script = load("res://Player/Components/upgrade_manager.gd")
	if upgrade_mgr_script == null:
		print("  ✗ 无法加载 upgrade_manager.gd")
		return false
	
	var stats_script = load("res://Player/Components/player_stats.gd")
	var skill_mgr_script = load("res://Player/Components/skill_manager.gd")
	
	var stats = stats_script.new()
	var skill_mgr = skill_mgr_script.new()
	var upgrade_mgr = upgrade_mgr_script.new()
	
	upgrade_mgr.set_player_stats(stats)
	upgrade_mgr.set_skill_manager(skill_mgr)
	
	# 测试应用升级
	upgrade_mgr.apply_upgrade("armor1")
	
	if stats.armor != 1:
		print("  ✗ UpgradeManager 护甲升级失败")
		return false
	
	if not upgrade_mgr.has_upgrade("armor1"):
		print("  ✗ UpgradeManager 升级记录失败")
		return false
	
	# 测试获取随机升级
	var random_upgrade = upgrade_mgr.get_random_upgrade()
	if random_upgrade == "":
		print("  ✗ UpgradeManager 获取随机升级失败")
		return false
	
	print("  ✓ UpgradeManager 测试通过")
	return true

func test_player_refactored() -> bool:
	print("测试 5: Player 重构验证")
	
	var player_script = load("res://Player/player_refactored.gd")
	if player_script == null:
		print("  ✗ 无法加载 player_refactored.gd")
		return false
	
	# 验证脚本可以正常解析
	print("  ✓ Player 重构脚本加载成功")
	return true
