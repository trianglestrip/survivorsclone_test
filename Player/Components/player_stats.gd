extends Node
class_name PlayerStats

# 玩家属性组件 - 管理所有玩家属性

# 基础属性
var movement_speed: float = 40.0
var hp: int = 80
var maxhp: int = 80

# 升级属性
var armor: int = 0
var speed_bonus: float = 0
var spell_cooldown: float = 0
var spell_size: float = 0
var additional_attacks: int = 0

# 经验相关
var experience: int = 0
var experience_level: int = 1
var collected_experience: int = 0

# 修改属性
func modify_stat(stat_name: String, value: float, operation: String = "add"):
	var current_value = get(stat_name)
	if current_value == null:
		push_warning("PlayerStats 没有属性: %s" % stat_name)
		return
	
	match operation:
		"add":
			set(stat_name, current_value + value)
		"multiply":
			set(stat_name, current_value * value)
		"set":
			set(stat_name, value)

# 获取当前移动速度（包含加成）
func get_movement_speed() -> float:
	return movement_speed + speed_bonus

# 获取伤害减免
func get_damage_reduction() -> int:
	return armor

# 治疗
func heal(amount: int) -> int:
	var old_hp = hp
	hp += amount
	hp = clamp(hp, 0, maxhp)
	return hp - old_hp

# 受到伤害
func take_damage(damage: int) -> int:
	var actual_damage = clamp(damage - armor, 1, 999)
	hp -= actual_damage
	return actual_damage

# 是否存活
func is_alive() -> bool:
	return hp > 0

# 重置属性
func reset():
	movement_speed = 40.0
	hp = 80
	maxhp = 80
	armor = 0
	speed_bonus = 0
	spell_cooldown = 0
	spell_size = 0
	additional_attacks = 0
	experience = 0
	experience_level = 1
	collected_experience = 0
