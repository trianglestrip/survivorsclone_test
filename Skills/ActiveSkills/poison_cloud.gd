class_name PoisonCloudSkill
extends BaseActiveSkill

## 毒云技能
## 释放毒云，范围内敌人持续中毒并降低防御
## 
## 设计：完全配置驱动，无硬编码数值

var radius: float = 0.0
var defense_reduce: float = 0.0
var cloud_node: Node2D = null

func _load_skill_config(cfg: Dictionary):
	radius = cfg.get("radius", 140.0)
	duration = cfg.get("duration", 6.0)
	defense_reduce = cfg.get("defense_reduce", 0.3)
	tick_interval = cfg.get("tick_interval", 0.5)  # 使用基类的tick_interval

func _on_skill_cast(cast_position: Vector2, _cast_direction: Vector2):
	trigger_screen_shake(GameConstants.Values.SHAKE_ATTACK * 0.3)
	
	# 使用基类方法创建技能节点
	var node_config = SkillNodeConfig.new()
	node_config.node_name = "PoisonCloud"
	node_config.node_type = SkillNodeType.AREA_CIRCLE
	node_config.position = cast_position
	node_config.z_index = 1
	node_config.skill_animation_name = "poison_cloud"
	node_config.animation_scale = VisualEffectsHelper.e_skill_scale_vector(radius)
	node_config.animation_modulate = Color(1.0, 1.0, 1.0, 0.5)
	node_config.animation_fps = 8.0
	node_config.animation_loop = true
	node_config.collision_radius = radius
	node_config.lifetime = duration
	node_config.fade_duration = 0.8
	node_config.fallback_color = GameConstants.Colors.SECT_POISON
	
	cloud_node = await create_skill_node(node_config)
	
	# 启用周期性伤害
	enable_tick_damage(tick_interval, _deal_damage)

func _deal_damage():
	if not is_instance_valid(cloud_node):
		return
	
	var enemies = get_enemies_in_range(cloud_node.global_position, radius)
	for enemy in enemies:
		damage_enemy(enemy, damage)
		_apply_poison(enemy)

func _apply_poison(enemy: Node):
	if enemy and enemy.has_method("apply_poison"):
		enemy.apply_poison(damage * 0.5, duration)
	if enemy and enemy.has_method("reduce_defense"):
		enemy.reduce_defense(defense_reduce, duration)
