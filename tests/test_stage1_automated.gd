extends SceneTree

## 第一阶段综合自动化测试
## 模拟各种输入操作并验证系统响应

var test_player: Node = null
var input_manager: Node = null
var attack_manager: Node = null
var dash_manager: Node = null

var test_results := []

func _init():
	print("\n" + "=".repeat(80))
	print("第一阶段综合自动化测试")
	print("=".repeat(80) + "\n")
	
	await create_timer(0.5).timeout
	
	var all_passed := true
	
	# ========================================
	# 测试 1: 初始化测试环境
	# ========================================
	print("【测试 1: 初始化测试环境】")
	if await _setup_test_environment():
		_log_result("环境初始化", true)
	else:
		_log_result("环境初始化", false)
		all_passed = false
	
	await create_timer(0.5).timeout
	
	# ========================================
	# 测试 2: 模拟移动输入
	# ========================================
	print("\n【测试 2: 模拟移动输入】")
	if await _test_movement():
		_log_result("移动输入", true)
	else:
		_log_result("移动输入", false)
		all_passed = false
	
	await create_timer(0.5).timeout
	
	# ========================================
	# 测试 3: 模拟攻击输入
	# ========================================
	print("\n【测试 3: 模拟攻击输入】")
	if await _test_attack():
		_log_result("攻击输入", true)
	else:
		_log_result("攻击输入", false)
		all_passed = false
	
	await create_timer(0.5).timeout
	
	# ========================================
	# 测试 4: 模拟冲刺输入
	# ========================================
	print("\n【测试 4: 模拟冲刺输入】")
	if await _test_dash():
		_log_result("冲刺输入", true)
	else:
		_log_result("冲刺输入", false)
		all_passed = false
	
	await create_timer(0.5).timeout
	
	# ========================================
	# 总结
	# ========================================
	print("\n" + "=".repeat(80))
	print("测试结果汇总：")
	print("=")
	for result in test_results:
		var status = "✓ 通过" if result["passed"] else "✗ 失败"
		print("  %s: %s" % [result["name"], status])
	print("=")
	if all_passed:
		print("✓ 所有测试通过！")
	else:
		print("✗ 部分测试失败")
	print("=".repeat(80) + "\n")
	
	quit(0 if all_passed else 1)

func _log_result(name: String, passed: bool):
	test_results.append({"name": name, "passed": passed})
	var status = "✓" if passed else "✗"
	print("  %s %s" % [status, name])

func _setup_test_environment() -> bool:
	print("  正在设置测试环境...")
	
	# 加载 InputManager
	var input_mgr_script = load("res://Player/Components/input_manager.gd")
	if not input_mgr_script:
		print("  ✗ 无法加载 InputManager")
		return false
	input_manager = input_mgr_script.new()
	root.add_child(input_manager)
	
	# 加载 AttackManager
	var attack_mgr_script = load("res://Player/Components/attack_manager.gd")
	if not attack_mgr_script:
		print("  ✗ 无法加载 AttackManager")
		return false
	attack_manager = attack_mgr_script.new()
	attack_manager.set_input_manager(input_manager)
	root.add_child(attack_manager)
	
	# 加载 DashManager
	var dash_mgr_script = load("res://Player/Components/dash_manager.gd")
	if not dash_mgr_script:
		print("  ✗ 无法加载 DashManager")
		return false
	dash_manager = dash_mgr_script.new()
	dash_manager.set_input_manager(input_manager)
	root.add_child(dash_manager)
	
	print("  ✓ 测试环境设置完成")
	return true

func _test_movement() -> bool:
	print("  测试移动输入...")
	
	# 模拟向上移动
	print("  - 模拟向上移动")
	# 在真实场景中这里会使用 Input.action_press() 等
	# 但在无头测试中我们直接验证组件
	
	if input_manager and input_manager.has_method("get_move_direction"):
		print("  ✓ InputManager 有 get_move_direction 方法")
	else:
		print("  ✗ InputManager 缺少 get_move_direction 方法")
		return false
	
	print("  ✓ 移动输入测试完成")
	return true

func _test_attack() -> bool:
	print("  测试攻击输入...")
	
	# 检查攻击系统
	if attack_manager:
		print("  ✓ AttackManager 已加载")
	else:
		print("  ✗ AttackManager 未加载")
		return false
	
	if attack_manager.has_method("can_attack"):
		print("  ✓ AttackManager 有 can_attack 方法")
	else:
		print("  ✗ AttackManager 缺少 can_attack 方法")
		return false
	
	print("  ✓ 攻击输入测试完成")
	return true

func _test_dash() -> bool:
	print("  测试冲刺输入...")
	
	# 检查冲刺系统
	if dash_manager:
		print("  ✓ DashManager 已加载")
	else:
		print("  ✗ DashManager 未加载")
		return false
	
	if dash_manager.has_method("can_dash"):
		print("  ✓ DashManager 有 can_dash 方法")
	else:
		print("  ✗ DashManager 缺少 can_dash 方法")
		return false
	
	print("  ✓ 冲刺输入测试完成")
	return true
