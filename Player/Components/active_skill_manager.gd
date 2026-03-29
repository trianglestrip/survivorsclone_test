class_name ActiveSkillManager
extends Node

## 主动技能管理器
## 管理QER三个主动技能的释放和冷却

## 信号
signal skill_cast(skill_id: String)
signal skill_cooldown_started(skill_id: String, cooldown: float)
signal skill_cooldown_updated(skill_id: String, current: float, max: float)
signal skill_ready(skill_id: String)

## 技能数据结构
class SkillData:
	var skill_id: String
	var cooldown: float
	var current_cooldown: float = 0.0
	var is_on_cooldown: bool = false
	var is_unlocked: bool = false
	
	func _init(id: String, cd: float):
		skill_id = id
		cooldown = cd

## 技能槽
var skills: Dictionary = {}  # "q" -> SkillData

## 引用
var player: Node = null
var input_manager: Node = null

func _ready():
	_initialize_skills()

func _initialize_skills():
	var config = _load_config()
	
	if config.has("skills"):
		var skills_config = config["skills"]
		for key in ["q", "e", "r"]:
			if skills_config.has(key):
				var skill_config = skills_config[key]
				var skill_data = SkillData.new(key, skill_config.get("cooldown", 3.0))
				skills[key] = skill_data

func _load_config() -> Dictionary:
	var json_data = ConfigManager.load_json_config("res://config/stage1_controls.json")
	return json_data if json_data else {}

func set_player(p: Node):
	player = p

func set_input_manager(im: Node):
	input_manager = im
	if input_manager:
		input_manager.skill_q_pressed.connect(_on_skill_q_pressed)
		input_manager.skill_e_pressed.connect(_on_skill_e_pressed)
		input_manager.skill_r_pressed.connect(_on_skill_r_pressed)

func _process(delta: float):
	for skill_data in skills.values():
		if skill_data.is_on_cooldown:
			skill_data.current_cooldown -= delta
			emit_signal("skill_cooldown_updated", skill_data.skill_id, 
				max(skill_data.current_cooldown, 0), skill_data.cooldown)
			
			if skill_data.current_cooldown <= 0:
				skill_data.is_on_cooldown = false
				skill_data.current_cooldown = 0.0
				emit_signal("skill_ready", skill_data.skill_id)

func _on_skill_q_pressed():
	try_cast_skill("q")

func _on_skill_e_pressed():
	try_cast_skill("e")

func _on_skill_r_pressed():
	try_cast_skill("r")

func try_cast_skill(skill_id: String) -> bool:
	if not skills.has(skill_id):
		return false
	
	var skill_data = skills[skill_id]
	
	if not skill_data.is_unlocked:
		if GameConfig.DEBUG_LOGGING:
			print("技能 %s 未解锁" % skill_id.to_upper())
		return false
	
	if skill_data.is_on_cooldown:
		if GameConfig.DEBUG_LOGGING:
			print("技能 %s 冷却中 (%.1fs)" % [skill_id.to_upper(), skill_data.current_cooldown])
		return false
	
	_cast_skill(skill_data)
	return true

func _cast_skill(skill_data: SkillData):
	if GameConfig.DEBUG_LOGGING:
		print("释放技能: %s" % skill_data.skill_id.to_upper())
	
	emit_signal("skill_cast", skill_data.skill_id)
	
	skill_data.is_on_cooldown = true
	skill_data.current_cooldown = skill_data.cooldown
	emit_signal("skill_cooldown_started", skill_data.skill_id, skill_data.cooldown)
	emit_signal("skill_cooldown_updated", skill_data.skill_id, 
		skill_data.current_cooldown, skill_data.cooldown)
	
	_update_skill_bar_ui(skill_data)

func _update_skill_bar_ui(skill_data: SkillData):
	var skill_bar_ui = player.get_node_or_null("%SkillBarUI") if player else null
	if skill_bar_ui and skill_bar_ui.has_method("update_skill_cooldown"):
		skill_bar_ui.update_skill_cooldown(skill_data.skill_id, 
			skill_data.current_cooldown, skill_data.cooldown)

## 公共API
func unlock_skill(skill_id: String):
	if skills.has(skill_id):
		skills[skill_id].is_unlocked = true
		if GameConfig.DEBUG_LOGGING:
			print("解锁技能: %s" % skill_id.to_upper())

func is_skill_unlocked(skill_id: String) -> bool:
	return skills.has(skill_id) and skills[skill_id].is_unlocked

func is_skill_on_cooldown(skill_id: String) -> bool:
	return skills.has(skill_id) and skills[skill_id].is_on_cooldown

func get_skill_cooldown_progress(skill_id: String) -> float:
	if not skills.has(skill_id):
		return 1.0
	
	var skill_data = skills[skill_id]
	if not skill_data.is_on_cooldown:
		return 1.0
	
	return 1.0 - (skill_data.current_cooldown / skill_data.cooldown)

func reduce_cooldown(skill_id: String, amount: float):
	if skills.has(skill_id):
		var skill_data = skills[skill_id]
		if skill_data.is_on_cooldown:
			skill_data.current_cooldown = max(0, skill_data.current_cooldown - amount)
			if skill_data.current_cooldown <= 0:
				skill_data.is_on_cooldown = false
				emit_signal("skill_ready", skill_id)
