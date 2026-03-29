class_name IceStormSkill
extends BaseActiveSkill

## 极寒风暴技能
## 召唤极寒风暴，大范围冻结并造成巨额伤害

var radius: float = 0.0
var freeze_duration: float = 0.0
var storm_node: Node2D = null

func _load_skill_config(cfg: Dictionary):
	radius = cfg.get("radius", 300.0)
	duration = cfg.get("duration", 5.0)
	freeze_duration = cfg.get("freeze_duration", 2.0)
	
	# 配置状态效果
	add_status_effect(StatusEffect.FREEZE, 0.0, freeze_duration)

func _on_skill_cast(cast_position: Vector2, _cast_direction: Vector2):
	trigger_screen_shake(GameConstants.Values.SHAKE_ATTACK * 1.5)
	
	# 使用基类方法创建技能节点
	var node_config = SkillNodeConfig.new()
	node_config.node_name = "IceStorm"
	node_config.visual_category = "ultimate"
	node_config.node_type = SkillNodeType.AREA_CIRCLE
	node_config.position = cast_position
	node_config.z_index = 3
	node_config.skill_animation_name = "ice_storm"
	node_config.animation_scale = VisualEffectsHelper.r_skill_scale_vector(radius)
	node_config.animation_modulate = Color(1.0, 1.0, 1.0, 0.7)
	node_config.animation_fps = 12.0
	node_config.animation_loop = true
	node_config.collision_radius = radius
	node_config.lifetime = duration
	node_config.fade_duration = 0.6
	node_config.fallback_color = GameConstants.Colors.SECT_ICE
	
	storm_node = await create_skill_node(node_config)
	
	# 启用周期性伤害
	enable_tick_damage(0.3, _deal_damage)

func _deal_damage():
	if not is_instance_valid(storm_node):
		return
	
	var enemies = get_enemies_in_range(storm_node.global_position, radius)
	for enemy in enemies:
		damage_enemy(enemy, damage)
		apply_status_effects(enemy)
		_create_ice_shard_effect(enemy.global_position)

func _create_ice_shard_effect(pos: Vector2):
	var effect = Sprite2D.new()
	effect.global_position = pos + Vector2(randf_range(-20, 20), randf_range(-20, 20))
	var p := clampf(VisualEffectsHelper.r_skill_scale_from_radius(radius) * 0.45, 0.9, 1.75)
	effect.scale = Vector2(p, p)
	effect.z_index = 10
	effect.rotation = randf() * TAU
	
	var ice_color = GameConstants.Colors.SECT_ICE
	effect.texture = VisualEffectsHelper.create_gradient_texture(
		Vector2(12, 12),
		Color(ice_color.r, ice_color.g, ice_color.b, 0.8),
		Color(ice_color.r * 0.9, ice_color.g * 0.95, ice_color.b, 0.0)
	)
	
	var fade_script = load("res://Utility/auto_fade_sprite.gd")
	effect.set_script(fade_script)
	effect.set("fade_duration", 0.4)
	
	if player and player.get_parent():
		player.get_parent().add_child(effect)
