extends Control

## 暖雪风格技能栏UI - 升级版
## 显示技能图标、按键、冷却进度和冷却数字
## 添加发光效果和边框装饰

## 技能数据结构
var _skills = {
	"q": {
		"key": "Q",
		"name": "技能1",
		"color": Color(0.4, 0.7, 1.0),
		"glow_color": Color(0.6, 0.85, 1.0),
		"cooldown": 0.0,
		"max_cooldown": 3.0,
		"on_cooldown": false
	},
	"e": {
		"key": "E",
		"name": "技能2",
		"color": Color(0.7, 0.4, 1.0),
		"glow_color": Color(0.85, 0.6, 1.0),
		"cooldown": 0.0,
		"max_cooldown": 5.0,
		"on_cooldown": false
	},
	"r": {
		"key": "R",
		"name": "必杀技",
		"color": Color(1.0, 0.4, 0.6),
		"glow_color": Color(1.0, 0.6, 0.75),
		"cooldown": 0.0,
		"max_cooldown": 10.0,
		"on_cooldown": false
	},
	"shift": {
		"key": "Shift",
		"name": "冲刺",
		"color": Color(0.4, 1.0, 0.6),
		"glow_color": Color(0.6, 1.0, 0.75),
		"cooldown": 0.0,
		"max_cooldown": 0.8,
		"on_cooldown": false
	}
}

## UI节点引用
var _skill_nodes = {}
var _glow_time: float = 0.0

func _ready():
	_create_skill_bar()

func _create_skill_bar():
	var bar_margin = 20
	var slot_size = 72
	var slot_spacing = 10
	var skill_order = ["q", "e", "r", "shift"]
	
	var start_x = bar_margin
	var y = get_viewport_rect().size.y - bar_margin - slot_size
	
	for skill_id in skill_order:
		var skill_data = _skills[skill_id]
		var slot = _create_skill_slot(skill_id, skill_data, slot_size)
		slot.position = Vector2(start_x, y)
		add_child(slot)
		_skill_nodes[skill_id] = slot
		
		start_x += slot_size + slot_spacing

func _create_skill_slot(skill_id: String, skill_data: Dictionary, size: int) -> Control:
	var slot = Control.new()
	slot.name = "SkillSlot_%s" % skill_id
	slot.custom_minimum_size = Vector2(size, size)
	
	var glow_bg = ColorRect.new()
	glow_bg.name = "GlowBackground"
	glow_bg.color = skill_data["glow_color"]
	glow_bg.size = Vector2(size + 6, size + 6)
	glow_bg.position = Vector2(-3, -3)
	glow_bg.modulate.a = 0.0
	slot.add_child(glow_bg)
	
	var border = ColorRect.new()
	border.name = "Border"
	border.color = Color(0.2, 0.2, 0.25, 1.0)
	border.size = Vector2(size + 4, size + 4)
	border.position = Vector2(-2, -2)
	slot.add_child(border)
	
	var bg = TextureRect.new()
	bg.name = "Background"
	bg.texture = load("res://Textures/UI/skill_slot_%s.png" % skill_id)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	bg.size = Vector2(size, size)
	slot.add_child(bg)
	
	var cooldown_overlay = ColorRect.new()
	cooldown_overlay.name = "CooldownOverlay"
	cooldown_overlay.color = Color(0, 0, 0, 0.75)
	cooldown_overlay.size = Vector2(size, size)
	cooldown_overlay.visible = false
	slot.add_child(cooldown_overlay)
	
	var cooldown_label = Label.new()
	cooldown_label.name = "CooldownLabel"
	cooldown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cooldown_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	cooldown_label.size = Vector2(size, size)
	cooldown_label.add_theme_font_size_override("font_size", 24)
	cooldown_label.add_theme_color_override("font_color", Color.WHITE)
	cooldown_label.add_theme_color_override("font_outline_color", Color.BLACK)
	cooldown_label.add_theme_constant_override("outline_size", 2)
	cooldown_label.visible = false
	slot.add_child(cooldown_label)
	
	var key_label = Label.new()
	key_label.name = "KeyLabel"
	key_label.text = skill_data["key"]
	key_label.position = Vector2(4, size - 20)
	key_label.size = Vector2(size - 8, 16)
	key_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	key_label.add_theme_font_size_override("font_size", 14)
	key_label.add_theme_color_override("font_color", skill_data["color"])
	key_label.add_theme_color_override("font_outline_color", Color.BLACK)
	key_label.add_theme_constant_override("outline_size", 2)
	slot.add_child(key_label)
	
	return slot

func update_skill_cooldown(skill_id: String, current_cooldown: float, max_cooldown: float):
	if not _skills.has(skill_id):
		return
	
	_skills[skill_id]["cooldown"] = current_cooldown
	_skills[skill_id]["max_cooldown"] = max_cooldown
	_skills[skill_id]["on_cooldown"] = current_cooldown > 0
	
	if _skill_nodes.has(skill_id):
		var slot = _skill_nodes[skill_id]
		var cooldown_overlay = slot.get_node_or_null("CooldownOverlay")
		var cooldown_label = slot.get_node_or_null("CooldownLabel")
		var glow_bg = slot.get_node_or_null("GlowBackground")
		
		if cooldown_overlay:
			if current_cooldown > 0:
				cooldown_overlay.visible = true
				var progress = current_cooldown / max_cooldown
				cooldown_overlay.size = Vector2(slot.custom_minimum_size.x, slot.custom_minimum_size.y * progress)
				cooldown_overlay.position = Vector2(0, slot.custom_minimum_size.y * (1 - progress))
				
				if cooldown_label:
					cooldown_label.visible = true
					cooldown_label.text = "%.1f" % current_cooldown
				
				if glow_bg:
					glow_bg.modulate.a = 0.0
			else:
				cooldown_overlay.visible = false
				if cooldown_label:
					cooldown_label.visible = false
				if glow_bg:
					_trigger_ready_glow(glow_bg)

func _process(delta: float):
	_glow_time += delta
	
	for skill_id in _skills:
		var skill_data = _skills[skill_id]
		if skill_data["on_cooldown"]:
			skill_data["cooldown"] -= delta
			if skill_data["cooldown"] <= 0:
				skill_data["cooldown"] = 0
				skill_data["on_cooldown"] = false
			update_skill_cooldown(skill_id, skill_data["cooldown"], skill_data["max_cooldown"])
		else:
			_update_idle_glow(skill_id)

func trigger_skill_cooldown(skill_id: String, cooldown_time: float):
	if _skills.has(skill_id):
		_skills[skill_id]["cooldown"] = cooldown_time
		_skills[skill_id]["max_cooldown"] = cooldown_time
		_skills[skill_id]["on_cooldown"] = true

func _trigger_ready_glow(glow_bg: ColorRect):
	var tween = create_tween()
	tween.tween_property(glow_bg, "modulate:a", 0.8, 0.3)
	tween.tween_property(glow_bg, "modulate:a", 0.3, 0.3)
	tween.play()

func _update_idle_glow(skill_id: String):
	if not _skill_nodes.has(skill_id):
		return
	
	var slot = _skill_nodes[skill_id]
	var glow_bg = slot.get_node_or_null("GlowBackground")
	
	if glow_bg and not _skills[skill_id]["on_cooldown"]:
		var pulse = (sin(_glow_time * 2.0) + 1.0) * 0.5
		glow_bg.modulate.a = 0.2 + pulse * 0.3
