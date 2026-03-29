class_name ThunderFieldSkill
extends BaseActiveSkill

## 雷阵技能
## 在地面布置雷阵，触碰的敌人受到电击
## 
## 设计：完全配置驱动，无硬编码数值

var radius: float = 0.0
var trigger_interval: float = 0.5
var field_node: Node2D = null
var tick_timer: float = 0.0
var hit_enemies: Array = []

func _load_skill_config(cfg: Dictionary):
	radius = cfg.get("radius", 120.0)
	duration = cfg.get("duration", 6.0)
	trigger_interval = cfg.get("trigger_interval", 0.5)

func _on_skill_cast(cast_position: Vector2, _cast_direction: Vector2):
	trigger_screen_shake(GameConstants.Values.SHAKE_ATTACK * 0.3)
	_create_thunder_field(cast_position)

func _create_thunder_field(pos: Vector2):
	field_node = Node2D.new()
	field_node.name = "ThunderField"
	field_node.global_position = pos
	field_node.z_index = 1
	
	# 创建视觉效果
	var sprite = Sprite2D.new()
	sprite.texture = VisualEffectsHelper.create_glow_background(
		Vector2(radius * 2, radius * 2),
		GameConstants.Colors.SECT_THUNDER
	)
	sprite.modulate = GameConstants.Colors.SECT_THUNDER
	sprite.modulate.a = 0.3
	sprite.scale = Vector2(0.1, 0.1)
	
	field_node.add_child(sprite)
	
	# 添加触发区域
	var trigger_area = Area2D.new()
	trigger_area.name = "TriggerArea"
	trigger_area.collision_layer = 0
	trigger_area.collision_mask = 2  # 检测敌人
	
	var shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = radius
	shape.shape = circle
	trigger_area.add_child(shape)
	
	field_node.add_child(trigger_area)
	
	if player and player.get_parent():
		player.get_parent().call_deferred("add_child", field_node)
		if field_node.is_inside_tree():
			await field_node.tree_entered
		_animate_field(sprite)
	else:
		field_node.queue_free()

func _animate_field(sprite: Sprite2D):
	# 展开动画
	var tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.2)
	tween.tween_property(sprite, "modulate:a", 0.5, 0.2)
	
	is_active = true
	elapsed_time = 0.0
	tick_timer = 0.0
	hit_enemies.clear()

func _process(delta: float):
	if not is_active or not is_instance_valid(field_node):
		return
	
	elapsed_time += delta
	tick_timer += delta
	
	# 定期触发电击
	if tick_timer >= trigger_interval:
		tick_timer = 0.0
		_trigger_lightning()
	
	# 持续时间结束
	if elapsed_time >= duration:
		_end_field()

func _trigger_lightning():
	if not field_node:
		return
	
	var enemies = get_enemies_in_range(field_node.global_position, radius)
	for enemy in enemies:
		damage_enemy(enemy, damage)
		_create_lightning_effect(enemy.global_position)

func _create_lightning_effect(pos: Vector2):
	var effect = Sprite2D.new()
	effect.global_position = pos
	effect.scale = Vector2(1.5, 2.0)
	effect.texture = VisualEffectsHelper.create_placeholder_texture(Vector2(16, 32))
	effect.z_index = 10
	effect.modulate = GameConstants.Colors.SECT_THUNDER
	effect.modulate.a = 0.9
	
	var fade_script = load("res://Utility/auto_fade_sprite.gd")
	effect.set_script(fade_script)
	effect.set("fade_duration", 0.3)
	
	if player and player.get_parent():
		player.get_parent().call_deferred("add_child", effect)

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
