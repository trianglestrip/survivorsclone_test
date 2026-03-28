extends Node
class_name SkillManager

# 技能管理器 - 管理玩家的所有技能

# 技能等级
var skill_levels = {}

# 技能弹药
var skill_ammo = {}
var skill_base_ammo = {}

# 技能攻击速度
var skill_attack_speeds = {}

# 引用
var player: Node = null

func _init():
	# 初始化技能数据
	_initialize_skills()

func _initialize_skills():
	# IceSpear
	skill_levels["icespear"] = 0
	skill_ammo["icespear"] = 0
	skill_base_ammo["icespear"] = 0
	skill_attack_speeds["icespear"] = 1.5
	
	# Tornado
	skill_levels["tornado"] = 0
	skill_ammo["tornado"] = 0
	skill_base_ammo["tornado"] = 0
	skill_attack_speeds["tornado"] = 3.0
	
	# Javelin
	skill_levels["javelin"] = 0
	skill_ammo["javelin"] = 0

# 设置玩家引用
func set_player(p_player: Node):
	player = p_player

# 获取技能等级
func get_skill_level(skill_id: String) -> int:
	return skill_levels.get(skill_id, 0)

# 设置技能等级
func set_skill_level(skill_id: String, level: int):
	skill_levels[skill_id] = level
	if has_node("/root/EventBus"):
		get_node("/root/EventBus").emit_skill_upgraded(skill_id, level)

# 增加技能弹药
func add_skill_ammo(skill_id: String, amount: int):
	if not skill_base_ammo.has(skill_id):
		skill_base_ammo[skill_id] = 0
	skill_base_ammo[skill_id] += amount

# 获取技能弹药
func get_skill_ammo(skill_id: String) -> int:
	return skill_ammo.get(skill_id, 0)

# 设置技能弹药
func set_skill_ammo(skill_id: String, amount: int):
	skill_ammo[skill_id] = amount

# 获取技能基础弹药
func get_skill_base_ammo(skill_id: String) -> int:
	return skill_base_ammo.get(skill_id, 0)

# 获取技能攻击速度
func get_skill_attack_speed(skill_id: String) -> float:
	return skill_attack_speeds.get(skill_id, 1.0)

# 设置技能攻击速度
func set_skill_attack_speed(skill_id: String, speed: float):
	skill_attack_speeds[skill_id] = speed

# 检查技能是否已解锁
func is_skill_unlocked(skill_id: String) -> bool:
	return get_skill_level(skill_id) > 0

# 获取所有已解锁的技能
func get_unlocked_skills() -> Array:
	var unlocked = []
	for skill_id in skill_levels.keys():
		if skill_levels[skill_id] > 0:
			unlocked.append(skill_id)
	return unlocked

# 修改技能属性
func modify_skill_property(skill_id: String, property_name: String, value):
	# 尝试在各个字典中查找和修改
	if property_name == "level":
		set_skill_level(skill_id, value)
	elif property_name == "baseammo":
		add_skill_ammo(skill_id, value)
	elif property_name == "attackspeed":
		set_skill_attack_speed(skill_id, value)
