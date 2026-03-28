extends Node

## GPU 实例化技能管理器
## 使用 MultiMesh 批量渲染同类型技能，提升性能

class SkillInstance:
	var position: Vector2
	var velocity: Vector2
	var rotation: float
	var scale: Vector2
	var type_id: String
	var active: bool = true
	var lifetime: float = 0.0
	var max_lifetime: float = 5.0
	var hit_box: Area2D = null
	var hit_enemies: Array = []
	var pierce_count: int = 1
	var anim_time: float = 0.0
	var anim_offset: float = 0.0
	var target: Vector2 = Vector2.ZERO
	
	# 行为特定数据（根据 behavior_type 使用）
	var behavior_data: Dictionary = {}
	
	func _init(pos: Vector2, skill_type: String):
		position = pos
		type_id = skill_type
		velocity = Vector2.ZERO
		rotation = 0.0
		scale = Vector2.ONE
		anim_offset = randf() * 0.5

class SkillTypeData:
	var type_id: String
	var texture: Texture2D
	var multimesh_instance: MultiMeshInstance2D
	var instances: Array[SkillInstance] = []
	var config: Dictionary
	var collision_shape: Shape2D = null
	var hframes: int = 1
	var behavior_script: Node = null  # 技能行为脚本实例（子类）
	
	func _init(id: String, tex: Texture2D, cfg: Dictionary):
		type_id = id
		texture = tex
		config = cfg

var skill_types: Dictionary = {}  # type_id -> SkillTypeData
var _sprite_sheet_materials: Dictionary = {}  # int -> ShaderMaterial

# 技能状态管理（整合自 skill_manager）
var skill_levels: Dictionary = {}  # skill_id -> level
var skill_ammo: Dictionary = {}  # skill_id -> current_ammo
var skill_base_ammo: Dictionary = {}  # skill_id -> base_ammo
var skill_attack_speeds: Dictionary = {}  # skill_id -> attack_speed

var player: Node = null
var container: Node2D = null
var is_initialized: bool = false

signal initialization_complete

func _ready():
	if GameConfig.DEBUG_LOGGING:
		print("\n=== GPU 实例化技能管理器初始化 ===")
	_initialize_skill_data()
	_initialize_skill_types()

func _initialize_skill_data():
	# 初始化所有技能的状态数据
	initialize_skill_data("icespear", 0, 0, 1.5)
	initialize_skill_data("tornado", 0, 0, 3.0)
	initialize_skill_data("javelin", 0, 0, 5.0)

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
	float frame_index = COLOR.r * float(hframes);
	int frame = int(frame_index);
	
	float frame_width = 1.0 / float(hframes);
	vec2 uv = UV;
	uv.x = uv.x * frame_width + float(frame) * frame_width;
	
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
		return pval as Texture2D
	return null

func _parse_skill_scene_from_state(packed: PackedScene) -> Dictionary:
	var result = {
		"texture": null,
		"hframes": 1,
		"collision_shape": null
	}
	
	var temp_instance = packed.instantiate()
	
	# 查找 Sprite2D
	for child in temp_instance.get_children():
		if child is Sprite2D:
			result.texture = child.texture
			result.hframes = child.hframes
			break
	
	# 查找 CollisionShape2D
	for child in temp_instance.get_children():
		if child is CollisionShape2D:
			result.collision_shape = child.shape
			break
	
	temp_instance.queue_free()
	return result

func _initialize_skill_types():
	var start_time := Time.get_ticks_msec()
	
	await SkillRegistry.ensure_loaded()
	
	var skill_ids = SkillRegistry.get_all_item_ids()
	
	if GameConfig.DEBUG_LOGGING:
		print("  初始化 %d 个技能类型..." % skill_ids.size())
	
	for skill_id in skill_ids:
		var scene = SkillRegistry.get_item_scene(skill_id)
		if not scene:
			push_error("❌ 无法加载技能场景: %s" % skill_id)
			continue
		
		var scene_data = _parse_skill_scene_from_state(scene)
		
		if not scene_data.texture:
			push_error("❌ 技能 %s 缺少纹理" % skill_id)
			continue
		
		var config = _load_skill_config(skill_id)
		var type_data = SkillTypeData.new(skill_id, scene_data.texture, config)
		type_data.hframes = scene_data.hframes
		type_data.collision_shape = scene_data.collision_shape
		
		# 实例化技能行为脚本（子类）
		var behavior_instance = scene.instantiate()
		if behavior_instance is BaseSkill:
			behavior_instance.setup(player, self)
			type_data.behavior_script = behavior_instance
			add_child(behavior_instance)
			if GameConfig.DEBUG_LOGGING:
				print("    - 行为脚本: %s" % behavior_instance.get_script().get_path())
		else:
			push_warning("⚠ 技能 %s 未继承 BaseSkill，使用默认行为" % skill_id)
		
		var multimesh := MultiMesh.new()
		multimesh.transform_format = MultiMesh.TRANSFORM_2D
		multimesh.use_colors = true
		multimesh.use_custom_data = false
		multimesh.mesh = QuadMesh.new()
		
		var multimesh_instance := MultiMeshInstance2D.new()
		multimesh_instance.multimesh = multimesh
		multimesh_instance.texture = scene_data.texture
		
		if scene_data.hframes > 1:
			multimesh_instance.material = _get_sprite_sheet_material(scene_data.hframes)
		
		type_data.multimesh_instance = multimesh_instance
		skill_types[skill_id] = type_data
		
		if container:
			container.add_child(multimesh_instance)
		
		if GameConfig.DEBUG_LOGGING:
			print("  ✓ 初始化技能: %s (帧数: %d)" % [skill_id, scene_data.hframes])
	
	is_initialized = true
	var total_time := Time.get_ticks_msec() - start_time
	
	if GameConfig.DEBUG_LOGGING:
		print("✓ GPU 技能管理器初始化完成 (耗时 %d ms)\n" % total_time)
	
	emit_signal("initialization_complete")

func _load_skill_config(skill_id: String) -> Dictionary:
	var cfg = ConfigFile.new()
	if cfg.load("res://config/skill_config.ini") != OK:
		return {}
	
	var section = skill_id.capitalize().replace(" ", "")
	if not cfg.has_section(section):
		return {}
	
	var config = {
		"behavior_type": cfg.get_value(section, "behavior_type", "linear"),
		"damage": cfg.get_value(section, "base_damage", 5),
		"speed": cfg.get_value(section, "base_speed", 100.0),
		"knockback": cfg.get_value(section, "base_knockback_amount", 100),
		"lifetime": cfg.get_value(section, "base_lifetime", 5.0),
		"pierce": cfg.get_value(section, "base_pierce", 1),
		"attack_size": cfg.get_value(section, "base_attack_size", 1.0),
	}
	
	# 根据行为类型加载额外参数
	match config.behavior_type:
		"tracking":
			config["rotation_offset"] = cfg.get_value(section, "rotation_offset", 0)
			config["tracking_enabled"] = cfg.get_value(section, "tracking_enabled", true)
		"zigzag":
			config["zigzag_range"] = cfg.get_value(section, "zigzag_range", 500)
			config["direction_change_interval"] = cfg.get_value(section, "direction_change_interval", 2.0)
			config["speed_acceleration"] = cfg.get_value(section, "speed_acceleration", 50)
		"orbital":
			config["orbit_radius"] = cfg.get_value(section, "orbit_radius", 50)
			config["return_speed"] = cfg.get_value(section, "return_speed", 20)
			config["attack_speed"] = cfg.get_value(section, "base_attack_speed", 5.0)
	
	return config

func spawn_skill_with_behavior(skill_type: String) -> int:
	if not skill_types.has(skill_type):
		push_error("❌ 未知技能类型: %s" % skill_type)
		return -1
	
	var type_data = skill_types[skill_type]
	
	# 调用技能子类获取生成参数
	if not type_data.behavior_script or not type_data.behavior_script.has_method("get_spawn_params"):
		push_error("❌ 技能 %s 缺少行为脚本" % skill_type)
		return -1
	
	var params = type_data.behavior_script.get_spawn_params()
	return spawn_skill(skill_type, params.position, params.target)

func spawn_skill(skill_type: String, pos: Vector2, target_pos: Vector2 = Vector2.ZERO) -> int:
	if not skill_types.has(skill_type):
		push_error("❌ 未知技能类型: %s" % skill_type)
		return -1
	
	var type_data = skill_types[skill_type]
	var config = type_data.config
	
	var inst = SkillInstance.new(pos, skill_type)
	inst.max_lifetime = config.get("lifetime", 5.0)
	inst.pierce_count = config.get("pierce", 1)
	inst.scale = Vector2.ONE * config.get("attack_size", 1.0)
	inst.target = target_pos
	
	# 应用玩家修正器
	if player and player.has_method("get"):
		var spell_size = player.get("spell_size")
		if spell_size != null:
			inst.scale *= (1.0 + spell_size)
	
	# 根据行为类型初始化速度和旋转
	var behavior_type = config.get("behavior_type", "linear")
	match behavior_type:
		"tracking":
			# 追踪型：指向目标
			if target_pos != Vector2.ZERO:
				var dir = pos.direction_to(target_pos)
				inst.velocity = dir * config.get("speed", 100.0)
				inst.rotation = dir.angle() + deg_to_rad(config.get("rotation_offset", 0))
		"zigzag":
			# 之字形：根据玩家移动方向
			var last_movement = player.last_movement if player and player.has("last_movement") else Vector2.UP
			var dir = last_movement.normalized()
			inst.velocity = dir * (config.get("speed", 100.0) * 0.2)  # 初始速度较慢
			inst.rotation = 0.0
			
			# 初始化之字形参数
			var zigzag_range = config.get("zigzag_range", 500)
			var move_to_less = pos + Vector2(-dir.y, dir.x) * zigzag_range * randf_range(0.25, 1.0)
			var move_to_more = pos + Vector2(dir.y, -dir.x) * zigzag_range * randf_range(0.25, 1.0)
			inst.behavior_data["angle_less"] = pos.direction_to(move_to_less)
			inst.behavior_data["angle_more"] = pos.direction_to(move_to_more)
			inst.behavior_data["current_angle"] = inst.behavior_data["angle_less"] if randi() % 2 == 0 else inst.behavior_data["angle_more"]
			inst.behavior_data["direction_timer"] = 0.0
			inst.behavior_data["current_speed"] = config.get("speed", 100.0) * 0.2
		"orbital":
			# 环绕型：围绕玩家
			inst.velocity = Vector2.ZERO
			inst.rotation = 0.0
			inst.behavior_data["orbit_angle"] = randf() * TAU
			inst.behavior_data["is_attacking"] = false
			inst.behavior_data["attack_targets"] = []
		_:
			# 默认：直线移动
			inst.velocity = Vector2.RIGHT * config.get("speed", 100.0)
			inst.rotation = 0.0
	
	# 创建碰撞体
	if type_data.collision_shape:
		var hit_box = Area2D.new()
		hit_box.collision_layer = 4  # Layer 3: 武器
		hit_box.collision_mask = 4   # Mask 3: 敌人
		hit_box.position = pos
		hit_box.rotation = inst.rotation
		hit_box.scale = inst.scale
		
		var collision = CollisionShape2D.new()
		collision.shape = type_data.collision_shape
		hit_box.add_child(collision)
		
		if container:
			container.add_child(hit_box)
		
		hit_box.area_entered.connect(_on_skill_hit_enemy.bind(skill_type, type_data.instances.size(), config.get("damage", 5), config.get("knockback", 100)))
		inst.hit_box = hit_box
	
	type_data.instances.append(inst)
	_update_multimesh(type_data)
	
	return type_data.instances.size() - 1

func _on_skill_hit_enemy(area: Area2D, skill_type: String, instance_id: int, damage: int, knockback: int):
	if not skill_types.has(skill_type):
		return
	
	var type_data = skill_types[skill_type]
	if instance_id < 0 or instance_id >= type_data.instances.size():
		return
	
	var inst = type_data.instances[instance_id]
	if not inst.active:
		return
	
	# 检查是否已击中此敌人
	var enemy_id = area.get_instance_id()
	if inst.hit_enemies.has(enemy_id):
		return
	
	inst.hit_enemies.append(enemy_id)
	
	# 发射伤害信号
	if area.has_signal("hurt"):
		var angle = inst.position.direction_to(area.global_position)
		area.emit_signal("hurt", damage, angle, knockback)
	
	# 减少穿透次数
	if inst.pierce_count > 0:
		inst.pierce_count -= 1
		if inst.pierce_count <= 0:
			_destroy_skill(type_data, inst, instance_id)

func _destroy_skill(type_data: SkillTypeData, inst: SkillInstance, _instance_id: int):
	inst.active = false
	
	if inst.hit_box and is_instance_valid(inst.hit_box):
		inst.hit_box.queue_free()
		inst.hit_box = null
	
	_update_multimesh(type_data)

func _physics_process(delta: float):
	if not is_initialized:
		return
	
	for type_data in skill_types.values():
		_update_skill_type(type_data, delta)

func _update_skill_type(type_data: SkillTypeData, delta: float):
	var needs_update := false
	
	for inst in type_data.instances:
		if not inst.active:
			continue
		
		# 更新生命周期
		inst.lifetime += delta
		if inst.lifetime >= inst.max_lifetime:
			_destroy_skill(type_data, inst, type_data.instances.find(inst))
			needs_update = true
			continue
		
		# 更新动画
		inst.anim_time += delta
		
		# 调用技能子类的行为逻辑
		if type_data.behavior_script and type_data.behavior_script.has_method("update_skill_instance"):
			var inst_dict = {
				"position": inst.position,
				"velocity": inst.velocity,
				"rotation": inst.rotation,
				"scale": inst.scale,
				"lifetime": inst.lifetime,
				"target": inst.target,
			}
			
			# 复制 behavior_data 到 inst_dict
			for key in inst.behavior_data:
				inst_dict[key] = inst.behavior_data[key]
			
			# 调用子类的更新方法
			var updated = type_data.behavior_script.update_skill_instance(inst_dict, delta)
			
			# 更新实例数据
			inst.position = updated.get("position", inst.position)
			inst.velocity = updated.get("velocity", inst.velocity)
			inst.rotation = updated.get("rotation", inst.rotation)
			
			# 更新 behavior_data
			for key in updated:
				if key not in ["position", "velocity", "rotation", "scale", "lifetime", "target"]:
					inst.behavior_data[key] = updated[key]
		else:
			# 默认行为：直线移动
			inst.position += inst.velocity * delta
		
		# 更新碰撞体位置
		if inst.hit_box and is_instance_valid(inst.hit_box):
			inst.hit_box.global_position = inst.position
			inst.hit_box.rotation = inst.rotation
			inst.hit_box.scale = inst.scale
		
		needs_update = true
	
	if needs_update:
		_update_multimesh(type_data)

# ========================================
# 行为系统 - 根据配置驱动
# ========================================

func _update_tracking_behavior(inst: SkillInstance, config: Dictionary, delta: float):
	# 追踪型：持续朝向目标
	if inst.target != Vector2.ZERO:
		var dir = inst.position.direction_to(inst.target)
		inst.velocity = dir * config.get("speed", 100.0)
		inst.rotation = dir.angle() + deg_to_rad(config.get("rotation_offset", 0))
	else:
		inst.position += inst.velocity * delta

func _update_zigzag_behavior(inst: SkillInstance, config: Dictionary, delta: float):
	# 之字形：定期切换方向
	if not inst.behavior_data.has("direction_timer"):
		inst.behavior_data["direction_timer"] = 0.0
		inst.behavior_data["current_speed"] = config.get("speed", 100.0) * 0.2
		inst.behavior_data["angle_less"] = inst.velocity.normalized()
		inst.behavior_data["angle_more"] = -inst.behavior_data["angle_less"]
		inst.behavior_data["current_angle"] = inst.behavior_data["angle_less"]
	
	inst.behavior_data["direction_timer"] += delta
	
	# 切换方向
	var interval = config.get("direction_change_interval", 2.0)
	if inst.behavior_data["direction_timer"] >= interval:
		inst.behavior_data["direction_timer"] = 0.0
		var current = inst.behavior_data["current_angle"]
		inst.behavior_data["current_angle"] = inst.behavior_data["angle_more"] if current == inst.behavior_data["angle_less"] else inst.behavior_data["angle_less"]
	
	# 速度逐渐增加
	var max_speed = config.get("speed", 100.0)
	var accel = config.get("speed_acceleration", 50)
	inst.behavior_data["current_speed"] = min(inst.behavior_data["current_speed"] + accel * delta, max_speed)
	
	inst.velocity = inst.behavior_data["current_angle"] * inst.behavior_data["current_speed"]
	inst.position += inst.velocity * delta

func _update_orbital_behavior(inst: SkillInstance, config: Dictionary, delta: float):
	# 环绕型：围绕玩家，定期攻击
	if not inst.behavior_data.has("orbit_angle"):
		inst.behavior_data["orbit_angle"] = randf() * TAU
		inst.behavior_data["is_attacking"] = false
		inst.behavior_data["attack_targets"] = []
	
	if inst.behavior_data["is_attacking"] and inst.behavior_data["attack_targets"].size() > 0:
		# 攻击模式：飞向目标
		var target = inst.behavior_data["attack_targets"][0]
		var dir = inst.position.direction_to(target)
		inst.velocity = dir * config.get("speed", 150.0)
		inst.rotation = dir.angle() + deg_to_rad(135)
		inst.position += inst.velocity * delta
		
		# 到达目标
		if inst.position.distance_to(target) < 20:
			inst.behavior_data["attack_targets"].remove_at(0)
			if inst.behavior_data["attack_targets"].size() == 0:
				inst.behavior_data["is_attacking"] = false
	else:
		# 环绕模式
		if not player:
			inst.position += inst.velocity * delta
			return
		
		inst.behavior_data["orbit_angle"] += delta * 2.0
		var radius = config.get("orbit_radius", 50)
		var offset = Vector2(cos(inst.behavior_data["orbit_angle"]), sin(inst.behavior_data["orbit_angle"])) * radius
		var target_pos = player.position + offset
		
		var return_speed = config.get("return_speed", 20)
		inst.velocity = (target_pos - inst.position) * return_speed * delta
		inst.position += inst.velocity
		inst.rotation = inst.velocity.angle() + deg_to_rad(135) if inst.velocity.length() > 0.1 else inst.rotation

func _update_multimesh(type_data: SkillTypeData):
	var active_instances = type_data.instances.filter(func(inst): return inst.active)
	var count = active_instances.size()
	
	type_data.multimesh_instance.multimesh.instance_count = count
	
	if count == 0:
		return
	
	var tex_size = type_data.texture.get_size()
	var frame_width = tex_size.x / float(type_data.hframes)
	var quad_size = Vector2(frame_width, tex_size.y)
	
	for i in range(count):
		var inst = active_instances[i]
		
		var transform = Transform2D()
		transform = transform.scaled(inst.scale * quad_size)
		transform = transform.rotated(inst.rotation)
		transform.origin = inst.position
		
		type_data.multimesh_instance.multimesh.set_instance_transform_2d(i, transform)
		
		# 动画帧
		var frame_index := 0.0
		if type_data.hframes > 1:
			var anim_duration = GameConfig.ENEMY_ANIM_FRAME_DURATION
			var total_time = inst.anim_time + inst.anim_offset
			frame_index = fmod(total_time / anim_duration, float(type_data.hframes))
		
		var color = Color(frame_index / float(type_data.hframes), 1.0, 1.0, 1.0)
		type_data.multimesh_instance.multimesh.set_instance_color(i, color)

func despawn_skill(skill_type: String, instance_id: int):
	if not skill_types.has(skill_type):
		return
	
	var type_data = skill_types[skill_type]
	if instance_id < 0 or instance_id >= type_data.instances.size():
		return
	
	_destroy_skill(type_data, type_data.instances[instance_id], instance_id)

func clear_all_skills():
	for type_data in skill_types.values():
		for inst in type_data.instances:
			if inst.active and inst.hit_box and is_instance_valid(inst.hit_box):
				inst.hit_box.queue_free()
		type_data.instances.clear()
		_update_multimesh(type_data)

func get_active_skill_count(skill_type: String = "") -> int:
	if skill_type != "":
		if skill_types.has(skill_type):
			return skill_types[skill_type].instances.filter(func(inst): return inst.active).size()
		return 0
	
	var total := 0
	for type_data in skill_types.values():
		total += type_data.instances.filter(func(inst): return inst.active).size()
	return total

# ========================================
# 技能状态管理 API（整合自 skill_manager）
# ========================================

func get_skill_level(skill_id: String) -> int:
	return skill_levels.get(skill_id, 0)

func set_skill_level(skill_id: String, level: int):
	skill_levels[skill_id] = level

func get_skill_ammo(skill_id: String) -> int:
	return skill_ammo.get(skill_id, 0)

func set_skill_ammo(skill_id: String, ammo: int):
	skill_ammo[skill_id] = ammo

func get_skill_base_ammo(skill_id: String) -> int:
	return skill_base_ammo.get(skill_id, 0)

func set_skill_base_ammo(skill_id: String, base_ammo: int):
	skill_base_ammo[skill_id] = base_ammo

func get_skill_attack_speed(skill_id: String) -> float:
	return skill_attack_speeds.get(skill_id, 1.5)

func set_skill_attack_speed(skill_id: String, speed: float):
	skill_attack_speeds[skill_id] = speed

func initialize_skill_data(skill_id: String, level: int = 0, base_ammo: int = 0, attack_speed: float = 1.5):
	skill_levels[skill_id] = level
	skill_ammo[skill_id] = 0
	skill_base_ammo[skill_id] = base_ammo
	skill_attack_speeds[skill_id] = attack_speed

func add_skill_ammo(skill_id: String, amount: int):
	if not skill_base_ammo.has(skill_id):
		skill_base_ammo[skill_id] = 0
	skill_base_ammo[skill_id] += amount

func is_skill_unlocked(skill_id: String) -> bool:
	return get_skill_level(skill_id) > 0

func get_unlocked_skills() -> Array:
	var unlocked = []
	for skill_id in skill_levels.keys():
		if skill_levels[skill_id] > 0:
			unlocked.append(skill_id)
	return unlocked

func modify_skill_property(skill_id: String, property_name: String, value):
	match property_name:
		"level":
			set_skill_level(skill_id, value)
			if has_node("/root/EventBus"):
				get_node("/root/EventBus").emit_skill_upgraded(skill_id, value)
		"baseammo":
			add_skill_ammo(skill_id, value)
		"attackspeed":
			set_skill_attack_speed(skill_id, value)
