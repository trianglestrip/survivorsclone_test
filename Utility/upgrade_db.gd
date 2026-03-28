extends Node

var UPGRADES = {}

func _init():
	_load_upgrade_config()

func _load_upgrade_config():
	var cfg = ConfigFile.new()
	if cfg.load("res://config/upgrade_config.ini") != OK:
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
