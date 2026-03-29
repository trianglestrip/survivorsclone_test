extends Node2D

## 主游戏世界脚本
## 处理全局输入（宗派/武器切换）

var player: CharacterBody2D = null
var sect_manager: Node = null
var weapon_registry: Node = null

# 按键冷却
var last_key_time: Dictionary = {}
var key_cooldown: float = 0.3

var sect_ids = ["ice", "thunder", "fire", "poison"]
var weapon_ids = ["sword_basic", "sword_frost", "hammer_thunder", "staff_fire", "dagger_poison", "spear_legendary"]

func _ready():
	await get_tree().process_frame
	_setup_references()

func _setup_references():
	player = get_node_or_null("Player")
	if not player:
		return
	
	var upgrade_ui = get_node_or_null("UpgradeCardLayer/UpgradeCardUI")
	if upgrade_ui and player.has_method("upgrade_character"):
		if not upgrade_ui.card_selected.is_connected(Callable(player, "upgrade_character")):
			upgrade_ui.card_selected.connect(Callable(player, "upgrade_character"))
	
	# 查找组件
	for child in player.get_children():
		if child.get_script() and child.get_script().get_global_name() == "SectManager":
			sect_manager = child
		elif child.has_method("get_weapon") and child.has_method("equip_weapon"):
			weapon_registry = child

func _input(event: InputEvent):
	if not player:
		return
	
	var current_time = Time.get_ticks_msec() / 1000.0
	
	# 宗派切换（1-4）
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				if _can_press_key("1", current_time):
					_switch_sect(0)
			KEY_2:
				if _can_press_key("2", current_time):
					_switch_sect(1)
			KEY_3:
				if _can_press_key("3", current_time):
					_switch_sect(2)
			KEY_4:
				if _can_press_key("4", current_time):
					_switch_sect(3)
			KEY_5:
				if _can_press_key("5", current_time):
					_switch_weapon(0)
			KEY_6:
				if _can_press_key("6", current_time):
					_switch_weapon(1)
			KEY_7:
				if _can_press_key("7", current_time):
					_switch_weapon(2)
			KEY_8:
				if _can_press_key("8", current_time):
					_switch_weapon(3)
			KEY_9:
				if _can_press_key("9", current_time):
					_switch_weapon(4)
			KEY_0:
				if _can_press_key("0", current_time):
					_switch_weapon(5)

func _can_press_key(key: String, current_time: float) -> bool:
	if not last_key_time.has(key):
		last_key_time[key] = current_time
		return true
	
	if current_time - last_key_time[key] > key_cooldown:
		last_key_time[key] = current_time
		return true
	
	return false

func _switch_sect(index: int):
	if not sect_manager or index < 0 or index >= sect_ids.size():
		return
	
	var sect_id = sect_ids[index]
	if sect_manager.has_method("select_sect"):
		sect_manager.select_sect(sect_id)
		if GameConfig.DEBUG_LOGGING:
			print("[World] 切换宗派: %s" % sect_id)

func _switch_weapon(index: int):
	if not weapon_registry or index < 0 or index >= weapon_ids.size():
		return
	
	var weapon_id = weapon_ids[index]
	
	# 先解锁武器
	if weapon_registry.has_method("unlock_weapon"):
		weapon_registry.unlock_weapon(weapon_id)
	
	# 装备武器
	if weapon_registry.has_method("equip_weapon"):
		weapon_registry.equip_weapon(weapon_id)
		if GameConfig.DEBUG_LOGGING:
			var weapon = weapon_registry.get_weapon(weapon_id)
			print("[World] 切换武器: %s" % weapon.get("name", weapon_id))
