class_name StatusEffect
extends RefCounted

## 状态效果基类
## 用于敌人的减速、灼烧、中毒等状态

const GameConstants = preload("res://Utility/game_constants.gd")

var effect_type: GameConstants.StatusEffectType
var duration: float = 0.0
var remaining_time: float = 0.0
var is_active: bool = false

# 效果参数（子类定义）
var effect_value: float = 0.0
var tick_interval: float = 1.0
var tick_timer: float = 0.0

func _init(type: GameConstants.StatusEffectType, dur: float, value: float):
	effect_type = type
	duration = dur
	remaining_time = dur
	effect_value = value
	is_active = true

## 更新状态效果
func update(delta: float) -> bool:
	if not is_active:
		return false
	
	remaining_time -= delta
	
	if remaining_time <= 0:
		is_active = false
		return false
	
	_on_update(delta)
	return true

## 子类重写：每帧更新
func _on_update(_delta: float):
	pass

## 应用效果到目标
func apply_to(target: Node):
	_on_apply(target)

## 子类重写：应用时
func _on_apply(_target: Node):
	pass

## 移除效果
func remove_from(target: Node):
	_on_remove(target)
	is_active = false

## 子类重写：移除时
func _on_remove(_target: Node):
	pass

## 获取效果进度（0-1）
func get_progress() -> float:
	if duration <= 0:
		return 0.0
	return 1.0 - (remaining_time / duration)

# ========================================
# 具体状态效果类
# ========================================

class SlowEffect extends StatusEffect:
	var slow_percent: float = 0.0
	var original_speed: float = 0.0
	
	func _init(dur: float, percent: float):
		super._init(GameConstants.StatusEffectType.SLOW, dur, percent)
		slow_percent = percent
	
	func _on_apply(target: Node):
		if target and "movement_speed" in target:
			original_speed = target.movement_speed
			target.movement_speed *= (1.0 - slow_percent)
	
	func _on_remove(target: Node):
		if target and "movement_speed" in target:
			target.movement_speed = original_speed

class BurnEffect extends StatusEffect:
	func _init(dur: float, dmg_per_sec: float):
		super._init(GameConstants.StatusEffectType.BURN, dur, dmg_per_sec)
		tick_interval = 1.0
	
	func _on_update(delta: float):
		tick_timer += delta
		if tick_timer >= tick_interval:
			tick_timer = 0.0
	
	func apply_tick_damage(target: Node):
		if target and target.has_method("take_damage"):
			target.take_damage(effect_value, Vector2.ZERO)

class PoisonEffect extends StatusEffect:
	func _init(dur: float, dmg_per_sec: float):
		super._init(GameConstants.StatusEffectType.POISON, dur, dmg_per_sec)
		tick_interval = 1.0
	
	func _on_update(delta: float):
		tick_timer += delta
		if tick_timer >= tick_interval:
			tick_timer = 0.0
	
	func apply_tick_damage(target: Node):
		if target and target.has_method("take_damage"):
			target.take_damage(effect_value, Vector2.ZERO)

class FreezeEffect extends StatusEffect:
	var original_speed: float = 0.0
	
	func _init(dur: float):
		super._init(GameConstants.StatusEffectType.FREEZE, dur, 0.0)
	
	func _on_apply(target: Node):
		if target and "movement_speed" in target:
			original_speed = target.movement_speed
			target.movement_speed = 0.0
	
	func _on_remove(target: Node):
		if target and "movement_speed" in target:
			target.movement_speed = original_speed
