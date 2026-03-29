class_name FireWallSkill
extends BaseActiveSkill

## 火墙技能
## 在前方召唤火墙，阻挡敌人并造成持续伤害
## 
## 设计：完全配置驱动，无硬编码数值

var wall_width: float = 0.0
var wall_height: float = 0.0
var burn_damage: float = 0.0
var tick_interval: float = 0.3
var wall_node: Node2D = null
var tick_timer: float = 0.0

func _load_skill_config(cfg: Dictionary):
	wall_width = cfg.get("width", 200.0)
	wall_height = cfg.get("height", 80.0)
	duration = cfg.get("duration", 5.0)
	burn_damage = cfg.get("burn_damage", 3.0)
	tick_interval = cfg.get("tick_interval", 0.3)

func _on_skill_cast(cast_position: Vector2, _cast_direction: Vector2):
	var direction = get_mouse_direction()
	trigger_screen_shake(GameConstants.Values.SHAKE_ATTACK * 0.4)
	_create_fire_wall(cast_position, direction)

func _create_fire_wall(pos: Vector2, dir: Vector2):
	wall_node = Node2D.new()
	wall_node.name = "FireWall"
	wall_node.global_position = pos + dir * 60.0  # 在前方生成
	wall_node.rotation = dir.angle() + PI / 2  # 垂直于方向
	wall_node.z_index = 2
	
	# 创建多层火焰效果
	for i in range(3):
		var sprite = Sprite2D.new()
		sprite.texture = VisualEffectsHelper.create_glow_background(
			Vector2(wall_width * (1.0 + i * 0.2), wall_height * (1.0 + i * 0.2)),
			GameConstants.Colors.SECT_FIRE
		)
		sprite.modulate = GameConstants.Colors.SECT_FIRE
		sprite.modulate.a = 0.7 - i * 0.2
		sprite.scale = Vector2(1.0, 1.0)
		sprite.name = "FireLayer" + str(i)
		wall_node.add_child(sprite)
	
	# 添加伤害区域
	var damage_area = Area2D.new()
	damage_area.name = "DamageArea"
	damage_area.collision_layer = 0
	damage_area.collision_mask = 2  # 检测敌人
	
	var shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(wall_width, wall_height)
	shape.shape = rect
	damage_area.add_child(shape)
	
	wall_node.add_child(damage_area)
	
	if player and player.get_parent():
		player.get_parent().add_child(wall_node)
		await get_tree().process_frame
		_start_wall_effect()
	else:
		wall_node.queue_free()

func _start_wall_effect():
	is_active = true
	elapsed_time = 0.0
	tick_timer = 0.0
	
	# 多层火焰闪烁效果
	if wall_node:
		for i in range(3):
			var sprite = wall_node.get_node_or_null("FireLayer" + str(i))
			if sprite:
				var tween = create_tween()
				tween.set_loops()
				var delay = i * 0.1
				tween.tween_interval(delay)
				tween.tween_property(sprite, "modulate:a", 0.9 - i * 0.2, 0.25)
				tween.tween_property(sprite, "modulate:a", 0.4 - i * 0.1, 0.25)
				
				# 添加缩放脉冲
				var scale_tween = create_tween()
				scale_tween.set_loops()
				scale_tween.tween_interval(delay)
				scale_tween.tween_property(sprite, "scale", Vector2(1.1, 1.05), 0.3)
				scale_tween.tween_property(sprite, "scale", Vector2(0.95, 1.0), 0.3)

func _process(delta: float):
	if not is_active or not is_instance_valid(wall_node):
		return
	
	elapsed_time += delta
	tick_timer += delta
	
	# 定期造成伤害
	if tick_timer >= tick_interval:
		tick_timer = 0.0
		_deal_burn_damage()
	
	# 持续时间结束
	if elapsed_time >= duration:
		_end_wall()

func _deal_burn_damage():
	if not wall_node:
		return
	
	# 使用火墙的宽度作为检测半径
	var check_radius = max(wall_width, wall_height) * 0.6
	var enemies = get_enemies_in_range(wall_node.global_position, check_radius)
	for enemy in enemies:
		damage_enemy(enemy, damage)
		_apply_burn(enemy)

func _apply_burn(enemy: Node):
	if enemy and enemy.has_method("apply_burn"):
		enemy.apply_burn(burn_damage, duration)

func _end_wall():
	is_active = false
	
	if not is_instance_valid(wall_node):
		return
	
	# 淡出动画
	var sprite = wall_node.get_node_or_null("Sprite2D")
	if sprite:
		var fade_script = load("res://Utility/auto_fade_sprite.gd")
		sprite.set_script(fade_script)
		sprite.set("fade_duration", 0.5)
	else:
		wall_node.queue_free()
