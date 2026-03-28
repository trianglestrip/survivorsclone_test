extends Node
class_name UpgradeManager

# 升级管理器 - 管理玩家的升级和道具收集

var collected_upgrades: Array = []
var upgrade_options: Array = []

var player_stats = null
var skill_manager = null

signal upgrade_applied(upgrade_id: String)

func set_player_stats(stats):
	player_stats = stats

func set_skill_manager(manager):
	skill_manager = manager

# 应用升级
func apply_upgrade(upgrade_id: String):
	var upgrade_db = get_node_or_null("/root/UpgradeDb")
	if upgrade_db == null:
		push_error("UpgradeDb 未找到")
		return
	
	var config = upgrade_db.UPGRADES.get(upgrade_id, null)
	if config == null:
		push_warning("升级不存在: %s" % upgrade_id)
		return
	
	_apply_upgrade_effects(upgrade_id, config)
	
	collected_upgrades.append(upgrade_id)
	emit_signal("upgrade_applied", upgrade_id)
	if has_node("/root/EventBus"):
		get_node("/root/EventBus").emit_upgrade_collected(upgrade_id)

# 应用升级效果
func _apply_upgrade_effects(_upgrade_id: String, config: Dictionary):
	if player_stats == null or skill_manager == null:
		return
	
	# 处理技能相关升级
	if config.has("spell"):
		var spell_id = config["spell"]
		
		# 设置技能等级
		if config.has("set_level"):
			skill_manager.set_skill_level(spell_id.to_lower(), config["set_level"])
		
		# 添加基础弹药
		if config.has("add_baseammo"):
			skill_manager.add_skill_ammo(spell_id.to_lower(), config["add_baseammo"])
		
		# 设置弹药（Javelin 特殊）
		if config.has("set_ammo"):
			skill_manager.set_skill_ammo(spell_id.to_lower(), config["set_ammo"])
		
		# 设置技能攻击速度（Tornado 特殊）
		if config.has("set_tornado_attackspeed"):
			skill_manager.set_skill_attack_speed("tornado", config["set_tornado_attackspeed"])
	
	# 处理属性升级
	if config.has("add_armor"):
		player_stats.armor += config["add_armor"]
	
	if config.has("add_movement_speed"):
		player_stats.speed_bonus += config["add_movement_speed"]
	
	if config.has("add_spell_size"):
		player_stats.spell_size += config["add_spell_size"]
	
	if config.has("add_spell_cooldown"):
		player_stats.spell_cooldown += config["add_spell_cooldown"]
	
	if config.has("add_additional_attacks"):
		player_stats.additional_attacks += config["add_additional_attacks"]
	
	# 处理治疗
	if config.has("heal"):
		var healed = player_stats.heal(config["heal"])
		if healed > 0 and has_node("/root/EventBus"):
			get_node("/root/EventBus").emit_signal("player_healed", healed, player_stats.hp)

# 获取随机升级选项
func get_random_upgrade() -> String:
	var upgrade_db = get_node_or_null("/root/UpgradeDb")
	if upgrade_db == null:
		return ""
	
	var dblist = []
	
	for upgrade_id in upgrade_db.UPGRADES:
		# 跳过已收集的升级
		if upgrade_id in collected_upgrades:
			continue
		
		# 跳过已经在选项中的升级
		if upgrade_id in upgrade_options:
			continue
		
		var upgrade_data = upgrade_db.UPGRADES[upgrade_id]
		
		# 跳过食物类道具
		if upgrade_data.get("type", "") == "item":
			continue
		
		# 检查前置条件
		var prerequisites = upgrade_data.get("prerequisite", [])
		if prerequisites.size() > 0:
			var can_add = true
			for prereq in prerequisites:
				if not prereq in collected_upgrades:
					can_add = false
					break
			if can_add:
				dblist.append(upgrade_id)
		else:
			dblist.append(upgrade_id)
	
	if dblist.size() > 0:
		var random_upgrade = dblist.pick_random()
		upgrade_options.append(random_upgrade)
		return random_upgrade
	
	return ""

# 清除升级选项
func clear_upgrade_options():
	upgrade_options.clear()

# 检查升级是否已收集
func has_upgrade(upgrade_id: String) -> bool:
	return upgrade_id in collected_upgrades

# 获取所有已收集的升级
func get_collected_upgrades() -> Array:
	return collected_upgrades.duplicate()
