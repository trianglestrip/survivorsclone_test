extends SceneTree

func _init():
	print("\n========== GPU 快速诊断 ==========\n")
	
	# 1. 检查场景解析
	print("--- 场景解析测试 ---")
	var scene := load("res://Enemy/enemy_cyclops.tscn") as PackedScene
	if scene:
		var state := scene.get_state()
		var found_sprite := false
		var found_collision := false
		var hframes := 1
		var has_shape := false
		
		for i in state.get_node_count():
			var node_type := state.get_node_type(i)
			var node_path := str(state.get_node_path(i))
			
			if node_type == &"Sprite2D":
				found_sprite = true
				for j in state.get_node_property_count(i):
					var pname := state.get_node_property_name(i, j)
					if pname == &"hframes":
						hframes = state.get_node_property_value(i, j)
						print("  ✓ Sprite2D hframes = %d" % hframes)
			
			if node_type == &"CollisionShape2D":
				print("  节点路径: %s" % node_path)
				if node_path.contains("HurtBox"):
					found_collision = true
					for j in state.get_node_property_count(i):
						if state.get_node_property_name(i, j) == &"shape":
							var shape_val = state.get_node_property_value(i, j)
							has_shape = (shape_val is Shape2D)
							print("  ✓ HurtBox CollisionShape2D, shape类型正确: %s" % has_shape)
		
		print("\n结果:")
		print("  Sprite2D: %s (hframes=%d)" % ["✓" if found_sprite else "❌", hframes])
		print("  HurtBox碰撞: %s (有shape=%s)" % ["✓" if found_collision else "❌", has_shape])
	
	# 2. 检查动画帧计算
	print("\n--- 动画帧计算测试 (2帧) ---")
	for frame in [0, 1]:
		var frame_normalized := (float(frame) + 0.5) / 2.0
		var shader_result := int(frame_normalized * 2.0)
		print("  帧%d: normalized=%.3f -> shader计算=%d %s" % [
			frame, 
			frame_normalized, 
			shader_result,
			"✓" if shader_result == frame else "❌"
		])
	
	# 3. 检查碰撞层配置
	print("\n--- 碰撞层配置 ---")
	print("  Layer 3 (Enemy) 的位值 = 4 (2^2)")
	print("  敌人 HurtBox 应设置: collision_layer=4, collision_mask=4")
	
	var weapon_scene := load("res://Player/Attack/ice_spear.tscn") as PackedScene
	if weapon_scene:
		var weapon_inst := weapon_scene.instantiate()
		print("\n  武器 (IceSpear) 配置:")
		print("    collision_layer = %d" % weapon_inst.collision_layer)
		print("    collision_mask = %d" % weapon_inst.collision_mask)
		print("    在 'attack' 组: %s" % weapon_inst.is_in_group("attack"))
		weapon_inst.queue_free()
	
	print("\n========== 诊断完成 ==========\n")
	quit()
