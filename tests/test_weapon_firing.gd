extends Node

# 测试武器发射逻辑

var test_player
var stats
var skill_mgr
var upgrade_mgr

func _ready():
	print("\n=== 武器发射测试 ===\n")
	
	# 创建测试玩家节点
	test_player = Node2D.new()
	add_child(test_player)
	
	# 初始化组件
	var stats_script = load("res://Player/Components/player_stats.gd")
	stats = stats_script.new()
	test_player.add_child(stats)
	
	var skill_mgr_script = load("res://Skills/skill_manager.gd")
	skill_mgr = skill_mgr_script.new()
	skill_mgr.set_player(test_player)
	test_player.add_child(skill_mgr)
	
	var upgrade_mgr_script = load("res://Player/Components/upgrade_manager.gd")
	upgrade_mgr = upgrade_mgr_script.new()
	upgrade_mgr.set_player_stats(stats)
	upgrade_mgr.set_skill_manager(skill_mgr)
	test_player.add_child(upgrade_mgr)
	
	print("【步骤 1】初始状态")
	print_skill_status()
	
	print("\n【步骤 2】应用 icespear1 升级")
	upgrade_mgr.apply_upgrade("icespear1")
	print_skill_status()
	
	print("\n【步骤 3】模拟计时器触发")
	simulate_timer_logic()
	
	print("\n=== 测试完成 ===")
	get_tree().quit()

func print_skill_status():
	print("  icespear 等级: ", skill_mgr.get_skill_level("icespear"))
	print("  icespear base_ammo: ", skill_mgr.get_skill_base_ammo("icespear"))
	print("  icespear ammo: ", skill_mgr.get_skill_ammo("icespear"))
	print("  icespear attack_speed: ", skill_mgr.get_skill_attack_speed("icespear"))

func simulate_timer_logic():
	# 模拟 _on_ice_spear_timer_timeout
	var icespear_level = skill_mgr.get_skill_level("icespear")
	print("  检查 icespear 等级: ", icespear_level)
	
	if icespear_level > 0:
		print("  ✓ icespear 已解锁")
		
		# 模拟设置弹药
		var base_ammo = skill_mgr.get_skill_base_ammo("icespear")
		var additional_attacks = stats.additional_attacks
		var total_ammo = base_ammo + additional_attacks
		
		print("  base_ammo: ", base_ammo)
		print("  additional_attacks: ", additional_attacks)
		print("  total_ammo: ", total_ammo)
		
		skill_mgr.set_skill_ammo("icespear", total_ammo)
		print("  设置后 ammo: ", skill_mgr.get_skill_ammo("icespear"))
		
		if skill_mgr.get_skill_ammo("icespear") > 0:
			print("  ✓ 应该发射冰矛！")
		else:
			print("  ✗ 弹药为 0，不会发射")
	else:
		print("  ✗ icespear 未解锁")
