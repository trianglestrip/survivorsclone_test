extends Control
class_name EnhancedHealthBar

## 暖雪风格血条UI
## 特点：平滑过渡、颜色渐变、边框装饰

@export var max_health: float = 100.0
@export var current_health: float = 100.0

var _display_health: float = 100.0
var _smooth_speed: float = 5.0

## UI节点
var _background: ColorRect
var _border: ColorRect
var _health_fill: ColorRect
var _health_damage: ColorRect
var _health_label: Label
var _glow: ColorRect

func _ready():
	_create_health_bar()
	_display_health = current_health

func _create_health_bar():
	custom_minimum_size = Vector2(300, 32)
	
	_border = ColorRect.new()
	_border.name = "Border"
	_border.color = Color(0.15, 0.15, 0.2, 1.0)
	_border.size = Vector2(304, 36)
	_border.position = Vector2(-2, -2)
	add_child(_border)
	
	_glow = ColorRect.new()
	_glow.name = "Glow"
	_glow.color = Color(0.8, 0.2, 0.2, 0.3)
	_glow.size = Vector2(306, 38)
	_glow.position = Vector2(-3, -3)
	_glow.z_index = -1
	add_child(_glow)
	
	_background = ColorRect.new()
	_background.name = "Background"
	_background.color = Color(0.1, 0.1, 0.15, 0.9)
	_background.size = Vector2(300, 32)
	add_child(_background)
	
	_health_damage = ColorRect.new()
	_health_damage.name = "HealthDamage"
	_health_damage.color = Color(0.6, 0.1, 0.1, 0.8)
	_health_damage.size = Vector2(300, 32)
	add_child(_health_damage)
	
	_health_fill = ColorRect.new()
	_health_fill.name = "HealthFill"
	_health_fill.size = Vector2(300, 32)
	add_child(_health_fill)
	
	_health_label = Label.new()
	_health_label.name = "HealthLabel"
	_health_label.text = "%d / %d" % [current_health, max_health]
	_health_label.size = Vector2(300, 32)
	_health_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_health_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_health_label.add_theme_font_size_override("font_size", 16)
	_health_label.add_theme_color_override("font_color", Color.WHITE)
	_health_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_health_label.add_theme_constant_override("outline_size", 2)
	add_child(_health_label)

func _process(delta: float):
	if _display_health != current_health:
		_display_health = lerp(_display_health, current_health, delta * _smooth_speed)
		if abs(_display_health - current_health) < 0.5:
			_display_health = current_health
		_update_health_bar()
	
	_update_glow_pulse(delta)

func set_health(value: float, max_value: float):
	var old_health = current_health
	current_health = clamp(value, 0, max_value)
	max_health = max_value
	
	if current_health < old_health:
		_trigger_damage_flash()
	
	_update_health_bar()

func _update_health_bar():
	if not _health_fill or not _health_label:
		return
	
	var health_percent = current_health / max_health if max_health > 0 else 0
	var display_percent = _display_health / max_health if max_health > 0 else 0
	
	_health_fill.size.x = 300 * health_percent
	_health_damage.size.x = 300 * display_percent
	
	_health_fill.color = _get_health_color(health_percent)
	
	_health_label.text = "%d / %d" % [int(current_health), int(max_health)]

func _get_health_color(percent: float) -> Color:
	if percent > 0.6:
		return Color(0.2, 0.8, 0.3, 1.0)
	elif percent > 0.3:
		return Color(0.9, 0.7, 0.2, 1.0)
	else:
		return Color(0.9, 0.2, 0.2, 1.0)

func _trigger_damage_flash():
	if not _health_fill:
		return
	
	var original_color = _health_fill.color
	_health_fill.color = Color.WHITE
	
	await get_tree().create_timer(0.1).timeout
	if is_instance_valid(_health_fill):
		_health_fill.color = original_color

func _update_glow_pulse(delta: float):
	if not _glow:
		return
	
	var health_percent = current_health / max_health if max_health > 0 else 0
	
	if health_percent < 0.3:
		var pulse = (sin(Time.get_ticks_msec() * 0.008) + 1.0) * 0.5
		_glow.modulate.a = 0.3 + pulse * 0.4
		_glow.color = Color(1.0, 0.2, 0.2, 1.0)
	else:
		_glow.modulate.a = 0.1
		_glow.color = Color(0.8, 0.2, 0.2, 0.3)
