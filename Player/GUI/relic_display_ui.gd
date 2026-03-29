extends Control

## 圣物显示UI
## 显示玩家拥有的圣物
## 
## 设计：简化占位版本

const GameConstants = preload("res://Utility/game_constants.gd")

var relic_manager: Node = null
var relic_slots: Array = []
var max_display: int = 6

func _ready():
	_setup_ui()

func set_relic_manager(rm: Node):
	relic_manager = rm
	if relic_manager:
		relic_manager.relic_acquired.connect(_on_relic_acquired)
	_update_display()

func _setup_ui():
	# 创建主容器
	var container = VBoxContainer.new()
	container.name = "RelicContainer"
	container.position = Vector2(10, 240)
	add_child(container)
	
	# 标题
	var title = Label.new()
	title.text = "圣物"
	title.add_theme_font_size_override("font_size", 16)
	container.add_child(title)
	
	# 圣物槽位网格
	var grid = GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	container.add_child(grid)
	
	# 创建圣物槽位
	for i in range(max_display):
		var slot = Panel.new()
		slot.custom_minimum_size = Vector2(50, 50)
		slot.name = "RelicSlot" + str(i)
		
		var icon = TextureRect.new()
		icon.name = "Icon"
		icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.custom_minimum_size = Vector2(40, 40)
		icon.position = Vector2(5, 5)
		icon.modulate = Color(0.3, 0.3, 0.3)  # 默认灰色
		slot.add_child(icon)
		
		grid.add_child(slot)
		relic_slots.append(slot)

func _update_display():
	if not relic_manager:
		return
	
	var owned_relics = relic_manager.get_owned_relics()
	
	for i in range(relic_slots.size()):
		var slot = relic_slots[i]
		var icon = slot.get_node_or_null("Icon")
		
		if not icon:
			continue
		
		if i < owned_relics.size():
			var relic = owned_relics[i]
			var icon_path = relic.get("icon", "")
			
			if ResourceLoader.exists(icon_path):
				icon.texture = load(icon_path)
			else:
				icon.texture = _create_relic_placeholder(relic.get("rarity", "common"))
			
			icon.modulate = Color.WHITE
			
			# 添加发光效果
			_add_relic_glow(slot, relic.get("rarity", "common"))
		else:
			icon.texture = null
			icon.modulate = Color(0.3, 0.3, 0.3)

func _create_relic_placeholder(rarity: String) -> Texture2D:
	return VisualEffectsHelper.create_placeholder_texture(Vector2(32, 32))

func _add_relic_glow(slot: Panel, rarity: String):
	var existing_glow = slot.get_node_or_null("Glow")
	if existing_glow:
		existing_glow.queue_free()
	
	var glow = ColorRect.new()
	glow.name = "Glow"
	glow.size = slot.custom_minimum_size + Vector2(4, 4)
	glow.position = Vector2(-2, -2)
	glow.z_index = -1
	
	match rarity:
		"epic":
			glow.color = Color(0.7, 0.4, 0.9, 0.5)
		"legendary":
			glow.color = Color(1.0, 0.6, 0.0, 0.6)
		"mythic":
			glow.color = Color(1.0, 0.2, 0.2, 0.7)
		_:
			glow.color = Color(0.5, 0.5, 0.5, 0.3)
	
	slot.add_child(glow)

func _on_relic_acquired(relic_id: String):
	_update_display()
	print("[RelicDisplayUI] 显示新圣物: ", relic_id)
