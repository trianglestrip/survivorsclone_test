extends Node

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
	"icespear2": {
		"icon": "Gem_blue",
		"displayname": "冰矛+",
		"details": "伤害 15%，每 0.4s 发射一次。",
		"level": 2,
		"prerequisite": ["icespear1"],
		"type": "weapon",
	},
	"icespear3": {
		"icon": "Gem_blue",
		"displayname": "冰矛++",
		"details": "伤害 20%，每 0.4s 发射一次。",
		"level": 3,
		"prerequisite": ["icespear2"],
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
		UPGRADES[section] = {
			"icon": cfg.get_value(section, "icon", ""),
			"displayname": cfg.get_value(section, "displayname", ""),
			"details": cfg.get_value(section, "details", ""),
			"level": cfg.get_value(section, "level", ""),
			"prerequisite": prerequisites,
			"type": cfg.get_value(section, "type", ""),
		}
