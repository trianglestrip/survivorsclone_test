class_name IceStormSkill
extends BaseActiveSkill

## 极寒风暴技能
## 召唤极寒风暴，大范围冻结并造成巨额伤害
## 
## 设计：完全配置驱动，无硬编码数值

var radius: float = 0.0
var freeze_duration: float = 0.0
var tick_interval: float = 0.3
var storm_node: Node2D = null
var tick_timer: float = 0.0

func _load_skill_config(cfg: Dictionary):
	radius = cfg.get("radius", 300.0)
	duration = cfg.get("duration", 5.0)
	freeze_duration = cfg.get("freeze_duration", 2.0)
	tick_interval = cfg.get("tick_interval", 0.3)

func _on_skill_cast(cast_position: Vector2, _cast_direction: Vector2):
	trigger_screen_shake(GameConstants.Values.SHAKE_ATTACK * 1.5)
	_create_ice_storm(cast_position)

func _create_ice_storm(pos: Vector2):
	storm_node = Node2D.new()
	storm_node.name = "IceStorm"
	storm_node.global_position = pos
	storm_node.z_index = 3
	
	# 创建视觉效果（5层，更强烈）
	for i in range(5):
		var sprite = Sprite2D.new()
		var layer_size = radius * 2.0 * (1.0 - i * 0.15)
		sprite.texture = VisualEffectsHelper.create_glow_background(
			Vector2(layer_size, layer_size),
			GameConstants.Colors.SECT_ICE
		)
		sprite.modulate = GameConstants.Colors.SECT_ICE
		sprite.modulate.a = 0.6 - i * 0.1
		sprite.scale = Vector2(1.0, 1.0)
		sprite.rotation = i * PI / 5
		sprite.name = "Layer" + str(i)
		storm_node.add_child(sprite)
	
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
	
	storm_node.add_child(damage_area)
	
	if player and player.get_parent():
		player.get_parent().add_child(storm_node)
		await get_tree().process_frame
		_animate_storm()
	else:
		storm_node.queue_free()

func _animate_storm():
	# 多层旋转动画（更快更明显）
	for i in range(5):
		var sprite = storm_node.get_node_or_null("Layer" + str(i))
		if sprite:
			# 脉冲缩放
			var scale_tween = create_tween()
			scale_tween.set_loops()
			var scale_min = 0.9 + i * 0.02
			var scale_max = 1.1 - i * 0.02
			scale_tween.tween_property(sprite, "scale", Vector2(scale_max, scale_max), 0.4)
			scale_tween.tween_property(sprite, "scale", Vector2(scale_min, scale_min), 0.4)
			
			# 快速旋转
			var rotate_tween = create_tween()
			rotate_tween.set_loops()
			var rotation_speed = 0.8 - i * 0.1
			var direction = 1 if i % 2 == 0 else -1
			rotate_tween.tween_property(sprite, "rotation", sprite.rotation + TAU * direction, rotation_speed)
	
	is_active = true
	elapsed_time = 0.0
	tick_timer = 0.0

func _process(delta: float):
	if not is_active or not is_instance_valid(storm_node):
		return
	
	elapsed_time += delta
	tick_timer += delta
	
	# 定期造成伤害
	if tick_timer >= tick_interval:
		tick_timer = 0.0
		_deal_storm_damage()
	
	# 持续时间结束
	if elapsed_time >= duration:
		_end_storm()

func _deal_storm_damage():
	if not storm_node:
		return
	
	var enemies = get_enemies_in_range(storm_node.global_position, radius)
	for enemy in enemies:
		damage_enemy(enemy, damage)
		_apply_freeze(enemy)
		_create_ice_shard_effect(enemy.global_position)

func _apply_freeze(enemy: Node):
	if enemy and enemy.has_method("apply_freeze"):
		enemy.apply_freeze(freeze_duration)
	elif enemy and enemy.has_method("apply_slow"):
		enemy.apply_slow(0.9, freeze_duration)  # 90%减速模拟冻结

func _create_ice_shard_effect(pos: Vector2):
	var effect = Sprite2D.new()
	effect.global_position = pos + Vector2(randf_range(-20, 20), randf_range(-20, 20))
	effect.scale = Vector2(1.0, 1.0)
	effect.texture = VisualEffectsHelper.create_placeholder_texture(Vector2(12, 12))
	effect.z_index = 10
	effect.modulate = GameConstants.Colors.SECT_ICE
	effect.rotation = randf() * TAU
	
	var fade_script = load("res://Utility/auto_fade_sprite.gd")
	effect.set_script(fade_script)
	effect.set("fade_duration", 0.4)
	
	if player and player.get_parent():
		player.get_parent().add_child(effect)

func _end_storm():
	is_active = false
	
	if not is_instance_valid(storm_node):
		return
	
	# 淡出动画
	for i in range(3):
		var sprite = storm_node.get_node_or_null("Layer" + str(i))
		if sprite:
			var tween = create_tween()
			tween.tween_property(sprite, "modulate:a", 0.0, 0.6)
	
	await get_tree().create_timer(0.6).timeout
	if is_instance_valid(storm_node):
		storm_node.queue_free()
