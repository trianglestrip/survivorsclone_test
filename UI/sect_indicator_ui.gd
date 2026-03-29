extends Control

## 宗派指示器UI
## 显示当前宗派和可切换的宗派列表
## 高亮当前选中的宗派

const GameConstants = preload("res://Utility/game_constants.gd")

## 宗派配置
const SECTS = [
	{"id": "ice", "name": "冰心宗", "key": "1", "color": Color(0.4, 0.8, 1.0)},
	{"id": "thunder", "name": "雷鸣宗", "key": "2", "color": Color(0.6, 0.4, 1.0)},
	{"id": "fire", "name": "烈焰宗", "key": "3", "color": Color(1.0, 0.5, 0.2)},
	{"id": "poison", "name": "毒瘴宗", "key": "4", "color": Color(0.4, 1.0, 0.4)}
]

var sect_buttons: Array = []
var current_sect_id: String = ""
var sect_manager: Node = null

func _ready():
	_setup_ui()
	_find_sect_manager()

func _find_sect_manager():
	# 延迟查找SectManager
	await get_tree().process_frame
	
	var player = get_tree().get_first_node_in_group("player")
	if player:
		for child in player.get_children():
			if child.has_method("select_sect"):
				sect_manager = child
				if sect_manager.has_signal("sect_selected"):
					sect_manager.sect_selected.connect(_on_sect_changed)
				current_sect_id = sect_manager.current_sect_id
				_update_highlights()
				break

func _setup_ui():
	# 容器
	var container = HBoxContainer.new()
	container.name = "SectContainer"
	container.position = Vector2(20, 20)
	add_child(container)
	
	# 标题
	var title = Label.new()
	title.text = "[宗派]"
	title.add_theme_font_size_override("font_size", 14)
	title.modulate = Color(0.8, 0.8, 0.8)
	container.add_child(title)
	
	# 间隔
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(10, 0)
	container.add_child(spacer)
	
	# 创建宗派按钮
	for sect in SECTS:
		var btn = _create_sect_button(sect)
		container.add_child(btn)
		sect_buttons.append(btn)

func _create_sect_button(sect: Dictionary) -> Control:
	var panel = PanelContainer.new()
	panel.name = "Sect_" + sect["id"]
	panel.custom_minimum_size = Vector2(80, 32)
	panel.set_meta("sect_id", sect["id"])
	
	# 样式
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.2, 0.25, 0.8)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = sect["color"]
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
	key_label.text = sect["key"]
	key_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	key_label.add_theme_font_size_override("font_size", 12)
	key_label.add_theme_color_override("font_color", sect["color"])
	vbox.add_child(key_label)
	
	# 宗派名称
	var name_label = Label.new()
	name_label.text = sect["name"]
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 10)
	vbox.add_child(name_label)
	
	return panel

func _on_sect_changed(sect_id: String):
	current_sect_id = sect_id
	_update_highlights()

func _update_highlights():
	for btn in sect_buttons:
		var sect_id = btn.get_meta("sect_id", "")
		var style = btn.get_theme_stylebox("panel") as StyleBoxFlat
		
		if sect_id == current_sect_id:
			# 高亮当前宗派
			style.bg_color = Color(0.3, 0.3, 0.4, 1.0)
			style.border_width_left = 3
			style.border_width_top = 3
			style.border_width_right = 3
			style.border_width_bottom = 3
			
			# 添加发光效果
			var glow_tween = create_tween().set_loops()
			glow_tween.tween_property(btn, "modulate:a", 1.0, 0.5)
			glow_tween.tween_property(btn, "modulate:a", 0.7, 0.5)
		else:
			# 非选中状态
			style.bg_color = Color(0.2, 0.2, 0.25, 0.8)
			style.border_width_left = 2
			style.border_width_top = 2
			style.border_width_right = 2
			style.border_width_bottom = 2
			btn.modulate.a = 0.6
