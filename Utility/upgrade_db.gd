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
		UPGRADES[section] = {
			"icon": cfg.get_value(section, "icon", ""),
			"displayname": cfg.get_value(section, "displayname", ""),
			"details": cfg.get_value(section, "details", ""),
			"level": cfg.get_value(section, "level", ""),
			"prerequisite": prerequisites,
			"type": cfg.get_value(section, "type", ""),
		}
