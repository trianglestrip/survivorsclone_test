extends Area2D

## 圣物掉落物
## 玩家接触后获得圣物
## 
## 设计：简化版本，自动吸引玩家

var relic_id: String = ""
var relic_name: String = ""
var move_speed: float = 0.0
var target_player: Node = null

func setup(r_id: String, r_name: String):
	relic_id = r_id
	relic_name = r_name
	
	# 设置碰撞
	collision_layer = 0
	collision_mask = 1  # 检测玩家
	
	# 创建碰撞形状
	var shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = 20.0
	shape.shape = circle
	add_child(shape)
	
	# 创建视觉效果
	_create_visual()
	
	# 连接信号
	body_entered.connect(_on_body_entered)

func _create_visual():
	var sprite = Sprite2D.new()
	sprite.texture = VisualEffectsHelper.create_placeholder_texture(Vector2(32, 32))
	sprite.modulate = Color(1.0, 0.8, 0.3)
	sprite.scale = Vector2(1.5, 1.5)
	add_child(sprite)
	
	# 添加发光效果
	var glow = Sprite2D.new()
	glow.texture = VisualEffectsHelper.create_glow_background(Vector2(64, 64), Color(1.0, 0.8, 0.3))
	glow.modulate = Color(1.0, 0.8, 0.3, 0.5)
	glow.z_index = -1
	add_child(glow)
	
	# 旋转动画
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(sprite, "rotation", TAU, 3.0)
	
	# 脉冲动画
	var pulse_tween = create_tween()
	pulse_tween.set_loops()
	pulse_tween.tween_property(glow, "scale", Vector2(1.2, 1.2), 1.0)
	pulse_tween.tween_property(glow, "scale", Vector2(1.0, 1.0), 1.0)

func _physics_process(delta: float):
	if not target_player:
		_find_player()
		return
	
	if not is_instance_valid(target_player):
		return
	
	# 吸引到玩家
	var direction = (target_player.global_position - global_position).normalized()
	move_speed += 200.0 * delta
	global_position += direction * move_speed * delta

func _find_player():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		target_player = players[0]

func _on_body_entered(body: Node):
	if body.is_in_group("player"):
		_pickup(body)

func _pickup(player_node: Node):
	# 查找RelicManager（可能是动态创建的子节点）
	var relic_mgr = null
	for child in player_node.get_children():
		if child.has_method("acquire_relic"):
			relic_mgr = child
			break
	
	if relic_mgr:
		relic_mgr.acquire_relic(relic_id)
	else:
		print("[RelicDrop] 找不到RelicManager")
	
	# 播放拾取效果
	_play_pickup_effect()
	queue_free()

func _play_pickup_effect():
	var effect = Sprite2D.new()
	effect.global_position = global_position
	effect.texture = VisualEffectsHelper.create_glow_background(Vector2(80, 80), Color(1.0, 0.8, 0.3))
	effect.modulate = Color(1.0, 0.8, 0.3, 0.8)
	effect.z_index = 10
	
	var fade_script = load("res://Utility/auto_fade_sprite.gd")
	effect.set_script(fade_script)
	effect.set("fade_duration", 0.5)
	
	if get_parent():
		get_parent().call_deferred("add_child", effect)
