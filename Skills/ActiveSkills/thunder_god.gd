class_name ThunderGodSkill
extends BaseActiveSkill

## 天罚雷劫技能
## 化身雷神，持续释放雷电链，造成大范围伤害
## 
## 设计：完全配置驱动，无硬编码数值

var radius: float = 0.0
var strike_interval: float = 0.3
var god_node: Node2D = null
var strike_timer: float = 0.0

func _load_skill_config(cfg: Dictionary):
	radius = cfg.get("radius", 250.0)
	duration = cfg.get("duration", 6.0)
	strike_interval = cfg.get("strike_interval", 0.3)

func _on_skill_cast(cast_position: Vector2, _cast_direction: Vector2):
	trigger_screen_shake(GameConstants.Values.SHAKE_ATTACK * 2.0)
	
	# 使用基类方法创建技能节点
	var node_config = SkillNodeConfig.new()
	node_config.node_name = "ThunderGod"
	node_config.visual_category = "ultimate"
	node_config.node_type = SkillNodeType.AREA_CIRCLE
	node_config.position = cast_position
	node_config.z_index = 4
	node_config.skill_animation_name = "thunder_god"
	node_config.animation_scale = VisualEffectsHelper.r_skill_scale_vector(radius)
	node_config.animation_modulate = Color(1.0, 1.0, 1.0, 0.6)
	node_config.animation_fps = 12.0
	node_config.animation_loop = true
	node_config.collision_radius = radius
	node_config.lifetime = duration
	node_config.fade_duration = 0.6
	node_config.fallback_color = GameConstants.Colors.SECT_THUNDER
	
	god_node = await create_skill_node(node_config)
	
	# 启用周期性伤害
	enable_tick_damage(strike_interval, _deal_damage)

func _deal_damage():
	if not is_instance_valid(god_node):
		return
	
	var enemies = get_enemies_in_range(god_node.global_position, radius)
	
	# 随机选择1-3个敌人打击
	var target_count = min(3, enemies.size())
	enemies.shuffle()
	
	for i in range(target_count):
		var enemy = enemies[i]
		damage_enemy(enemy, damage)
		_create_lightning_bolt(god_node.global_position, enemy.global_position)

func _create_lightning_bolt(from: Vector2, to: Vector2):
	var bolt = Line2D.new()
	bolt.add_point(Vector2.ZERO)
	bolt.add_point(to - from)
	bolt.width = clampf(3.0 * VisualEffectsHelper.r_skill_scale_from_radius(radius) / (250.0 / 150.0), 3.0, 6.5)
	bolt.default_color = GameConstants.Colors.SECT_THUNDER
	bolt.global_position = from
	bolt.z_index = 11
	
	if player and player.get_parent():
		player.get_parent().add_child(bolt)
		await get_tree().process_frame
		_animate_bolt(bolt)

func _animate_bolt(bolt: Line2D):
	await get_tree().create_timer(0.1).timeout
	if is_instance_valid(bolt):
		bolt.queue_free()
