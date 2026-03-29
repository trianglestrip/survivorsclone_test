extends SceneTree

## 阶段3武器系统测试

const GameConstants = preload("res://Utility/game_constants.gd")

var test_results = []
var world_scene = null
var player = null

func _init():
	print("\n========================================")
	print("阶段3：武器系统测试")
	print("========================================\n")
	
	await _run_tests()
	
	print("\n========================================")
	print("测试完成")
	print("========================================")
	_print_summary()
	
	quit()

func _run_tests():
	await _test_weapon_registry_init()
	await _test_default_weapon()
	await _test_weapon_switch()
	await _test_sect_weapons()
	await _test_weapon_attack()

## 测试1: 武器注册表初始化
func _test_weapon_registry_init():
	print("\n[测试1] 武器注册表初始化")
	
	await _setup_world()
	
	if not player or not player.weapon_registry:
		_log_result("测试1", false, "WeaponRegistry不存在")
		return
	
	var weapon_count = player.weapon_registry.weapons.size()
	var mode_count = player.weapon_registry.attack_modes.size()
	
	print("  武器数量: ", weapon_count)
	print("  攻击模式数量: ", mode_count)
	
	if weapon_count >= 6 and mode_count >= 4:
		_log_result("测试1", true, "武器注册表初始化成功 (%d武器, %d模式)" % [weapon_count, mode_count])
	else:
		_log_result("测试1", false, "武器配置不完整")
	
	_cleanup_world()

## 测试2: 默认武器装备
func _test_default_weapon():
	print("\n[测试2] 默认武器装备")
	
	await _setup_world()
	
	if not player or not player.weapon_registry:
		_log_result("测试2", false, "WeaponRegistry不存在")
		return
	
	var current_weapon = player.weapon_registry.get_current_weapon()
	
	if current_weapon.is_empty():
		_log_result("测试2", false, "未装备任何武器")
		_cleanup_world()
		return
	
	var weapon_name = current_weapon.get("name", "")
	var weapon_id = current_weapon.get("id", "")
	
	print("  当前武器ID: ", weapon_id)
	print("  当前武器名称: ", weapon_name)
	
	if weapon_id == "sword_basic":
		_log_result("测试2", true, "默认武器装备成功: " + weapon_name)
	else:
		_log_result("测试2", false, "默认武器不正确: " + weapon_id)
	
	_cleanup_world()

## 测试3: 武器切换
func _test_weapon_switch():
	print("\n[测试3] 武器切换")
	
	await _setup_world()
	
	if not player or not player.weapon_registry:
		_log_result("测试3", false, "WeaponRegistry不存在")
		return
	
	# 解锁并切换到寒川
	player.weapon_registry.unlock_weapon("sword_frost")
	var success = player.weapon_registry.equip_weapon("sword_frost")
	
	if not success:
		_log_result("测试3", false, "武器切换失败")
		_cleanup_world()
		return
	
	var current_weapon = player.weapon_registry.get_current_weapon()
	var weapon_id = current_weapon.get("id", "")
	
	print("  切换后武器: ", current_weapon.get("name", ""))
	
	if weapon_id == "sword_frost":
		_log_result("测试3", true, "武器切换成功")
	else:
		_log_result("测试3", false, "武器切换后ID不匹配")
	
	_cleanup_world()

## 测试4: 宗派专属武器
func _test_sect_weapons():
	print("\n[测试4] 宗派专属武器")
	
	await _setup_world()
	
	if not player or not player.weapon_registry:
		_log_result("测试4", false, "WeaponRegistry不存在")
		return
	
	var ice_weapons = player.weapon_registry.get_sect_weapons("ice")
	var thunder_weapons = player.weapon_registry.get_sect_weapons("thunder")
	var fire_weapons = player.weapon_registry.get_sect_weapons("fire")
	var poison_weapons = player.weapon_registry.get_sect_weapons("poison")
	
	print("  冰心宗武器: ", ice_weapons.size())
	print("  雷鸣宗武器: ", thunder_weapons.size())
	print("  烈焰宗武器: ", fire_weapons.size())
	print("  毒瘴宗武器: ", poison_weapons.size())
	
	var total_sect_weapons = ice_weapons.size() + thunder_weapons.size() + fire_weapons.size() + poison_weapons.size()
	
	if total_sect_weapons >= 4:
		_log_result("测试4", true, "宗派专属武器配置正确 (共%d个)" % total_sect_weapons)
	else:
		_log_result("测试4", false, "宗派武器配置不足")
	
	_cleanup_world()

## 测试5: 武器攻击伤害
func _test_weapon_attack():
	print("\n[测试5] 武器攻击伤害")
	
	await _setup_world()
	
	if not player:
		_log_result("测试5", false, "Player不存在")
		return
	
	# 生成敌人
	var enemy = _spawn_test_enemy(player.global_position + Vector2(0, -40))
	
	for i in range(10):
		await process_frame
	
	var initial_hp = enemy.hp
	print("  敌人初始HP: ", initial_hp)
	
	# 执行攻击
	Input.action_press("attack")
	for i in range(5):
		await process_frame
	Input.action_release("attack")
	
	for i in range(30):
		await process_frame
	
	if is_instance_valid(enemy):
		var current_hp = enemy.hp
		print("  攻击后HP: ", current_hp)
		
		if current_hp < initial_hp:
			var damage_dealt = initial_hp - current_hp
			_log_result("测试5", true, "武器攻击造成伤害: %d" % damage_dealt)
		else:
			_log_result("测试5", false, "武器攻击未造成伤害")
	else:
		_log_result("测试5", true, "武器攻击击杀敌人")
	
	_cleanup_world()

## 辅助函数

func _setup_world():
	world_scene = load("res://World/world.tscn").instantiate()
	root.add_child(world_scene)
	
	for i in range(20):
		await process_frame
	
	player = world_scene.get_node_or_null("Player")

func _spawn_test_enemy(pos: Vector2) -> Node:
	var enemy_scene = load("res://Enemy/simple_enemy.tscn")
	var enemy = enemy_scene.instantiate()
	enemy.global_position = pos
	
	var world = player.get_parent()
	var enemies_container = world.get_node_or_null("Enemies")
	if enemies_container:
		enemies_container.add_child(enemy)
	else:
		world.add_child(enemy)
	
	return enemy

func _cleanup_world():
	if world_scene:
		world_scene.queue_free()
		world_scene = null
		player = null
	
	for i in range(10):
		await process_frame

func _log_result(test_name: String, passed: bool, message: String = ""):
	test_results.append({
		"test": test_name,
		"passed": passed,
		"message": message
	})
	var status = "✓ 通过" if passed else "✗ 失败"
	print("  %s: %s" % [status, message if message else test_name])

func _print_summary():
	var passed = 0
	var failed = 0
	
	for result in test_results:
		if result.passed:
			passed += 1
		else:
			failed += 1
	
	var total = passed + failed
	var pass_rate = (float(passed) / total * 100.0) if total > 0 else 0.0
	
	print("\n总计: %d 个测试" % total)
	print("通过: %d" % passed)
	print("失败: %d" % failed)
	print("通过率: %.1f%%" % pass_rate)
