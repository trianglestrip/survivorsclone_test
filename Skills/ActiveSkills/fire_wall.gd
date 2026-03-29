class_name FireWallSkill
extends BaseActiveSkill

## 火墙技能
## 在前方召唤火墙，阻挡敌人并造成持续伤害
## 
## 设计：完全配置驱动，无硬编码数值

var wall_width: float = 0.0
var wall_height: float = 0.0
var burn_damage: float = 0.0
var wall_node: Node2D = null

func _load_skill_config(cfg: Dictionary):
	wall_width = cfg.get("width", 200.0)
	wall_height = cfg.get("height", 80.0)
	duration = cfg.get("duration", 5.0)
	burn_damage = cfg.get("burn_damage", 3.0)
	tick_interval = cfg.get("tick_interval", 0.3)  # 使用基类的tick_interval

func _on_skill_cast(cast_position: Vector2, _cast_direction: Vector2):
	var direction = get_mouse_direction()
	trigger_screen_shake(GameConstants.Values.SHAKE_ATTACK * 0.4)
	
	# 使用基类方法创建技能节点
	var node_config = SkillNodeConfig.new()
	node_config.node_name = "FireWall"
	node_config.node_type = SkillNodeType.AREA_RECT
	node_config.position = cast_position + direction * 60.0
	node_config.rotation = direction.angle() + PI / 2
	node_config.z_index = 2
	node_config.skill_animation_name = "fire_wall"
	node_config.animation_scale = VisualEffectsHelper.e_skill_fire_wall_scale(wall_width, wall_height)
	node_config.animation_modulate = Color(1.0, 1.0, 1.0, 0.7)
	node_config.animation_fps = 8.0
	node_config.animation_loop = true
	node_config.collision_size = Vector2(wall_width, wall_height)
	node_config.lifetime = duration
	node_config.fade_duration = 0.5
	node_config.fallback_color = GameConstants.Colors.SECT_FIRE
	
	wall_node = await create_skill_node(node_config)
	
	# 启用周期性伤害
	enable_tick_damage(tick_interval, _deal_damage)

func _deal_damage():
	if not is_instance_valid(wall_node):
		return
	
	var check_radius = max(wall_width, wall_height) * 0.6
	var enemies = get_enemies_in_range(wall_node.global_position, check_radius)
	for enemy in enemies:
		damage_enemy(enemy, damage)
		_apply_burn(enemy)

func _apply_burn(enemy: Node):
	if enemy and enemy.has_method("apply_burn"):
		enemy.apply_burn(burn_damage, duration)
