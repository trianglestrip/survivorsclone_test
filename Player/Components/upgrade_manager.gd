extends Node
class_name UpgradeManager

# 升级管理器 - 管理玩家的升级和道具收集

var collected_upgrades: Array = []
var upgrade_options: Array = []

var player_stats = null
var skill_manager = null

# Effect 工厂
var effect_factory = null

signal upgrade_applied(upgrade_id: String)

func _ready():
	# 初始化 Effect 工厂
	var EffectFactory = preload("res://Utility/Effects/effect_factory.gd")
	effect_factory = EffectFactory.new()

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

# 应用升级效果（使用 Effect 系统）
func _apply_upgrade_effects(_upgrade_id: String, config: Dictionary):
	if player_stats == null or skill_manager == null or effect_factory == null:
		return
	
	# 从配置创建 Effect 对象
	var effects = effect_factory.create_effects_from_config(config)
	
	# 应用所有效果
	effect_factory.apply_effects(effects, player_stats, skill_manager)

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
