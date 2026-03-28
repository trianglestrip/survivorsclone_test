extends "res://Utility/Effects/base_effect.gd"
class_name HealEffect

# 治疗效果 - 用于恢复玩家生命值

@export var heal_amount: int = 0

func _init(p_amount: int = 0):
	effect_type = EffectType.HEAL
	heal_amount = p_amount

func apply(target) -> void:
	if target == null or not target.has("hp") or not target.has("maxhp"):
		return
	
	var old_hp = target.hp
	target.hp += heal_amount
	target.hp = clamp(target.hp, 0, target.maxhp)
	
	var actual_heal = target.hp - old_hp
	
	# 发送治疗事件
	if actual_heal > 0 and target.has_signal("player_healed"):
		target.emit_signal("player_healed", actual_heal, target.hp)

func get_description() -> String:
	if description != "":
		return description
	
	return "恢复 %d 点生命值" % heal_amount
