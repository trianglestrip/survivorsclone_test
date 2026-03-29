extends Node

## 武器注册表
## 管理所有武器配置和武器切换
## 
## 设计原则：
## 1. 从JSON配置加载所有武器数据
## 2. 提供武器查询和过滤功能
## 3. 管理玩家当前装备的武器

const GameConstants = preload("res://Utility/game_constants.gd")

var weapons: Dictionary = {}
var attack_modes: Dictionary = {}
var current_weapon_id: String = ""
var unlocked_weapons: Array = []

func _ready():
	_load_weapon_config()

func _load_weapon_config():
	var config_path = "res://config/weapon_config.json"
	var file = FileAccess.open(config_path, FileAccess.READ)
	
	if not file:
		push_error("无法加载武器配置: " + config_path)
		return
	
	var json_text = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_text)
	
	if parse_result != OK:
		push_error("武器配置JSON解析失败")
		return
	
	var config = json.get_data()
	
	if config.has("weapons"):
		weapons = config["weapons"]
		print("[WeaponRegistry] 加载了 %d 个武器配置" % weapons.size())
	
	if config.has("attack_modes"):
		attack_modes = config["attack_modes"]
		print("[WeaponRegistry] 加载了 %d 个攻击模式" % attack_modes.size())
	
	# 默认解锁基础武器
	unlocked_weapons.append("sword_basic")
	current_weapon_id = "sword_basic"

## 获取武器配置
func get_weapon(weapon_id: String) -> Dictionary:
	if weapons.has(weapon_id):
		return weapons[weapon_id]
	return {}

## 获取当前武器
func get_current_weapon() -> Dictionary:
	return get_weapon(current_weapon_id)

## 切换武器
func equip_weapon(weapon_id: String) -> bool:
	if not weapons.has(weapon_id):
		push_warning("武器不存在: " + weapon_id)
		return false
	
	if not unlocked_weapons.has(weapon_id):
		push_warning("武器未解锁: " + weapon_id)
		return false
	
	current_weapon_id = weapon_id
	print("[WeaponRegistry] 装备武器: ", weapons[weapon_id].get("name", weapon_id))
	return true

## 解锁武器
func unlock_weapon(weapon_id: String):
	if not weapons.has(weapon_id):
		push_warning("武器不存在: " + weapon_id)
		return
	
	if not unlocked_weapons.has(weapon_id):
		unlocked_weapons.append(weapon_id)
		print("[WeaponRegistry] 解锁武器: ", weapons[weapon_id].get("name", weapon_id))

## 获取宗派专属武器
func get_sect_weapons(sect_id: String) -> Array:
	var sect_weapons = []
	for weapon_id in weapons.keys():
		var weapon = weapons[weapon_id]
		if weapon.get("sect", "") == sect_id:
			sect_weapons.append(weapon)
	return sect_weapons

## 获取已解锁武器列表
func get_unlocked_weapons() -> Array:
	var result = []
	for weapon_id in unlocked_weapons:
		if weapons.has(weapon_id):
			result.append(weapons[weapon_id])
	return result

## 获取攻击模式
func get_attack_mode(mode_id: String) -> Dictionary:
	if attack_modes.has(mode_id):
		return attack_modes[mode_id]
	return {}

## 获取武器攻击模式
func get_weapon_attack_mode(weapon_id: String) -> Dictionary:
	var weapon = get_weapon(weapon_id)
	if weapon.is_empty():
		return {}
	
	var mode_id = weapon.get("attack_mode", "melee_fast")
	return get_attack_mode(mode_id)
