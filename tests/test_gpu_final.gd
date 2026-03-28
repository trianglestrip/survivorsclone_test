extends Node2D

## GPU 实例化最终测试
## 测试：动画播放、玩家受伤、武器伤害、时间完成

var enemy_manager = null
var player = null

func _ready():
	print("\n" + "=".repeat(60))
	print("GPU 实例化最终测试")
	print("=".repeat(60) + "\n")
	
	player = get_tree().get_first_node_in_group("player")
	if not player:
		print("✗ 找不到玩家")
		return
	
	print("✓ 玩家初始状态:")
	print("  - HP: %d / %d" % [player.stats.hp, player.stats.maxhp])
	print("  - 位置: %s" % player.global_position)
	
	# 创建敌人管理器
	var manager_script = load("res://Enemy/enemy_instance_manager.gd")
	enemy_manager = manager_script.new()
	enemy_manager.set_container(self)
	enemy_manager.set_player(player)
	add_child(enemy_manager)
	
	print("\n等待敌人管理器初始化...")
	await enemy_manager.initialization_complete
	print("✓ 敌人管理器初始化完成\n")
	
	# 测试 1: 生成不同类型的敌人
	print("测试 1: 生成多种敌人")
	var test_enemies = [
		{"type": "enemy_kobold_weak", "offset": Vector2(100, 0)},
		{"type": "enemy_cyclops", "offset": Vector2(-100, 0)},
		{"type": "enemy_kobold_strong", "offset": Vector2(0, 100)},
	]
	
	for enemy_info in test_enemies:
		var spawn_pos = player.global_position + enemy_info.offset
		var spawn_id = enemy_manager.spawn_enemy(enemy_info.type, spawn_pos)
		print("  ✓ 生成 %s (ID: %d)" % [enemy_info.type, spawn_id])
	
	# 测试 2: 观察动画播放（等待几秒）
	print("\n测试 2: 动画播放")
	print("  等待 3 秒观察敌人动画...")
	await get_tree().create_timer(3.0).timeout
	
	var enemy_types = enemy_manager.enemy_types
	for type_id in enemy_types:
		var type_data = enemy_types[type_id]
		if type_data.hframes > 1:
			print("  ✓ %s: %d 帧动画" % [type_id, type_data.hframes])
	
	# 测试 3: 检查玩家是否受伤
	print("\n测试 3: 玩家受伤检测")
	var initial_hp = player.stats.hp
	print("  初始 HP: %d" % initial_hp)
	print("  等待 2 秒让敌人接触玩家...")
	await get_tree().create_timer(2.0).timeout
	var current_hp = player.stats.hp
	print("  当前 HP: %d" % current_hp)
	if current_hp < initial_hp:
		print("  ✓ 玩家受到伤害 (-%d HP)" % (initial_hp - current_hp))
	else:
		print("  ✗ 玩家未受伤")
	
	# 测试 4: 检查碰撞体配置
	print("\n测试 4: 碰撞体配置")
	var enemy_hitboxes = get_tree().get_nodes_in_group("enemy_hitbox")
	var enemy_hurtboxes = get_tree().get_nodes_in_group("enemy_hurtbox")
	print("  - 敌人 HitBox 数量: %d" % enemy_hitboxes.size())
	print("  - 敌人 HurtBox 数量: %d" % enemy_hurtboxes.size())
	
	if enemy_hitboxes.size() > 0:
		var hitbox = enemy_hitboxes[0]
		print("  - HitBox Layer: %d (应为 2)" % hitbox.collision_layer)
		print("  - HitBox Mask: %d (应为 1)" % hitbox.collision_mask)
	
	if enemy_hurtboxes.size() > 0:
		var hurtbox = enemy_hurtboxes[0]
		print("  - HurtBox Layer: %d (应为 4)" % hurtbox.collision_layer)
		print("  - HurtBox Mask: %d (应为 4)" % hurtbox.collision_mask)
	
	var player_hurtbox = player.get_node_or_null("HurtBox")
	if player_hurtbox:
		print("  - 玩家 HurtBox Layer: %d (应为 1)" % player_hurtbox.collision_layer)
		print("  - 玩家 HurtBox Mask: %d (应为 2)" % player_hurtbox.collision_mask)
	
	# 测试 5: 时间完成
	print("\n测试 5: 时间完成触发")
	print("  当前时间: %d 秒" % player.time)
	print("  设置时间为 300 秒...")
	player.change_time(300)
	await get_tree().create_timer(0.5).timeout
	print("  游戏暂停: %s (应为 true)" % get_tree().paused)
	
	print("\n" + "=".repeat(60))
	print("测试完成！")
	print("=".repeat(60))
	
	await get_tree().create_timer(2.0).timeout
	get_tree().quit()
