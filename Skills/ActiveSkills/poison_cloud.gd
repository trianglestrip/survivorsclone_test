class_name PoisonCloudSkill
extends BaseActiveSkill

## 毒云技能
## 释放毒云，范围内敌人持续中毒并降低防御
## 
## 设计：完全配置驱动，无硬编码数值

var radius: float = 0.0
var defense_reduce: float = 0.0
var tick_interval: float = 0.5
var cloud_node: Node2D = null
var tick_timer: float = 0.0

func _load_skill_config(cfg: Dictionary):
	radius = cfg.get("radius", 140.0)
	duration = cfg.get("duration", 6.0)
	defense_reduce = cfg.get("defense_reduce", 0.3)
	tick_interval = cfg.get("tick_interval", 0.5)

func _on_skill_cast(cast_position: Vector2, _cast_direction: Vector2):
	trigger_screen_shake(GameConstants.Values.SHAKE_ATTACK * 0.3)
	_create_poison_cloud(cast_position)

func _create_poison_cloud(pos: Vector2):
	cloud_node = Node2D.new()
	cloud_node.name = "PoisonCloud"
	cloud_node.global_position = pos
	cloud_node.z_index = 1
	
	# 创建视觉效果
	var sprite = Sprite2D.new()
	sprite.texture = VisualEffectsHelper.create_glow_background(
		Vector2(radius * 2, radius * 2),
		GameConstants.Colors.SECT_POISON
	)
	sprite.modulate = GameConstants.Colors.SECT_POISON
	sprite.modulate.a = 0.5
	sprite.scale = Vector2(0.1, 0.1)
	
	cloud_node.add_child(sprite)
	
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
	
	cloud_node.add_child(damage_area)
	
	if player and player.get_parent():
		player.get_parent().add_child(cloud_node)
		await get_tree().process_frame
		_animate_cloud(sprite)
	else:
		cloud_node.queue_free()

func _animate_cloud(sprite: Sprite2D):
	# 展开动画
	var tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2(1.2, 1.2), 0.4)
	tween.tween_property(sprite, "modulate:a", 0.6, 0.4)
	
	# 毒云飘动效果
	var float_tween = create_tween()
	float_tween.set_loops()
	float_tween.tween_property(sprite, "scale", Vector2(1.3, 1.1), 1.0)
	float_tween.tween_property(sprite, "scale", Vector2(1.1, 1.3), 1.0)
	
	is_active = true
	elapsed_time = 0.0
	tick_timer = 0.0

func _process(delta: float):
	if not is_active or not is_instance_valid(cloud_node):
		return
	
	elapsed_time += delta
	tick_timer += delta
	
	# 定期造成伤害
	if tick_timer >= tick_interval:
		tick_timer = 0.0
		_deal_poison_damage()
	
	# 持续时间结束
	if elapsed_time >= duration:
		_end_cloud()

func _deal_poison_damage():
	if not cloud_node:
		return
	
	var enemies = get_enemies_in_range(cloud_node.global_position, radius)
	for enemy in enemies:
		damage_enemy(enemy, damage)
		_apply_poison(enemy)

func _apply_poison(enemy: Node):
	if enemy and enemy.has_method("apply_poison"):
		enemy.apply_poison(damage * 0.5, duration)
	if enemy and enemy.has_method("reduce_defense"):
		enemy.reduce_defense(defense_reduce, duration)

func _end_cloud():
	is_active = false
	
	if not is_instance_valid(cloud_node):
		return
	
	# 淡出动画
	var sprite = cloud_node.get_node_or_null("Sprite2D")
	if sprite:
		var fade_script = load("res://Utility/auto_fade_sprite.gd")
		sprite.set_script(fade_script)
		sprite.set("fade_duration", 0.8)
	else:
		cloud_node.queue_free()
