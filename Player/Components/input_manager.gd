extends Node

## 输入管理器 - 统一管理所有玩家输入
## 事件驱动，解耦输入处理与游戏逻辑

## 输入信号
signal move_input(direction: Vector2)  # 移动输入
signal attack_pressed()               # 攻击按下
signal attack_released()              # 攻击释放
signal dash_pressed()                 # 冲刺按下
signal dash_released()                # 冲刺释放

## 输入状态
var move_direction: Vector2 = Vector2.ZERO
var is_attack_pressed: bool = false
var is_dash_pressed: bool = false

## 配置
var _config: Dictionary = {}

func _ready():
	_load_config()

func _load_config():
	var json_data = ConfigManager.load_json_config("res://config/stage1_controls.json")
	if json_data and json_data.has("input"):
		_config = json_data["input"]

func _process(_delta: float):
	_update_movement()
	_update_attack()
	_update_dash()

func _update_movement():
	var x = Input.get_action_strength("right") - Input.get_action_strength("left")
	var y = Input.get_action_strength("down") - Input.get_action_strength("up")
	var new_dir = Vector2(x, y).normalized()
	
	if new_dir != move_direction:
		move_direction = new_dir
		if move_direction != Vector2.ZERO:
			emit_signal("move_input", move_direction)

func _update_attack():
	var was_pressed = is_attack_pressed
	is_attack_pressed = Input.is_action_just_pressed("click") or Input.is_action_just_pressed("attack")
	
	if is_attack_pressed and not was_pressed:
		emit_signal("attack_pressed")
	elif not is_attack_pressed and was_pressed:
		emit_signal("attack_released")

func _update_dash():
	var was_pressed = is_dash_pressed
	is_dash_pressed = Input.is_action_just_pressed("shift")
	
	if is_dash_pressed and not was_pressed:
		emit_signal("dash_pressed")
	elif not is_dash_pressed and was_pressed:
		emit_signal("dash_released")

## 公共 API - 查询输入状态
func get_move_direction() -> Vector2:
	return move_direction

func is_attacking() -> bool:
	return is_attack_pressed

func is_dashing() -> bool:
	return is_dash_pressed
