extends SceneTree

## 测试伤害系统 - 验证玩家和敌人的伤害交互

const GameConstants = preload("res://Utility/game_constants.gd")

var test_results = []
var world_scene = null
var player = null

func _init():
	print("\n========================================")
	print("伤害系统测试")
	print("========================================\n")
	
	await _run_tests()
	
	print("\n========================================")
	print("测试完成")
	print("========================================")
	_print_summary()
	
	quit()

func _run_tests():
	await _test_player_hurt_box()
	await _test_enemy_take_damage()
	await _test_player_attack_enemy()
	await _test_enemy_attack_player()

## 测试1: 玩家HurtBox存在
func _test_player_hurt_box():
	print("\n[测试1] 玩家HurtBox组件")
	
	world_scene = load("res://World/world.tscn").instantiate()
	root.add_child(world_scene)
	
	for i in range(10):
		await process_frame
	
	player = world_scene.get_node_or_null("Player")
	
	if not player:
		_log_result("测试1", false, "找不到Player节点")
		return
	
	var hurt_box = player.get_node_or_null("HurtBox")
	if not hurt_box:
		_log_result("测试1", false, "Player没有HurtBox组件")
		return
	
	print("  HurtBox类型: ", hurt_box.HurtBoxType)
	print("  HurtBox碰撞层: ", hurt_box.collision_layer)
	print("  HurtBox碰撞遮罩: ", hurt_box.collision_mask)
	
	var has_collision = hurt_box.has_node("CollisionShape2D")
	if has_collision:
		_log_result("测试1", true, "Player HurtBox配置正确")
	else:
		_log_result("测试1", false, "HurtBox缺少CollisionShape2D")

## 测试2: 敌人受伤系统
func _test_enemy_take_damage():
	print("\n[测试2] 敌人受伤系统")
	
	if not player:
		_log_result("测试2", false, "Player不存在")
		return
	
	# 创建测试敌人
	var enemy_scene = load("res://Enemy/simple_enemy.tscn")
	var enemy = enemy_scene.instantiate()
	enemy.global_position = player.global_position + Vector2(100, 0)
	
	var world = player.get_parent()
	var enemies_container = world.get_node_or_null("Enemies")
	if enemies_container:
		enemies_container.add_child(enemy)
	else:
		world.add_child(enemy)
	
	for i in range(10):
		await process_frame
	
	var initial_hp = enemy.hp
	print("  敌人初始HP: ", initial_hp)
	
	# 造成伤害
	enemy.take_damage(10.0, Vector2.ZERO)
	
	for i in range(5):
		await process_frame
	
	var current_hp = enemy.hp
	print("  造成伤害后HP: ", current_hp)
	
	if current_hp < initial_hp:
		_log_result("测试2", true, "敌人受伤系统工作正常 (HP: %d -> %d)" % [initial_hp, current_hp])
	else:
		_log_result("测试2", false, "敌人未受到伤害")

## 测试3: 玩家攻击敌人
func _test_player_attack_enemy():
	print("\n[测试3] 玩家攻击敌人")
	
	if not player:
		_log_result("测试3", false, "Player不存在")
		return
	
	# 创建敌人在玩家正前方（攻击方向）
	var enemy_scene = load("res://Enemy/simple_enemy.tscn")
	var enemy = enemy_scene.instantiate()
	# 玩家默认朝向是UP(-1)，所以敌人放在上方
	enemy.global_position = player.global_position + Vector2(0, -40)
	
	var world = player.get_parent()
	var enemies_container = world.get_node_or_null("Enemies")
	if enemies_container:
		enemies_container.add_child(enemy)
	else:
		world.add_child(enemy)
	
	for i in range(10):
		await process_frame
	
	var initial_hp = enemy.hp
	var enemy_count_before = world.get_tree().get_nodes_in_group("enemies").size()
	print("  敌人初始HP: ", initial_hp)
	print("  敌人位置: ", enemy.global_position)
	print("  玩家位置: ", player.global_position)
	print("  场景中敌人数: ", enemy_count_before)
	
	# 检查敌人HurtBox
	var enemy_hurt_box = enemy.get_node_or_null("HurtBox")
	if enemy_hurt_box:
		print("  敌人HurtBox碰撞层: ", enemy_hurt_box.collision_layer)
		print("  敌人HurtBox碰撞遮罩: ", enemy_hurt_box.collision_mask)
	else:
		print("  敌人没有HurtBox!")
	
	# 模拟攻击（使用正确的action名称）
	Input.action_press("attack")
	for i in range(5):
		await process_frame
	Input.action_release("attack")
	
	# 等待攻击执行和碰撞检测
	print("  等待攻击和碰撞检测...")
	for i in range(30):
		await process_frame
		if i == 10:
			print("  0.17秒后敌人HP: ", enemy.hp if is_instance_valid(enemy) else "已死亡")
	
	var enemy_count_after = world.get_tree().get_nodes_in_group("enemies").size()
	
	if is_instance_valid(enemy):
		var current_hp = enemy.hp
		print("  最终敌人HP: ", current_hp)
		print("  敌人最终位置: ", enemy.global_position)
		if current_hp < initial_hp:
			_log_result("测试3", true, "玩家成功攻击敌人 (HP: %d -> %d)" % [initial_hp, current_hp])
		else:
			_log_result("测试3", false, "攻击未造成伤害（HitBox可能未碰撞到HurtBox）")
	else:
		print("  敌人已被击杀")
		_log_result("测试3", true, "玩家成功击杀敌人")

## 测试4: 敌人攻击玩家
func _test_enemy_attack_player():
	print("\n[测试4] 敌人攻击玩家")
	
	if not player:
		_log_result("测试4", false, "Player不存在")
		return
	
	if not player.stats:
		_log_result("测试4", false, "Player.stats未初始化")
		return
	
	var initial_hp = player.stats.hp
	print("  玩家初始HP: ", initial_hp)
	print("  玩家位置: ", player.global_position)
	
	# 检查玩家HurtBox配置
	var player_hurt_box = player.get_node_or_null("HurtBox")
	if player_hurt_box:
		print("  玩家HurtBox碰撞层: ", player_hurt_box.collision_layer)
		print("  玩家HurtBox碰撞遮罩: ", player_hurt_box.collision_mask)
	
	# 创建敌人在玩家位置（会接触到玩家）
	var enemy_scene = load("res://Enemy/simple_enemy.tscn")
	var enemy = enemy_scene.instantiate()
	enemy.global_position = player.global_position
	print("  创建敌人于玩家位置: ", enemy.global_position)
	
	var world = player.get_parent()
	var enemies_container = world.get_node_or_null("Enemies")
	if enemies_container:
		enemies_container.add_child(enemy)
	else:
		world.add_child(enemy)
	
	# 等待碰撞检测
	for i in range(60):
		await process_frame
		if i == 10:
			print("  0.17秒后玩家HP: ", player.stats.hp)
	
	var current_hp = player.stats.hp
	print("  最终玩家HP: ", current_hp)
	
	# 检查敌人是否有HitBox
	var enemy_hit_box = enemy.get_node_or_null("HitBox") if is_instance_valid(enemy) else null
	if enemy_hit_box:
		print("  敌人HitBox: 存在")
		print("  敌人HitBox碰撞层: ", enemy_hit_box.collision_layer)
		print("  敌人HitBox碰撞遮罩: ", enemy_hit_box.collision_mask)
		print("  敌人HitBox组: ", enemy_hit_box.get_groups())
		print("  敌人HitBox.damage: ", enemy_hit_box.get("damage"))
	else:
		print("  敌人HitBox: 不存在")
	
	if current_hp < initial_hp:
		_log_result("测试4", true, "敌人成功攻击玩家 (HP: %d -> %d)" % [initial_hp, current_hp])
	else:
		_log_result("测试4", false, "敌人未造成伤害（需要实现敌人HitBox）")

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
