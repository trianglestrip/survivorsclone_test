extends Resource
class_name BaseEffect

# 效果基类 - 所有升级效果的基础

# 效果类型
enum EffectType {
	STAT_MODIFIER,      # 属性修改
	SKILL_UNLOCK,       # 技能解锁
	SKILL_MODIFIER,     # 技能修改
	HEAL,               # 治疗
	CUSTOM              # 自定义效果
}

@export var effect_type: EffectType = EffectType.CUSTOM
@export var description: String = ""

# 应用效果到目标
func apply(target) -> void:
	push_warning("BaseEffect.apply() should be overridden in subclass")

# 移除效果（用于临时效果）
func remove(target) -> void:
	pass

# 获取效果描述
func get_description() -> String:
	return description
