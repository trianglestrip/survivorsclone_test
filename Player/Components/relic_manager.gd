class_name RelicManager
extends Node

## 圣物管理器
## 管理玩家的圣物并应用效果
## 
## 设计原则：
## 1. 与RelicRegistry交互获取圣物数据
## 2. 将圣物效果应用到玩家属性
## 3. 处理特殊圣物效果（如触发类效果）

signal relic_acquired(relic_id: String)
signal relic_effect_triggered(relic_id: String, effect_type: String)

var player: Node = null
var player_stats: Node = null
var relic_registry: Node = null

func set_player(p: Node):
	player = p

func set_player_stats(ps: Node):
	player_stats = ps

func set_relic_registry(rr: Node):
	relic_registry = rr

## 获得圣物
func acquire_relic(relic_id: String):
	if not relic_registry:
		push_warning("[RelicManager] RelicRegistry未设置")
		return
	
	if relic_registry.add_relic(relic_id):
		_apply_relic_effects(relic_id)
		emit_signal("relic_acquired", relic_id)

## 应用圣物效果
func _apply_relic_effects(relic_id: String):
	if not player_stats or not relic_registry:
		return
	
	var relic = relic_registry.get_relic(relic_id)
	if relic.is_empty():
		return
	
	# 重新计算所有圣物的属性加成
	_recalculate_all_bonuses()

## 重新计算所有圣物加成
func _recalculate_all_bonuses():
	if not player_stats or not relic_registry:
		return
	
	var bonuses = relic_registry.calculate_stat_bonuses()
	
	# 应用加成到玩家属性
	if bonuses.has("max_hp") and bonuses["max_hp"] > 0:
		player_stats.maxhp += bonuses["max_hp"]
		player_stats.hp += bonuses["max_hp"]
	
	if bonuses.has("move_speed"):
		player_stats.movement_speed *= (1.0 + bonuses["move_speed"])
	
	# attack_damage不在PlayerStats中，跳过
	# defense也不在PlayerStats中，使用armor代替
	if bonuses.has("defense") and bonuses["defense"] > 0:
		player_stats.armor += int(bonuses["defense"] * 10)
	
	print("[RelicManager] 应用圣物加成: HP+%d, 速度+%.1f%%, 攻击+%.1f%%" % [
		bonuses.get("max_hp", 0),
		bonuses.get("move_speed", 0) * 100,
		bonuses.get("attack_damage", 0) * 100
	])

## 检查触发类效果（在攻击时调用）
func check_trigger_effects(trigger_type: String, context: Dictionary = {}) -> Array:
	if not relic_registry:
		return []
	
	var triggered_effects = []
	
	for relic_id in relic_registry.owned_relics:
		var relic = relic_registry.get_relic(relic_id)
		if relic.is_empty():
			continue
		
		var effects = relic.get("effects", {})
		var core_effect = effects.get("core", {})
		
		# 检查核心效果是否匹配触发类型
		if core_effect.get("trigger", "") == trigger_type:
			var chance = core_effect.get("chance", 1.0)
			if randf() <= chance:
				triggered_effects.append({
					"relic_id": relic_id,
					"effect": core_effect
				})
				emit_signal("relic_effect_triggered", relic_id, trigger_type)
	
	return triggered_effects

## 获取所有拥有的圣物
func get_owned_relics() -> Array:
	if relic_registry:
		return relic_registry.get_owned_relics()
	return []
