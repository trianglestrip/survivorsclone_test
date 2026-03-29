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
var tick_interval: float = 0.5
var plague_node: Node2D = null
var tick_timer: float = 0.0
var infected_enemies: Array = []

func _load_skill_config(cfg: Dictionary):
	radius = cfg.get("radius", 260.0)
	duration = cfg.get("duration", 8.0)
	poison_damage = cfg.get("poison_damage", 15.0)
	poison_duration = cfg.get("poison_duration", 6.0)
	spread_radius = cfg.get("spread_radius", 100.0)
	tick_interval = cfg.get("tick_interval", 0.5)

func _on_skill_cast(cast_position: Vector2, _cast_direction: Vector2):
	trigger_screen_shake(GameConstants.Values.SHAKE_ATTACK * 1.5)
	_create_plague(cast_position)

func _create_plague(pos: Vector2):
	plague_node = Node2D.new()
	plague_node.name = "PoisonPlague"
	plague_node.global_position = pos
	plague_node.z_index = 3
	
	# 创建瘟疫视觉效果（多层毒雾）
	for i in range(4):
		var sprite = Sprite2D.new()
		sprite.texture = VisualEffectsHelper.create_glow_background(
			Vector2(radius * 2, radius * 2),
			GameConstants.Colors.SECT_POISON
		)
		sprite.modulate = GameConstants.Colors.SECT_POISON
		sprite.modulate.a = 0.25 - i * 0.04
		sprite.scale = Vector2(0.1, 0.1)
		sprite.rotation = i * PI / 4
		sprite.name = "Layer" + str(i)
		plague_node.add_child(sprite)
	
	# 添加伤害区域
	var damage_area = Area2D.new()
	damage_area.name = "DamageArea"
	damage_area.collision_layer = 0
	damage_area.collision_mask = 2  # 检测敌人
	
	var shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = radius
	shape.shape = circle
	damage_area.add_child(shape)
	
	plague_node.add_child(damage_area)
	
	if player and player.get_parent():
		player.get_parent().call_deferred("add_child", plague_node)
		if plague_node.is_inside_tree():
			await plague_node.tree_entered
		_animate_plague()
	else:
		plague_node.queue_free()

func _animate_plague():
	# 展开动画
	for i in range(4):
		var sprite = plague_node.get_node_or_null("Layer" + str(i))
		if sprite:
			var tween = create_tween()
			tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.6 + i * 0.1)
			
			# 缓慢旋转
			var rotate_tween = create_tween()
			rotate_tween.set_loops()
			rotate_tween.tween_property(sprite, "rotation", sprite.rotation + TAU, 3.0 + i * 0.5)
	
	is_active = true
	elapsed_time = 0.0
	tick_timer = 0.0
	infected_enemies.clear()

func _process(delta: float):
	if not is_active or not is_instance_valid(plague_node):
		return
	
	elapsed_time += delta
	tick_timer += delta
	
	# 定期造成伤害和传播
	if tick_timer >= tick_interval:
		tick_timer = 0.0
		_deal_plague_damage()
		_spread_plague()
	
	# 持续时间结束
	if elapsed_time >= duration:
		_end_plague()

func _deal_plague_damage():
	if not plague_node:
		return
	
	var enemies = get_enemies_in_range(plague_node.global_position, radius)
	for enemy in enemies:
		damage_enemy(enemy, damage)
		_apply_poison(enemy)
		
		if not infected_enemies.has(enemy):
			infected_enemies.append(enemy)

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
	line.width = 2.0
	line.default_color = GameConstants.Colors.SECT_POISON
	line.default_color.a = 0.6
	line.global_position = from
	line.z_index = 9
	
	if player and player.get_parent():
		player.get_parent().call_deferred("add_child", line)
		if line.is_inside_tree():
			await line.tree_entered
		_animate_spread_line(line)

func _animate_spread_line(line: Line2D):
	await get_tree().create_timer(0.2).timeout
	if is_instance_valid(line):
		line.queue_free()

func _end_plague():
	is_active = false
	
	if not is_instance_valid(plague_node):
		return
	
	# 淡出动画
	for i in range(4):
		var sprite = plague_node.get_node_or_null("Layer" + str(i))
		if sprite:
			var tween = create_tween()
			tween.tween_property(sprite, "modulate:a", 0.0, 0.8)
	
	await get_tree().create_timer(0.8).timeout
	if is_instance_valid(plague_node):
		plague_node.queue_free()
