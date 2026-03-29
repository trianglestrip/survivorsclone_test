class_name IceFieldSkill
extends BaseActiveSkill

## 冰封领域技能
## 在周围创造冰霜领域，持续造成伤害并减速
## 
## 设计：完全配置驱动，无硬编码数值

var radius: float = 0.0
var tick_interval: float = 0.5
var slow_percent: float = 0.0
var slow_duration: float = 0.0
var field_node: Node2D = null
var tick_timer: float = 0.0

func _load_skill_config(cfg: Dictionary):
	radius = cfg.get("radius", 150.0)
	duration = cfg.get("duration", 4.0)
	slow_percent = cfg.get("slow_percent", 0.5)
	slow_duration = duration  # 减速持续时间等于领域持续时间
	tick_interval = cfg.get("tick_interval", 0.5)

func _on_skill_cast(cast_position: Vector2, _cast_direction: Vector2):
	trigger_screen_shake(GameConstants.Values.SHAKE_ATTACK * 0.5)
	_create_ice_field(cast_position)

func _create_ice_field(pos: Vector2):
	field_node = Node2D.new()
	field_node.name = "IceField"
	field_node.global_position = pos
	field_node.z_index = 1
	
	# 创建视觉效果
	var sprite = Sprite2D.new()
	sprite.texture = VisualEffectsHelper.create_glow_background(
		Vector2(radius * 2, radius * 2),
		GameConstants.Colors.SECT_ICE
	)
	sprite.modulate = GameConstants.Colors.SECT_ICE
	sprite.modulate.a = 0.4
	sprite.scale = Vector2(0.1, 0.1)
	
	field_node.add_child(sprite)
	
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
	
	field_node.add_child(damage_area)
	
	if player and player.get_parent():
		player.get_parent().add_child(field_node)
		await get_tree().process_frame
		_animate_field(sprite)
	else:
		field_node.queue_free()

func _animate_field(sprite: Sprite2D):
	# 展开动画
	var tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.3)
	tween.tween_property(sprite, "modulate:a", 0.6, 0.3)
	
	is_active = true
	elapsed_time = 0.0
	tick_timer = 0.0

func _process(delta: float):
	if not is_active or not is_instance_valid(field_node):
		return
	
	elapsed_time += delta
	tick_timer += delta
	
	# 定期造成伤害
	if tick_timer >= tick_interval:
		tick_timer = 0.0
		_deal_field_damage()
	
	# 持续时间结束
	if elapsed_time >= duration:
		_end_field()

func _deal_field_damage():
	if not field_node:
		return
	
	var damage_area = field_node.get_node_or_null("DamageArea")
	if not damage_area:
		return
	
	var enemies = get_enemies_in_range(field_node.global_position, radius)
	for enemy in enemies:
		damage_enemy(enemy, damage)
		_apply_slow(enemy)

func _apply_slow(enemy: Node):
	if enemy and enemy.has_method("apply_slow"):
		enemy.apply_slow(slow_percent, slow_duration)

func _end_field():
	is_active = false
	
	if not is_instance_valid(field_node):
		return
	
	# 淡出动画
	var sprite = field_node.get_node_or_null("Sprite2D")
	if sprite:
		var fade_script = load("res://Utility/auto_fade_sprite.gd")
		sprite.set_script(fade_script)
		sprite.set("fade_duration", 0.5)
	else:
		field_node.queue_free()
