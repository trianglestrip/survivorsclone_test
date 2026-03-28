extends "res://Utility/Effects/base_effect.gd"
class_name SkillModifierEffect

# 技能修改效果 - 用于修改特定技能的属性

@export var skill_id: String = ""
@export var property_name: String = ""
@export var modifier_value: float = 0.0

func _init(p_skill_id: String = "", p_property: String = "", p_value: float = 0.0):
	effect_type = EffectType.SKILL_MODIFIER
	skill_id = p_skill_id
	property_name = p_property
	modifier_value = p_value

func apply(target) -> void:
	if skill_id == "" or property_name == "" or target == null:
		return
	
	# 构建变量名：skill_property
	var var_name = "%s_%s" % [skill_id.to_lower(), property_name]
	
	if target.has(var_name):
		target.set(var_name, modifier_value)
	else:
		push_warning("Target does not have property: %s" % var_name)

func get_description() -> String:
	if description != "":
		return description
	
	return "修改 %s 的 %s 为 %s" % [skill_id, property_name, modifier_value]
