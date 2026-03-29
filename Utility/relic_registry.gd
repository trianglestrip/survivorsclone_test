extends Node

## 圣物注册表
## 管理所有圣物配置和圣物效果
## 
## 设计原则：
## 1. 从JSON配置加载所有圣物数据
## 2. 提供圣物查询和过滤功能
## 3. 管理玩家拥有的圣物

const GameConstants = preload("res://Utility/game_constants.gd")

var relics: Dictionary = {}
var owned_relics: Array = []

func _ready():
	_load_relic_config()

func _load_relic_config():
	var config_path = "res://config/relic_config.json"
	var file = FileAccess.open(config_path, FileAccess.READ)
	
	if not file:
		push_error("无法加载圣物配置: " + config_path)
		return
	
	var json_text = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_text)
	
	if parse_result != OK:
		push_error("圣物配置JSON解析失败")
		return
	
	var config = json.get_data()
	
	if config.has("relics"):
		relics = config["relics"]
		print("[RelicRegistry] 加载了 %d 个圣物配置" % relics.size())

## 获取圣物配置
func get_relic(relic_id: String) -> Dictionary:
	if relics.has(relic_id):
		return relics[relic_id]
	return {}

## 添加圣物
func add_relic(relic_id: String) -> bool:
	if not relics.has(relic_id):
		push_warning("圣物不存在: " + relic_id)
		return false
	
	if owned_relics.has(relic_id):
		push_warning("圣物已拥有: " + relic_id)
		return false
	
	owned_relics.append(relic_id)
	print("[RelicRegistry] 获得圣物: ", relics[relic_id].get("name", relic_id))
	return true

## 获取已拥有圣物列表
func get_owned_relics() -> Array:
	var result = []
	for relic_id in owned_relics:
		if relics.has(relic_id):
			result.append(relics[relic_id])
	return result

## 检查是否拥有圣物
func has_relic(relic_id: String) -> bool:
	return owned_relics.has(relic_id)

## 获取圣物效果
func get_relic_effect(relic_id: String, effect_type: String) -> Dictionary:
	var relic = get_relic(relic_id)
	if relic.is_empty():
		return {}
	
	var effects = relic.get("effects", {})
	if effects.has(effect_type):
		return effects[effect_type]
	return {}

## 计算所有圣物的属性加成
func calculate_stat_bonuses() -> Dictionary:
	var bonuses = {
		"max_hp": 0,
		"move_speed": 0,
		"attack_damage": 0,
		"melee_damage": 0,
		"skill_damage": 0,
		"attack_speed": 0,
		"cooldown_reduction": 0,
		"defense": 0,
		"critical_chance": 0,
		"critical_damage": 0,
		"lifesteal": 0,
		"fire_damage": 0,
		"ice_damage": 0,
		"thunder_damage": 0,
		"poison_damage": 0
	}
	
	for relic_id in owned_relics:
		var relic = get_relic(relic_id)
		if relic.is_empty():
			continue
		
		var effects = relic.get("effects", {})
		
		# 遍历所有效果类型（core, power, agility, utility）
		for effect_type in effects.keys():
			var effect = effects[effect_type]
			if effect.get("type", "") == "stat_bonus":
				# 累加属性加成
				for stat_key in effect.keys():
					if stat_key != "type" and bonuses.has(stat_key):
						bonuses[stat_key] += effect[stat_key]
	
	return bonuses

## 获取特定类型的圣物
func get_relics_by_rarity(rarity: String) -> Array:
	var result = []
	for relic_id in relics.keys():
		var relic = relics[relic_id]
		if relic.get("rarity", "") == rarity:
			result.append(relic)
	return result
