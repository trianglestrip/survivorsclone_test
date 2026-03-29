class_name IceShardSkill
extends BaseActiveSkill

## 冰霜碎片技能
## 发射3枚冰霜碎片，造成伤害并减速敌人
## 
## 设计：完全配置驱动，无硬编码数值

var projectile_count: int = 0
var range: float = 0.0
var slow_duration: float = 0.0
var slow_percent: float = 0.0
var projectile_speed: float = 400.0
var angle_spread: float = 20.0

func _load_skill_config(cfg: Dictionary):
	projectile_count = cfg.get("projectile_count", 3)
	range = cfg.get("range", 250.0)
	slow_duration = cfg.get("slow_duration", 2.0)
	slow_percent = cfg.get("slow_percent", 0.3)
	projectile_speed = cfg.get("projectile_speed", 400.0)
	angle_spread = cfg.get("angle_spread", 20.0)

func _on_skill_cast(cast_position: Vector2, _cast_direction: Vector2):
	var direction = get_mouse_direction()
	trigger_screen_shake(GameConstants.Values.SHAKE_ATTACK)
	
	for i in range(projectile_count):
		var offset_angle = (i - projectile_count / 2.0) * angle_spread
		var projectile_dir = direction.rotated(deg_to_rad(offset_angle))
		_spawn_projectile(cast_position, projectile_dir)

func _spawn_projectile(pos: Vector2, dir: Vector2):
	var projectile = Node2D.new()
	projectile.name = "IceShard"
	projectile.position = pos
	projectile.z_index = 5
	
	var sprite = Sprite2D.new()
	sprite.rotation = dir.angle()
	sprite.scale = Vector2(1.5, 1.5)
	sprite.modulate = GameConstants.Colors.SECT_ICE
	sprite.texture = VisualEffectsHelper.create_placeholder_texture(Vector2(16, 8))
	
	projectile.add_child(sprite)
	
	if player and player.get_parent():
		player.get_parent().call_deferred("add_child", projectile)
		call_deferred("_animate_projectile", projectile, dir)
	else:
		projectile.queue_free()

func _animate_projectile(projectile: Node2D, direction: Vector2):
	if not is_instance_valid(projectile):
		return
	
	if not projectile.is_inside_tree():
		await projectile.tree_entered
	
	if not is_instance_valid(projectile) or not projectile.is_inside_tree():
		return
	
	var distance_traveled = 0.0
	var lifetime = range / projectile_speed
	
	for t in range(int(lifetime * 60)):
		await projectile.get_tree().create_timer(1.0 / 60.0).timeout
		
		if not is_instance_valid(projectile):
			return
		
		var move_delta = direction * projectile_speed / 60.0
		projectile.position += move_delta
		distance_traveled += move_delta.length()
		
		_check_projectile_hit(projectile)
		
		if distance_traveled >= range:
			break
	
	if is_instance_valid(projectile):
		projectile.queue_free()

func _check_projectile_hit(projectile: Node2D):
	var enemies = get_enemies_in_range(projectile.position, 20.0)
	
	if enemies.size() > 0:
		for enemy in enemies:
			damage_enemy(enemy, damage)
			_apply_slow(enemy)
		
		_create_hit_effect(projectile.position)
		projectile.queue_free()

func _apply_slow(enemy: Node):
	if enemy and enemy.has_method("apply_slow"):
		enemy.apply_slow(slow_percent, slow_duration)

func _create_hit_effect(pos: Vector2):
	var effect = spawn_effect(config.get("effect", ""), pos, 2.0)
	effect.modulate = GameConstants.Colors.SECT_ICE
	effect.modulate.a = 0.8
	VisualEffectsHelper.fade_out(effect, GameConstants.Values.EFFECT_FADE_TIME)
