class_name ThunderFieldSkill
extends BaseActiveSkill

## 雷阵技能
## 在地面布置雷阵，触碰的敌人受到电击
## 
## 设计：完全配置驱动，无硬编码数值

var radius: float = 0.0
var field_node: Node2D = null
var hit_enemies: Array = []

func _load_skill_config(cfg: Dictionary):
	radius = cfg.get("radius", 120.0)
	duration = cfg.get("duration", 6.0)
	tick_interval = cfg.get("trigger_interval", 0.5)  # 使用基类的tick_interval

func _on_skill_cast(cast_position: Vector2, _cast_direction: Vector2):
	trigger_screen_shake(GameConstants.Values.SHAKE_ATTACK * 0.3)
	
	# 使用基类方法创建技能节点
	var node_config = SkillNodeConfig.new()
	node_config.node_name = "ThunderField"
	node_config.node_type = SkillNodeType.AREA_CIRCLE
	node_config.position = cast_position
	node_config.z_index = 1
	node_config.skill_animation_name = "thunder_field"
	node_config.animation_scale = VisualEffectsHelper.e_skill_scale_vector(radius)
	node_config.animation_modulate = Color(1.0, 1.0, 1.0, 0.4)
	node_config.animation_fps = 8.0
	node_config.animation_loop = true
	node_config.collision_radius = radius
	node_config.lifetime = duration
	node_config.fade_duration = 0.5
	node_config.fallback_color = GameConstants.Colors.SECT_THUNDER
	
	field_node = await create_skill_node(node_config)
	
	# 启用周期性伤害
	enable_tick_damage(tick_interval, _deal_damage)

func _deal_damage():
	if not is_instance_valid(field_node):
		return
	
	var enemies = get_enemies_in_range(field_node.global_position, radius)
	for enemy in enemies:
		damage_enemy(enemy, damage)
		_create_lightning_effect(enemy.global_position)


func _create_lightning_effect(pos: Vector2):
	var effect = Sprite2D.new()
	effect.global_position = pos
	var spark := VisualEffectsHelper.q_skill_scale_vector(1.25)
	effect.scale = Vector2(spark.x, spark.y * 1.35)
	effect.z_index = 10
	
	var thunder_color = GameConstants.Colors.SECT_THUNDER
	effect.texture = VisualEffectsHelper.create_gradient_texture(
		Vector2(16, 32),
		Color(thunder_color.r, thunder_color.g, thunder_color.b, 0.9),
		Color(thunder_color.r, thunder_color.g, thunder_color.b, 0.0)
	)
	
	var fade_script = load("res://Utility/auto_fade_sprite.gd")
	effect.set_script(fade_script)
	effect.set("fade_duration", 0.3)
	
	if player and player.get_parent():
		player.get_parent().add_child(effect)
