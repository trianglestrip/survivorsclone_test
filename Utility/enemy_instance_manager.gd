extends Node

# GPU 实例化敌人管理器
# 使用 MultiMesh 批量渲染同类型敌人，大幅提升性能

class EnemyInstance:
	var position: Vector2
	var velocity: Vector2
	var hp: float
	var max_hp: float
	var knockback: Vector2
	var type_id: String
	var active: bool = true
	var flip_h: bool = false
	var hurt_box: Area2D = null  # 碰撞检测区域
	
	func _init(pos: Vector2, enemy_type: String, health: float):
		position = pos
		type_id = enemy_type
		hp = health
		max_hp = health
		velocity = Vector2.ZERO
		knockback = Vector2.ZERO

# 敌人类型数据
class EnemyTypeData:
	var type_id: String
	var texture: Texture2D
	var multimesh_instance: MultiMeshInstance2D
	var instances: Array[EnemyInstance] = []
	var config: Dictionary
	var collision_shape: Shape2D = null  # 碰撞形状模板
	
	func _init(id: String, tex: Texture2D, cfg: Dictionary):
		type_id = id
		texture = tex
		config = cfg

# 存储所有敌人类型
var enemy_types: Dictionary = {}  # type_id -> EnemyTypeData

# 引用
var player: Node = null
var container: Node2D = null

func _ready():
	print("\n=== GPU 实例化敌人管理器初始化 ===")
	_initialize_enemy_types()

func set_container(parent: Node2D):
	container = parent

func set_player(p: Node):
	player = p

func _initialize_enemy_types():
	# 等待 EnemyRegistry 初始化
	await get_tree().process_frame
	
	var enemy_ids = EnemyRegistry.get_all_enemy_ids()
	
	for enemy_id in enemy_ids:
		var enemy_data = EnemyRegistry.get_enemy_data(enemy_id)
		var scene = EnemyRegistry.get_enemy_scene(enemy_id)
		
		if scene == null:
			continue
		
		# 实例化一个敌人获取纹理、精灵信息和碰撞形状
		var temp_enemy = scene.instantiate()
		var sprite = temp_enemy.get_node_or_null("Sprite2D")
		var texture = null
		var sprite_scale = Vector2(0.75, 0.75)  # 默认缩放
		var hframes = 1
		var frame = 0
		
		if sprite:
			texture = sprite.texture
			sprite_scale = sprite.scale
			hframes = sprite.hframes if sprite.hframes > 0 else 1
			frame = sprite.frame
		
		# 获取碰撞形状
		var hurt_box = temp_enemy.get_node_or_null("HurtBox")
		var collision_shape = null
		if hurt_box:
			var shape_node = hurt_box.get_node_or_null("CollisionShape2D")
			if shape_node and shape_node.shape:
				collision_shape = shape_node.shape.duplicate()
		
		# 加载配置
		var config = _load_enemy_config(enemy_id)
		
		# 创建类型数据
		var type_data = EnemyTypeData.new(enemy_id, texture, config)
		type_data.collision_shape = collision_shape
		
		# 创建 MultiMesh
		if texture and container:
			var multimesh_instance = MultiMeshInstance2D.new()
			var multimesh = MultiMesh.new()
			
			# 使用 QuadMesh 作为基础网格
			var quad = QuadMesh.new()
			var tex_size = texture.get_size()
			
			# 如果是精灵表，创建 AtlasTexture 只使用第一帧
			var final_texture = texture
			if hframes > 1:
				var atlas = AtlasTexture.new()
				atlas.atlas = texture
				var frame_width = tex_size.x / float(hframes)
				atlas.region = Rect2(0, 0, frame_width, tex_size.y)
				final_texture = atlas
				tex_size = Vector2(frame_width, tex_size.y)
			
			# 设置 quad 大小（应用缩放）
			quad.size = tex_size * sprite_scale
			
			multimesh.mesh = quad
			multimesh.transform_format = MultiMesh.TRANSFORM_2D
			multimesh.instance_count = 0  # 初始为 0，动态调整
			
			multimesh_instance.multimesh = multimesh
			multimesh_instance.texture = final_texture
			multimesh_instance.z_index = 0
			
			container.add_child(multimesh_instance)
			type_data.multimesh_instance = multimesh_instance
			
			print("    - 创建 MultiMesh: %s (纹理: %dx%d, 帧: %d/%d)" % [enemy_id, tex_size.x, tex_size.y, frame, hframes])
		
		enemy_types[enemy_id] = type_data
		temp_enemy.queue_free()
		
		print("  ✓ 初始化敌人类型: %s" % enemy_id)
	
	print("✓ GPU 实例化系统就绪\n")

func _load_enemy_config(enemy_id: String) -> Dictionary:
	var file = FileAccess.open("res://config/enemy_config.ini", FileAccess.READ)
	if file == null:
		return {}
	
	var current_section = ""
	var config = {}
	
	while not file.eof_reached():
		var line = file.get_line().strip_edges()
		
		if line == "" or line.begins_with("#"):
			continue
		
		if line.begins_with("[") and line.ends_with("]"):
			current_section = line.substr(1, line.length() - 2)
			if current_section == enemy_id:
				config = {}
			continue
		
		if current_section == enemy_id and line.contains("="):
			var parts = line.split("=", true, 1)
			if parts.size() == 2:
				var key = parts[0].strip_edges()
				var value = parts[1].strip_edges()
				
				if key in ["hp", "enemy_damage", "experience"]:
					config[key] = int(value) if value.is_valid_int() else 0
				elif key in ["movement_speed", "knockback_recovery"]:
					config[key] = float(value) if value.is_valid_float() else 0.0
				else:
					config[key] = value
	
	file.close()
	return config

# 生成敌人
func spawn_enemy(enemy_type: String, pos: Vector2) -> int:
	if not enemy_types.has(enemy_type):
		return -1
	
	var type_data = enemy_types[enemy_type]
	var hp = type_data.config.get("hp", 10)
	
	var instance = EnemyInstance.new(pos, enemy_type, hp)
	
	# 创建碰撞检测区域
	if type_data.collision_shape and container:
		var hurt_box = Area2D.new()
		hurt_box.collision_layer = 0
		hurt_box.collision_mask = 4  # 检测武器层
		hurt_box.position = pos
		
		var collision_shape_node = CollisionShape2D.new()
		collision_shape_node.shape = type_data.collision_shape
		hurt_box.add_child(collision_shape_node)
		
		# 连接信号
		var instance_id = type_data.instances.size()
		hurt_box.area_entered.connect(_on_enemy_hurt.bind(enemy_type, instance_id))
		
		container.add_child(hurt_box)
		instance.hurt_box = hurt_box
	
	type_data.instances.append(instance)
	
	# 更新 MultiMesh 实例数量
	_update_multimesh(enemy_type)
	
	return type_data.instances.size() - 1

func _update_multimesh(enemy_type: String):
	if not enemy_types.has(enemy_type):
		return
	
	var type_data = enemy_types[enemy_type]
	var active_count = 0
	
	# 计算活跃敌人数量
	for inst in type_data.instances:
		if inst.active:
			active_count += 1
	
	# 更新 MultiMesh 实例数量
	if type_data.multimesh_instance:
		type_data.multimesh_instance.multimesh.instance_count = active_count

func _physics_process(delta):
	if player == null:
		return
	
	# 更新所有敌人
	for enemy_type in enemy_types:
		var type_data = enemy_types[enemy_type]
		_update_enemy_type(type_data, delta)

func _update_enemy_type(type_data: EnemyTypeData, delta: float):
	var config = type_data.config
	var movement_speed = config.get("movement_speed", 20.0)
	var knockback_recovery = config.get("knockback_recovery", 3.5)
	
	var active_index = 0
	
	for i in range(type_data.instances.size()):
		var inst = type_data.instances[i]
		
		if not inst.active:
			continue
		
		# 更新击退
		inst.knockback = inst.knockback.move_toward(Vector2.ZERO, knockback_recovery)
		
		# 移动向玩家
		var direction = inst.position.direction_to(player.global_position)
		inst.velocity = direction * movement_speed
		inst.velocity += inst.knockback
		inst.position += inst.velocity * delta
		
		# 更新翻转
		if direction.x > 0.1:
			inst.flip_h = true
		elif direction.x < -0.1:
			inst.flip_h = false
		
		# 更新碰撞体位置
		if inst.hurt_box and is_instance_valid(inst.hurt_box):
			inst.hurt_box.global_position = inst.position
		
		# 更新 MultiMesh Transform
		if type_data.multimesh_instance:
			# 创建基础 Transform
			var transform = Transform2D()
			
			# 应用翻转（如果需要）
			if inst.flip_h:
				transform.x.x = -1.0  # 翻转 X 轴
			
			# 设置位置
			transform.origin = inst.position
			
			type_data.multimesh_instance.multimesh.set_instance_transform_2d(active_index, transform)
		
		active_index += 1

# 敌人受伤
func damage_enemy(enemy_type: String, instance_id: int, damage: int, angle: Vector2, knockback_amount: int) -> bool:
	if not enemy_types.has(enemy_type):
		return false
	
	var type_data = enemy_types[enemy_type]
	if instance_id < 0 or instance_id >= type_data.instances.size():
		return false
	
	var inst = type_data.instances[instance_id]
	if not inst.active:
		return false
	
	inst.hp -= damage
	inst.knockback = angle * knockback_amount
	
	if inst.hp <= 0:
		_kill_enemy(type_data, inst, instance_id)
		return true
	
	return false

# 碰撞处理
func _on_enemy_hurt(area: Area2D, enemy_type: String, instance_id: int):
	if not area.is_in_group("attack"):
		return
	
	# 获取武器伤害
	var damage = 1
	var knockback_amount = 100
	var angle = Vector2.ZERO
	
	if area.has_method("get_damage"):
		damage = area.get_damage()
	if area.has_method("get_knockback"):
		knockback_amount = area.get_knockback()
	
	# 计算击退方向
	if enemy_types.has(enemy_type) and instance_id < enemy_types[enemy_type].instances.size():
		var inst = enemy_types[enemy_type].instances[instance_id]
		if inst.active:
			angle = area.global_position.direction_to(inst.position)
			damage_enemy(enemy_type, instance_id, damage, angle, knockback_amount)

func _kill_enemy(type_data: EnemyTypeData, inst: EnemyInstance, _instance_id: int):
	inst.active = false
	
	# 移除碰撞体
	if inst.hurt_box and is_instance_valid(inst.hurt_box):
		inst.hurt_box.queue_free()
		inst.hurt_box = null
	
	# 生成经验宝石
	var exp_amount = type_data.config.get("experience", 1)
	EventBus.emit_enemy_killed(inst.type_id, inst.position, exp_amount)
	
	# 更新 MultiMesh
	_update_multimesh(inst.type_id)

# 获取区域内的敌人（用于武器碰撞检测）
func get_enemies_in_area(area_position: Vector2, area_size: Vector2) -> Array:
	var result = []
	var half_size = area_size * 0.5
	
	for enemy_type in enemy_types:
		var type_data = enemy_types[enemy_type]
		
		for i in range(type_data.instances.size()):
			var inst = type_data.instances[i]
			if not inst.active:
				continue
			
			# 简单的矩形碰撞检测
			var diff = inst.position - area_position
			if abs(diff.x) <= half_size.x and abs(diff.y) <= half_size.y:
				result.append({
					"enemy_type": enemy_type,
					"instance_id": i,
					"position": inst.position
				})
	
	return result

# 获取圆形区域内的敌人
func get_enemies_in_radius(center: Vector2, radius: float) -> Array:
	var result = []
	var radius_sq = radius * radius
	
	for enemy_type in enemy_types:
		var type_data = enemy_types[enemy_type]
		
		for i in range(type_data.instances.size()):
			var inst = type_data.instances[i]
			if not inst.active:
				continue
			
			# 圆形碰撞检测
			var dist_sq = inst.position.distance_squared_to(center)
			if dist_sq <= radius_sq:
				result.append({
					"enemy_type": enemy_type,
					"instance_id": i,
					"position": inst.position,
					"distance": sqrt(dist_sq)
				})
	
	return result

# 获取统计信息
func get_stats() -> Dictionary:
	var stats = {
		"total_active": 0,
		"total_pooled": 0,
		"by_type": {}
	}
	
	for enemy_type in enemy_types:
		var type_data = enemy_types[enemy_type]
		var active = 0
		var pooled = 0
		
		for inst in type_data.instances:
			if inst.active:
				active += 1
			else:
				pooled += 1
		
		stats["total_active"] += active
		stats["total_pooled"] += pooled
		stats["by_type"][enemy_type] = {"active": active, "pooled": pooled}
	
	return stats
