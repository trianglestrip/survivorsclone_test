extends Node
class_name UpgradeManagerV2

# 升级管理器 V2 - 使用效果系统

var collected_upgrades: Array = []
var upgrade_options: Array = []

var player_stats = null
var skill_manager = null
var player_node = null

signal upgrade_applied(upgrade_id: String)

func set_player_stats(stats):
	player_stats = stats

func set_skill_manager(manager):
	skill_manager = manager

func set_player_node(player):
	player_node = player

# 应用升级（使用效果系统）
func apply_upgrade(upgrade_id: String):
	var upgrade_db = get_node_or_null("/root/UpgradeDb")
	if upgrade_db == null:
		push_error("UpgradeDb 未找到")
		return
	
	var config = upgrade_db.UPGRADES.get(upgrade_id, null)
	if config == null:
		push_warning("升级不存在: %s" % upgrade_id)
		return
	
	# 使用效果系统应用升级
	if upgrade_db.has_method("get_upgrade_effects"):
		var effects = upgrade_db.get_upgrade_effects(upgrade_id)
		_apply_effects(effects)
	else:
		# 回退到传统方式
		_apply_upgrade_effects_legacy(upgrade_id, config)
	
	collected_upgrades.append(upgrade_id)
	emit_signal("upgrade_applied", upgrade_id)
	if has_node("/root/EventBus"):
		get_node("/root/EventBus").emit_upgrade_collected(upgrade_id)

# 应用效果列表
func _apply_effects(effects: Array):
	for effect_data in effects:
		_apply_single_effect(effect_data)

# 应用单个效果
func _apply_single_effect(effect_data: Dictionary):
	var effect_type = effect_data.get("type", "")
	
	match effect_type:
		"skill_unlock":
			_apply_skill_unlock(effect_data)
		"skill_ammo":
			_apply_skill_ammo(effect_data)
		"skill_set_ammo":
			_apply_skill_set_ammo(effect_data)
		"skill_modifier":
			_apply_skill_modifier(effect_data)
		"stat_modifier":
			_apply_stat_modifier(effect_data)
		"heal":
			_apply_heal(effect_data)

func _apply_skill_unlock(data: Dictionary):
	if skill_manager == null:
		return
	
	var skill_id = data.get("skill_id", "").to_lower()
	var level = data.get("level", 1)
	skill_manager.set_skill_level(skill_id, level)

func _apply_skill_ammo(data: Dictionary):
	if skill_manager == null:
		return
	
	var skill_id = data.get("skill_id", "").to_lower()
	var amount = data.get("amount", 0)
	skill_manager.add_skill_ammo(skill_id, amount)

func _apply_skill_set_ammo(data: Dictionary):
	if skill_manager == null:
		return
	
	var skill_id = data.get("skill_id", "").to_lower()
	var amount = data.get("amount", 0)
	skill_manager.set_skill_ammo(skill_id, amount)

func _apply_skill_modifier(data: Dictionary):
	if skill_manager == null:
		return
	
	var skill_id = data.get("skill_id", "").to_lower()
	var property = data.get("property", "")
	var value = data.get("value", 0)
	skill_manager.set_skill_attack_speed(skill_id, value)

func _apply_stat_modifier(data: Dictionary):
	if player_stats == null:
		return
	
	var stat_name = data.get("stat", "")
	var value = data.get("value", 0)
	var operation = data.get("operation", "add")
	
	# 映射配置中的属性名到实际属性名
	var stat_mapping = {
		"armor": "armor",
		"movement_speed": "speed_bonus",
		"spell_size": "spell_size",
		"spell_cooldown": "spell_cooldown",
		"additional_attacks": "additional_attacks"
	}
	
	var actual_stat = stat_mapping.get(stat_name, stat_name)
	
	if operation == "add":
		var current = player_stats.get(actual_stat)
		player_stats.set(actual_stat, current + value)

func _apply_heal(data: Dictionary):
	if player_stats == null:
		return
	
	var amount = data.get("amount", 0)
	var healed = player_stats.heal(amount)
	
	if healed > 0 and has_node("/root/EventBus"):
		get_node("/root/EventBus").emit_signal("player_healed", healed, player_stats.hp)

# 传统方式应用效果（向后兼容）
func _apply_upgrade_effects_legacy(upgrade_id: String, config: Dictionary):
	if player_stats == null or skill_manager == null:
		return
	
	# 处理技能相关升级
	if config.has("spell"):
		var spell_id = config["spell"]
		
		if config.has("set_level"):
			skill_manager.set_skill_level(spell_id.to_lower(), config["set_level"])
		
		if config.has("add_baseammo"):
			skill_manager.add_skill_ammo(spell_id.to_lower(), config["add_baseammo"])
		
		if config.has("set_ammo"):
			skill_manager.set_skill_ammo(spell_id.to_lower(), config["set_ammo"])
		
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
		
		# 跳过食物类道具
		if upgrade_db.UPGRADES[upgrade_id]["type"] == "item":
			continue
		
		# 检查前置条件
		var prerequisites = upgrade_db.UPGRADES[upgrade_id]["prerequisite"]
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
