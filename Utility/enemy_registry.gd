extends Node

## 敌人注册表
## 管理所有敌人配置和生成波次
## 
## 设计原则：
## 1. 从JSON配置加载所有敌人数据
## 2. 提供敌人配置查询功能
## 3. 管理敌人生成波次

const GameConstants = preload("res://Utility/game_constants.gd")

var enemies: Dictionary = {}
var spawn_waves: Array = []

func _ready():
	_load_enemy_config()

func _load_enemy_config():
	var config_path = "res://config/enemy_config.json"
	var file = FileAccess.open(config_path, FileAccess.READ)
	
	if not file:
		push_error("无法加载敌人配置: " + config_path)
		return
	
	var json_text = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_text)
	
	if parse_result != OK:
		push_error("敌人配置JSON解析失败")
		return
	
	var config = json.get_data()
	
	if config.has("enemies"):
		enemies = config["enemies"]
		print("[EnemyRegistry] 加载了 %d 个敌人配置" % enemies.size())
	
	if config.has("spawn_waves"):
		spawn_waves = config["spawn_waves"]
		print("[EnemyRegistry] 加载了 %d 个生成波次" % spawn_waves.size())

## 获取敌人配置
func get_enemy(enemy_id: String) -> Dictionary:
	if enemies.has(enemy_id):
		return enemies[enemy_id]
	return {}

## 获取波次配置
func get_wave(wave_number: int) -> Dictionary:
	for wave in spawn_waves:
		if wave.get("wave", 0) == wave_number:
			return wave
	return {}

## 根据权重随机选择敌人
func get_random_enemy_from_wave(wave_number: int) -> String:
	var wave = get_wave(wave_number)
	if wave.is_empty():
		return ""
	
	var enemy_list = wave.get("enemies", [])
	if enemy_list.is_empty():
		return ""
	
	# 计算总权重
	var total_weight = 0
	for enemy_entry in enemy_list:
		total_weight += enemy_entry.get("weight", 1)
	
	# 随机选择
	var random_value = randf() * total_weight
	var accumulated_weight = 0.0
	
	for enemy_entry in enemy_list:
		accumulated_weight += enemy_entry.get("weight", 1)
		if random_value <= accumulated_weight:
			return enemy_entry.get("id", "")
	
	return enemy_list[0].get("id", "")

## 获取特定类型的敌人
func get_enemies_by_type(enemy_type: String) -> Array:
	var result = []
	for enemy_id in enemies.keys():
		var enemy = enemies[enemy_id]
		if enemy.get("type", "") == enemy_type:
			result.append(enemy)
	return result

## 获取当前波次应该生成的敌人列表
func get_wave_enemies(wave_number: int) -> Array:
	var wave = get_wave(wave_number)
	if wave.is_empty():
		return []
	
	return wave.get("enemies", [])
