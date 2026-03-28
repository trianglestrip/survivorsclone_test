extends SceneTree

func _init():
	print("\n========== GPU 初始化测试 ==========\n")
	
	# 等待 Autoload 初始化
	await create_timer(0.1).timeout
	
	print("\n--- 检查 Registry 状态 ---")
	print("技能数量: ", SkillRegistry.get_all_skill_ids().size())
	print("敌人数量: ", EnemyRegistry.get_all_enemy_ids().size())
	
	print("\n--- 测试场景解析 ---")
	var test_enemy_id := "enemy_cyclops"
	var scene := EnemyRegistry.get_enemy_scene(test_enemy_id)
	if scene:
		var state := scene.get_state()
		print("场景节点数: ", state.get_node_count())
		
		var found_sprite := false
		var found_hurtbox := false
		var hframes := 1
		
		for i in state.get_node_count():
			var node_type := state.get_node_type(i)
			var node_path := str(state.get_node_path(i))
			
			if node_type == &"Sprite2D":
				found_sprite = true
				for j in state.get_node_property_count(i):
					if state.get_node_property_name(i, j) == &"hframes":
						hframes = state.get_node_property_value(i, j)
				print("  ✓ 找到 Sprite2D, hframes=", hframes)
			
			if node_type == &"CollisionShape2D" and node_path.contains("HurtBox"):
				found_hurtbox = true
				for j in state.get_node_property_count(i):
					if state.get_node_property_name(i, j) == &"shape":
						var shape = state.get_node_property_value(i, j)
						print("  ✓ 找到 HurtBox CollisionShape2D, shape=", shape)
		
		if not found_sprite:
			print("  ❌ 未找到 Sprite2D")
		if not found_hurtbox:
			print("  ❌ 未找到 HurtBox CollisionShape2D")
	
	print("\n--- 测试 EnemyInstanceManager 初始化 ---")
	
	# 创建最小场景
	var root := Node2D.new()
	root.name = "TestRoot"
	get_root().add_child(root)
	
	var player := Node2D.new()
	player.name = "TestPlayer"
	player.add_to_group("player")
	root.add_child(player)
	
	var container := Node2D.new()
	container.name = "EnemyContainer"
	root.add_child(container)
	
	# 创建管理器
	var manager_script := load("res://Utility/enemy_instance_manager.gd")
	var manager = manager_script.new()
	manager.set_container(container)
	manager.set_player(player)
	root.add_child(manager)
	
	# 等待初始化完成
	await manager.initialization_complete
	
	print("\n--- 检查初始化结果 ---")
	print("管理器已初始化: ", manager.is_initialized)
	print("敌人类型数: ", manager.enemy_types.size())
	
	for enemy_id in manager.enemy_types:
		var type_data = manager.enemy_types[enemy_id]
		print("  - %s: 纹理=%s, hframes=%d, 碰撞形状=%s" % [
			enemy_id,
			"有" if type_data.texture else "无",
			type_data.hframes,
			"有" if type_data.collision_shape else "无"
		])
	
	print("\n--- 测试生成敌人 ---")
	var spawn_id: int = manager.spawn_enemy("enemy_cyclops", Vector2(100, 100))
	print("生成敌人 ID: ", spawn_id)
	
	if spawn_id >= 0:
		var type_data = manager.enemy_types["enemy_cyclops"]
		if type_data.instances.size() > 0:
			var inst = type_data.instances[0]
			print("  位置: ", inst.position)
			print("  HP: ", inst.hp)
			print("  HurtBox: ", "有" if inst.hurt_box else "无")
			
			if inst.hurt_box:
				print("  HurtBox collision_layer: ", inst.hurt_box.collision_layer)
				print("  HurtBox collision_mask: ", inst.hurt_box.collision_mask)
				print("  HurtBox 在组 enemy_hurtbox: ", inst.hurt_box.is_in_group("enemy_hurtbox"))
	
	print("\n--- 测试动画帧计算 ---")
	if manager.enemy_types.has("enemy_cyclops"):
		var type_data = manager.enemy_types["enemy_cyclops"]
		if type_data.hframes > 1:
			for frame in range(type_data.hframes):
				var frame_normalized := (float(frame) + 0.5) / float(type_data.hframes)
				var shader_frame := int(frame_normalized * float(type_data.hframes))
				print("  帧 %d -> normalized=%.3f -> shader_frame=%d" % [frame, frame_normalized, shader_frame])
	
	print("\n========== 测试完成 ==========\n")
	quit()
