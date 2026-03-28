extends SceneTree

# 测试升级池是否足够

func _init():
	print("\n=== 升级池测试 ===\n")
	
	# 测试 UpgradeDb
	var upgrade_db_scene = load("res://Utility/upgrade_db.tscn")
	var upgrade_db = upgrade_db_scene.instantiate()
	
	# 等待 _ready 执行
	await get_root().ready
	
	print("【UpgradeDb 内容】")
	print("  总升级数: ", upgrade_db.UPGRADES.size())
	
	var weapons = []
	var upgrades = []
	var items = []
	
	for upgrade_id in upgrade_db.UPGRADES:
		var upgrade_data = upgrade_db.UPGRADES[upgrade_id]
		var type = upgrade_data.get("type", "")
		match type:
			"weapon":
				weapons.append(upgrade_id)
			"upgrade":
				upgrades.append(upgrade_id)
			"item":
				items.append(upgrade_id)
	
	print("  武器数量: ", weapons.size())
	print("  升级数量: ", upgrades.size())
	print("  道具数量: ", items.size())
	
	print("\n【武器列表】")
	for w in weapons:
		print("  - ", w, ": ", upgrade_db.UPGRADES[w]["displayname"])
	
	print("\n【升级列表】")
	for u in upgrades:
		print("  - ", u, ": ", upgrade_db.UPGRADES[u]["displayname"])
	
	print("\n【道具列表】")
	for i in items:
		print("  - ", i, ": ", upgrade_db.UPGRADES[i]["displayname"])
	
	# 模拟升级选择
	print("\n【模拟升级选择】")
	var stats_script = load("res://Player/Components/player_stats.gd")
	var stats = stats_script.new()
	
	var skill_mgr_script = load("res://Player/Components/skill_manager.gd")
	var skill_mgr = skill_mgr_script.new()
	
	var upgrade_mgr_script = load("res://Player/Components/upgrade_manager.gd")
	var upgrade_mgr = upgrade_mgr_script.new()
	upgrade_mgr.set_player_stats(stats)
	upgrade_mgr.set_skill_manager(skill_mgr)
	
	# 模拟收集升级
	var collected = ["icespear1"]
	upgrade_mgr.collected_upgrades = collected.duplicate()
	
	print("  已收集: ", collected)
	
	# 尝试获取 10 次升级选项
	var level = 2
	while level <= 10:
		print("\n  等级 ", level, " 升级选项:")
		upgrade_mgr.clear_upgrade_options()
		
		var options = []
		for i in range(3):
			var option = upgrade_mgr.get_random_upgrade()
			if option != "":
				options.append(option)
				print("    选项 ", i+1, ": ", option)
			else:
				print("    选项 ", i+1, ": 无可用升级！")
		
		if options.size() == 0:
			print("  ⚠️ 等级 ", level, " 没有任何升级可选！")
			break
		elif options.size() < 3:
			print("  ⚠️ 等级 ", level, " 只有 ", options.size(), " 个升级可选")
		
		# 模拟选择第一个
		if options.size() > 0:
			upgrade_mgr.collected_upgrades.append(options[0])
			print("  选择: ", options[0])
		
		level += 1
	
	print("\n=== 测试完成 ===")
	quit(0)
