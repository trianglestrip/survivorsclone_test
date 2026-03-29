class_name FireBallSkill
extends BaseActiveSkill

## 火球术技能
## 发射火球，命中后爆炸造成范围伤害和灼烧
## 
## 设计：完全配置驱动，使用工具类

var radius: float = 0.0
var burn_damage: float = 0.0
var burn_duration: float = 0.0
var projectile_speed: float = 350.0
var range: float = 400.0

func _load_skill_config(cfg: Dictionary):
	radius = cfg.get("radius", 80.0)
	burn_damage = cfg.get("burn_damage", 5.0)
	burn_duration = cfg.get("burn_duration", 3.0)
	projectile_speed = cfg.get("projectile_speed", 350.0)
	range = cfg.get("range", 400.0)

func _on_skill_cast(cast_position: Vector2, _cast_direction: Vector2):
	var direction = get_mouse_direction()
	trigger_screen_shake(GameConstants.Values.SHAKE_ATTACK)
	_spawn_fireball(cast_position, direction)

func _spawn_fireball(pos: Vector2, dir: Vector2):
	var fireball = Node2D.new()
	fireball.name = "FireBall"
	fireball.position = pos
	fireball.z_index = 5
	
	var sprite = Sprite2D.new()
	sprite.rotation = dir.angle()
	sprite.scale = Vector2(2.0, 2.0)
	sprite.modulate = GameConstants.Colors.SECT_FIRE
	sprite.texture = VisualEffectsHelper.create_placeholder_texture(Vector2(24, 24))
	
	fireball.add_child(sprite)
	
	if player and player.get_parent():
		player.get_parent().call_deferred("add_child", fireball)
	
	_animate_fireball(fireball, dir)

func _animate_fireball(fireball: Node2D, direction: Vector2):
	var distance_traveled = 0.0
	var lifetime = range / projectile_speed
	
	for t in range(int(lifetime * 60)):
		await get_tree().create_timer(1.0 / 60.0).timeout
		
		if not is_instance_valid(fireball):
			return
		
		var move_delta = direction * projectile_speed / 60.0
		fireball.position += move_delta
		distance_traveled += move_delta.length()
		
		var hit = _check_fireball_hit(fireball.position)
		if hit:
			_explode(fireball.position)
			fireball.queue_free()
			return
		
		if distance_traveled >= range:
			break
	
	if is_instance_valid(fireball):
		_explode(fireball.position)
		fireball.queue_free()

func _check_fireball_hit(pos: Vector2) -> bool:
	var enemies = get_enemies_in_range(pos, 20.0)
	return enemies.size() > 0

func _explode(pos: Vector2):
	_create_explosion_effect(pos)
	
	var enemies = get_enemies_in_range(pos, radius)
	for enemy in enemies:
		damage_enemy(enemy, damage)
		_apply_burn(enemy)

func _apply_burn(enemy: Node):
	if enemy and enemy.has_method("apply_burn"):
		enemy.apply_burn(burn_damage, burn_duration)

func _create_explosion_effect(pos: Vector2):
	var effect = spawn_effect(config.get("effect", ""), pos, radius / 32.0)
	effect.modulate = GameConstants.Colors.SECT_FIRE
	effect.modulate.a = 0.8
	_animate_explosion(effect)

func _animate_explosion(effect: Sprite2D):
	var scale_factor = 1.15
	var steps = 8
	
	for i in range(steps):
		await get_tree().create_timer(0.05).timeout
		if is_instance_valid(effect):
			effect.scale *= scale_factor
			effect.modulate.a -= 1.0 / steps
	
	if is_instance_valid(effect):
		effect.queue_free()
