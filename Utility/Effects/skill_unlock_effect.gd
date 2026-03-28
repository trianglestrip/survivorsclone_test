extends "res://Utility/Effects/base_effect.gd"
class_name SkillUnlockEffect

# 技能解锁效果 - 用于解锁或升级技能

@export var skill_id: String = ""
@export var skill_level: int = 1
@export var ammo_to_add: int = 0

func _init(p_skill_id: String = "", p_level: int = 1, p_ammo: int = 0):
	effect_type = EffectType.SKILL_UNLOCK
	skill_id = p_skill_id
	skill_level = p_level
	ammo_to_add = p_ammo

func apply(target) -> void:
	if skill_id == "" or target == null:
		return
	
	# 根据技能 ID 设置对应的等级和弹药
	var level_var = "%s_level" % skill_id.to_lower()
	var ammo_var = "%s_baseammo" % skill_id.to_lower()
	
	if target.has(level_var):
		target.set(level_var, skill_level)
	
	if ammo_to_add > 0 and target.has(ammo_var):
		var current_ammo = target.get(ammo_var)
		target.set(ammo_var, current_ammo + ammo_to_add)

func get_description() -> String:
	if description != "":
		return description
	
	return "解锁技能: %s (等级 %d)" % [skill_id, skill_level]
