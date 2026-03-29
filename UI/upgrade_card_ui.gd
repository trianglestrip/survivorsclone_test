extends Control

## 升级卡牌UI
## 暖雪风格：3张卡牌选1

signal card_selected(upgrade_id: String)

const GameConstants = preload("res://Utility/game_constants.gd")

var cards: Array = []
var upgrade_data: Array = []
var selected_card: Control = null
var _selection_in_progress: bool = false

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_STOP
	hide()

## 显示升级选项
## @param options: Array[Dictionary] - 升级配置数组
func show_upgrade_options(options: Array):
	_selection_in_progress = false
	upgrade_data = options
	_create_cards()
	show()
	get_tree().paused = true

func _create_cards():
	# 清除旧卡牌
	for card in cards:
		if is_instance_valid(card):
			card.queue_free()
	cards.clear()
	
	# 创建背景遮罩
	var overlay = ColorRect.new()
	overlay.name = "Overlay"
	overlay.color = Color(0, 0, 0, 0.7)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.z_index = -1
	add_child(overlay)
	
	# 创建标题
	var title = Label.new()
	title.text = "选择升级"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector2(size.x / 2 - 100, 50)
	title.size = Vector2(200, 50)
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", Color(1.0, 0.9, 0.6))
	add_child(title)
	
	# 创建3张卡牌
	var card_width = 280
	var card_height = 400
	var spacing = 40
	var total_width = card_width * 3 + spacing * 2
	var start_x = (size.x - total_width) / 2
	var start_y = 150
	
	for i in range(min(3, upgrade_data.size())):
		var card = _create_card(upgrade_data[i], i)
		card.position = Vector2(start_x + i * (card_width + spacing), start_y)
		card.custom_minimum_size = Vector2(card_width, card_height)
		add_child(card)
		cards.append(card)

func _create_card(data: Dictionary, index: int) -> Control:
	var card = PanelContainer.new()
	card.name = "Card_%d" % index
	card.set_meta("upgrade_id", data.get("id", ""))
	card.set_meta("index", index)
	
	# 卡牌样式
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.15, 0.2, 0.95)
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.border_color = _get_rarity_color(data.get("rarity", "common"))
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.shadow_size = 5
	style.shadow_color = Color(0, 0, 0, 0.5)
	card.add_theme_stylebox_override("panel", style)
	
	# 卡牌内容
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 15)
	card.add_child(vbox)
	
	# 图标区域
	var icon_container = CenterContainer.new()
	icon_container.custom_minimum_size = Vector2(0, 120)
	vbox.add_child(icon_container)
	
	var icon = TextureRect.new()
	icon.custom_minimum_size = Vector2(100, 100)
	icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	# 尝试加载图标
	var icon_path = data.get("icon", "")
	if ResourceLoader.exists(icon_path):
		icon.texture = load(icon_path)
	else:
		# 占位图标
		icon.texture = VisualEffectsHelper.create_placeholder_texture(Vector2(100, 100))
		icon.modulate = _get_rarity_color(data.get("rarity", "common"))
	
	icon_container.add_child(icon)
	
	# 稀有度标签
	var rarity_label = Label.new()
	rarity_label.text = _get_rarity_text(data.get("rarity", "common"))
	rarity_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rarity_label.add_theme_font_size_override("font_size", 14)
	rarity_label.add_theme_color_override("font_color", _get_rarity_color(data.get("rarity", "common")))
	vbox.add_child(rarity_label)
	
	# 名称
	var name_label = Label.new()
	name_label.text = data.get("displayname", data.get("name", "未知"))
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 20)
	name_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(name_label)
	
	# 描述
	var desc_label = Label.new()
	desc_label.text = data.get("details", "")
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.add_theme_font_size_override("font_size", 14)
	desc_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.custom_minimum_size.y = 80
	vbox.add_child(desc_label)
	
	# 效果详情
	var effects_label = Label.new()
	effects_label.text = _format_effects(data.get("effects", {}))
	effects_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	effects_label.add_theme_font_size_override("font_size", 12)
	effects_label.add_theme_color_override("font_color", Color(0.6, 0.9, 0.6))
	effects_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(effects_label)
	
	# 添加间隔
	var spacer = Control.new()
	spacer.custom_minimum_size.y = 10
	vbox.add_child(spacer)
	
	# 选择按钮
	var button = Button.new()
	button.text = "选择"
	button.custom_minimum_size = Vector2(0, 40)
	button.add_theme_font_size_override("font_size", 18)
	button.pressed.connect(_on_card_selected.bind(card))
	vbox.add_child(button)
	
	# 鼠标悬停效果
	card.mouse_entered.connect(_on_card_hover.bind(card, true))
	card.mouse_exited.connect(_on_card_hover.bind(card, false))
	
	return card

func _get_rarity_color(rarity: String) -> Color:
	match rarity:
		"common":
			return Color(0.7, 0.7, 0.7)  # 灰色
		"uncommon":
			return Color(0.3, 0.8, 0.3)  # 绿色
		"rare":
			return Color(0.3, 0.5, 1.0)  # 蓝色
		"epic":
			return Color(0.8, 0.3, 0.8)  # 紫色
		"legendary":
			return Color(1.0, 0.7, 0.2)  # 金色
		_:
			return Color(0.7, 0.7, 0.7)

func _get_rarity_text(rarity: String) -> String:
	match rarity:
		"common":
			return "普通"
		"uncommon":
			return "优秀"
		"rare":
			return "稀有"
		"epic":
			return "史诗"
		"legendary":
			return "传说"
		_:
			return "普通"

func _format_effects(effects: Dictionary) -> String:
	var lines = []
	
	for key in effects:
		var value = effects[key]
		var display_value = ""
		
		# 格式化数值
		if value is float:
			if value > 0:
				display_value = "+%.1f%%" % (value * 100) if abs(value) < 1.0 else "+%.0f" % value
			else:
				display_value = "%.1f%%" % (value * 100) if abs(value) < 1.0 else "%.0f" % value
		elif value is int:
			display_value = "+%d" % value if value > 0 else "%d" % value
		else:
			display_value = str(value)
		
		# 格式化属性名
		var stat_name = _get_stat_name(key)
		lines.append("%s %s" % [stat_name, display_value])
	
	return "\n".join(lines)

func _get_stat_name(stat: String) -> String:
	match stat:
		"max_hp":
			return "最大生命"
		"move_speed":
			return "移动速度"
		"attack_damage":
			return "攻击伤害"
		"armor":
			return "护甲"
		"critical_chance":
			return "暴击率"
		"critical_damage":
			return "暴击伤害"
		"skill_damage":
			return "技能伤害"
		"skill_cooldown":
			return "技能冷却"
		"attack_speed":
			return "攻击速度"
		"melee_damage":
			return "近战伤害"
		"defense":
			return "防御"
		_:
			return stat

func _on_card_hover(card: Control, is_hover: bool):
	if not is_instance_valid(card):
		return
	
	var style = card.get_theme_stylebox("panel") as StyleBoxFlat
	if not style:
		return
	
	if is_hover:
		# 高亮效果
		var tween = create_tween()
		tween.tween_property(card, "scale", Vector2(1.05, 1.05), 0.2)
		style.shadow_size = 10
		style.border_width_left = 4
		style.border_width_top = 4
		style.border_width_right = 4
		style.border_width_bottom = 4
	else:
		# 恢复
		var tween = create_tween()
		tween.tween_property(card, "scale", Vector2(1.0, 1.0), 0.2)
		style.shadow_size = 5
		style.border_width_left = 3
		style.border_width_top = 3
		style.border_width_right = 3
		style.border_width_bottom = 3

func _on_card_selected(card: Control):
	if _selection_in_progress:
		return
	if not is_instance_valid(card):
		return
	
	var upgrade_id = card.get_meta("upgrade_id", "")
	if upgrade_id.is_empty():
		return
	
	_selection_in_progress = true
	# 播放选择动画
	var tween = create_tween()
	tween.tween_property(card, "modulate", Color(1.5, 1.5, 1.5), 0.1)
	tween.tween_property(card, "modulate", Color(1.0, 1.0, 1.0), 0.1)
	
	await tween.finished
	
	# 发送信号
	emit_signal("card_selected", upgrade_id)
	
	# 隐藏UI
	_hide_ui()

func _hide_ui():
	get_tree().paused = false
	
	# 清理所有子节点
	for child in get_children():
		child.queue_free()
	
	cards.clear()
	_selection_in_progress = false
	hide()

func _input(event):
	if not visible:
		return
	
	# 数字键快捷选择
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_1 and cards.size() > 0:
			_on_card_selected(cards[0])
		elif event.keycode == KEY_2 and cards.size() > 1:
			_on_card_selected(cards[1])
		elif event.keycode == KEY_3 and cards.size() > 2:
			_on_card_selected(cards[2])
