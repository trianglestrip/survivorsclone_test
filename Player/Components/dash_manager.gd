class_name DashManager
extends Node

## 冲刺管理器 - 处理玩家冲刺/闪避机制
## 完全解耦，数值从配置加载

## 信号
signal dash_started()
signal dash_ended()
signal dash_cooldown_started()
signal dash_cooldown_ended()

## 冲刺属性（从配置加载）
var cooldown: float = 1.0
var distance: float = 150.0
var duration: float = 0.2
var invincible_duration: float = 0.3

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

## 引用
var player: Node = null
var input_manager: Node = null

func _ready():
	_load_config()

func _load_config():
	var json_data = ConfigManager.load_json_config("res://config/stage1_controls.json")
	if json_data and json_data.has("dash"):
		var dash_config = json_data["dash"]
		cooldown = dash_config.get("cooldown", 1.0)
		distance = dash_config.get("distance", 150.0)
		duration = dash_config.get("duration", 0.2)
		invincible_duration = dash_config.get("invincible_frames", 0.3)

func set_player(p: Node):
	player = p

func set_input_manager(im: Node):
	input_manager = im
	if input_manager:
		input_manager.dash_pressed.connect(_on_dash_pressed)

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
	var new_pos = dash_start_pos.lerp(dash_target_pos, progress)
	
	if player:
		player.global_position = new_pos
	
	if progress >= 1.0:
		_end_dash()

func _update_invincible(delta: float):
	invincible_timer += delta
	if invincible_timer >= invincible_duration:
		is_invincible = false

func _update_cooldown(delta: float):
	current_cooldown -= delta
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
	
	emit_signal("dash_started")

func _end_dash():
	is_dashing = false
	is_on_cooldown = true
	current_cooldown = cooldown
	emit_signal("dash_ended")
	emit_signal("dash_cooldown_started")

## 公共 API
func get_dash_progress() -> float:
	if not is_dashing:
		return 1.0
	return dash_timer / duration

func get_cooldown_progress() -> float:
	if not is_on_cooldown:
		return 1.0
	return 1.0 - (current_cooldown / cooldown)
