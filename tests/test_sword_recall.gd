extends SceneTree

## 飞剑召回与必杀键位测试
## 验证：R→recall_sword、T→skill_t、飞剑 recall() 返回玩家、召回伤害、必杀仍走技能槽 r

var _passed := 0
var _failed := 0


func _init() -> void:
	print("\n" + "=".repeat(60))
	print("test_sword_recall — 飞剑召回 / 必杀改键")
	print("=".repeat(60))
	
	await _run_all()
	
	print("\n" + "=".repeat(60))
	print("通过: %d  失败: %d" % [_passed, _failed])
	print("=".repeat(60) + "\n")
	quit(0 if _failed == 0 else 1)


func _ok(cond: bool, msg: String) -> void:
	if cond:
		_passed += 1
		print("  ✓ %s" % msg)
	else:
		_failed += 1
		print("  ✗ %s" % msg)


func _run_all() -> void:
	await _test_input_map()
	await _test_input_manager_signals()
	await _test_attack_manager_uses_flying_sword()
	await _test_recall_damage_and_despawn()


func _test_input_map() -> void:
	print("\n[1] 输入映射")
	_ok(InputMap.has_action("skill_t"), "存在 skill_t（必杀）")
	_ok(InputMap.has_action("recall_sword"), "存在 recall_sword（召回）")
	_ok(not InputMap.has_action("skill_r"), "已移除 skill_r（避免与旧映射混淆）")


func _test_input_manager_signals() -> void:
	print("\n[2] InputManager 信号")
	var script = load("res://Player/Components/input_manager.gd")
	var im = script.new()
	_ok(im.has_signal("skill_t_pressed"), "skill_t_pressed")
	_ok(im.has_signal("recall_sword"), "recall_sword")
	im.free()


func _test_attack_manager_uses_flying_sword() -> void:
	print("\n[3] AttackManager + 剑类副攻击为飞剑")
	var AttackManagerClass = load("res://Player/Components/attack_manager.gd")
	var WeaponRegistry = load("res://Utility/weapon_registry.gd")
	var mgr_script = load("res://Player/Components/flying_sword_manager.gd")
	var am = AttackManagerClass.new()
	var wr = WeaponRegistry.new()
	var fsm = mgr_script.new()
	var p = CharacterBody2D.new()
	p.add_to_group("player")
	var root_nd = Node2D.new()
	root.add_child(root_nd)
	root_nd.add_child(p)
	root_nd.add_child(am)
	root_nd.add_child(wr)
	root_nd.add_child(fsm)
	await process_frame
	fsm.set_player(p)
	am.set_player(p)
	am.set_flying_sword_manager(fsm)
	am.set_weapon_registry(wr)
	await process_frame
	var sec = am.get_secondary_attack()
	_ok(sec != null, "存在副攻击")
	_ok(sec != null and sec.get_script() == load("res://Player/Components/flying_sword_attack.gd"), "剑类副攻击为 FlyingSwordAttack")
	am.queue_free()
	wr.queue_free()
	fsm.queue_free()
	p.queue_free()
	root_nd.queue_free()
	await process_frame


func _test_recall_damage_and_despawn() -> void:
	print("\n[4] 飞剑召回路径伤害与到达玩家后消失")
	var world = Node2D.new()
	root.add_child(world)
	var player = CharacterBody2D.new()
	player.add_to_group("player")
	player.global_position = Vector2(120, 200)
	world.add_child(player)
	var enemy_scene = load("res://Enemy/simple_enemy.tscn")
	var enemy = enemy_scene.instantiate()
	enemy.global_position = Vector2(320, 200)
	world.add_child(enemy)
	var mgr_script = load("res://Player/Components/flying_sword_manager.gd")
	var fsm = mgr_script.new()
	fsm.set_player(player)
	world.add_child(fsm)
	await process_frame
	var hp_start: int = enemy.hp
	fsm.spawn_sword(Vector2.RIGHT, 4, 10, 600.0, 900.0)
	await process_frame
	var sword: Node = null
	for c in world.get_children():
		if c.name == "FlyingSword":
			sword = c
			break
	_ok(sword != null, "已生成 FlyingSword 节点")
	if sword and sword.has_method("recall"):
		sword.recall()
	for _i in range(200):
		await process_frame
	_ok(not is_instance_valid(sword), "飞剑到达玩家后已释放")
	var hp_lost := hp_start - enemy.hp
	_ok(hp_lost > 0, "召回路径上对敌人造成伤害 (hpΔ=%d)" % hp_lost)
	# 必杀仍绑定技能槽 r（由 ActiveSkillManager 监听 skill_t）
	var asm_script = load("res://Player/Components/active_skill_manager.gd")
	var asm = asm_script.new()
	_ok(asm.has_method("try_cast_skill"), "ActiveSkillManager.try_cast_skill 存在")
	asm.unlock_skill("r")
	_ok(asm.try_cast_skill("r"), "槽位 r 的必杀仍可通过 try_cast_skill 释放")
	world.queue_free()
	await process_frame
