extends Control

## 武器栏UI
## 显示当前装备的武器和可切换的武器列表
## 
## 设计：简化占位版本，使用Python生成的图标

const GameConstants = preload("res://Utility/game_constants.gd")

var weapon_registry: Node = null
var current_weapon_display: Panel = null
var weapon_slots: Array = []

func _ready():
	_setup_ui()

func set_weapon_registry(wr: Node):
	weapon_registry = wr
	_update_display()

func _setup_ui():
	# 创建主容器
	var container = VBoxContainer.new()
	container.name = "WeaponContainer"
	container.position = Vector2(10, 100)
	add_child(container)
	
	# 标题
	var title = Label.new()
	title.text = "武器"
	title.add_theme_font_size_override("font_size", 16)
	container.add_child(title)
	
	# 当前武器显示
	current_weapon_display = Panel.new()
	current_weapon_display.custom_minimum_size = Vector2(80, 80)
	current_weapon_display.name = "CurrentWeapon"
	container.add_child(current_weapon_display)
	
	var weapon_icon = TextureRect.new()
	weapon_icon.name = "Icon"
	weapon_icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	weapon_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	weapon_icon.custom_minimum_size = Vector2(64, 64)
	weapon_icon.position = Vector2(8, 8)
	current_weapon_display.add_child(weapon_icon)
	
	var weapon_name = Label.new()
	weapon_name.name = "WeaponName"
	weapon_name.position = Vector2(8, 72)
	weapon_name.add_theme_font_size_override("font_size", 12)
	current_weapon_display.add_child(weapon_name)
	
	# 添加发光边框
	_add_glow_border(current_weapon_display)

func _add_glow_border(panel: Panel):
	var border = ColorRect.new()
	border.name = "GlowBorder"
	border.color = GameConstants.Colors.UI_SKILL_BORDER
	border.color.a = 0.6
	border.size = panel.custom_minimum_size + Vector2(4, 4)
	border.position = Vector2(-2, -2)
	border.z_index = -1
	panel.add_child(border)

func _update_display():
	if not weapon_registry:
		return
	
	var weapon = weapon_registry.get_current_weapon()
	if weapon.is_empty():
		return
	
	# 更新武器名称
	var name_label = current_weapon_display.get_node_or_null("WeaponName")
	if name_label:
		name_label.text = weapon.get("name", "未知")
	
	# 更新武器图标
	var icon = current_weapon_display.get_node_or_null("Icon")
	if icon:
		var icon_path = weapon.get("icon", "")
		if ResourceLoader.exists(icon_path):
			icon.texture = load(icon_path)
		else:
			# 使用占位图标
			icon.texture = _create_weapon_placeholder(weapon.get("weapon_type", "sword"))

func _create_weapon_placeholder(weapon_type: String) -> Texture2D:
	return VisualEffectsHelper.create_placeholder_texture(Vector2(32, 32))

func switch_weapon(weapon_id: String):
	if weapon_registry and weapon_registry.equip_weapon(weapon_id):
		_update_display()
		# 通知玩家重新初始化攻击
		if get_parent() and get_parent().has_method("_reinitialize_weapon"):
			get_parent()._reinitialize_weapon()
