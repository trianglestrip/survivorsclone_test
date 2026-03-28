extends SceneTree

func _init():
	var scene := load("res://Enemy/enemy_cyclops.tscn") as PackedScene
	var state := scene.get_state()
	
	print("\n所有 CollisionShape2D 节点:")
	for i in state.get_node_count():
		if state.get_node_type(i) == &"CollisionShape2D":
			var path := str(state.get_node_path(i))
			var parent_idx := state.get_node_instance(i)
			print("  路径: '%s', 父索引: %d" % [path, parent_idx])
			
			# 检查父节点
			var owner_idx := state.get_node_owner(i)
			if owner_idx >= 0:
				print("    owner: %s" % state.get_node_path(owner_idx))
	
	print("\n所有 HurtBox 相关节点:")
	for i in state.get_node_count():
		var path := str(state.get_node_path(i))
		var node_type := state.get_node_type(i)
		if path.contains("HurtBox") or path.contains("HitBox"):
			print("  [%d] %s: %s" % [i, node_type, path])
	
	quit()
