extends "res://Utility/Effects/base_effect.gd"
class_name StatModifierEffect

# 属性修改效果 - 用于修改玩家或技能的属性

enum ModifierOperation {
	ADD,        # 加法
	MULTIPLY,   # 乘法
	SET         # 设置
}

@export var stat_name: String = ""
@export var modifier_value: float = 0.0
@export var operation: ModifierOperation = ModifierOperation.ADD

func _init(p_stat_name: String = "", p_value: float = 0.0, p_operation: ModifierOperation = ModifierOperation.ADD):
	effect_type = EffectType.STAT_MODIFIER
	stat_name = p_stat_name
	modifier_value = p_value
	operation = p_operation

func apply(target) -> void:
	if stat_name == "" or target == null:
		return
	
	if not target.has(stat_name):
		push_warning("Target does not have stat: %s" % stat_name)
		return
	
	var current_value = target.get(stat_name)
	var new_value = current_value
	
	match operation:
		ModifierOperation.ADD:
			new_value = current_value + modifier_value
		ModifierOperation.MULTIPLY:
			new_value = current_value * modifier_value
		ModifierOperation.SET:
			new_value = modifier_value
	
	target.set(stat_name, new_value)

func get_description() -> String:
	if description != "":
		return description
	
	var op_text = ""
	match operation:
		ModifierOperation.ADD:
			op_text = "+%s" % modifier_value if modifier_value >= 0 else str(modifier_value)
		ModifierOperation.MULTIPLY:
			op_text = "x%s" % modifier_value
		ModifierOperation.SET:
			op_text = "=%s" % modifier_value
	
	return "%s %s" % [stat_name, op_text]
