extends Node

# 技能注册系统 - 管理所有技能的注册和查询

var registered_skills = {}

# 注册技能
func register_skill(skill_id: String, skill_scene: PackedScene, skill_data: Dictionary = {}):
	registered_skills[skill_id] = {
		"scene": skill_scene,
		"data": skill_data
	}

# 获取技能场景
func get_skill_scene(skill_id: String) -> PackedScene:
	if registered_skills.has(skill_id):
		return registered_skills[skill_id]["scene"]
	return null

# 获取技能数据
func get_skill_data(skill_id: String) -> Dictionary:
	if registered_skills.has(skill_id):
		return registered_skills[skill_id]["data"]
	return {}

# 检查技能是否已注册
func has_skill(skill_id: String) -> bool:
	return registered_skills.has(skill_id)

# 获取所有已注册的技能 ID
func get_all_skill_ids() -> Array:
	return registered_skills.keys()

# 实例化技能
func instantiate_skill(skill_id: String) -> Node:
	var scene = get_skill_scene(skill_id)
	if scene:
		return scene.instantiate()
	return null

func _ready():
	# 注册所有技能
	_register_default_skills()

func _register_default_skills():
	# 注册冰矛
	register_skill("IceSpear", preload("res://Player/Attack/ice_spear.tscn"), {
		"name": "冰矛",
		"description": "向随机敌人投掷冰矛",
		"type": "projectile"
	})
	
	# 注册龙卷风
	register_skill("Tornado", preload("res://Player/Attack/tornado.tscn"), {
		"name": "龙卷风",
		"description": "生成龙卷风并在玩家方向上随机移动",
		"type": "projectile"
	})
	
	# 注册标枪
	register_skill("Javelin", preload("res://Player/Attack/javelin.tscn"), {
		"name": "标枪",
		"description": "魔法标枪会沿直线跟随你攻击敌人",
		"type": "orbital"
	})
