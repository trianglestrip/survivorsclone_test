class_name SectManager
extends Node

## 宗派管理器
## 管理玩家选择的宗派和宗派技能

## 信号
signal sect_selected(sect_id: String)
signal sect_bonus_applied(sect_id: String)

## 当前宗派
var current_sect_id: String = ""
var current_sect_data: Dictionary = {}

## 所有宗派配置
var sects_config: Dictionary = {}

## 引用
var player: Node = null
var active_skill_mgr: Node = null

func _ready():
	_load_sects_config()

func _load_sects_config():
	var json_data = ConfigManager.load_json_config("res://config/sect_config.json")
	if json_data and json_data.has("sects"):
		sects_config = json_data["sects"]
		if GameConfig.DEBUG_LOGGING:
			print("[SectManager] 加载了 %d 个宗派配置" % sects_config.size())

func set_player(p: Node):
	player = p

func set_active_skill_manager(asm: Node):
	active_skill_mgr = asm

## 选择宗派
func select_sect(sect_id: String) -> bool:
	if not sects_config.has(sect_id):
		push_error("宗派不存在: %s" % sect_id)
		return false
	
	current_sect_id = sect_id
	current_sect_data = sects_config[sect_id]
	
	_apply_sect_bonus()
	_unlock_sect_skills()
	
	emit_signal("sect_selected", sect_id)
	
	if GameConfig.DEBUG_LOGGING:
		print("[SectManager] 选择宗派: %s" % current_sect_data.get("name", sect_id))
	
	return true

## 应用宗派属性加成
func _apply_sect_bonus():
	if not player or not player.has_node("PlayerStats"):
		return
	
	var stats = player.get_node("PlayerStats")
	var bonus = current_sect_data.get("stats_bonus", {})
	
	if bonus.has("max_hp") and bonus["max_hp"] > 0:
		stats.maxhp += bonus["max_hp"]
		stats.hp = stats.maxhp
	
	if bonus.has("move_speed") and bonus["move_speed"] > 0:
		stats.movespeed += bonus["move_speed"]
	
	if bonus.has("attack_damage") and bonus["attack_damage"] > 0:
		if player.has_node("AttackManager"):
			var attack_mgr = player.get_node("AttackManager")
			if attack_mgr.current_attack:
				attack_mgr.current_attack.damage += bonus["attack_damage"]
	
	emit_signal("sect_bonus_applied", current_sect_id)
	
	if GameConfig.DEBUG_LOGGING:
		print("[SectManager] 应用宗派加成: HP+%d, 速度+%d, 攻击+%d" % [
			bonus.get("max_hp", 0),
			bonus.get("move_speed", 0),
			bonus.get("attack_damage", 0)
		])

## 解锁宗派技能
func _unlock_sect_skills():
	if not active_skill_mgr:
		return
	
	active_skill_mgr.unlock_skill("q")
	active_skill_mgr.unlock_skill("e")
	active_skill_mgr.unlock_skill("r")
	
	if GameConfig.DEBUG_LOGGING:
		print("[SectManager] 解锁技能: Q, E, R")

## 获取技能配置
func get_skill_config(skill_id: String) -> Dictionary:
	if current_sect_data.is_empty():
		return {}
	
	var skills = current_sect_data.get("skills", {})
	return skills.get(skill_id, {})

## 获取当前宗派信息
func get_current_sect() -> Dictionary:
	return current_sect_data

func get_current_sect_id() -> String:
	return current_sect_id

func get_sect_name() -> String:
	return current_sect_data.get("name", "")

func get_sect_color() -> Color:
	var color_str = current_sect_data.get("color", "#FFFFFF")
	return Color(color_str)

## 获取所有宗派列表（用于选择界面）
func get_all_sects() -> Array:
	var result = []
	for sect_id in sects_config.keys():
		result.append(sects_config[sect_id])
	return result

## 检查是否已选择宗派
func has_selected_sect() -> bool:
	return not current_sect_id.is_empty()
