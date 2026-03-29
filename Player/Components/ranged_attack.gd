class_name RangedAttack
extends BaseAttack

## 远程攻击组件
## 处理右键远程攻击（弓箭、法术等）
## 
## 设计：完全配置驱动，继承BaseAttack

const GameConstants = preload("res://Utility/game_constants.gd")
const VisualEffectsHelper = preload("res://Utility/visual_effects_helper.gd")

var projectile_speed: float = 400.0
var projectile_count: int = 1
var spread_angle: float = 0.0
var pierce_count: int = 0

func load_config(config: Dictionary):
	super.load_config(config)
	
	projectile_speed = config.get("projectile_speed", 400.0)
	projectile_count = config.get("projectile_count", 1)
	spread_angle = config.get("spread_angle", 0.0)
	pierce_count = config.get("pierce_count", 0)

func try_attack() -> bool:
	if not can_attack():
		return false
	
	start_attack()
	return true

func can_attack() -> bool:
	return current_cooldown <= 0.0

func start_attack():
	current_cooldown = cooldown
	var attack_pos = player.global_position if player else Vector2.ZERO
	var attack_dir = _get_attack_direction()
	
	spawn_attack_effect(attack_pos, attack_dir)
	emit_signal("attack_executed", attack_pos, attack_dir, damage, knockback)

func _get_attack_direction() -> Vector2:
	if player:
		var mouse_pos = player.get_global_mouse_position()
		return (mouse_pos - player.global_position).normalized()
	return Vector2.RIGHT

func spawn_attack_effect(position: Vector2, direction: Vector2):
	VisualEffectsHelper.trigger_screen_shake(self, GameConstants.Values.SHAKE_ATTACK)
	
	for i in range(projectile_count):
		var offset_angle = 0.0
		if projectile_count > 1:
			offset_angle = (i - projectile_count / 2.0) * spread_angle
		
		var projectile_dir = direction.rotated(deg_to_rad(offset_angle))
		_spawn_projectile(position, projectile_dir)

func _spawn_projectile(pos: Vector2, dir: Vector2):
	var projectile = Node2D.new()
	projectile.name = "RangedProjectile"
	projectile.position = pos
	projectile.z_index = 5
	
	var sprite = Sprite2D.new()
	sprite.rotation = dir.angle()
	sprite.scale = Vector2(1.0, 1.0)
	sprite.modulate = Color(0.9, 0.9, 1.0, 1.0)
	sprite.texture = VisualEffectsHelper.create_placeholder_texture(Vector2(16, 8))
	
	projectile.add_child(sprite)
	
	if player and player.get_parent():
		player.get_parent().call_deferred("add_child", projectile)
	
	_animate_projectile(projectile, dir)

func _animate_projectile(projectile: Node2D, direction: Vector2):
	var distance_traveled = 0.0
	var max_range = range
	var hit_count = 0
	
	while distance_traveled < max_range and is_instance_valid(projectile):
		await get_tree().create_timer(GameConstants.Values.FRAME_TIME).timeout
		
		if not is_instance_valid(projectile):
			return
		
		var move_delta = direction * projectile_speed * GameConstants.Values.FRAME_TIME
		projectile.position += move_delta
		distance_traveled += move_delta.length()
		
		var hit = _check_projectile_hit(projectile.position)
		if hit:
			hit_count += 1
			if hit_count > pierce_count:
				_create_hit_effect(projectile.position)
				projectile.queue_free()
				return
	
	if is_instance_valid(projectile):
		projectile.queue_free()

func _check_projectile_hit(pos: Vector2) -> bool:
	if not player:
		return false
	
	var world = player.get_parent()
	if not world:
		return false
	
	var enemies = world.get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if enemy and is_instance_valid(enemy):
			var distance = enemy.global_position.distance_to(pos)
			if distance <= 20.0:
				_hit_enemy(enemy)
				return true
	
	return false

func _hit_enemy(enemy: Node):
	if enemy.has_method("take_damage"):
		var dir = (enemy.global_position - player.global_position).normalized()
		enemy.take_damage(damage, dir * knockback)

func _create_hit_effect(pos: Vector2):
	var effect = Sprite2D.new()
	effect.position = pos
	effect.scale = Vector2(1.5, 1.5)
	effect.modulate = Color(0.9, 0.9, 1.0, 0.8)
	effect.z_index = 10
	effect.texture = VisualEffectsHelper.create_placeholder_texture(Vector2(24, 24))
	
	if player and player.get_parent():
		player.get_parent().call_deferred("add_child", effect)
	
	VisualEffectsHelper.fade_out(effect, GameConstants.Values.EFFECT_FADE_TIME)
