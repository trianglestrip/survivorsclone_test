class_name IceFieldSkill
extends BaseActiveSkill

## 冰封领域技能
## 在周围创造冰霜领域，持续造成伤害并减速

var radius: float = 0.0
var slow_percent: float = 0.0
var slow_duration: float = 0.0
var field_node: Node2D = null

func _load_skill_config(cfg: Dictionary):
	radius = cfg.get("radius", 150.0)
	duration = cfg.get("duration", 4.0)
	slow_percent = cfg.get("slow_percent", 0.5)
	slow_duration = duration
	
	# 配置状态效果
	add_status_effect(StatusEffect.SLOW, slow_percent, slow_duration)

func _on_skill_cast(cast_position: Vector2, _cast_direction: Vector2):
	trigger_screen_shake(GameConstants.Values.SHAKE_ATTACK * 0.5)
	
	# 使用基类方法创建技能节点
	var node_config = SkillNodeConfig.new()
	node_config.node_name = "IceField"
	node_config.node_type = SkillNodeType.AREA_CIRCLE
	node_config.position = cast_position
	node_config.z_index = 1
	node_config.skill_animation_name = "ice_field"
	node_config.animation_scale = VisualEffectsHelper.e_skill_scale_vector(radius)
	node_config.animation_modulate = Color(1.0, 1.0, 1.0, 0.6)
	node_config.animation_fps = 8.0
	node_config.animation_loop = true
	node_config.collision_radius = radius
	node_config.lifetime = duration
	node_config.fade_duration = 0.5
	node_config.fallback_color = GameConstants.Colors.SECT_ICE
	
	field_node = await create_skill_node(node_config)
	
	# 启用周期性伤害
	enable_tick_damage(0.5, _deal_damage)

func _deal_damage():
	if not is_instance_valid(field_node):
		return
	
	var enemies = get_enemies_in_range(field_node.global_position, radius)
	for enemy in enemies:
		damage_enemy(enemy, damage)
		apply_status_effects(enemy)
