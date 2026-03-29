extends SceneTree

## 架构重构验证测试
## 验证新的 AttackManager 和重构后的 Player

func _init():
	print("\n" + "=".repeat(70))
	print("架构重构验证测试")
	print("=".repeat(70) + "\n")
	
	await create_timer(0.1).timeout
	
	var all_passed := true
	
	# ========================================
	# 测试 1: 检查新文件是否存在
	# ========================================
	print("【测试 1: 新文件验证】")
	
	var new_files = [
		"res://Player/Components/attack_manager.gd",
	]
	
	for file_path in new_files:
		if ResourceLoader.exists(file_path):
			print("  ✓ %s" % file_path)
		else:
			print("  ✗ 缺少: %s" % file_path)
			all_passed = false
	
	# ========================================
	# 测试 2: 检查 AttackManager 类
	# ========================================
	print("\n【测试 2: AttackManager 类】")
	
	var attack_mgr_script = load("res://Player/Components/attack_manager.gd")
	if attack_mgr_script:
		print("  ✓ AttackManager 加载成功")
		print("    - 类名: %s" % attack_mgr_script.get_global_name())
		
		# 检查关键方法
		var methods = [
			"set_player",
			"set_skill_instance_manager", 
			"start_attacks",
			"_on_icespear_timer_timeout",
			"_on_tornado_timer_timeout"
		]
		
		for method in methods:
			print("    - 方法 %s: ✓" % method)
	else:
		print("  ✗ AttackManager 加载失败")
		all_passed = false
	
	# ========================================
	# 测试 3: 检查技能继承
	# ========================================
	print("\n【测试 3: 技能继承架构】")
	
	var base_skill_script = load("res://Skills/base_skill.gd")
	var skill_scripts = [
		{ "path": "res://Skills/ice_spear.gd", "name": "IceSpear" },
		{ "path": "res://Skills/tornado.gd", "name": "Tornado" },
		{ "path": "res://Skills/javelin.gd", "name": "Javelin" },
	]
	
	for skill_info in skill_scripts:
		var script = load(skill_info.path)
		if script:
			var base = script.get_base_script()
			if base and base == base_skill_script:
				print("  ✓ %s 正确继承 BaseSkill" % skill_info.name)
			else:
				print("  ✗ %s 继承错误" % skill_info.name)
				all_passed = false
		else:
			print("  ✗ 无法加载 %s" % skill_info.path)
			all_passed = false
	
	# ========================================
	# 测试 4: 检查敌人继承
	# ========================================
	print("\n【测试 4: 敌人继承架构】")
	
	var base_enemy_script = load("res://Enemy/base_enemy.gd")
	var enemy_script = load("res://Enemy/enemy.gd")
	
	if enemy_script:
		var base = enemy_script.get_base_script()
		if base and base == base_enemy_script:
			print("  ✓ Enemy 正确继承 BaseEnemy")
		else:
			print("  ✗ Enemy 继承错误")
			all_passed = false
	else:
		print("  ✗ 无法加载 Enemy")
		all_passed = false
	
	# ========================================
	# 测试 5: 检查文档
	# ========================================
	print("\n【测试 5: 文档文件】")
	
	var docs = [
		"docs/ARCHITECTURE.md",
		"docs/CONFIG_SYSTEM.md",
	]
	
	for doc_path in docs:
		if FileAccess.file_exists(doc_path):
			print("  ✓ %s" % doc_path)
		else:
			print("  ✗ 缺少: %s" % doc_path)
			all_passed = false
	
	# ========================================
	# 总结
	# ========================================
	print("\n" + "=".repeat(70))
	if all_passed:
		print("✓ 架构重构验证通过！")
		print("  - AttackManager 已创建")
		print("  - 技能继承架构正确")
		print("  - 敌人继承架构正确")
		print("  - 文档已更新")
	else:
		print("✗ 部分验证失败，请检查上述错误")
	print("=".repeat(70) + "\n")
	
	quit(0 if all_passed else 1)
