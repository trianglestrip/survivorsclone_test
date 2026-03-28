extends SceneTree

# 测试配置加载和验证系统

func _init():
	var sep = "============================================================"
	print("\n" + sep)
	print("测试：配置加载和验证")
	print(sep)
	
	var all_passed = true
	
	# 等待 Autoload 初始化
	await create_timer(0.5).timeout
	
	# 测试 1: UpgradeDb 是否已加载
	print("\n[测试 1] UpgradeDb 是否已加载")
	if not root.has_node("/root/UpgradeDb"):
		print("  ❌ 失败: UpgradeDb Autoload 不存在")
		all_passed = false
		quit(1)
		return
	
	var upgrade_db = root.get_node("/root/UpgradeDb")
	print("  ✓ UpgradeDb 已加载")
	
	# 测试 2: 升级数据是否已加载
	print("\n[测试 2] 升级数据是否已加载")
	if upgrade_db.UPGRADES.size() == 0:
		print("  ❌ 失败: UPGRADES 为空")
		all_passed = false
	else:
		print("  ✓ 已加载 %d 个升级" % upgrade_db.UPGRADES.size())
	
	# 测试 3: 检查必需的初始武器
	print("\n[测试 3] 检查初始武器")
	var required_weapons = ["icespear1", "tornado1", "javelin1"]
	for weapon_id in required_weapons:
		if not upgrade_db.UPGRADES.has(weapon_id):
			print("  ❌ 失败: 缺少初始武器 '%s'" % weapon_id)
			all_passed = false
		else:
			var weapon = upgrade_db.UPGRADES[weapon_id]
			if not weapon.has("spell"):
				print("  ❌ 失败: 武器 '%s' 缺少 spell 字段" % weapon_id)
				all_passed = false
			else:
				print("  ✓ 武器 '%s' 配置正确 (spell=%s)" % [weapon_id, weapon["spell"]])
	
	# 测试 4: 检查属性升级
	print("\n[测试 4] 检查属性升级")
	var required_upgrades = ["armor1", "speed1", "tome1", "scroll1"]
	for upgrade_id in required_upgrades:
		if not upgrade_db.UPGRADES.has(upgrade_id):
			print("  ❌ 失败: 缺少升级 '%s'" % upgrade_id)
			all_passed = false
		else:
			print("  ✓ 升级 '%s' 存在" % upgrade_id)
	
	# 测试 5: 检查升级链的完整性
	print("\n[测试 5] 检查升级链完整性")
	for upgrade_id in upgrade_db.UPGRADES:
		var data = upgrade_db.UPGRADES[upgrade_id]
		var prereqs = data.get("prerequisite", [])
		
		for prereq in prereqs:
			if not upgrade_db.UPGRADES.has(prereq):
				print("  ❌ 失败: 升级 '%s' 的前置条件 '%s' 不存在" % [upgrade_id, prereq])
				all_passed = false
	
	if all_passed:
		print("  ✓ 所有升级链完整")
	
	# 测试 6: 统计升级类型
	print("\n[测试 6] 升级类型统计")
	var type_counts = {}
	for upgrade_id in upgrade_db.UPGRADES:
		var type = upgrade_db.UPGRADES[upgrade_id].get("type", "unknown")
		if not type_counts.has(type):
			type_counts[type] = 0
		type_counts[type] += 1
	
	for type in type_counts:
		print("  %s: %d 个" % [type, type_counts[type]])
	
	# 最终结果
	print("\n" + sep)
	if all_passed:
		print("✓ 所有测试通过！配置系统正常工作")
	else:
		print("❌ 部分测试失败，请检查配置")
	print(sep)
	
	quit(0 if all_passed else 1)
