extends Control

## 武器指示器UI
## 显示当前武器和可切换的武器列表
## 高亮当前选中的武器

const GameConstants = preload("res://Utility/game_constants.gd")

## 武器配置
const WEAPONS = [
	{"id": "sword_basic", "name": "无名", "key": "5"},
	{"id": "sword_frost", "name": "寒川", "key": "6"},
	{"id": "hammer_thunder", "name": "雷息", "key": "7"},
	{"id": "staff_fire", "name": "炽焰", "key": "8"},
	{"id": "dagger_poison", "name": "百足", "key": "9"},
	{"id": "spear_legendary", "name": "养战", "key": "0"}
]

var weapon_buttons: Array = []
var current_weapon_id: String = ""
var weapon_registry: Node = null

func _ready():
	_setup_ui()
	_find_weapon_registry()

func _find_weapon_registry():
	# 延迟查找WeaponRegistry
	await get_tree().process_frame
	
	var player = get_tree().get_first_node_in_group("player")
	if player:
		for child in player.get_children():
			if child.has_method("get_weapon"):
				weapon_registry = child
				current_weapon_id = weapon_registry.current_weapon_id
				_update_highlights()
				break

func _setup_ui():
	# 容器
	var container = HBoxContainer.new()
	container.name = "WeaponContainer"
	container.position = Vector2(20, 60)
	add_child(container)
	
	# 标题
	var title = Label.new()
	title.text = "[武器]"
	title.add_theme_font_size_override("font_size", 14)
	title.modulate = Color(0.8, 0.8, 0.8)
	container.add_child(title)
	
	# 间隔
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(10, 0)
	container.add_child(spacer)
	
	# 创建武器按钮
	for weapon in WEAPONS:
		var btn = _create_weapon_button(weapon)
		container.add_child(btn)
		weapon_buttons.append(btn)

func _create_weapon_button(weapon: Dictionary) -> Control:
	var panel = PanelContainer.new()
	panel.name = "Weapon_" + weapon["id"]
	panel.custom_minimum_size = Vector2(60, 32)
	panel.set_meta("weapon_id", weapon["id"])
	
	# 样式
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.25, 0.2, 0.2, 0.8)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.6, 0.5, 0.4)
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	panel.add_theme_stylebox_override("panel", style)
	
	# 内容容器
	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(vbox)
	
	# 按键提示
	var key_label = Label.new()
	key_label.text = weapon["key"]
	key_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	key_label.add_theme_font_size_override("font_size", 12)
	key_label.add_theme_color_override("font_color", Color(0.9, 0.8, 0.6))
	vbox.add_child(key_label)
	
	# 武器名称
	var name_label = Label.new()
	name_label.text = weapon["name"]
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 10)
	vbox.add_child(name_label)
	
	return panel

func _process(_delta):
	# 每帧检查武器变化
	if weapon_registry and weapon_registry.current_weapon_id != current_weapon_id:
		current_weapon_id = weapon_registry.current_weapon_id
		_update_highlights()

func _update_highlights():
	for btn in weapon_buttons:
		var weapon_id = btn.get_meta("weapon_id", "")
		var style = btn.get_theme_stylebox("panel") as StyleBoxFlat
		
		if weapon_id == current_weapon_id:
			# 高亮当前武器
			style.bg_color = Color(0.4, 0.3, 0.2, 1.0)
			style.border_width_left = 3
			style.border_width_top = 3
			style.border_width_right = 3
			style.border_width_bottom = 3
			style.border_color = Color(1.0, 0.8, 0.4)
			btn.modulate.a = 1.0
			
			# 添加发光效果
			var glow_tween = create_tween().set_loops()
			glow_tween.tween_property(btn, "scale", Vector2(1.05, 1.05), 0.4)
			glow_tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.4)
		else:
			# 非选中状态
			style.bg_color = Color(0.25, 0.2, 0.2, 0.8)
			style.border_width_left = 2
			style.border_width_top = 2
			style.border_width_right = 2
			style.border_width_bottom = 2
			style.border_color = Color(0.6, 0.5, 0.4)
			btn.modulate.a = 0.6
			btn.scale = Vector2(1.0, 1.0)
