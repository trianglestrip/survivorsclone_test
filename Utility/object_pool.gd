extends Node

# 对象池系统 - 用于复用游戏对象，减少创建/销毁开销

var pools = {}

# 从对象池获取对象
func get_object(pool_name: String, scene: PackedScene) -> Node:
	if not pools.has(pool_name):
		pools[pool_name] = []
	
	# 查找可用的对象
	for obj in pools[pool_name]:
		if not is_instance_valid(obj):
			continue
		if obj.is_queued_for_deletion():
			continue
		if not obj.is_inside_tree():
			return obj
	
	# 没有可用对象，创建新的
	var new_obj = scene.instantiate()
	pools[pool_name].append(new_obj)
	return new_obj

# 归还对象到池中
func return_object(pool_name: String, obj: Node):
	if obj == null or not is_instance_valid(obj):
		return
	
	if not pools.has(pool_name):
		pools[pool_name] = []
	
	# 从场景树中移除
	if obj.is_inside_tree():
		obj.get_parent().remove_child(obj)
	
	# 重置对象状态
	if obj.has_method("reset_state"):
		obj.reset_state()
	
	# 确保对象在池中
	if not obj in pools[pool_name]:
		pools[pool_name].append(obj)

# 清空指定池
func clear_pool(pool_name: String):
	if not pools.has(pool_name):
		return
	
	for obj in pools[pool_name]:
		if is_instance_valid(obj):
			obj.queue_free()
	
	pools[pool_name].clear()

# 清空所有池
func clear_all_pools():
	for pool_name in pools.keys():
		clear_pool(pool_name)
	pools.clear()

# 获取池的大小
func get_pool_size(pool_name: String) -> int:
	if not pools.has(pool_name):
		return 0
	return pools[pool_name].size()

# 获取池中可用对象数量
func get_available_count(pool_name: String) -> int:
	if not pools.has(pool_name):
		return 0
	
	var count = 0
	for obj in pools[pool_name]:
		if is_instance_valid(obj) and not obj.is_inside_tree() and not obj.is_queued_for_deletion():
			count += 1
	
	return count

# 预热对象池
func prewarm_pool(pool_name: String, scene: PackedScene, count: int):
	if not pools.has(pool_name):
		pools[pool_name] = []
	
	for i in range(count):
		var obj = scene.instantiate()
		pools[pool_name].append(obj)
