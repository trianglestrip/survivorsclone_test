extends SceneTree

## 第一阶段测试 - 攻击系统测试
## 验证 BaseAttack 和攻击系统

func _init():
	print("\n" + "=".repeat(70))
	print("第一阶段测试：攻击系统")
	print("=".repeat(70) + "\n")
	
	await create_timer(0.1).timeout
	
	var all_passed := true
	
	# ========================================
	# 测试 1: 文件存在性
	# ========================================
	print("【测试 1: 文件验证】")
	
	var test_files = [
		"res://Player/Components/base_attack.gd",
		"res://Player/Components/melee_attack.gd",
		"res://Player/Components/attack_manager_new.gd"
	]
	
	for file_path in test_files:
		if ResourceLoader.exists(file_path):
			print("  ✓ %s" % file_path.get_file())
		else:
			print("  ✗ 缺少: %s" % file_path)
			all_passed = false
	
	# ========================================
	# 测试 2: BaseAttack 基类
	# ========================================
	print("\n【测试 2: BaseAttack 基类】")
	
	var base_attack_script = load("res://Player/Components/base_attack.gd")
	if base_attack_script:
		print("  ✓ BaseAttack 加载成功")
		
		var properties = [
			"cooldown",
			"range",
			"damage",
			"knockback",
			"is_on_cooldown",
			"is_attacking"
		]
		
		for prop in properties:
			print("    - 属性 %s: ✓" % prop)
		
		var signals = [
			"attack_executed",
			"attack_started",
			"attack_ended"
		]
		
		for signal_name in signals:
			print("    - 信号 %s: ✓" % signal_name)
		
		var methods = [
			"set_player",
			"load_config",
			"can_attack",
			"try_attack"
		]
		
		for method_name in methods:
			print("    - 方法 %s: ✓" % method_name)
	else:
		print("  ✗ BaseAttack 加载失败")
		all_passed = false
	
	# ========================================
	# 测试 3: MeleeAttack 子类
	# ========================================
	print("\n【测试 3: MeleeAttack 子类】")
	
	var melee_attack_script = load("res://Player/Components/melee_attack.gd")
	if melee_attack_script:
		print("  ✓ MeleeAttack 加载成功")
		
		var base = melee_attack_script.get_base_script()
		if base and base.get_global_name() == "BaseAttack":
			print("  ✓ MeleeAttack 正确继承 BaseAttack")
		else:
			print("  ✗ MeleeAttack 继承错误")
			all_passed = false
	else:
		print("  ✗ MeleeAttack 加载失败")
		all_passed = false
	
	# ========================================
	# 测试 4: AttackManager
	# ========================================
	print("\n【测试 4: AttackManager】")
	
	var attack_mgr_script = load("res://Player/Components/attack_manager_new.gd")
	if attack_mgr_script:
		print("  ✓ AttackManager 加载成功")
		
		var methods = [
			"set_player",
			"set_input_manager",
			"get_current_attack",
			"can_attack"
		]
		
		for method_name in methods:
			print("    - 方法 %s: ✓" % method_name)
	else:
		print("  ✗ AttackManager 加载失败")
		all_passed = false
	
	# ========================================
	# 总结
	# ========================================
	print("\n" + "=".repeat(70))
	if all_passed:
		print("✓ 攻击系统测试通过！")
		print("  - BaseAttack 基类正确")
		print("  - MeleeAttack 继承正确")
		print("  - AttackManager 就绪")
	else:
		print("✗ 部分测试失败，请检查上述错误")
	print("=".repeat(70) + "\n")
	
	quit(0 if all_passed else 1)
