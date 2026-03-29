class_name ThunderStrikeSkill
extends BaseActiveSkill

## 雷霆一击技能
## 召唤雷电打击目标区域，造成范围伤害并链式传播
## 
## 设计：完全配置驱动，使用工具类

var radius: float = 0.0
var chain_count: int = 0
var chain_range: float = 0.0
var chain_delay: float = 0.2

func _load_skill_config(cfg: Dictionary):
	radius = cfg.get("radius", 100.0)
	chain_count = cfg.get("chain_count", 3)
	chain_range = cfg.get("chain_range", 80.0)
	chain_delay = cfg.get("chain_delay", 0.2)

func _on_skill_cast(cast_position: Vector2, _cast_direction: Vector2):
	var target_pos = player.get_global_mouse_position() if player else cast_position
	trigger_screen_shake(GameConstants.Values.SHAKE_HIT)
	_strike_at_position(target_pos, chain_count)

func _strike_at_position(pos: Vector2, remaining_chains: int):
	_create_strike_effect(pos)
	
	var enemies = get_enemies_in_range(pos, radius)
	var hit_enemies = []
	
	for enemy in enemies:
		damage_enemy(enemy, damage)
		hit_enemies.append(enemy)
	
	if remaining_chains > 1 and hit_enemies.size() > 0:
		await get_tree().create_timer(chain_delay).timeout
		_chain_to_nearby(hit_enemies, remaining_chains - 1)

func _chain_to_nearby(hit_enemies: Array, remaining_chains: int):
	var next_target = null
	var min_distance = 999999.0
	
	for enemy in hit_enemies:
		if not is_instance_valid(enemy):
			continue
		
		var nearby = get_enemies_in_range(enemy.global_position, chain_range)
		for nearby_enemy in nearby:
			if nearby_enemy in hit_enemies:
				continue
			
			var dist = enemy.global_position.distance_to(nearby_enemy.global_position)
			if dist < min_distance:
				min_distance = dist
				next_target = nearby_enemy
	
	if next_target and is_instance_valid(next_target):
		_strike_at_position(next_target.global_position, remaining_chains)

func _create_strike_effect(pos: Vector2):
	var effect = Node2D.new()
	effect.position = pos
	effect.z_index = 10
	effect.name = "ThunderStrike"
	
	# 使用动画精灵
	var animated_sprite = preload("res://Utility/animated_skill_sprite.gd").new()
	animated_sprite.fps = 15.0
	animated_sprite.loop = false
	animated_sprite.auto_destroy = true
	animated_sprite.scale = VisualEffectsHelper.q_skill_scale_vector()
	animated_sprite.modulate = Color(1.0, 1.0, 1.0, 0.9)
	
	# 尝试加载动画帧
	if animated_sprite.load_from_skill("thunder_strike"):
		apply_standard_to_skill_visual(animated_sprite, "area")
		effect.add_child(animated_sprite)
	else:
		# 回退到渐变纹理
		var flash = Sprite2D.new()
		flash.scale = VisualEffectsHelper.q_skill_scale_vector()
		var thunder_color = GameConstants.Colors.SECT_THUNDER
		flash.texture = VisualEffectsHelper.create_gradient_texture(
			Vector2(64, 64),
			Color(thunder_color.r, thunder_color.g, thunder_color.b, 0.9),
			Color(thunder_color.r, thunder_color.g, thunder_color.b, 0.0)
		)
		effect.add_child(flash)
		
		var circle = Sprite2D.new()
		# 64px 纹理半径约 32，使精灵半径与伤害半径一致
		var ring_s := radius / 32.0
		circle.scale = Vector2(ring_s, ring_s)
		circle.texture = VisualEffectsHelper.create_circle_texture(
			Vector2(64, 64),
			Color(thunder_color.r, thunder_color.g, thunder_color.b, 0.25),
			true
		)
		circle.z_index = 5
		effect.add_child(circle)
	
	if player and player.get_parent():
		player.get_parent().add_child(effect)
		await get_tree().process_frame
		if not animated_sprite.load_from_skill("thunder_strike"):
			_animate_strike_effect(effect)
	else:
		effect.queue_free()

func _animate_strike_effect(effect: Node2D):
	if not is_instance_valid(effect):
		return
	
	if not effect.is_inside_tree():
		await effect.tree_entered
	
	if not is_instance_valid(effect) or not effect.is_inside_tree():
		return
	
	var flash = effect.get_node_or_null("Sprite2D")
	var circle = effect.get_node_or_null("Sprite2D2")
	
	for i in range(5):
		await effect.get_tree().create_timer(0.05).timeout
		if is_instance_valid(flash):
			flash.modulate.a -= 0.2
		if is_instance_valid(circle):
			circle.scale *= 1.05
			circle.modulate.a -= 0.1
	
	if is_instance_valid(effect):
		effect.queue_free()
