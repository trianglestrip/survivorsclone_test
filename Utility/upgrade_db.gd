extends Node

var UPGRADES = {}

const _DEFAULT_UPGRADES = {
	"icespear1": {
		"icon": "res://Textures/Items/Weapons/ice_spear.png",
		"displayname": "冰矛",
		"details": "向随机敌人投掷冰矛",
		"level": "等级：1",
		"prerequisite": [],
		"type": "weapon",
		"spell": "IceSpear",
		"set_level": 1,
		"add_baseammo": 1,
	},
	"tornado1": {
		"icon": "res://Textures/Items/Weapons/tornado.png",
		"displayname": "龙卷风",
		"details": "召唤一个龙卷风",
		"level": "等级：1",
		"prerequisite": [],
		"type": "weapon",
		"spell": "Tornado",
		"set_level": 1,
		"add_baseammo": 1,
	},
	"javelin1": {
		"icon": "res://Textures/Items/Weapons/javelin_3_new_attack.png",
		"displayname": "标枪",
		"details": "围绕玩家旋转的标枪",
		"level": "等级：1",
		"prerequisite": [],
		"type": "weapon",
		"spell": "Javelin",
		"set_level": 1,
		"set_ammo": 1,
	},
	"armor1": {
		"icon": "res://Textures/Items/Upgrades/helmet_1.png",
		"displayname": "护甲",
		"details": "减少1点伤害",
		"level": "等级：1",
		"prerequisite": [],
		"type": "upgrade",
		"add_armor": 1,
	},
	"speed1": {
		"icon": "res://Textures/Items/Upgrades/boots_4_green.png",
		"displayname": "速度",
		"details": "移动速度提升50%",
		"level": "等级：1",
		"prerequisite": [],
		"type": "upgrade",
		"add_movement_speed": 20.0,
	},
	"tome1": {
		"icon": "res://Textures/Items/Upgrades/thick_new.png",
		"displayname": "法典",
		"details": "法术大小增加10%",
		"level": "等级：1",
		"prerequisite": [],
		"type": "upgrade",
		"add_spell_size": 0.10,
	},
	"food": {
		"icon": "res://Textures/Items/Upgrades/chunk.png",
		"displayname": "食物",
		"details": "恢复20点生命值",
		"level": "无",
		"prerequisite": [],
		"type": "item",
		"heal": 20,
	},
}

func _ready():
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
		
		# 基础字段
		var upgrade_data = {
			"icon": cfg.get_value(section, "icon", ""),
			"displayname": cfg.get_value(section, "displayname", ""),
			"details": cfg.get_value(section, "details", ""),
			"level": cfg.get_value(section, "level", ""),
			"prerequisite": prerequisites,
			"type": cfg.get_value(section, "type", ""),
		}
		
		# 技能相关字段
		if cfg.has_section_key(section, "spell"):
			upgrade_data["spell"] = cfg.get_value(section, "spell")
		if cfg.has_section_key(section, "set_level"):
			upgrade_data["set_level"] = cfg.get_value(section, "set_level")
		if cfg.has_section_key(section, "add_baseammo"):
			upgrade_data["add_baseammo"] = cfg.get_value(section, "add_baseammo")
		if cfg.has_section_key(section, "set_ammo"):
			upgrade_data["set_ammo"] = cfg.get_value(section, "set_ammo")
		if cfg.has_section_key(section, "set_tornado_attackspeed"):
			upgrade_data["set_tornado_attackspeed"] = cfg.get_value(section, "set_tornado_attackspeed")
		
		# 属性修改字段
		if cfg.has_section_key(section, "add_armor"):
			upgrade_data["add_armor"] = cfg.get_value(section, "add_armor")
		if cfg.has_section_key(section, "add_movement_speed"):
			upgrade_data["add_movement_speed"] = cfg.get_value(section, "add_movement_speed")
		if cfg.has_section_key(section, "add_spell_size"):
			upgrade_data["add_spell_size"] = cfg.get_value(section, "add_spell_size")
		if cfg.has_section_key(section, "add_spell_cooldown"):
			upgrade_data["add_spell_cooldown"] = cfg.get_value(section, "add_spell_cooldown")
		if cfg.has_section_key(section, "add_additional_attacks"):
			upgrade_data["add_additional_attacks"] = cfg.get_value(section, "add_additional_attacks")
		
		# 治疗字段
		if cfg.has_section_key(section, "heal"):
			upgrade_data["heal"] = cfg.get_value(section, "heal")
		
		UPGRADES[section] = upgrade_data
