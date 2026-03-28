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
	var hurt_box: Area2D = null  # 受击检测区域（被武器攻击）
	var hit_box: Area2D = null   # 攻击检测区域（攻击玩家）
	var anim_time: float = 0.0  # 动画时间
	var anim_offset: float = 0.0  # 动画偏移（让敌人不同步）
	
	func _init(pos: Vector2, enemy_type: String, health: float):
		position = pos
		type_id = enemy_type
		hp = health
		max_hp = health
		velocity = Vector2.ZERO
		knockback = Vector2.ZERO
		anim_offset = randf() * GameConfig.ENEMY_ANIM_OFFSET_RANGE

# 敌人类型数据
class EnemyTypeData:
	var type_id: String
	var texture: Texture2D
	var multimesh_instance: MultiMeshInstance2D
	var instances: Array[EnemyInstance] = []
	var config: Dictionary
	var hurt_collision_shape: Shape2D = null  # HurtBox 碰撞形状（被攻击）
	var hit_collision_shape: Shape2D = null   # HitBox 碰撞形状（攻击玩家）
	var hframes: int = 1  # 精灵表帧数
	
	func _init(id: String, tex: Texture2D, cfg: Dictionary):
		type_id = id
		texture = tex
		config = cfg

# 存储所有敌人类型
var enemy_types: Dictionary = {}  # type_id -> EnemyTypeData

# 同 hframes 共用一个 ShaderMaterial，避免重复编译
var _sprite_sheet_materials: Dictionary = {}  # int -> ShaderMaterial

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

func _get_sprite_sheet_material(hframes: int) -> ShaderMaterial:
	if _sprite_sheet_materials.has(hframes):
		return _sprite_sheet_materials[hframes]
	var shader_material := ShaderMaterial.new()
	var shader := Shader.new()
	shader.code = _create_sprite_sheet_shader(hframes)
	shader_material.shader = shader
	_sprite_sheet_materials[hframes] = shader_material
	return shader_material

func _coerce_texture2d(pval: Variant) -> Texture2D:
	if pval is Texture2D:
		return pval
	if pval is Resource:
		var path: String = pval.resource_path
		if path != "":
			var loaded = load(path)
			if loaded is Texture2D:
				return loaded
	return null

## 从 PackedScene 读取精灵与碰撞数据。
## 精灵数据用 SceneState 读取（快），碰撞形状用 instantiate（准确）。
func _parse_enemy_scene_from_state(packed: PackedScene) -> Dictionary:
	var out := {
		"texture": null,
		"sprite_scale": Vector2(0.75, 0.75),
		"hframes": 1,
		"hurt_collision_shape": null,
		"hit_collision_shape": null,
	}
	if packed == null:
		return out
	
	# 用 SceneState 读取精灵数据（快速，无副作用）
	var state := packed.get_state()
	if state:
		for i in state.get_node_count():
			var node_type := state.get_node_type(i)
			if node_type == &"Sprite2D":
				for j in state.get_node_property_count(i):
					var pname: StringName = state.get_node_property_name(i, j)
					var pval: Variant = state.get_node_property_value(i, j)
					match pname:
						&"texture":
							out.texture = _coerce_texture2d(pval)
						&"scale":
							if pval is Vector2:
								out.sprite_scale = pval
						&"hframes":
							if pval is int and pval > 0:
								out.hframes = pval
	
	# 用 instantiate 读取碰撞形状（准确，但需要临时实例化）
	var temp_enemy := packed.instantiate()
	
	# 获取 HurtBox（被攻击）
	var hurt_box := temp_enemy.get_node_or_null("HurtBox")
	if hurt_box:
		var shape_node := hurt_box.get_node_or_null("CollisionShape2D")
		if shape_node and shape_node.shape:
			out.hurt_collision_shape = shape_node.shape.duplicate()
	
	# 获取 HitBox（攻击玩家）
	var hit_box := temp_enemy.get_node_or_null("HitBox")
	if hit_box:
		var shape_node := hit_box.get_node_or_null("CollisionShape2D")
		if shape_node and shape_node.shape:
			out.hit_collision_shape = shape_node.shape.duplicate()
	
	temp_enemy.queue_free()
	
	return out

func _initialize_enemy_types():
	var start_time := Time.get_ticks_msec()
	
	var enemy_ids = EnemyRegistry.get_all_item_ids()
	if GameConfig.DEBUG_LOGGING:
		print("  开始初始化 %d 种敌人类型..." % enemy_ids.size())
	
	# 异步并行加载配置和场景数据
	var config_load_start := Time.get_ticks_msec()
	var configs := _load_all_enemy_configs_from_ini()
	var config_load_time := Time.get_ticks_msec() - config_load_start
	if GameConfig.DEBUG_LOGGING:
		print("    ⏱ 配置加载: %d ms" % config_load_time)
	
	# 批量解析场景数据（CPU 密集，但很快）
	var scene_parse_start := Time.get_ticks_msec()
	var scene_metas := {}
	for enemy_id in enemy_ids:
		var scene = EnemyRegistry.get_item_scene(enemy_id)
		if scene:
			scene_metas[enemy_id] = _parse_enemy_scene_from_state(scene)
	var scene_parse_time := Time.get_ticks_msec() - scene_parse_start
	if GameConfig.DEBUG_LOGGING:
		print("    ⏱ 场景解析: %d ms" % scene_parse_time)
	
	# 创建 MultiMesh（分帧执行，避免卡顿）
	var mesh_create_start := Time.get_ticks_msec()
	var init_count := 0
	for enemy_id in enemy_ids:
		init_count += 1
		
		if not scene_metas.has(enemy_id):
			continue
		
		var meta: Dictionary = scene_metas[enemy_id]
		var texture: Texture2D = meta.texture
		var sprite_scale: Vector2 = meta.sprite_scale
		var hframes: int = meta.hframes
		var hurt_shape: Shape2D = meta.hurt_collision_shape
		var hit_shape: Shape2D = meta.hit_collision_shape
		
		var config: Dictionary = configs.get(enemy_id, {})
		
		var type_data := EnemyTypeData.new(enemy_id, texture, config)
		type_data.hurt_collision_shape = hurt_shape
		type_data.hit_collision_shape = hit_shape
		type_data.hframes = hframes
		
		if texture and container:
			var tex_size := texture.get_size()
			var frame_width := tex_size.x / float(hframes) if hframes > 1 else tex_size.x
			
			var multimesh_instance := MultiMeshInstance2D.new()
			var multimesh := MultiMesh.new()
			
			var quad := QuadMesh.new()
			quad.size = Vector2(frame_width, tex_size.y) * sprite_scale
			
			multimesh.mesh = quad
			multimesh.transform_format = MultiMesh.TRANSFORM_2D
			multimesh.use_colors = true
			multimesh.instance_count = 0
			
			multimesh_instance.multimesh = multimesh
			multimesh_instance.texture = texture
			multimesh_instance.z_index = 0
			
			if hframes > 1:
				multimesh_instance.material = _get_sprite_sheet_material(hframes)
			
			container.add_child(multimesh_instance)
			type_data.multimesh_instance = multimesh_instance
		
		enemy_types[enemy_id] = type_data
		
		# 调试信息（仅在出错时显示）
		if not texture:
			push_warning("⚠️ 敌人 %s 没有纹理！" % enemy_id)
		if not hurt_shape:
			push_warning("⚠️ 敌人 %s 没有 HurtBox 碰撞形状！" % enemy_id)
		if not hit_shape:
			push_warning("⚠️ 敌人 %s 没有 HitBox 碰撞形状！" % enemy_id)
		
		if GameConfig.DEBUG_LOGGING and hframes > 1:
			print("    📽 敌人 %s 有 %d 帧动画" % [enemy_id, hframes])
		
		# 每创建一个类型，让出一帧（避免长时间阻塞）
		if init_count < enemy_ids.size():
			await get_tree().process_frame
	
	var mesh_create_time := Time.get_ticks_msec() - mesh_create_start
	var total_time := Time.get_ticks_msec() - start_time
	
	if GameConfig.DEBUG_LOGGING:
		print("    ⏱ MultiMesh 创建: %d ms" % mesh_create_time)
		print("✓ GPU 实例化系统就绪（共 %d 种敌人，总耗时 %d ms）\n" % [enemy_ids.size(), total_time])
	
	is_initialized = true
	call_deferred("emit_signal", "initialization_complete")

func _parse_enemy_config_line(section: String, key: String, value: String, into: Dictionary) -> void:
	if key in ["hp", "enemy_damage", "experience"]:
		into[section][key] = int(value) if value.is_valid_int() else 0
	elif key in ["movement_speed", "knockback_recovery"]:
		into[section][key] = float(value) if value.is_valid_float() else 0.0
	else:
		into[section][key] = value

## 只读一次 enemy_config.ini，避免每种敌人整文件扫一遍。
func _load_all_enemy_configs_from_ini() -> Dictionary:
	var result: Dictionary = {}
	var file = FileAccess.open(GameConfig.PATH_ENEMY_CONFIG, FileAccess.READ)
	if file == null:
		return result
	var current_section: String = ""
	while not file.eof_reached():
		var line: String = file.get_line().strip_edges()
		if line == "" or line.begins_with("#"):
			continue
		if line.begins_with("[") and line.ends_with("]"):
			current_section = line.substr(1, line.length() - 2)
			result[current_section] = {}
			continue
		if current_section != "" and line.contains("="):
			var parts: PackedStringArray = line.split("=", true, 1)
			if parts.size() == 2:
				var key: String = parts[0].strip_edges()
				var value: String = parts[1].strip_edges()
				_parse_enemy_config_line(current_section, key, value, result)
	file.close()
	return result

# 生成敌人
func spawn_enemy(enemy_type: String, pos: Vector2) -> int:
	if not enemy_types.has(enemy_type):
		return -1
	
	var type_data = enemy_types[enemy_type]
	var hp = type_data.config.get("hp", 10)
	
	var instance = EnemyInstance.new(pos, enemy_type, hp)
	
	# 创建碰撞检测区域
	if container:
		var instance_id = type_data.instances.size()
		
		# 创建 HurtBox（被武器攻击）
		if type_data.hurt_collision_shape:
			var hurt_box = Area2D.new()
			hurt_box.collision_layer = 4  # Layer 3 (Enemy)
			hurt_box.collision_mask = 4   # 检测 Layer 3（武器）
			hurt_box.position = pos
			hurt_box.monitoring = true
			hurt_box.monitorable = true
			hurt_box.add_to_group("enemy_hurtbox")
			
			var hurt_shape_node = CollisionShape2D.new()
			hurt_shape_node.shape = type_data.hurt_collision_shape
			hurt_box.add_child(hurt_shape_node)
			
			hurt_box.area_entered.connect(_on_enemy_hurt.bind(enemy_type, instance_id))
			container.add_child(hurt_box)
			instance.hurt_box = hurt_box
		
		# 创建 HitBox（攻击玩家）
		if type_data.hit_collision_shape:
			var hit_box = Area2D.new()
			hit_box.collision_layer = 2  # Layer 2 (Enemy Attack)
			hit_box.collision_mask = 1   # 检测 Layer 1（玩家）
			hit_box.position = pos
			hit_box.monitoring = true
			hit_box.monitorable = true
			hit_box.add_to_group("enemy_hitbox")
			
			var hit_shape_node = CollisionShape2D.new()
			hit_shape_node.shape = type_data.hit_collision_shape
			hit_box.add_child(hit_shape_node)
			
			var enemy_damage = type_data.config.get("enemy_damage", 1)
			hit_box.area_entered.connect(_on_enemy_hit_player.bind(enemy_type, instance_id, enemy_damage))
			
			container.add_child(hit_box)
			instance.hit_box = hit_box
	
	type_data.instances.append(instance)
	
	# 不在这里更新 MultiMesh，由 _physics_process 统一处理
	# 这样可以避免生成时的闪现
	
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
	if not type_data.multimesh_instance:
		return
	
	var config = type_data.config
	var movement_speed = config.get("movement_speed", 20.0)
	var knockback_recovery = config.get("knockback_recovery", 3.5)
	
	# 准备 Transform 和 Color 数据
	var transforms = []
	var colors = []
	
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
		if inst.hit_box and is_instance_valid(inst.hit_box):
			inst.hit_box.global_position = inst.position
		
		# 准备 Transform
		var scale_x = -1.0 if inst.flip_h else 1.0
		var scale_y = -1.0  # 翻转 Y 轴
		
		var transform = Transform2D(
			Vector2(scale_x, 0),
			Vector2(0, scale_y),
			inst.position
		)
		transforms.append(transform)
		
		# 准备 Color（动画帧）
		if type_data.hframes > 1:
			var total_time = inst.anim_time + inst.anim_offset
			var current_frame = int(total_time / GameConfig.ENEMY_ANIM_FRAME_DURATION) % type_data.hframes
			# 映射到 [0, 1) 范围，确保 Shader 能正确计算帧索引
			# 例如 2 帧：frame 0 -> 0.0, frame 1 -> 0.5
			var frame_normalized = (float(current_frame) + 0.5) / float(type_data.hframes)
			colors.append(Color(frame_normalized, 0, 0, 1))
		else:
			colors.append(Color(1, 1, 1, 1))
	
	# 一次性更新 MultiMesh（先设置数量，再批量设置 Transform）
	var active_count = transforms.size()
	type_data.multimesh_instance.multimesh.instance_count = active_count
	
	for idx in range(active_count):
		type_data.multimesh_instance.multimesh.set_instance_transform_2d(idx, transforms[idx])
		if type_data.hframes > 1:
			type_data.multimesh_instance.multimesh.set_instance_color(idx, colors[idx])

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
		if GameConfig.DEBUG_COLLISION:
			print("⚠️ 碰撞区域不在 attack 组: ", area.name)
		return
	
	if GameConfig.DEBUG_COLLISION:
		print("✓ 敌人受击: %s[%d] 被 %s 击中" % [enemy_type, instance_id, area.name])
	
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

# 敌人攻击玩家
func _on_enemy_hit_player(area: Area2D, enemy_type: String, instance_id: int, enemy_damage: int):
	if not enemy_types.has(enemy_type):
		return
	if instance_id < 0 or instance_id >= enemy_types[enemy_type].instances.size():
		return
	
	var inst = enemy_types[enemy_type].instances[instance_id]
	if not inst.active:
		return
	
	# 检查是否是玩家的 HurtBox
	if area.has_signal("hurt"):
		var angle = inst.position.direction_to(area.global_position)
		area.emit_signal("hurt", enemy_damage, angle, 0)

func _kill_enemy(type_data: EnemyTypeData, inst: EnemyInstance, _instance_id: int):
	inst.active = false
	
	# 移除碰撞体
	if inst.hurt_box and is_instance_valid(inst.hurt_box):
		inst.hurt_box.queue_free()
		inst.hurt_box = null
	if inst.hit_box and is_instance_valid(inst.hit_box):
		inst.hit_box.queue_free()
		inst.hit_box = null
	
	# 生成死亡爆炸动画（直接实例化，避免对象池的父节点冲突）
	var death_anim_scene = load("res://Enemy/explosion.tscn")
	var explosion = death_anim_scene.instantiate()
	
	if explosion:
		explosion.global_position = inst.position
		
		# 添加到容器
		if container:
			container.call_deferred("add_child", explosion)
	
	# 生成经验宝石（直接实例化，避免对象池的父节点冲突）
	var exp_amount = type_data.config.get("experience", 1)
	var exp_gem_scene = load("res://Objects/experience_gem.tscn")
	var exp_gem = exp_gem_scene.instantiate()
	
	if exp_gem:
		exp_gem.global_position = inst.position
		exp_gem.experience = exp_amount
		
		# 添加到 Loot 节点
		var loot_base = get_tree().get_first_node_in_group("loot")
		if loot_base:
			loot_base.call_deferred("add_child", exp_gem)
	
	# 不在这里更新 MultiMesh，由 _physics_process 统一处理

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
