extends Node2D

## 交互式测试场景
## 快速测试所有宗派、武器、技能
## 
## 按键说明：
## 数字键1-4：切换宗派（1=冰心，2=雷鸣，3=烈焰，4=毒瘴）
## 数字键5-9：切换武器（5=无名，6=破军，7=碎星弓，8=重锤，9=疾风刃）
## Q/E/R：释放技能
## 空格/左键：攻击
## Shift：冲刺
## F：生成测试敌人
## G：清除所有敌人
## H：显示帮助信息

var player: CharacterBody2D = null
var sect_manager: Node = null
var weapon_registry: Node = null
var info_label: Label = null

var sect_names = {
	"ice": "冰心宗",
	"thunder": "雷鸣宗",
	"fire": "烈焰宗",
	"poison": "毒瘴宗"
}

var weapon_ids = ["nameless_sword", "army_breaker", "star_bow", "heavy_hammer", "swift_blade", "dual_blades"]

func _ready():
	_setup_player()
	_setup_ui()
	_spawn_test_enemies()
	print("\n========================================")
	print("交互式测试场景已启动")
	print("========================================")
	_print_help()

func _setup_player():
	# 等待场景加载
	await get_tree().process_frame
	
	player = get_node_or_null("World/Player")
	if not player:
		print("错误：找不到Player节点")
		return
	
	# 获取组件引用
	for child in player.get_children():
		if child.has_method("select_sect"):
			sect_manager = child
		if child.has_method("get_weapon"):
			weapon_registry = child
	
	print("✓ Player初始化完成")
	print("  SectManager: ", sect_manager != null)
	print("  WeaponRegistry: ", weapon_registry != null)

func _setup_ui():
	# 创建信息显示UI
	var canvas = CanvasLayer.new()
	canvas.name = "TestUI"
	add_child(canvas)
	
	info_label = Label.new()
	info_label.position = Vector2(10, 10)
	info_label.add_theme_font_size_override("font_size", 16)
	canvas.add_child(info_label)
	
	_update_info_display()

func _update_info_display():
	if not info_label or not player:
		return
	
	var current_sect = sect_manager.current_sect if sect_manager else "未选择"
	var sect_display = sect_names.get(current_sect, current_sect)
	
	var current_weapon = weapon_registry.current_weapon if weapon_registry else {}
	var weapon_display = current_weapon.get("name", "无武器")
	
	var player_stats = player.get_node_or_null("PlayerStats")
	var hp_display = "???"
	if player_stats:
		hp_display = "%d/%d" % [player_stats.hp, player_stats.maxhp]
	
	info_label.text = """[测试模式]
当前宗派: %s
当前武器: %s
生命值: %s

按H显示帮助""" % [sect_display, weapon_display, hp_display]

var last_key_time = {}
var key_cooldown = 0.3  # 防止按键重复触发

func _process(_delta):
	_update_info_display()
	
	var current_time = Time.get_ticks_msec() / 1000.0
	
	# 宗派切换（1-4）
	if Input.is_key_pressed(KEY_1) and _can_press_key("1", current_time):
		_switch_sect("ice")
	elif Input.is_key_pressed(KEY_2) and _can_press_key("2", current_time):
		_switch_sect("thunder")
	elif Input.is_key_pressed(KEY_3) and _can_press_key("3", current_time):
		_switch_sect("fire")
	elif Input.is_key_pressed(KEY_4) and _can_press_key("4", current_time):
		_switch_sect("poison")
	
	# 武器切换（5-9, 0）
	elif Input.is_key_pressed(KEY_5) and _can_press_key("5", current_time):
		_switch_weapon(0)
	elif Input.is_key_pressed(KEY_6) and _can_press_key("6", current_time):
		_switch_weapon(1)
	elif Input.is_key_pressed(KEY_7) and _can_press_key("7", current_time):
		_switch_weapon(2)
	elif Input.is_key_pressed(KEY_8) and _can_press_key("8", current_time):
		_switch_weapon(3)
	elif Input.is_key_pressed(KEY_9) and _can_press_key("9", current_time):
		_switch_weapon(4)
	elif Input.is_key_pressed(KEY_0) and _can_press_key("0", current_time):
		_switch_weapon(5)
	
	# 测试功能
	elif Input.is_key_pressed(KEY_F) and _can_press_key("F", current_time):
		_spawn_test_enemy()
	elif Input.is_key_pressed(KEY_G) and _can_press_key("G", current_time):
		_clear_all_enemies()
	elif Input.is_key_pressed(KEY_H) and _can_press_key("H", current_time):
		_print_help()

func _can_press_key(key: String, current_time: float) -> bool:
	if not last_key_time.has(key):
		last_key_time[key] = current_time
		return true
	
	if current_time - last_key_time[key] > key_cooldown:
		last_key_time[key] = current_time
		return true
	
	return false

func _switch_sect(sect_id: String):
	if not sect_manager:
		print("错误：SectManager未找到")
		return
	
	if sect_manager.has_method("select_sect"):
		sect_manager.select_sect(sect_id)
		print("\n✓ 切换宗派: %s" % sect_names.get(sect_id, sect_id))
		_print_current_skills()

func _switch_weapon(index: int):
	if not weapon_registry:
		print("错误：WeaponRegistry未找到")
		return
	
	if index < 0 or index >= weapon_ids.size():
		return
	
	var weapon_id = weapon_ids[index]
	if weapon_registry.has_method("equip_weapon"):
		weapon_registry.equip_weapon(weapon_id)
		var weapon = weapon_registry.get_weapon(weapon_id)
		print("\n✓ 切换武器: %s" % weapon.get("name", weapon_id))

func _spawn_test_enemy():
	var enemy_scene = load("res://Enemy/melee_enemy.tscn")
	if not enemy_scene:
		print("错误：无法加载敌人场景")
		return
	
	var enemy = enemy_scene.instantiate()
	
	# 在玩家周围随机位置生成
	var spawn_distance = 200.0
	var angle = randf() * TAU
	var spawn_pos = player.global_position + Vector2(cos(angle), sin(angle)) * spawn_distance
	
	enemy.global_position = spawn_pos
	
	# 加载配置
	var config = {
		"hp": 50,
		"damage": 5,
		"move_speed": 80,
		"attack_range": 40,
		"attack_cooldown": 1.5,
		"knockback_resistance": 0.3,
		"exp_value": 10,
		"color": Color(1.0, 0.3, 0.3)
	}
	
	if enemy.has_method("load_config"):
		enemy.load_config(config)
	
	var enemies_node = get_node_or_null("Enemies")
	if enemies_node:
		enemies_node.add_child(enemy)
		print("✓ 生成测试敌人")

func _spawn_test_enemies():
	# 等待player初始化
	await get_tree().create_timer(1.0).timeout
	
	if not player:
		return
	
	# 初始生成几个敌人用于测试
	print("\n生成初始测试敌人...")
	for i in range(5):
		await get_tree().create_timer(0.2).timeout
		_spawn_test_enemy()

func _clear_all_enemies():
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	print("\n✓ 清除所有敌人 (%d个)" % enemies.size())

func _print_current_skills():
	if not sect_manager:
		return
	
	var current_sect = sect_manager.current_sect
	var sect_config = sect_manager.get_sect_config(current_sect)
	
	if sect_config:
		print("  技能列表:")
		var skills = sect_config.get("skills", {})
		for key in ["Q", "E", "R"]:
			var skill = skills.get(key, {})
			print("    %s: %s" % [key, skill.get("name", "未知")])

func _print_help():
	print("\n========================================")
	print("交互式测试 - 按键说明")
	print("========================================")
	print("宗派切换:")
	print("  1 - 冰心宗")
	print("  2 - 雷鸣宗")
	print("  3 - 烈焰宗")
	print("  4 - 毒瘴宗")
	print("\n武器切换:")
	print("  5 - 无名")
	print("  6 - 破军")
	print("  7 - 碎星弓")
	print("  8 - 重锤")
	print("  9 - 疾风刃")
	print("  0 - 双刀")
	print("\n战斗操作:")
	print("  Q/E/R - 释放技能")
	print("  空格/左键 - 普通攻击")
	print("  Shift - 冲刺闪避")
	print("\n测试功能:")
	print("  F - 生成测试敌人")
	print("  G - 清除所有敌人")
	print("  H - 显示此帮助")
	print("========================================\n")
