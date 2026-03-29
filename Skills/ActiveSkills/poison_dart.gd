class_name PoisonDartSkill
extends BaseActiveSkill

## 毒镖技能
## 发射毒镖，造成伤害并施加剧毒效果
## 
## 设计：完全配置驱动，使用工具类

var range: float = 0.0
var poison_damage: float = 0.0
var poison_duration: float = 0.0
var projectile_speed: float = 450.0

func _load_skill_config(cfg: Dictionary):
	range = cfg.get("range", 220.0)
	poison_damage = cfg.get("poison_damage", 8.0)
	poison_duration = cfg.get("poison_duration", 4.0)
	projectile_speed = cfg.get("projectile_speed", 450.0)

func _on_skill_cast(cast_position: Vector2, _cast_direction: Vector2):
	var direction = get_mouse_direction()
	_spawn_dart(cast_position, direction)

func _spawn_dart(pos: Vector2, dir: Vector2):
	var dart = Node2D.new()
	dart.name = "PoisonDart"
	dart.position = pos
	dart.z_index = 5
	
	var sprite = Sprite2D.new()
	sprite.rotation = dir.angle()
	sprite.scale = Vector2(1.2, 1.2)
	sprite.modulate = GameConstants.Colors.SECT_POISON
	sprite.texture = VisualEffectsHelper.create_placeholder_texture(Vector2(12, 6))
	
	dart.add_child(sprite)
	
	if player and player.get_parent():
		player.get_parent().call_deferred("add_child", dart)
		call_deferred("_animate_dart", dart, dir)
	else:
		dart.queue_free()

func _animate_dart(dart: Node2D, direction: Vector2):
	if not is_instance_valid(dart):
		return
	
	if not dart.is_inside_tree():
		await dart.tree_entered
	
	if not is_instance_valid(dart) or not dart.is_inside_tree():
		return
	
	var distance_traveled = 0.0
	var lifetime = range / projectile_speed
	
	for t in range(int(lifetime * 60)):
		await dart.get_tree().create_timer(1.0 / 60.0).timeout
		
		if not is_instance_valid(dart):
			return
		
		var move_delta = direction * projectile_speed / 60.0
		dart.position += move_delta
		distance_traveled += move_delta.length()
		
		var enemies = get_enemies_in_range(dart.position, 15.0)
		if enemies.size() > 0:
			for enemy in enemies:
				damage_enemy(enemy, damage)
				_apply_poison(enemy)
			
			_create_hit_effect(dart.position)
			dart.queue_free()
			return
		
		if distance_traveled >= range:
			break
	
	if is_instance_valid(dart):
		dart.queue_free()

func _apply_poison(enemy: Node):
	if enemy and enemy.has_method("apply_poison"):
		enemy.apply_poison(poison_damage, poison_duration)

func _create_hit_effect(pos: Vector2):
	var effect = spawn_effect(config.get("effect", ""), pos, 1.5)
	effect.modulate = GameConstants.Colors.SECT_POISON
	effect.modulate.a = 0.8
	VisualEffectsHelper.fade_out(effect, GameConstants.Values.EFFECT_FADE_TIME)
