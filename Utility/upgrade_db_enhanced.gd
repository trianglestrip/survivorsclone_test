extends Node

# 增强的升级数据库 - 支持效果系统

var UPGRADES = {}

const _DEFAULT_UPGRADES = {
	"icespear1": {
		"icon": "Gem_blue",
		"displayname": "冰矛",
		"details": "伤害 10%，每 0.4s 发射一次。",
		"level": 1,
		"prerequisite": [],
		"type": "weapon",
	},
}

func _init():
	_load_upgrade_config()

func _load_upgrade_config():
	var cfg = ConfigFile.new()
	var load_result = cfg.load("res://config/upgrade_config.ini")
	
	if load_result != OK:
		push_warning("无法加载 upgrade_config.ini，使用默认配置 (错误代码: %d)" % load_result)
		UPGRADES = _DEFAULT_UPGRADES
		return

	for section in cfg.get_sections():
		var prerequisite_text = cfg.get_value(section, "prerequisite", "")
		var prerequisites = []
		if prerequisite_text != "":
			prerequisites = prerequisite_text.split(",", false)
		
		# 基础数据
		var upgrade_data = {
			"icon": cfg.get_value(section, "icon", ""),
			"displayname": cfg.get_value(section, "displayname", ""),
			"details": cfg.get_value(section, "details", ""),
			"level": cfg.get_value(section, "level", ""),
			"prerequisite": prerequisites,
			"type": cfg.get_value(section, "type", ""),
		}
		
		# 解析效果配置并转换为效果描述
		var effects = _parse_effects_from_config(cfg, section)
		if effects.size() > 0:
			upgrade_data["effects"] = effects
		
		UPGRADES[section] = upgrade_data

# 从配置中解析效果
func _parse_effects_from_config(cfg: ConfigFile, section: String) -> Array:
	var effects = []
	
	# 技能相关效果
	if cfg.has_section_key(section, "spell"):
		var spell_id = cfg.get_value(section, "spell")
		
		if cfg.has_section_key(section, "set_level"):
			effects.append({
				"type": "skill_unlock",
				"skill_id": spell_id,
				"level": cfg.get_value(section, "set_level")
			})
		
		if cfg.has_section_key(section, "add_baseammo"):
			effects.append({
				"type": "skill_ammo",
				"skill_id": spell_id,
				"amount": cfg.get_value(section, "add_baseammo")
			})
		
		if cfg.has_section_key(section, "set_ammo"):
			effects.append({
				"type": "skill_set_ammo",
				"skill_id": spell_id,
				"amount": cfg.get_value(section, "set_ammo")
			})
		
		if cfg.has_section_key(section, "set_tornado_attackspeed"):
			effects.append({
				"type": "skill_modifier",
				"skill_id": spell_id,
				"property": "attackspeed",
				"value": cfg.get_value(section, "set_tornado_attackspeed")
			})
	
	# 属性修改效果
	var stat_modifiers = [
		"add_armor",
		"add_movement_speed",
		"add_spell_size",
		"add_spell_cooldown",
		"add_additional_attacks"
	]
	
	for modifier in stat_modifiers:
		if cfg.has_section_key(section, modifier):
			var stat_name = modifier.replace("add_", "")
			effects.append({
				"type": "stat_modifier",
				"stat": stat_name,
				"value": cfg.get_value(section, modifier),
				"operation": "add"
			})
	
	# 治疗效果
	if cfg.has_section_key(section, "heal"):
		effects.append({
			"type": "heal",
			"amount": cfg.get_value(section, "heal")
		})
	
	return effects

# 获取升级的效果列表
func get_upgrade_effects(upgrade_id: String) -> Array:
	if not UPGRADES.has(upgrade_id):
		return []
	
	var upgrade = UPGRADES[upgrade_id]
	if upgrade.has("effects"):
		return upgrade["effects"]
	
	return []
