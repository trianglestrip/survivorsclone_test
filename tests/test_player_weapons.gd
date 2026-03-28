extends SceneTree

# 测试玩家武器是否正常工作

func _init():
	var sep = "============================================================"
	print("\n" + sep)
	print("玩家武器测试")
	print(sep + "\n")
	
	# 测试 UpgradeDb 加载
	print("【测试 1】UpgradeDb 加载")
	test_upgrade_db()
	
	print("\n【测试 2】SkillManager 初始化")
	test_skill_manager()
	
	print("\n【测试 3】UpgradeManager 应用升级")
	test_upgrade_application()
	
	print("\n" + sep)
	print("测试完成")
	print(sep)
	quit(0)

func test_upgrade_db():
	# 加载 UpgradeDb 脚本
	var upgrade_db_script = load("res://Utility/upgrade_db.gd")
	if upgrade_db_script == null:
		print("  ✗ 无法加载 upgrade_db.gd")
		return
	
	var upgrade_db = upgrade_db_script.new()
	print("  ✓ UpgradeDb 已加载")
	print("  升级数量: ", upgrade_db.UPGRADES.size())
	
	if upgrade_db.UPGRADES.has("icespear1"):
		var icespear1 = upgrade_db.UPGRADES["icespear1"]
		print("  icespear1 配置:")
		print("    displayname: ", icespear1.get("displayname", "N/A"))
		print("    type: ", icespear1.get("type", "N/A"))
		print("    spell: ", icespear1.get("spell", "N/A"))
		print("    set_level: ", icespear1.get("set_level", "N/A"))
		print("    add_baseammo: ", icespear1.get("add_baseammo", "N/A"))
	else:
		print("  ✗ icespear1 不存在于 UPGRADES")

func test_skill_manager():
	var skill_mgr_script = load("res://Player/Components/skill_manager.gd")
	var skill_mgr = skill_mgr_script.new()
	
	print("  初始 icespear 等级: ", skill_mgr.get_skill_level("icespear"))
	print("  初始 icespear base_ammo: ", skill_mgr.get_skill_base_ammo("icespear"))
	
	# 模拟升级
	skill_mgr.set_skill_level("icespear", 1)
	skill_mgr.add_skill_ammo("icespear", 1)
	
	print("  设置后 icespear 等级: ", skill_mgr.get_skill_level("icespear"))
	print("  设置后 icespear base_ammo: ", skill_mgr.get_skill_base_ammo("icespear"))

func test_upgrade_application():
	var stats_script = load("res://Player/Components/player_stats.gd")
	var stats = stats_script.new()
	
	var skill_mgr_script = load("res://Player/Components/skill_manager.gd")
	var skill_mgr = skill_mgr_script.new()
	
	var upgrade_mgr_script = load("res://Player/Components/upgrade_manager.gd")
	var upgrade_mgr = upgrade_mgr_script.new()
	upgrade_mgr.set_player_stats(stats)
	upgrade_mgr.set_skill_manager(skill_mgr)
	
	print("  应用升级前:")
	print("    icespear 等级: ", skill_mgr.get_skill_level("icespear"))
	print("    icespear base_ammo: ", skill_mgr.get_skill_base_ammo("icespear"))
	
	upgrade_mgr.apply_upgrade("icespear1")
	
	print("  应用升级后:")
	print("    icespear 等级: ", skill_mgr.get_skill_level("icespear"))
	print("    icespear base_ammo: ", skill_mgr.get_skill_base_ammo("icespear"))
