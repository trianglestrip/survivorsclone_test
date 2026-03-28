extends SceneTree

# 测试升级数量

func _init():
	print("\n=== 升级数量测试 ===\n")
	
	# 直接加载脚本
	var upgrade_db_script = load("res://Utility/upgrade_db.gd")
	var upgrade_db = upgrade_db_script.new()
	
	print("【默认配置】")
	print("  总数: ", upgrade_db._DEFAULT_UPGRADES.size())
	for key in upgrade_db._DEFAULT_UPGRADES:
		var data = upgrade_db._DEFAULT_UPGRADES[key]
		print("  - ", key, ": ", data.get("displayname", ""), " (", data.get("type", ""), ")")
	
	print("\n【实际加载的配置】")
	print("  总数: ", upgrade_db.UPGRADES.size())
	
	if upgrade_db.UPGRADES.size() == 0:
		print("  ⚠️ UPGRADES 为空！")
	else:
		var weapons = 0
		var upgrades = 0
		var items = 0
		
		for key in upgrade_db.UPGRADES:
			var data = upgrade_db.UPGRADES[key]
			var type = data.get("type", "")
			match type:
				"weapon":
					weapons += 1
				"upgrade":
					upgrades += 1
				"item":
					items += 1
		
		print("  武器: ", weapons)
		print("  升级: ", upgrades)
		print("  道具: ", items)
		print("  可选升级总数（武器+升级）: ", weapons + upgrades)
	
	# 分析问题
	print("\n【问题分析】")
	var available_for_selection = upgrade_db.UPGRADES.size()
	var items_count = 0
	for key in upgrade_db.UPGRADES:
		if upgrade_db.UPGRADES[key].get("type", "") == "item":
			items_count += 1
	
	available_for_selection -= items_count  # 减去道具（不会出现在升级选项中）
	
	print("  可用于升级选择的数量: ", available_for_selection)
	print("  假设每级选 1 个，可支持等级: ", available_for_selection + 1)
	
	if available_for_selection < 20:
		print("  ⚠️ 升级池太小！建议至少 20-30 个升级")
		print("  当前只能支持到大约 ", available_for_selection + 1, " 级")
	
	print("\n=== 测试完成 ===")
	quit(0)
