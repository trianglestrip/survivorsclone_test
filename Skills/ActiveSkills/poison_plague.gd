class_name PoisonPlagueSkill
extends BaseActiveSkill

## 瘟疫爆发技能
## 引发瘟疫，造成大范围剧毒，并在敌人间传播
## 
## 设计：完全配置驱动，无硬编码数值

var radius: float = 0.0
var poison_damage: float = 0.0
var poison_duration: float = 0.0
var spread_radius: float = 0.0
var plague_node: Node2D = null
var infected_enemies: Array = []

func _load_skill_config(cfg: Dictionary):
	radius = cfg.get("radius", 260.0)
	duration = cfg.get("duration", 8.0)
	poison_damage = cfg.get("poison_damage", 15.0)
	poison_duration = cfg.get("poison_duration", 6.0)
	spread_radius = cfg.get("spread_radius", 100.0)
	tick_interval = cfg.get("tick_interval", 0.5)  # 使用基类的tick_interval

func _on_skill_cast(cast_position: Vector2, _cast_direction: Vector2):
	trigger_screen_shake(GameConstants.Values.SHAKE_ATTACK * 1.5)
	
	# 使用基类方法创建技能节点
	var node_config = SkillNodeConfig.new()
	node_config.node_name = "PoisonPlague"
	node_config.visual_category = "ultimate"
	node_config.node_type = SkillNodeType.AREA_CIRCLE
	node_config.position = cast_position
	node_config.z_index = 3
	node_config.skill_animation_name = "poison_plague"
	node_config.animation_scale = VisualEffectsHelper.r_skill_scale_vector(radius)
	node_config.animation_modulate = Color(1.0, 1.0, 1.0, 0.5)
	node_config.animation_fps = 10.0
	node_config.animation_loop = true
	node_config.collision_radius = radius
	node_config.lifetime = duration
	node_config.fade_duration = 0.8
	node_config.fallback_color = GameConstants.Colors.SECT_POISON
	
	plague_node = await create_skill_node(node_config)
	
	# 启用周期性伤害
	enable_tick_damage(tick_interval, _deal_damage)
	
	is_active = true
	elapsed_time = 0.0
	infected_enemies.clear()

func _process(delta: float):
	if not is_active or not is_instance_valid(plague_node):
		return
	
	elapsed_time += delta
	
	# 持续时间结束
	if elapsed_time >= duration:
		is_active = false

func _deal_damage():
	if not is_instance_valid(plague_node):
		return
	
	var enemies = get_enemies_in_range(plague_node.global_position, radius)
	for enemy in enemies:
		damage_enemy(enemy, damage)
		_apply_poison(enemy)
		
		if not infected_enemies.has(enemy):
			infected_enemies.append(enemy)
	
	# 传播瘟疫
	_spread_plague()

func _spread_plague():
	# 从已感染敌人传播到附近敌人
	var new_infected = []
	
	for infected in infected_enemies:
		if not is_instance_valid(infected):
			continue
		
		var nearby = get_enemies_in_range(infected.global_position, spread_radius)
		for enemy in nearby:
			if not infected_enemies.has(enemy):
				damage_enemy(enemy, poison_damage * 0.5)
				_apply_poison(enemy)
				new_infected.append(enemy)
				_create_spread_effect(infected.global_position, enemy.global_position)
	
	infected_enemies.append_array(new_infected)

func _apply_poison(enemy: Node):
	if enemy and enemy.has_method("apply_poison"):
		enemy.apply_poison(poison_damage, poison_duration)

func _create_spread_effect(from: Vector2, to: Vector2):
	var line = Line2D.new()
	line.add_point(Vector2.ZERO)
	line.add_point(to - from)
	line.width = clampf(2.5 * VisualEffectsHelper.r_skill_scale_from_radius(radius) / (260.0 / 150.0), 2.5, 5.0)
	line.default_color = GameConstants.Colors.SECT_POISON
	line.default_color.a = 0.6
	line.global_position = from
	line.z_index = 9
	
	if player and player.get_parent():
		player.get_parent().add_child(line)
		await get_tree().process_frame
		_animate_spread_line(line)

func _animate_spread_line(line: Line2D):
	await get_tree().create_timer(0.2).timeout
	if is_instance_valid(line):
		line.queue_free()
