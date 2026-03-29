class_name BaseAttack
extends Node

## 攻击基类 - 定义攻击接口
## 使用继承架构，子类实现具体攻击逻辑

## 攻击信号
signal attack_executed(position: Vector2, direction: Vector2, damage: int, knockback: int)
signal attack_started()
signal attack_ended()

## 攻击属性（从配置加载）
var cooldown: float = 0.3
var attack_range: float = 90.0
var damage: int = 12
var knockback: int = 180
var attack_duration: float = 0.2
var animation_speed: float = 1.5
var hit_pause_duration: float = 0.05

## 状态
var is_on_cooldown: bool = false
var is_attacking: bool = false
var current_cooldown: float = 0.0
var current_attack_time: float = 0.0

## 引用
var player: Node = null
var attack_direction: Vector2 = Vector2.RIGHT

## 抽象方法 - 子类必须实现
func get_attack_direction() -> Vector2:
	push_error("BaseAttack: get_attack_direction() must be implemented by subclass")
	return Vector2.RIGHT

func play_attack_animation():
	push_error("BaseAttack: play_attack_animation() must be implemented by subclass")

func spawn_attack_effect(attack_position: Vector2, attack_direction: Vector2):
	push_error("BaseAttack: spawn_attack_effect() must be implemented by subclass")

## 公共方法
func set_player(p: Node):
	player = p

func load_config(config: Dictionary):
	if config.is_empty():
		return
	
	cooldown = config.get("base_cooldown", 0.3)
	attack_range = config.get("base_range", 90.0)
	damage = config.get("base_damage", 12)
	knockback = config.get("base_knockback", 180)
	animation_speed = config.get("animation_speed", 1.5)
	hit_pause_duration = config.get("hit_pause_duration", 0.05)

func can_attack() -> bool:
	return not is_on_cooldown and not is_attacking

func try_attack() -> bool:
	if not can_attack():
		return false
	
	_start_attack()
	return true

func _process(delta: float):
	if is_on_cooldown:
		current_cooldown -= delta
		if current_cooldown <= 0:
			is_on_cooldown = false
			current_cooldown = 0.0
	
	if is_attacking:
		current_attack_time += delta
		if current_attack_time >= attack_duration:
			_end_attack()

func _start_attack():
	is_attacking = true
	current_attack_time = 0.0
	attack_direction = get_attack_direction()
	
	emit_signal("attack_started")
	play_attack_animation()
	
	await get_tree().create_timer(attack_duration * 0.5).timeout
	_execute_attack()

func _execute_attack():
	if not player:
		return
	
	var attack_pos = player.global_position + attack_direction * (attack_range * 0.5)
	spawn_attack_effect(attack_pos, attack_direction)
	emit_signal("attack_executed", attack_pos, attack_direction, damage, knockback)

func _end_attack():
	is_attacking = false
	is_on_cooldown = true
	current_cooldown = cooldown
	emit_signal("attack_ended")
