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
var primary_attack: BaseAttack = null
var secondary_attack: BaseAttack = null
var _primary_config: Dictionary = {}
var _secondary_config: Dictionary = {}

func _ready():
	_load_config()

func _load_config():
	var json_data = ConfigManager.load_json_config("res://config/stage1_controls.json")
	if json_data:
		if json_data.has("primary_attack"):
			_primary_config = json_data["primary_attack"]
		elif json_data.has("attack"):
			_primary_config = json_data["attack"]
		
		if json_data.has("secondary_attack"):
			_secondary_config = json_data["secondary_attack"]

func set_player(p: Node):
	player = p
	_initialize_attack()

func set_input_manager(im: Node):
	input_manager = im
	if input_manager:
		input_manager.attack_pressed.connect(_on_primary_attack_pressed)
		input_manager.secondary_attack_pressed.connect(_on_secondary_attack_pressed)

func _initialize_attack():
	var melee_attack = MeleeAttack.new()
	melee_attack.set_player(player)
	melee_attack.load_config(_primary_config)
	melee_attack.attack_executed.connect(_on_attack_executed)
	add_child(melee_attack)
	primary_attack = melee_attack
	
	if not _secondary_config.is_empty():
		var ranged_attack = RangedAttack.new()
		ranged_attack.set_player(player)
		ranged_attack.load_config(_secondary_config)
		ranged_attack.attack_executed.connect(_on_attack_executed)
		add_child(ranged_attack)
		secondary_attack = ranged_attack

func _on_primary_attack_pressed():
	if primary_attack and primary_attack.try_attack():
		if primary_attack is MeleeAttack and player and "last_movement" in player:
			primary_attack.set_last_movement(player.last_movement)
		emit_signal("attack_launched", "primary")

func _on_secondary_attack_pressed():
	if secondary_attack and secondary_attack.try_attack():
		emit_signal("attack_launched", "secondary")

func _on_attack_executed(pos: Vector2, dir: Vector2, _dmg: int, _kb: int):
	if GameConfig.DEBUG_LOGGING:
		print("Attack executed at: ", pos, " direction: ", dir)

func get_primary_attack() -> BaseAttack:
	return primary_attack

func get_secondary_attack() -> BaseAttack:
	return secondary_attack

func can_primary_attack() -> bool:
	return primary_attack and primary_attack.can_attack()

func can_secondary_attack() -> bool:
	return secondary_attack and secondary_attack.can_attack()

## 向后兼容 - 旧的方法
func start_attacks():
	pass
