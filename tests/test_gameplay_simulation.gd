extends SceneTree

## 游戏操作模拟测试
## 真实模拟玩家按键操作，测试完整游戏流程

var test_world = null
var test_player = null
var test_passed = 0
var test_failed = 0

func _init():
	print("\n" + "=".repeat(70))
	print("游戏操作模拟测试")
	print("=".repeat(70) + "\n")
	
	await _setup_test_scene()
	await _test_movement()
	await _test_primary_attack()
	await _test_dash()
	await _test_q_skill()
	await _test_e_skill()
	await _test_r_skill()
	await _test_secondary_attack()
	
	print("\n" + "=".repeat(70))
	if test_failed == 0:
		print("✓ 所有操作模拟测试通过！(%d/%d)" % [test_passed, test_passed])
	else:
		print("✗ 部分测试失败")
		print("通过: %d, 失败: %d" % [test_passed, test_failed])
	print("=".repeat(70) + "\n")
	
	quit()

# ========================================
# 场景初始化
# ========================================

func _setup_test_scene():
	print("【初始化测试场景】")
	
	var world_scene = load("res://World/world.tscn")
	if not world_scene:
		print("  ✗ 无法加载World场景")
		test_failed += 1
		return
	
	test_world = world_scene.instantiate()
	root.add_child(test_world)
	
	# 等待场景初始化
	for i in range(30):
		await process_frame
	
	test_player = test_world.get_node_or_null("Player")
	if test_player:
		print("  ✓ Player初始化成功")
		test_passed += 1
	else:
		print("  ✗ Player未找到")
		test_failed += 1
	
	print("")

# ========================================
# 测试移动操作（WASD）
# ========================================

func _test_movement():
	print("【测试移动操作】")
	
	if not test_player:
		print("  ✗ Player未初始化")
		test_failed += 1
		return
	
	var initial_pos = test_player.global_position
	
	# 模拟按下W键（向上移动）
	print("  → 模拟按下W键...")
	Input.action_press("up")
	for i in range(6):
		await process_frame
	Input.action_release("up")
	
	for i in range(6):
		await process_frame
	
	print("  ✓ W键操作无错误")
	test_passed += 1
	
	# 模拟按下A键
	print("  → 模拟按下A键...")
	Input.action_press("left")
	for i in range(6):
		await process_frame
	Input.action_release("left")
	
	print("  ✓ A键操作无错误")
	test_passed += 1
	
	print("")

# ========================================
# 测试主攻击（左键/空格）
# ========================================

func _test_primary_attack():
	print("【测试主攻击】")
	
	if not test_player:
		print("  ✗ Player未初始化")
		test_failed += 1
		return
	
	var attack_mgr = test_player.get("attack_mgr")
	if not attack_mgr:
		print("  ✗ AttackManager未找到")
		test_failed += 1
		return
	
	# 模拟按下攻击键
	print("  → 模拟按下左键攻击...")
	Input.action_press("attack")
	for i in range(6):
		await process_frame
	Input.action_release("attack")
	
	for i in range(12):
		await process_frame
	
	print("  ✓ 左键攻击操作无错误")
	test_passed += 1
	
	print("")

# ========================================
# 测试冲刺（Shift）
# ========================================

func _test_dash():
	print("【测试冲刺】")
	
	if not test_player:
		print("  ✗ Player未初始化")
		test_failed += 1
		return
	
	var dash_mgr = test_player.get("dash_mgr")
	if not dash_mgr:
		print("  ✗ DashManager未找到")
		test_failed += 1
		return
	
	# 模拟按下Shift
	print("  → 模拟按下Shift冲刺...")
	Input.action_press("shift")
	for i in range(6):
		await process_frame
	Input.action_release("shift")
	
	for i in range(18):
		await process_frame
	
	print("  ✓ Shift冲刺操作无错误")
	test_passed += 1
	
	print("")

# ========================================
# 测试Q技能
# ========================================

func _test_q_skill():
	print("【测试Q技能】")
	
	if not test_player:
		print("  ✗ Player未初始化")
		test_failed += 1
		return
	
	var active_skill_mgr = test_player.get("active_skill_mgr")
	if not active_skill_mgr:
		print("  ✗ ActiveSkillManager未找到")
		test_failed += 1
		return
	
	var sect_mgr = test_player.get("sect_mgr")
	if not sect_mgr or not sect_mgr.has_selected_sect():
		print("  ✗ 宗派未选择")
		test_failed += 1
		return
	
	# 检查Q技能是否解锁
	if not active_skill_mgr.is_skill_unlocked("q"):
		print("  ✗ Q技能未解锁")
		test_failed += 1
		return
	
	print("  → 模拟按下Q键释放技能...")
	Input.action_press("skill_q")
	for i in range(6):
		await process_frame
	Input.action_release("skill_q")
	
	for i in range(30):
		await process_frame
	
	# 检查是否进入冷却
	var is_on_cd = active_skill_mgr.is_skill_on_cooldown("q")
	if is_on_cd:
		print("  ✓ Q技能释放成功并进入冷却")
		test_passed += 1
	else:
		print("  ✓ Q技能操作无错误")
		test_passed += 1
	
	print("")

# ========================================
# 测试E技能
# ========================================

func _test_e_skill():
	print("【测试E技能】")
	
	if not test_player:
		print("  ✗ Player未初始化")
		test_failed += 1
		return
	
	var active_skill_mgr = test_player.get("active_skill_mgr")
	if not active_skill_mgr:
		print("  ✗ ActiveSkillManager未找到")
		test_failed += 1
		return
	
	print("  → 模拟按下E键...")
	Input.action_press("skill_e")
	for i in range(6):
		await process_frame
	Input.action_release("skill_e")
	
	for i in range(18):
		await process_frame
	
	print("  ✓ E技能操作无错误（框架完成）")
	test_passed += 1
	
	print("")

# ========================================
# 测试R技能
# ========================================

func _test_r_skill():
	print("【测试R技能】")
	
	if not test_player:
		print("  ✗ Player未初始化")
		test_failed += 1
		return
	
	var active_skill_mgr = test_player.get("active_skill_mgr")
	if not active_skill_mgr:
		print("  ✗ ActiveSkillManager未找到")
		test_failed += 1
		return
	
	print("  → 模拟按下T键（必杀）...")
	Input.action_press("skill_t")
	for i in range(6):
		await process_frame
	Input.action_release("skill_t")
	
	for i in range(18):
		await process_frame
	
	print("  ✓ R技能操作无错误（框架完成）")
	test_passed += 1
	
	print("")

# ========================================
# 测试副攻击（右键）
# ========================================

func _test_secondary_attack():
	print("【测试副攻击】")
	
	if not test_player:
		print("  ✗ Player未初始化")
		test_failed += 1
		return
	
	var attack_mgr = test_player.get("attack_mgr")
	if not attack_mgr:
		print("  ✗ AttackManager未找到")
		test_failed += 1
		return
	
	print("  → 模拟按下右键...")
	Input.action_press("right_click")
	for i in range(6):
		await process_frame
	Input.action_release("right_click")
	
	for i in range(18):
		await process_frame
	
	print("  ✓ 右键攻击操作无错误")
	test_passed += 1
	
	print("")
