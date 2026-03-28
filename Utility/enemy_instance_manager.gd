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
	var anim_time: float = 0.0  # 动画时间
	var anim_offset: float = 0.0  # 动画偏移（让敌人不同步）
	
	func _init(pos: Vector2, enemy_type: String, health: float):
		position = pos
		type_id = enemy_type
		hp = health
		max_hp = health
		velocity = Vector2.ZERO
		knockback = Vector2.ZERO
		anim_offset = randf() * 0.6  # 随机偏移 0-0.6 秒

# 敌人类型数据
class EnemyTypeData:
	var type_id: String
	var texture: Texture2D
	var multimesh_instance: MultiMeshInstance2D
	var instances: Array[EnemyInstance] = []
	var config: Dictionary
	var collision_shape: Shape2D = null  # 碰撞形状模板
	var hframes: int = 1  # 精灵表帧数
	
	func _init(id: String, tex: Texture2D, cfg: Dictionary):
		type_id = id
		texture = tex
		config = cfg

# 存储所有敌人类型
var enemy_types: Dictionary = {}  # type_id -> EnemyTypeData

# 引用
var player: Node = null
var container: Node2D = null
var is_initialized: bool = false

signal initialization_complete

func _ready():
	print("\n=== GPU 实例化敌人管理器初始化 ===")
	_initialize_enemy_types()

func set_container(parent: Node2D):
	container = parent

func set_player(p: Node):
	player = p

# 创建精灵表 Shader
func _create_sprite_sheet_shader(hframes: int) -> String:
	return """
shader_type canvas_item;

uniform int hframes = %d;

void fragment() {
	// 从 COLOR.r 获取帧索引（0-1 范围映射到 0-hframes）
	float frame_index = COLOR.r * float(hframes);
	int frame = int(frame_index);
	
	// 计算 UV 偏移
	float frame_width = 1.0 / float(hframes);
	vec2 uv = UV;
	uv.x = uv.x * frame_width + float(frame) * frame_width;
	
	// 采样纹理
	COLOR = texture(TEXTURE, uv);
}
""" % hframes

func _initialize_enemy_types():
	# 等待 EnemyRegistry 初始化
	await get_tree().process_frame
	
	var enemy_ids = EnemyRegistry.get_all_enemy_ids()
	print("  开始初始化 %d 种敌人类型..." % enemy_ids.size())
	
	# 第一步：批量预加载所有配置（快速）
	var configs = {}
	for enemy_id in enemy_ids:
		configs[enemy_id] = _load_enemy_config(enemy_id)
	
	var init_count = 0
	for enemy_id in enemy_ids:
		init_count += 1
		var _enemy_data = EnemyRegistry.get_enemy_data(enemy_id)
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
		
		# 使用预加载的配置
		var config = configs.get(enemy_id, {})
		
		# 创建类型数据
		var type_data = EnemyTypeData.new(enemy_id, texture, config)
		type_data.collision_shape = collision_shape
		type_data.hframes = hframes
		
		# 创建单个 MultiMesh（使用 Shader 控制帧）
		if texture and container:
			var tex_size = texture.get_size()
			var frame_width = tex_size.x / float(hframes) if hframes > 1 else tex_size.x
			
			var multimesh_instance = MultiMeshInstance2D.new()
			var multimesh = MultiMesh.new()
			
			var quad = QuadMesh.new()
			quad.size = Vector2(frame_width, tex_size.y) * sprite_scale
			
			multimesh.mesh = quad
			multimesh.transform_format = MultiMesh.TRANSFORM_2D
			multimesh.use_colors = true  # 使用 color 通道传递帧索引
			multimesh.instance_count = 0
			
			multimesh_instance.multimesh = multimesh
			multimesh_instance.texture = texture
			multimesh_instance.z_index = 0
			
			# 创建 Shader 材质
			if hframes > 1:
				var shader_material = ShaderMaterial.new()
				var shader = Shader.new()
				shader.code = _create_sprite_sheet_shader(hframes)
				shader_material.shader = shader
				multimesh_instance.material = shader_material
			
			container.add_child(multimesh_instance)
			type_data.multimesh_instance = multimesh_instance
			
			print("    - 创建 MultiMesh: %s (纹理: %dx%d, %d 帧)" % [enemy_id, tex_size.x, tex_size.y, hframes])
		
		enemy_types[enemy_id] = type_data
		temp_enemy.queue_free()
		
		print("  ✓ [%d/%d] 初始化敌人类型: %s" % [init_count, enemy_ids.size(), enemy_id])
		
		# 每初始化一个类型，等待一帧（避免卡顿）
		if init_count < enemy_ids.size():
			await get_tree().process_frame
	
	print("✓ GPU 实例化系统就绪（共 %d 种敌人）\n" % enemy_ids.size())
	is_initialized = true
	emit_signal("initialization_complete")

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
		hurt_box.monitoring = true
		hurt_box.monitorable = true
		
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
	
	# 第一遍：更新逻辑并计算活跃数量
	var active_count = 0
	for i in range(type_data.instances.size()):
		var inst = type_data.instances[i]
		
		if not inst.active:
			continue
		
		active_count += 1
		
		# 更新击退
		inst.knockback = inst.knockback.move_toward(Vector2.ZERO, knockback_recovery)
		
		# 移动向玩家
		var direction = inst.position.direction_to(player.global_position)
		inst.velocity = direction * movement_speed
		inst.velocity += inst.knockback
		inst.position += inst.velocity * delta
		
		# 更新动画时间
		inst.anim_time += delta
		
		# 更新翻转（因为 Y 轴翻转，X 轴逻辑也要反转）
		if direction.x > 0.1:
			inst.flip_h = true   # 向右，需要翻转（因为 Y 轴已翻转）
		elif direction.x < -0.1:
			inst.flip_h = false  # 向左，不翻转
		
		# 更新碰撞体位置
		if inst.hurt_box and is_instance_valid(inst.hurt_box):
			inst.hurt_box.global_position = inst.position
	
	# 先更新 instance_count，避免闪现
	if type_data.multimesh_instance:
		type_data.multimesh_instance.multimesh.instance_count = active_count
	
	# 第二遍：更新 MultiMesh Transform 和颜色
	var active_index = 0
	for i in range(type_data.instances.size()):
		var inst = type_data.instances[i]
		
		if not inst.active:
			continue
		
		# 更新 MultiMesh Transform 和动画帧
		if type_data.multimesh_instance:
			# 创建 Transform（Y 轴翻转以匹配 Sprite2D 坐标系）
			var scale_x = -1.0 if inst.flip_h else 1.0
			var scale_y = -1.0  # 翻转 Y 轴修正上下颠倒
			
			var transform = Transform2D(
				Vector2(scale_x, 0),    # X 轴
				Vector2(0, scale_y),     # Y 轴（翻转）
				inst.position            # 位置
			)
			
			type_data.multimesh_instance.multimesh.set_instance_transform_2d(active_index, transform)
			
			# 计算当前帧并通过 COLOR 传递给 Shader
			if type_data.hframes > 1:
				var total_time = inst.anim_time + inst.anim_offset
				var current_frame = int(total_time / 0.3) % type_data.hframes
				var frame_normalized = float(current_frame) / float(type_data.hframes)
				
				# 使用 COLOR.r 传递帧索引（0-1 范围）
				var color = Color(frame_normalized, 0, 0, 1)
				type_data.multimesh_instance.multimesh.set_instance_color(active_index, color)
		
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
	
	# 生成经验宝石（直接实例化，不使用信号）
	var exp_amount = type_data.config.get("experience", 1)
	var exp_gem_scene = load("res://Objects/experience_gem.tscn")
	var exp_gem = ObjectPool.get_object("experience_gem", exp_gem_scene)
	if exp_gem:
		exp_gem.global_position = inst.position
		exp_gem.experience = exp_amount
		
		# 添加到 Loot 节点（如果已有父节点，ObjectPool 会处理）
		var loot_base = get_tree().get_first_node_in_group("loot")
		if loot_base and exp_gem.get_parent() == null:
			loot_base.call_deferred("add_child", exp_gem)
	
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
