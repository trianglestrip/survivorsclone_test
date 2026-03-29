extends Node
class_name EffectFactory

## 效果工厂 - 从升级配置创建 Effect 对象

## 从配置字典创建 Effect 数组
func create_effects_from_config(config: Dictionary) -> Array[BaseEffect]:
	var effects: Array[BaseEffect] = []
	
	# 技能相关效果
	if config.has("spell"):
		var spell_id = config["spell"]
		
		# 技能解锁效果
		if config.has("set_level"):
			var ammo = config.get("add_baseammo", 0)
			var effect = SkillUnlockEffect.new(spell_id.to_lower(), config["set_level"], ammo)
			effects.append(effect)
		
		# 技能特殊修改效果
		if config.has("set_tornado_attackspeed"):
			var effect = SkillModifierEffect.new("tornado", "attackspeed", config["set_tornado_attackspeed"])
			effects.append(effect)
	
	# 属性修改效果
	var stat_modifiers = [
		{ "config_key": "add_armor", "stat_name": "armor" },
		{ "config_key": "add_movement_speed", "stat_name": "speed_bonus" },
		{ "config_key": "add_spell_size", "stat_name": "spell_size" },
		{ "config_key": "add_spell_cooldown", "stat_name": "spell_cooldown" },
		{ "config_key": "add_additional_attacks", "stat_name": "additional_attacks" }
	]
	
	for modifier in stat_modifiers:
		if config.has(modifier.config_key):
			var effect = StatModifierEffect.new(
				modifier.stat_name,
				config[modifier.config_key],
				StatModifierEffect.ModifierOperation.ADD
			)
			effects.append(effect)
	
	# 治疗效果
	if config.has("heal"):
		var effect = HealEffect.new(config["heal"])
		effects.append(effect)
	
	return effects

## 应用多个效果到目标
func apply_effects(effects: Array[BaseEffect], stats_target, skill_target):
	for effect in effects:
		match effect.effect_type:
			BaseEffect.EffectType.STAT_MODIFIER:
				effect.apply(stats_target)
			BaseEffect.EffectType.SKILL_UNLOCK:
				_apply_skill_unlock_effect(effect, skill_target)
			BaseEffect.EffectType.SKILL_MODIFIER:
				_apply_skill_modifier_effect(effect, skill_target)
			BaseEffect.EffectType.HEAL:
				effect.apply(stats_target)
			_:
				effect.apply(stats_target)

## 特殊处理技能解锁效果（因为需要 SkillInstanceManager 接口）
func _apply_skill_unlock_effect(effect: SkillUnlockEffect, skill_target):
	if skill_target == null:
		return
	
	skill_target.set_skill_level(effect.skill_id, effect.skill_level)
	
	if effect.ammo_to_add > 0:
		skill_target.add_skill_ammo(effect.skill_id, effect.ammo_to_add)

## 特殊处理技能修改效果
func _apply_skill_modifier_effect(effect: SkillModifierEffect, skill_target):
	if skill_target == null:
		return
	
	match effect.property_name:
		"attackspeed":
			skill_target.set_skill_attack_speed(effect.skill_id, effect.modifier_value)
