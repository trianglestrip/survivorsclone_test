extends SceneTree

func _init():
	print("\n=== 测试敌人动画帧数 ===\n")
	
	var enemies = [
		"enemy_kobold_weak",
		"enemy_kobold_strong",
		"enemy_cyclops",
		"enemy_juggernaut",
		"enemy_super"
	]
	
	for enemy_id in enemies:
		var scene := EnemyRegistry.get_enemy_scene(enemy_id)
		if scene:
			var state := scene.get_state()
			var hframes := 1
			var has_sprite := false
			
			for i in state.get_node_count():
				if state.get_node_type(i) == &"Sprite2D":
					has_sprite = true
					for j in state.get_node_property_count(i):
						if state.get_node_property_name(i, j) == &"hframes":
							hframes = state.get_node_property_value(i, j)
			
			var status := "✓" if hframes > 1 else "⚠"
			print("%s %s: %d 帧 (Sprite2D: %s)" % [status, enemy_id, hframes, "有" if has_sprite else "无"])
	
	print("\n=== 测试完成 ===\n")
	quit()
