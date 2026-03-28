extends Node

# 在场景树中测试组件

func _ready():
	print("\n=== 场景树测试 ===")
	
	# 测试 Autoload
	print("\n【Autoload 检查】")
	print("  EventBus: ", has_node("/root/EventBus"))
	print("  ConfigManager: ", has_node("/root/ConfigManager"))
	print("  SkillRegistry: ", has_node("/root/SkillRegistry"))
	print("  EnemyRegistry: ", has_node("/root/EnemyRegistry"))
	print("  ObjectPool: ", has_node("/root/ObjectPool"))
	print("  UpgradeDb: ", has_node("/root/UpgradeDb"))
	
	# 测试 UpgradeDb
	if has_node("/root/UpgradeDb"):
		var upgrade_db = get_node("/root/UpgradeDb")
		print("\n【UpgradeDb 内容】")
		print("  升级数量: ", upgrade_db.UPGRADES.size())
		if upgrade_db.UPGRADES.has("icespear1"):
			var icespear1 = upgrade_db.UPGRADES["icespear1"]
			print("  icespear1:")
			print("    spell: ", icespear1.get("spell", "N/A"))
			print("    set_level: ", icespear1.get("set_level", "N/A"))
			print("    add_baseammo: ", icespear1.get("add_baseammo", "N/A"))
	
	# 测试组件
	print("\n【组件测试】")
	var stats_script = load("res://Player/Components/player_stats.gd")
	var stats = stats_script.new()
	add_child(stats)
	
	var skill_mgr_script = load("res://Skills/skill_manager.gd")
	var skill_mgr = skill_mgr_script.new()
	add_child(skill_mgr)
	
	var upgrade_mgr_script = load("res://Player/Components/upgrade_manager.gd")
	var upgrade_mgr = upgrade_mgr_script.new()
	upgrade_mgr.set_player_stats(stats)
	upgrade_mgr.set_skill_manager(skill_mgr)
	add_child(upgrade_mgr)
	
	print("  应用升级前 icespear 等级: ", skill_mgr.get_skill_level("icespear"))
	print("  应用升级前 icespear base_ammo: ", skill_mgr.get_skill_base_ammo("icespear"))
	
	upgrade_mgr.apply_upgrade("icespear1")
	
	print("  应用升级后 icespear 等级: ", skill_mgr.get_skill_level("icespear"))
	print("  应用升级后 icespear base_ammo: ", skill_mgr.get_skill_base_ammo("icespear"))
	
	print("\n=== 测试完成 ===")
	get_tree().quit()
