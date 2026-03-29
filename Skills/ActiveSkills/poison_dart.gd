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
	
	var projectile_script = load("res://Utility/auto_projectile.gd")
	dart.set_script(projectile_script)
	dart.set("direction", dir)
	dart.set("speed", projectile_speed)
	dart.set("max_range", range)
	dart.set("skill_instance", self)
	
	if player and player.get_parent():
		player.get_parent().call_deferred("add_child", dart)
	else:
		dart.queue_free()

func _check_projectile_hit(projectile: Node2D):
	var enemies = get_enemies_in_range(projectile.position, 15.0)
	
	if enemies.size() > 0:
		for enemy in enemies:
			damage_enemy(enemy, damage)
			_apply_poison(enemy)
		
		_create_hit_effect(projectile.position)
		projectile.queue_free()

func _apply_poison(enemy: Node):
	if enemy and enemy.has_method("apply_poison"):
		enemy.apply_poison(poison_damage, poison_duration)

func _create_hit_effect(pos: Vector2):
	var effect = Sprite2D.new()
	effect.position = pos
	effect.scale = Vector2(1.5, 1.5)
	effect.texture = VisualEffectsHelper.load_texture_or_placeholder(config.get("effect", ""), Vector2(64, 64))
	effect.z_index = 10
	effect.modulate = GameConstants.Colors.SECT_POISON
	effect.modulate.a = 0.8
	
	var fade_script = load("res://Utility/auto_fade_sprite.gd")
	effect.set_script(fade_script)
	effect.set("fade_duration", GameConstants.Values.EFFECT_FADE_TIME)
	
	if player and player.get_parent():
		player.get_parent().call_deferred("add_child", effect)
