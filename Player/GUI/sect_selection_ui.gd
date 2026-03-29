class_name SectSelectionUI
extends Control

## 宗派选择界面
## 暖雪风格的宗派选择UI

## 信号
signal sect_selected(sect_id: String)

## 配置
var card_size := Vector2(160, 240)
var card_spacing := 20
var glow_intensity := 0.0

## 引用
var sect_manager: Node = null
var _selected_sect_id: String = ""
var _card_nodes: Dictionary = {}

func _ready():
	_create_ui()

func set_sect_manager(sm: Node):
	sect_manager = sm
	if sect_manager:
		_populate_sects()

func _create_ui():
	size = Vector2(800, 600)
	position = (get_viewport_rect().size - size) / 2
	
	var bg = ColorRect.new()
	bg.name = "Background"
	bg.color = Color(0.05, 0.05, 0.1, 0.95)
	bg.size = size
	add_child(bg)
	
	var border = ColorRect.new()
	border.name = "Border"
	border.color = Color.TRANSPARENT
	border.size = size
	var border_style = StyleBoxFlat.new()
	border_style.border_color = Color(0.8, 0.7, 0.3, 1.0)
	border_style.border_width_left = 2
	border_style.border_width_right = 2
	border_style.border_width_top = 2
	border_style.border_width_bottom = 2
	add_child(border)
	
	var title = Label.new()
	title.name = "Title"
	title.text = "选择宗派"
	title.position = Vector2(size.x / 2 - 100, 40)
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", Color(0.9, 0.85, 0.6, 1.0))
	add_child(title)
	
	var subtitle = Label.new()
	subtitle.name = "Subtitle"
	subtitle.text = "选择你的修炼之道"
	subtitle.position = Vector2(size.x / 2 - 80, 80)
	subtitle.add_theme_font_size_override("font_size", 16)
	subtitle.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7, 1.0))
	add_child(subtitle)
	
	var cards_container = Control.new()
	cards_container.name = "CardsContainer"
	cards_container.position = Vector2(60, 140)
	cards_container.size = Vector2(680, 400)
	add_child(cards_container)

func _populate_sects():
	if not sect_manager:
		return
	
	var sects = sect_manager.get_all_sects()
	var cards_container = get_node_or_null("CardsContainer")
	if not cards_container:
		return
	
	var total_width = sects.size() * card_size.x + (sects.size() - 1) * card_spacing
	var start_x = (cards_container.size.x - total_width) / 2
	
	for i in range(sects.size()):
		var sect = sects[i]
		var card = _create_sect_card(sect, i)
		card.position = Vector2(start_x + i * (card_size.x + card_spacing), 0)
		cards_container.add_child(card)
		_card_nodes[sect["id"]] = card

func _create_sect_card(sect: Dictionary, index: int) -> Control:
	var card = Control.new()
	card.name = "SectCard_%s" % sect["id"]
	card.size = card_size
	card.custom_minimum_size = card_size
	
	var bg = ColorRect.new()
	bg.name = "Background"
	bg.color = Color(0.1, 0.1, 0.15, 1.0)
	bg.size = card_size
	add_child(bg)
	card.add_child(bg)
	
	var glow_bg = ColorRect.new()
	glow_bg.name = "GlowBackground"
	glow_bg.color = Color(sect.get("color", "#FFFFFF"))
	glow_bg.color.a = 0.0
	glow_bg.size = card_size
	glow_bg.position = Vector2.ZERO
	glow_bg.z_index = -1
	card.add_child(glow_bg)
	
	var border = ColorRect.new()
	border.name = "Border"
	border.color = Color.TRANSPARENT
	border.size = card_size
	var border_style = StyleBoxFlat.new()
	border_style.border_color = Color(0.3, 0.3, 0.4, 1.0)
	border_style.border_width_left = 2
	border_style.border_width_right = 2
	border_style.border_width_top = 2
	border_style.border_width_bottom = 2
	card.add_child(border)
	
	var icon_rect = ColorRect.new()
	icon_rect.name = "IconRect"
	icon_rect.color = Color(sect.get("color", "#FFFFFF"))
	icon_rect.color.a = 0.3
	icon_rect.size = Vector2(96, 96)
	icon_rect.position = Vector2((card_size.x - 96) / 2, 20)
	card.add_child(icon_rect)
	
	var name_label = Label.new()
	name_label.name = "NameLabel"
	name_label.text = sect.get("name", "")
	name_label.position = Vector2(10, 130)
	name_label.size = Vector2(card_size.x - 20, 30)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 20)
	name_label.add_theme_color_override("font_color", Color(sect.get("color", "#FFFFFF")))
	card.add_child(name_label)
	
	var desc_label = Label.new()
	desc_label.name = "DescLabel"
	desc_label.text = sect.get("description", "")
	desc_label.position = Vector2(10, 165)
	desc_label.size = Vector2(card_size.x - 20, 60)
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	desc_label.add_theme_font_size_override("font_size", 12)
	desc_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7, 1.0))
	card.add_child(desc_label)
	
	var button = Button.new()
	button.name = "SelectButton"
	button.text = "选择"
	button.position = Vector2(30, 200)
	button.size = Vector2(100, 30)
	button.pressed.connect(_on_sect_card_pressed.bind(sect["id"]))
	card.add_child(button)
	
	return card

func _on_sect_card_pressed(sect_id: String):
	_selected_sect_id = sect_id
	
	for card_id in _card_nodes:
		var card = _card_nodes[card_id]
		var border = card.get_node_or_null("Border")
		if border:
			var border_style = StyleBoxFlat.new()
			if card_id == sect_id:
				border_style.border_color = Color(0.9, 0.8, 0.3, 1.0)
			else:
				border_style.border_color = Color(0.3, 0.3, 0.4, 1.0)
			border_style.border_width_left = 2
			border_style.border_width_right = 2
			border_style.border_width_top = 2
			border_style.border_width_bottom = 2

func _process(delta: float):
	glow_intensity += delta * 2.0
	
	for card_id in _card_nodes:
		if card_id == _selected_sect_id:
			var card = _card_nodes[card_id]
			var glow_bg = card.get_node_or_null("GlowBackground")
			if glow_bg:
				glow_bg.color.a = 0.2 + sin(glow_intensity) * 0.1

## 确认选择
func confirm_selection():
	if _selected_sect_id.is_empty():
		return
	
	if sect_manager:
		sect_manager.select_sect(_selected_sect_id)
	
	emit_signal("sect_selected", _selected_sect_id)
	queue_free()

## 获取选中的宗派
func get_selected_sect_id() -> String:
	return _selected_sect_id
