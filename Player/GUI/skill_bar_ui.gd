extends Control

## 暖雪风格技能栏UI
## 显示技能图标、按键和冷却进度

## 技能数据结构
var _skills = {
	"q": {
		"key": "Q",
		"color": Color(100/255, 150/255, 255/255),
		"cooldown": 0.0,
		"max_cooldown": 3.0,
		"on_cooldown": false
	},
	"e": {
		"key": "E",
		"color": Color(150/255, 100/255, 255/255),
		"cooldown": 0.0,
		"max_cooldown": 5.0,
		"on_cooldown": false
	},
	"r": {
		"key": "R",
		"color": Color(255/255, 100/255, 150/255),
		"cooldown": 0.0,
		"max_cooldown": 10.0,
		"on_cooldown": false
	},
	"shift": {
		"key": "Shift",
		"color": Color(100/255, 255/255, 150/255),
		"cooldown": 0.0,
		"max_cooldown": 1.0,
		"on_cooldown": false
	}
}

## UI节点引用
var _skill_nodes = {}

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
	
	var bg = TextureRect.new()
	bg.name = "Background"
	bg.texture = load("res://Textures/UI/skill_slot_%s.png" % skill_id)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	slot.add_child(bg)
	
	var cooldown_overlay = ColorRect.new()
	cooldown_overlay.name = "CooldownOverlay"
	cooldown_overlay.color = Color(0, 0, 0, 0.7)
	cooldown_overlay.size = Vector2(size, size)
	cooldown_overlay.visible = false
	slot.add_child(cooldown_overlay)
	
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
		
		if cooldown_overlay:
			if current_cooldown > 0:
				cooldown_overlay.visible = true
				var progress = current_cooldown / max_cooldown
				cooldown_overlay.size = Vector2(slot.custom_minimum_size.x, slot.custom_minimum_size.y * progress)
				cooldown_overlay.position = Vector2(0, slot.custom_minimum_size.y * (1 - progress))
			else:
				cooldown_overlay.visible = false

func _process(delta: float):
	for skill_id in _skills:
		var skill_data = _skills[skill_id]
		if skill_data["on_cooldown"]:
			skill_data["cooldown"] -= delta
			if skill_data["cooldown"] <= 0:
				skill_data["cooldown"] = 0
				skill_data["on_cooldown"] = false
			update_skill_cooldown(skill_id, skill_data["cooldown"], skill_data["max_cooldown"])

func trigger_skill_cooldown(skill_id: String, cooldown_time: float):
	if _skills.has(skill_id):
		_skills[skill_id]["cooldown"] = cooldown_time
		_skills[skill_id]["max_cooldown"] = cooldown_time
		_skills[skill_id]["on_cooldown"] = true
