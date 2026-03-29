class_name AttackManager
extends Node

## 新的攻击管理器 - 支持主动攻击
## 管理所有攻击类型，处理攻击输入和冷却

## 信号
signal attack_launched(attack_type: String)

## 引用
var player: Node = null
var input_manager: Node = null

## 攻击系统
var current_attack: BaseAttack = null
var _config: Dictionary = {}

func _ready():
	_load_config()

func _load_config():
	var json_data = ConfigManager.load_json_config("res://config/stage1_controls.json")
	if json_data and json_data.has("attack"):
		_config = json_data["attack"]

func set_player(p: Node):
	player = p
	_initialize_attack()

func set_input_manager(im: Node):
	input_manager = im
	if input_manager:
		input_manager.attack_pressed.connect(_on_attack_pressed)

func _initialize_attack():
	var melee_attack = MeleeAttack.new()
	melee_attack.set_player(player)
	melee_attack.load_config(_config)
	melee_attack.attack_executed.connect(_on_attack_executed)
	add_child(melee_attack)
	current_attack = melee_attack

func _on_attack_pressed():
	if current_attack and current_attack.try_attack():
		if current_attack is MeleeAttack and player and player.has("last_movement"):
			current_attack.set_last_movement(player.last_movement)
		emit_signal("attack_launched", "melee")

func _on_attack_executed(pos: Vector2, dir: Vector2, dmg: int, kb: int):
	if GameConfig.DEBUG_LOGGING:
		print("Attack executed at: ", pos, " direction: ", dir)

func get_current_attack() -> BaseAttack:
	return current_attack

func can_attack() -> bool:
	return current_attack and current_attack.can_attack()

## 向后兼容 - 旧的方法
func start_attacks():
	pass

func set_skill_instance_manager(skill_mgr: Node):
	pass
