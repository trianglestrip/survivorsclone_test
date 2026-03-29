class_name DashManager
extends Node

## 冲刺管理器 - 处理玩家冲刺/闪避机制
## 完全解耦，数值从配置加载

## 信号
signal dash_started()
signal dash_ended()
signal dash_cooldown_started(cooldown_time: float)
signal dash_cooldown_ended()
signal dash_cooldown_updated(current_cooldown: float, max_cooldown: float)

## 冲刺属性（从配置加载）
var cooldown: float = 0.8
var distance: float = 160.0
var duration: float = 0.12
var invincible_duration: float = 0.3
var trail_effect: bool = true
var screen_shake_intensity: float = 0.3

## 状态
var is_dashing: bool = false
var is_invincible: bool = false
var is_on_cooldown: bool = false
var current_cooldown: float = 0.0
var dash_timer: float = 0.0
var invincible_timer: float = 0.0
var dash_direction: Vector2 = Vector2.ZERO
var dash_start_pos: Vector2 = Vector2.ZERO
var dash_target_pos: Vector2 = Vector2.ZERO

## 残影效果
var _trail_nodes: Array = []

## 引用
var player: Node = null
var input_manager: Node = null

## 特效
var _dash_frames: Array = []
var _current_effect_node: Node2D = null
var _current_effect_sprite: Sprite2D = null

func _ready():
	_load_config()
	_load_dash_frames()

func _load_dash_frames():
	for i in range(8):
		var texture_path = "res://Textures/Placeholder/Effects/Dash/dash_%d.png" % i
		if ResourceLoader.exists(texture_path):
			var texture = load(texture_path)
			_dash_frames.append(texture)

func _load_config():
	var json_data = ConfigManager.load_json_config("res://config/stage1_controls.json")
	if json_data and json_data.has("dash"):
		var dash_config = json_data["dash"]
		cooldown = dash_config.get("cooldown", 0.8)
		distance = dash_config.get("distance", 160.0)
		duration = dash_config.get("duration", 0.12)
		invincible_duration = dash_config.get("invincible_frames", 0.3)
		trail_effect = dash_config.get("trail_effect", true)
		screen_shake_intensity = dash_config.get("screen_shake_intensity", 0.3)

func set_player(p: Node):
	player = p

func set_input_manager(im: Node):
	input_manager = im
	if input_manager:
		input_manager.dash_pressed.connect(_on_dash_pressed)

func _on_dash_pressed():
	try_dash()

func _process(delta: float):
	if is_dashing:
		_update_dash(delta)
	
	if is_invincible:
		_update_invincible(delta)
	
	if is_on_cooldown:
		_update_cooldown(delta)

func _update_dash(delta: float):
	dash_timer += delta
	
	var progress = min(dash_timer / duration, 1.0)
	var eased_progress = ease(progress, -2.0)
	var new_pos = dash_start_pos.lerp(dash_target_pos, eased_progress)
	
	if player:
		player.global_position = new_pos
		if trail_effect and int(dash_timer * 100) % 2 == 0:
			_create_trail_effect(new_pos)
	
	if progress >= 1.0:
		_end_dash()

func _update_invincible(delta: float):
	invincible_timer += delta
	if invincible_timer >= invincible_duration:
		is_invincible = false

func _update_cooldown(delta: float):
	current_cooldown -= delta
	emit_signal("dash_cooldown_updated", max(current_cooldown, 0), cooldown)
	if current_cooldown <= 0:
		is_on_cooldown = false
		emit_signal("dash_cooldown_ended")

func can_dash() -> bool:
	return not is_dashing and not is_on_cooldown and not is_invincible

func try_dash() -> bool:
	if not can_dash() or not player:
		return false
	
	var move_dir = Vector2.ZERO
	if input_manager:
		move_dir = input_manager.get_move_direction()
	
	if move_dir == Vector2.ZERO:
		if player and player.has("last_movement"):
			move_dir = player.last_movement
	
	if move_dir == Vector2.ZERO:
		move_dir = Vector2.RIGHT
	
	_start_dash(move_dir.normalized())
	return true

func _start_dash(direction: Vector2):
	is_dashing = true
	is_invincible = true
	dash_timer = 0.0
	invincible_timer = 0.0
	dash_direction = direction
	dash_start_pos = player.global_position
	dash_target_pos = dash_start_pos + direction * distance
	
	_play_dash_effect(dash_start_pos)
	_trigger_screen_shake()
	_clear_old_trails()
	
	emit_signal("dash_started")

func _play_dash_effect(position: Vector2):
	if _dash_frames.is_empty():
		return
	
	_current_effect_node = Node2D.new()
	_current_effect_node.name = "DashEffect"
	_current_effect_node.position = position
	_current_effect_node.z_index = 10
	
	_current_effect_sprite = Sprite2D.new()
	_current_effect_sprite.texture = _dash_frames[0]
	_current_effect_sprite.scale = Vector2(1.0, 1.0)
	_current_effect_node.add_child(_current_effect_sprite)
	
	if player and player.get_parent():
		player.get_parent().add_child(_current_effect_node)
	
	_animate_dash_effect()

func _animate_dash_effect():
	for i in range(_dash_frames.size()):
		await get_tree().create_timer(0.03).timeout
		if is_instance_valid(_current_effect_sprite):
			if i < _dash_frames.size():
				_current_effect_sprite.texture = _dash_frames[i]
	
	await get_tree().create_timer(0.1).timeout
	if is_instance_valid(_current_effect_node):
		_current_effect_node.queue_free()
		_current_effect_node = null
		_current_effect_sprite = null

func _end_dash():
	is_dashing = false
	is_on_cooldown = true
	current_cooldown = cooldown
	emit_signal("dash_ended")
	emit_signal("dash_cooldown_started", cooldown)
	emit_signal("dash_cooldown_updated", current_cooldown, cooldown)

## 公共 API
func get_dash_progress() -> float:
	if not is_dashing:
		return 1.0
	return dash_timer / duration

func get_cooldown_progress() -> float:
	if not is_on_cooldown:
		return 1.0
	return 1.0 - (current_cooldown / cooldown)

func _create_trail_effect(position: Vector2):
	if not player or not player.has_node("Sprite2D"):
		return
	
	var trail = Sprite2D.new()
	trail.name = "DashTrail"
	var player_sprite = player.get_node("Sprite2D")
	trail.texture = player_sprite.texture
	
	if player_sprite.hframes * player_sprite.vframes > 1:
		trail.hframes = player_sprite.hframes
		trail.vframes = player_sprite.vframes
		trail.frame = player_sprite.frame
	
	trail.flip_h = player_sprite.flip_h
	trail.position = position
	trail.modulate = Color(0.5, 0.8, 1.0, 0.6)
	trail.z_index = player.z_index - 1
	
	if player.get_parent():
		player.get_parent().add_child(trail)
		_trail_nodes.append(trail)
		_fade_out_trail(trail)

func _fade_out_trail(trail: Sprite2D):
	var fade_duration = 0.3
	var elapsed = 0.0
	while elapsed < fade_duration and is_instance_valid(trail):
		await get_tree().create_timer(0.02).timeout
		elapsed += 0.02
		if is_instance_valid(trail):
			trail.modulate.a = lerp(0.6, 0.0, elapsed / fade_duration)
	
	if is_instance_valid(trail):
		trail.queue_free()
		_trail_nodes.erase(trail)

func _clear_old_trails():
	for trail in _trail_nodes:
		if is_instance_valid(trail):
			trail.queue_free()
	_trail_nodes.clear()

func _trigger_screen_shake():
	if player and player.has_node("Camera2D"):
		var camera = player.get_node("Camera2D")
		_shake_camera(camera, screen_shake_intensity)

func _shake_camera(camera: Camera2D, intensity: float):
	var original_offset = camera.offset
	var shake_amount = intensity * 5.0
	
	for i in range(4):
		var shake_x = randf_range(-shake_amount, shake_amount)
		var shake_y = randf_range(-shake_amount, shake_amount)
		camera.offset = original_offset + Vector2(shake_x, shake_y)
		await get_tree().create_timer(0.015).timeout
		shake_amount *= 0.6
	
	camera.offset = original_offset
