extends Node

var UPGRADES = {}

const _DEFAULT_UPGRADES = {
	# 冰矛系列
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
	"icespear2": {
		"icon": "res://Textures/Items/Weapons/ice_spear.png",
		"displayname": "冰矛",
		"details": "额外投掷一支冰矛",
		"level": "等级：2",
		"prerequisite": ["icespear1"],
		"type": "weapon",
		"spell": "IceSpear",
		"set_level": 2,
		"add_baseammo": 1,
	},
	"icespear3": {
		"icon": "res://Textures/Items/Weapons/ice_spear.png",
		"displayname": "冰矛",
		"details": "冰矛穿透并造成额外伤害",
		"level": "等级：3",
		"prerequisite": ["icespear2"],
		"type": "weapon",
		"spell": "IceSpear",
		"set_level": 3,
	},
	"icespear4": {
		"icon": "res://Textures/Items/Weapons/ice_spear.png",
		"displayname": "冰矛",
		"details": "额外投掷两支冰矛",
		"level": "等级：4",
		"prerequisite": ["icespear3"],
		"type": "weapon",
		"spell": "IceSpear",
		"set_level": 4,
		"add_baseammo": 2,
	},
	
	# 龙卷风系列
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
	"tornado2": {
		"icon": "res://Textures/Items/Weapons/tornado.png",
		"displayname": "龙卷风",
		"details": "生成额外的龙卷风",
		"level": "等级：2",
		"prerequisite": ["tornado1"],
		"type": "weapon",
		"spell": "Tornado",
		"set_level": 2,
		"add_baseammo": 1,
	},
	"tornado3": {
		"icon": "res://Textures/Items/Weapons/tornado.png",
		"displayname": "龙卷风",
		"details": "龙卷风冷却减少",
		"level": "等级：3",
		"prerequisite": ["tornado2"],
		"type": "weapon",
		"spell": "Tornado",
		"set_level": 3,
		"set_tornado_attackspeed": 2.5,
	},
	"tornado4": {
		"icon": "res://Textures/Items/Weapons/tornado.png",
		"displayname": "龙卷风",
		"details": "生成额外龙卷风",
		"level": "等级：4",
		"prerequisite": ["tornado3"],
		"type": "weapon",
		"spell": "Tornado",
		"set_level": 4,
		"add_baseammo": 1,
	},
	
	# 标枪系列
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
	"javelin2": {
		"icon": "res://Textures/Items/Weapons/javelin_3_new_attack.png",
		"displayname": "标枪",
		"details": "额外攻击一个敌人",
		"level": "等级：2",
		"prerequisite": ["javelin1"],
		"type": "weapon",
		"spell": "Javelin",
		"set_level": 2,
	},
	"javelin3": {
		"icon": "res://Textures/Items/Weapons/javelin_3_new_attack.png",
		"displayname": "标枪",
		"details": "再额外攻击一个敌人",
		"level": "等级：3",
		"prerequisite": ["javelin2"],
		"type": "weapon",
		"spell": "Javelin",
		"set_level": 3,
	},
	"javelin4": {
		"icon": "res://Textures/Items/Weapons/javelin_3_new_attack.png",
		"displayname": "标枪",
		"details": "额外伤害和击退",
		"level": "等级：4",
		"prerequisite": ["javelin3"],
		"type": "weapon",
		"spell": "Javelin",
		"set_level": 4,
	},
	
	# 护甲系列
	"armor1": {
		"icon": "res://Textures/Items/Upgrades/helmet_1.png",
		"displayname": "护甲",
		"details": "减少1点伤害",
		"level": "等级：1",
		"prerequisite": [],
		"type": "upgrade",
		"add_armor": 1,
	},
	"armor2": {
		"icon": "res://Textures/Items/Upgrades/helmet_1.png",
		"displayname": "护甲",
		"details": "额外减少1点伤害",
		"level": "等级：2",
		"prerequisite": ["armor1"],
		"type": "upgrade",
		"add_armor": 1,
	},
	"armor3": {
		"icon": "res://Textures/Items/Upgrades/helmet_1.png",
		"displayname": "护甲",
		"details": "额外减少1点伤害",
		"level": "等级：3",
		"prerequisite": ["armor2"],
		"type": "upgrade",
		"add_armor": 1,
	},
	"armor4": {
		"icon": "res://Textures/Items/Upgrades/helmet_1.png",
		"displayname": "护甲",
		"details": "额外减少1点伤害",
		"level": "等级：4",
		"prerequisite": ["armor3"],
		"type": "upgrade",
		"add_armor": 1,
	},
	
	# 速度系列
	"speed1": {
		"icon": "res://Textures/Items/Upgrades/boots_4_green.png",
		"displayname": "速度",
		"details": "移动速度提升50%",
		"level": "等级：1",
		"prerequisite": [],
		"type": "upgrade",
		"add_movement_speed": 20.0,
	},
	"speed2": {
		"icon": "res://Textures/Items/Upgrades/boots_4_green.png",
		"displayname": "速度",
		"details": "移动速度额外提升50%",
		"level": "等级：2",
		"prerequisite": ["speed1"],
		"type": "upgrade",
		"add_movement_speed": 20.0,
	},
	"speed3": {
		"icon": "res://Textures/Items/Upgrades/boots_4_green.png",
		"displayname": "速度",
		"details": "移动速度额外提升50%",
		"level": "等级：3",
		"prerequisite": ["speed2"],
		"type": "upgrade",
		"add_movement_speed": 20.0,
	},
	"speed4": {
		"icon": "res://Textures/Items/Upgrades/boots_4_green.png",
		"displayname": "速度",
		"details": "移动速度额外提升50%",
		"level": "等级：4",
		"prerequisite": ["speed3"],
		"type": "upgrade",
		"add_movement_speed": 20.0,
	},
	
	# 法典系列
	"tome1": {
		"icon": "res://Textures/Items/Upgrades/thick_new.png",
		"displayname": "法典",
		"details": "法术大小增加10%",
		"level": "等级：1",
		"prerequisite": [],
		"type": "upgrade",
		"add_spell_size": 0.10,
	},
	"tome2": {
		"icon": "res://Textures/Items/Upgrades/thick_new.png",
		"displayname": "法典",
		"details": "法术大小额外增加10%",
		"level": "等级：2",
		"prerequisite": ["tome1"],
		"type": "upgrade",
		"add_spell_size": 0.10,
	},
	"tome3": {
		"icon": "res://Textures/Items/Upgrades/thick_new.png",
		"displayname": "法典",
		"details": "法术大小额外增加10%",
		"level": "等级：3",
		"prerequisite": ["tome2"],
		"type": "upgrade",
		"add_spell_size": 0.10,
	},
	"tome4": {
		"icon": "res://Textures/Items/Upgrades/thick_new.png",
		"displayname": "法典",
		"details": "法术大小额外增加10%",
		"level": "等级：4",
		"prerequisite": ["tome3"],
		"type": "upgrade",
		"add_spell_size": 0.10,
	},
	
	# 卷轴系列
	"scroll1": {
		"icon": "res://Textures/Items/Upgrades/scroll_old.png",
		"displayname": "卷轴",
		"details": "法术冷却减少5%",
		"level": "等级：1",
		"prerequisite": [],
		"type": "upgrade",
		"add_spell_cooldown": 0.05,
	},
	"scroll2": {
		"icon": "res://Textures/Items/Upgrades/scroll_old.png",
		"displayname": "卷轴",
		"details": "法术冷却额外减少5%",
		"level": "等级：2",
		"prerequisite": ["scroll1"],
		"type": "upgrade",
		"add_spell_cooldown": 0.05,
	},
	"scroll3": {
		"icon": "res://Textures/Items/Upgrades/scroll_old.png",
		"displayname": "卷轴",
		"details": "法术冷却额外减少5%",
		"level": "等级：3",
		"prerequisite": ["scroll2"],
		"type": "upgrade",
		"add_spell_cooldown": 0.05,
	},
	"scroll4": {
		"icon": "res://Textures/Items/Upgrades/scroll_old.png",
		"displayname": "卷轴",
		"details": "法术冷却额外减少5%",
		"level": "等级：4",
		"prerequisite": ["scroll3"],
		"type": "upgrade",
		"add_spell_cooldown": 0.05,
	},
	
	# 戒指系列
	"ring1": {
		"icon": "res://Textures/Items/Upgrades/urand_mage.png",
		"displayname": "戒指",
		"details": "法术额外生成1次攻击",
		"level": "等级：1",
		"prerequisite": [],
		"type": "upgrade",
		"add_additional_attacks": 1,
	},
	"ring2": {
		"icon": "res://Textures/Items/Upgrades/urand_mage.png",
		"displayname": "戒指",
		"details": "法术再额外生成1次攻击",
		"level": "等级：2",
		"prerequisite": ["ring1"],
		"type": "upgrade",
		"add_additional_attacks": 1,
	},
	
	# 道具
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
