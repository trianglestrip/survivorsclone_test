class_name FireMeteorSkill
extends BaseActiveSkill

## 陨火天降技能
## 召唤陨石雨，大范围轰炸并留下火海
## 
## 设计：完全配置驱动，无硬编码数值

var radius: float = 0.0
var meteor_count: int = 0
var burn_duration: float = 0.0
var meteor_interval: float = 0.15
var meteor_timer: float = 0.0
var meteors_spawned: int = 0
var cast_center: Vector2 = Vector2.ZERO

func _load_skill_config(cfg: Dictionary):
	radius = cfg.get("radius", 280.0)
	duration = cfg.get("duration", 3.0)
	meteor_count = cfg.get("meteor_count", 8)
	burn_duration = cfg.get("burn_duration", 4.0)
	meteor_interval = cfg.get("meteor_interval", 0.15)

func _on_skill_cast(cast_position: Vector2, _cast_direction: Vector2):
	trigger_screen_shake(GameConstants.Values.SHAKE_ATTACK * 1.8)
	cast_center = cast_position
	is_active = true
	elapsed_time = 0.0
	meteor_timer = 0.0
	meteors_spawned = 0

func _process(delta: float):
	if not is_active:
		return
	
	elapsed_time += delta
	meteor_timer += delta
	
	# 定期召唤陨石
	if meteor_timer >= meteor_interval and meteors_spawned < meteor_count:
		meteor_timer = 0.0
		_spawn_meteor()
		meteors_spawned += 1
	
	# 持续时间结束
	if elapsed_time >= duration:
		is_active = false

func _spawn_meteor():
	# 随机位置
	var angle = randf() * TAU
	var distance = randf() * radius
	var meteor_pos = cast_center + Vector2(cos(angle), sin(angle)) * distance
	
	_create_meteor(meteor_pos)

func _create_meteor(pos: Vector2):
	var meteor = Node2D.new()
	meteor.name = "Meteor"
	meteor.global_position = pos + Vector2(0, -200)  # 从上方落下
	meteor.z_index = 10
	
	var sprite = Sprite2D.new()
	sprite.texture = VisualEffectsHelper.create_placeholder_texture(Vector2(24, 24))
	sprite.modulate = GameConstants.Colors.SECT_FIRE
	sprite.scale = Vector2(2.0, 2.0)
	
	meteor.add_child(sprite)
	
	if player and player.get_parent():
		player.get_parent().call_deferred("add_child", meteor)
		if meteor.is_inside_tree():
			await meteor.tree_entered
		_animate_meteor_fall(meteor, pos)
	else:
		meteor.queue_free()

func _animate_meteor_fall(meteor: Node2D, target_pos: Vector2):
	# 下落动画
	var tween = create_tween()
	tween.tween_property(meteor, "global_position", target_pos, 0.4)
	
	await tween.finished
	
	if is_instance_valid(meteor):
		_meteor_impact(target_pos)
		meteor.queue_free()

func _meteor_impact(pos: Vector2):
	# 造成范围伤害
	var impact_radius = 60.0
	var enemies = get_enemies_in_range(pos, impact_radius)
	for enemy in enemies:
		damage_enemy(enemy, damage)
		_apply_burn(enemy)
	
	# 爆炸特效
	_create_explosion_effect(pos)

func _apply_burn(enemy: Node):
	if enemy and enemy.has_method("apply_burn"):
		enemy.apply_burn(damage * 0.3, burn_duration)

func _create_explosion_effect(pos: Vector2):
	var effect = Sprite2D.new()
	effect.global_position = pos
	effect.scale = Vector2(3.0, 3.0)
	effect.texture = VisualEffectsHelper.create_glow_background(Vector2(60, 60), GameConstants.Colors.SECT_FIRE)
	effect.z_index = 11
	effect.modulate = GameConstants.Colors.SECT_FIRE
	effect.modulate.a = 0.9
	
	var fade_script = load("res://Utility/auto_fade_sprite.gd")
	effect.set_script(fade_script)
	effect.set("fade_duration", 0.6)
	
	if player and player.get_parent():
		player.get_parent().call_deferred("add_child", effect)
