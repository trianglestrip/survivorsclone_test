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
	_create_thunder_god(cast_position)

func _create_thunder_god(pos: Vector2):
	god_node = Node2D.new()
	god_node.name = "ThunderGod"
	god_node.global_position = pos
	god_node.z_index = 4
	
	# 创建雷神光环效果
	var aura = Sprite2D.new()
	aura.texture = VisualEffectsHelper.create_glow_background(
		Vector2(radius * 2, radius * 2),
		GameConstants.Colors.SECT_THUNDER
	)
	aura.modulate = GameConstants.Colors.SECT_THUNDER
	aura.modulate.a = 0.6
	aura.scale = Vector2(0.1, 0.1)
	aura.name = "Aura"
	
	god_node.add_child(aura)
	
	# 添加伤害区域
	var damage_area = Area2D.new()
	damage_area.name = "DamageArea"
	damage_area.collision_layer = 0
	damage_area.collision_mask = 2  # 检测敌人
	
	var shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = radius
	shape.shape = circle
	damage_area.add_child(shape)
	
	god_node.add_child(damage_area)
	
	if player and player.get_parent():
		player.get_parent().call_deferred("add_child", god_node)
		if god_node.is_inside_tree():
			await god_node.tree_entered
		_animate_god_aura(aura)
	else:
		god_node.queue_free()

func _animate_god_aura(aura: Sprite2D):
	# 展开动画
	var tween = create_tween()
	tween.tween_property(aura, "scale", Vector2(1.0, 1.0), 0.3)
	
	# 脉冲效果
	var pulse_tween = create_tween()
	pulse_tween.set_loops()
	pulse_tween.tween_property(aura, "modulate:a", 0.8, 0.4)
	pulse_tween.tween_property(aura, "modulate:a", 0.4, 0.4)
	
	# 旋转效果
	var rotate_tween = create_tween()
	rotate_tween.set_loops()
	rotate_tween.tween_property(aura, "rotation", TAU, 2.0)
	
	is_active = true
	elapsed_time = 0.0
	strike_timer = 0.0

func _process(delta: float):
	if not is_active or not is_instance_valid(god_node):
		return
	
	elapsed_time += delta
	strike_timer += delta
	
	# 定期释放雷电
	if strike_timer >= strike_interval:
		strike_timer = 0.0
		_strike_lightning()
	
	# 持续时间结束
	if elapsed_time >= duration:
		_end_god_mode()

func _strike_lightning():
	if not god_node:
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
	bolt.width = 3.0
	bolt.default_color = GameConstants.Colors.SECT_THUNDER
	bolt.global_position = from
	bolt.z_index = 11
	
	if player and player.get_parent():
		player.get_parent().call_deferred("add_child", bolt)
		if bolt.is_inside_tree():
			await bolt.tree_entered
		_animate_bolt(bolt)

func _animate_bolt(bolt: Line2D):
	await get_tree().create_timer(0.1).timeout
	if is_instance_valid(bolt):
		bolt.queue_free()

func _end_god_mode():
	is_active = false
	
	if not is_instance_valid(god_node):
		return
	
	# 淡出动画
	var aura = god_node.get_node_or_null("Aura")
	if aura:
		var fade_script = load("res://Utility/auto_fade_sprite.gd")
		aura.set_script(fade_script)
		aura.set("fade_duration", 0.5)
	else:
		god_node.queue_free()
