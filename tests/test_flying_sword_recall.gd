extends SceneTree

## 飞剑召回测试

const GameConstants = preload("res://Utility/game_constants.gd")

var _passed := 0
var _failed := 0

func _initialize():
	print("\n========================================")
	print("飞剑召回功能测试")
	print("========================================\n")

func _init():
	_initialize()
	await _run_all()
	print("\n========================================")
	print("通过: ", _passed, "  失败: ", _failed)
	print("========================================\n")
	quit()

func _run_all() -> void:
	await _test_recall_mode_switch()
	await _test_recall_damage_multiplier()
	await _test_recall_via_input_manager()

func _test_recall_mode_switch() -> void:
	print("[测试] 召回模式切换")
	var root = get_root()
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
	world.add_child(manager)
	
	var direction = Vector2.RIGHT
	var sword = manager.spawn_sword(direction, 10, 40, 600.0, 1000.0, 28.0, 8.0)
	_assert(sword != null, "飞剑创建成功")
	
	for i in range(10):
		await process_frame
	
	var FlyingSwordClass = load("res://Player/Components/flying_sword.gd")
	var Mode = FlyingSwordClass.Mode
	_assert(sword.get("mode") == Mode.OUTBOUND, "初始为 OUTBOUND 模式")
	
	if sword.has_method("recall"):
		sword.recall()
	
	await process_frame
	_assert(sword.get("mode") == Mode.RECALL, "召回后为 RECALL 模式")
	
	world.queue_free()
	await process_frame

func _test_recall_damage_multiplier() -> void:
	print("[测试] 召回速度倍率")
	var root = get_root()
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
	world.add_child(manager)
	
	var direction = Vector2.RIGHT
	var sword = manager.spawn_sword(direction, 10, 40, 600.0, 1000.0, 28.0, 8.0)
	
	for i in range(10):
		await process_frame
	
	var speed_before = sword.get("speed")
	_assert(speed_before == 600.0, "飞出时速度为 600")
	
	if sword and is_instance_valid(sword) and sword.has_method("recall"):
		sword.recall()
	
	await process_frame
	var speed_after = sword.get("speed")
	_assert(speed_after > speed_before, "召回后速度增加（1.8倍）")
	
	world.queue_free()
	await process_frame

func _test_recall_via_input_manager() -> void:
	print("[测试] 通过 InputManager 召回所有飞剑")
	var root = get_root()
	var world = Node2D.new()
	world.name = "TestWorld"
	root.add_child(world)
	
	var player = CharacterBody2D.new()
	player.name = "Player"
	player.add_to_group("player")
	player.global_position = Vector2(200, 200)
	world.add_child(player)
	
	var InputManagerClass = load("res://Player/Components/input_manager.gd")
	var input_mgr = InputManagerClass.new()
	world.add_child(input_mgr)
	
	var FlyingSwordManagerClass = load("res://Player/Components/flying_sword_manager.gd")
	var manager = FlyingSwordManagerClass.new()
	manager.set_player(player)
	manager.set_input_manager(input_mgr)
	world.add_child(manager)
	
	var s1 = manager.spawn_sword(Vector2.RIGHT, 10, 40, 600.0, 1000.0, 28.0, 8.0)
	var s2 = manager.spawn_sword(Vector2.UP, 10, 40, 600.0, 1000.0, 28.0, 8.0)
	
	for i in range(10):
		await process_frame
	
	var FlyingSwordClass = load("res://Player/Components/flying_sword.gd")
	var Mode = FlyingSwordClass.Mode
	_assert(s1.get("mode") == Mode.OUTBOUND, "飞剑1初始为 OUTBOUND")
	_assert(s2.get("mode") == Mode.OUTBOUND, "飞剑2初始为 OUTBOUND")
	
	input_mgr.emit_signal("recall_sword")
	
	for i in range(5):
		await process_frame
	
	_assert(s1.get("mode") == Mode.RECALL, "飞剑1召回后为 RECALL")
	_assert(s2.get("mode") == Mode.RECALL, "飞剑2召回后为 RECALL")
	
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

func _assert(condition: bool, message: String) -> void:
	if condition:
		_passed += 1
		print("  ✓ ", message)
	else:
		_failed += 1
		print("  ✗ ", message)

func process_frame() -> void:
	await get_root().process_frame
