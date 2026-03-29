class_name EnemyStatusManager
extends Node

## 敌人状态效果管理器
## 管理敌人身上的所有状态效果（减速、灼烧、中毒等）

var active_effects: Array[StatusEffect] = []
var enemy: Node = null

func set_enemy(e: Node):
	enemy = e

func _process(delta: float):
	_update_effects(delta)

func _update_effects(delta: float):
	var i = 0
	while i < active_effects.size():
		var effect = active_effects[i]
		
		if not effect.update(delta):
			effect.remove_from(enemy)
			active_effects.remove_at(i)
		else:
			if effect is StatusEffect.BurnEffect or effect is StatusEffect.PoisonEffect:
				if effect.tick_timer == 0.0:
					effect.apply_tick_damage(enemy)
			i += 1

## 应用状态效果
func apply_effect(effect: StatusEffect):
	var existing = _find_effect(effect.effect_type)
	if existing:
		existing.remaining_time = max(existing.remaining_time, effect.duration)
	else:
		effect.apply_to(enemy)
		active_effects.append(effect)

func _find_effect(type: GameConstants.StatusEffectType) -> StatusEffect:
	for effect in active_effects:
		if effect.effect_type == type:
			return effect
	return null

## 检查是否有某种状态
func has_effect(type: GameConstants.StatusEffectType) -> bool:
	return _find_effect(type) != null

## 移除某种状态
func remove_effect(type: GameConstants.StatusEffectType):
	for i in range(active_effects.size() - 1, -1, -1):
		if active_effects[i].effect_type == type:
			active_effects[i].remove_from(enemy)
			active_effects.remove_at(i)

## 清除所有状态
func clear_all_effects():
	for effect in active_effects:
		effect.remove_from(enemy)
	active_effects.clear()

## 公共API：应用各种状态
func apply_slow(percent: float, duration: float):
	var effect = StatusEffect.SlowEffect.new(duration, percent)
	apply_effect(effect)

func apply_burn(damage_per_sec: float, duration: float):
	var effect = StatusEffect.BurnEffect.new(duration, damage_per_sec)
	apply_effect(effect)

func apply_poison(damage_per_sec: float, duration: float):
	var effect = StatusEffect.PoisonEffect.new(duration, damage_per_sec)
	apply_effect(effect)

func apply_freeze(duration: float):
	var effect = StatusEffect.FreezeEffect.new(duration)
	apply_effect(effect)
