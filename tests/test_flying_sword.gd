extends SceneTree

## 飞剑副攻击：发射、追踪、伤害、数量上限

const GameConstants = preload("res://Utility/game_constants.gd")

var _passed := 0
var _failed := 0


func _init() -> void:
	print("\n========================================")
	print("飞剑副攻击测试 (FlyingSword)")
	print("========================================\n")

	await _run_all()

	print("\n========================================")
	print("通过: %d  失败: %d" % [_passed, _failed])
	print("========================================\n")
	quit()


func _run_all() -> void:
	await _test_config_load()
	await _test_attack_manager_secondary_type()
	await _test_spawn_track_damage_limit()


func _test_config_load() -> void:
	print("[测试] 配置文件")
	var ConfigManagerClass = load("res://Utility/config_manager.gd")
	var config_mgr = ConfigManagerClass.new()
	var controls = config_mgr.load_json_config("res://config/stage1_controls.json")
	var sec = controls.get("secondary_attack", {})
	var ok = sec.get("type", "") == "flying_sword"
	ok = ok and sec.has("max_active_swords") and sec.has("lifetime")
	_assert(ok, "stage1_controls secondary_attack 含 flying_sword 字段")

	var fs_cfg = config_mgr.load_json_config("res://config/flying_sword_config.json")
	_assert(not fs_cfg.is_empty(), "flying_sword_config.json 可加载")


func _test_attack_manager_secondary_type() -> void:
	print("[测试] AttackManager 副攻击类型")
	var player_scene = load("res://Player/player.tscn")
	var player = player_scene.instantiate()
	root.add_child(player)
	for i in range(90):
		await process_frame

	var am = player.get("attack_mgr")
	if not am:
		_assert(false, "存在 attack_mgr")
		player.queue_free()
		return

	var sec = am.get_secondary_attack()
	var FlyingSwordAttackClass = load("res://Player/Components/flying_sword_attack.gd")
	var ok = sec != null and is_instance_of(sec, FlyingSwordAttackClass)
	_assert(ok, "副攻击为 FlyingSwordAttack")

	player.queue_free()
	await process_frame


func _test_spawn_track_damage_limit() -> void:
	print("[测试] 发射、追踪、伤害、数量上限")

	var world = Node2D.new()
	world.name = "TestWorld"
	root.add_child(world)

	var player = CharacterBody2D.new()
	player.name = "Player"
	player.add_to_group("player")
	player.global_position = Vector2(200, 200)
	world.add_child(player)

	var FlyingSwordManagerClass = load("res://Player/Components/flying_sword_manager.gd")
	var manager = FlyingSwordManagerClass.new()
	manager.set_player(player)
	manager.set_max_active_swords(3)
	world.add_child(manager)
	
	var FlyingSwordAttackClass = load("res://Player/Components/flying_sword_attack.gd")
	var attack = FlyingSwordAttackClass.new()
	attack.set_player(player)
	attack.set_flying_sword_manager(manager)
	var cfg = {
		"type": "flying_sword",
		"base_cooldown": 0.5,
		"base_damage": 10,
		"base_knockback": 40,
		"max_active_swords": 3,
		"lifetime": 8.0,
		"move_speed": 600.0,
		"turn_rate": 12.0,
		"homing_range": 2000.0,
		"collision_radius": 28.0,
	}
	attack.load_config(cfg)
	world.add_child(attack)

	var enemy = _make_dummy_enemy(Vector2(400, 200))
	world.add_child(enemy)

	var before_hp = enemy.hp
	var direction_to_enemy = (enemy.global_position - player.global_position).normalized()
	var sword = manager.spawn_sword(direction_to_enemy, 10, 40, 600.0, 500.0, 28.0, 8.0)
	_assert(sword != null, "首次发射成功")
	for i in range(10):
		await process_frame
	var swords = _find_flying_swords(world)
	_assert(swords.size() == 1, "场上有 1 把飞剑")

	for i in range(180):
		await process_frame

	var hit = enemy.hp < before_hp
	_assert(hit, "飞剑命中后敌人扣血")

	swords = _find_flying_swords(world)
	_assert(swords.is_empty(), "飞剑达到最大距离后销毁")

	# 数量上限：连发 3 把，第 4 把应失败
	enemy.hp = 100
	enemy.global_position = Vector2(900, 200)
	var dir_right = Vector2.RIGHT
	var s1 = manager.spawn_sword(dir_right, 10, 40, 600.0, 1000.0, 28.0, 8.0)
	_assert(s1 != null, "第 1 把发射")
	for i in range(10):
		await process_frame
	var s2 = manager.spawn_sword(dir_right, 10, 40, 600.0, 1000.0, 28.0, 8.0)
	_assert(s2 != null, "第 2 把发射")
	for i in range(10):
		await process_frame
	var s3 = manager.spawn_sword(dir_right, 10, 40, 600.0, 1000.0, 28.0, 8.0)
	_assert(s3 != null, "第 3 把发射")
	for i in range(10):
		await process_frame
	var s4 = manager.spawn_sword(dir_right, 10, 40, 600.0, 1000.0, 28.0, 8.0)
	_assert(s4 == null, "超过 max_active 时拒绝发射")

	for n in _find_flying_swords(world):
		n.queue_free()

	world.queue_free()
	await process_frame


func _make_dummy_enemy(pos: Vector2) -> CharacterBody2D:
	var e = CharacterBody2D.new()
	e.name = "DummyEnemy"
	e.set_script(load("res://Enemy/base_enemy.gd"))
	e.global_position = pos
	e.hp = 50
	e.add_to_group("enemies")
	return e


func _find_flying_swords(node: Node) -> Array:
	var FlyingSwordClass = load("res://Player/Components/flying_sword.gd")
	var out: Array = []
	for c in node.get_children():
		if c.name.begins_with("FlyingSword") or is_instance_of(c, FlyingSwordClass):
			out.append(c)
		out.append_array(_find_flying_swords(c))
	return out


func _assert(cond: bool, msg: String) -> void:
	if cond:
		_passed += 1
		print("  ✓ %s" % msg)
	else:
		_failed += 1
		print("  ✗ %s" % msg)
