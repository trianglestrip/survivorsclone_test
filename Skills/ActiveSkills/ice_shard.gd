class_name IceShardSkill
extends BaseActiveSkill

## 冰霜碎片技能
## 发射3枚冰霜碎片，造成伤害并减速敌人

var projectile_count: int = 0
var skill_range: float = 0.0
var slow_duration: float = 0.0
var slow_percent: float = 0.0
var projectile_speed: float = 400.0
var angle_spread: float = 20.0

func _load_skill_config(cfg: Dictionary):
	projectile_count = cfg.get("projectile_count", 3)
	skill_range = cfg.get("range", 250.0)
	slow_duration = cfg.get("slow_duration", 2.0)
	slow_percent = cfg.get("slow_percent", 0.3)
	projectile_speed = cfg.get("projectile_speed", 400.0)
	angle_spread = cfg.get("angle_spread", 20.0)
	
	# 配置状态效果
	add_status_effect(StatusEffect.SLOW, slow_percent, slow_duration)

func _on_skill_cast(cast_position: Vector2, _cast_direction: Vector2):
	var direction = get_mouse_direction()
	trigger_screen_shake(GameConstants.Values.SHAKE_ATTACK)
	
	# 发射多个弹射物
	for i in range(projectile_count):
		var offset_angle = (i - projectile_count / 2.0) * angle_spread
		var projectile_dir = direction.rotated(deg_to_rad(offset_angle))
		await _spawn_projectile(cast_position, projectile_dir)

func _spawn_projectile(pos: Vector2, dir: Vector2):
	# 使用基类方法创建弹射物节点
	var node_config = SkillNodeConfig.new()
	node_config.node_name = "IceShard"
	node_config.node_type = SkillNodeType.PROJECTILE
	node_config.position = pos
	node_config.rotation = dir.angle()
	node_config.z_index = 5
	node_config.skill_animation_name = "ice_shard"
	node_config.animation_scale = VisualEffectsHelper.q_skill_scale_vector()
	node_config.animation_modulate = Color(1.0, 1.0, 1.0, 0.9)
	node_config.animation_fps = 15.0
	node_config.animation_loop = true
	node_config.collision_radius = 20.0
	node_config.projectile_direction = dir
	node_config.projectile_speed = projectile_speed
	node_config.projectile_range = skill_range
	node_config.fallback_color = GameConstants.Colors.SECT_ICE
	
	await create_skill_node(node_config)

func _check_projectile_hit(projectile: Node2D):
	var enemies = get_enemies_in_range(projectile.position, 20.0)
	
	if enemies.size() > 0:
		for enemy in enemies:
			damage_enemy(enemy, damage)
			apply_status_effects(enemy)
		
		_create_hit_effect(projectile.position)
		projectile.queue_free()

func _create_hit_effect(pos: Vector2):
	var effect_container = Node2D.new()
	effect_container.global_position = pos
	effect_container.z_index = 10
	
	var center_glow = Sprite2D.new()
	center_glow.texture = VisualEffectsHelper.create_glow_background(
		Vector2(80, 80),
		GameConstants.Colors.SECT_ICE
	)
	center_glow.modulate = GameConstants.Colors.SECT_ICE
	center_glow.modulate.a = 0.9
	center_glow.scale = Vector2(0.5, 0.5)
	effect_container.add_child(center_glow)
	
	for i in range(4):
		var shard = Sprite2D.new()
		var ice_color = GameConstants.Colors.SECT_ICE
		shard.texture = VisualEffectsHelper.create_gradient_texture(
			Vector2(12, 12),
			Color(ice_color.r, ice_color.g, ice_color.b, 0.8),
			Color(ice_color.r * 0.9, ice_color.g * 0.95, ice_color.b, 0.0)
		)
		var angle = i * PI / 2
		shard.position = Vector2(cos(angle), sin(angle)) * 20
		shard.rotation = angle
		effect_container.add_child(shard)
	
	if player and player.get_parent():
		player.get_parent().add_child(effect_container)
		_animate_hit_effect(effect_container, center_glow)

func _animate_hit_effect(container: Node2D, glow: Sprite2D):
	if not is_instance_valid(container):
		return
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(glow, "scale", Vector2(2.0, 2.0), 0.3)
	tween.tween_property(glow, "modulate:a", 0.0, 0.3)
	
	for i in range(4):
		var shard = container.get_child(i + 1) if i + 1 < container.get_child_count() else null
		if shard:
			var angle = i * PI / 2
			var target_pos = Vector2(cos(angle), sin(angle)) * 40
			var shard_tween = create_tween()
			shard_tween.set_parallel(true)
			shard_tween.tween_property(shard, "position", target_pos, 0.3)
			shard_tween.tween_property(shard, "modulate:a", 0.0, 0.3)
	
	await tween.finished
	if is_instance_valid(container):
		container.queue_free()
