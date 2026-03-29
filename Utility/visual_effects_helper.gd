class_name VisualEffectsHelper
extends Object

## 视觉特效工具类
## 封装所有重复的特效创建代码

const GameConstants = preload("res://Utility/game_constants.gd")

# ========================================
# 屏幕震动
# ========================================

static func trigger_screen_shake(source_node: Node, intensity: float = 0.3):
	if not source_node or not source_node.is_inside_tree():
		return
	
	var viewport = source_node.get_viewport()
	if not viewport:
		return
	
	var camera = viewport.get_camera_2d()
	if camera:
		shake_camera(camera, intensity)

static func shake_camera(camera: Camera2D, intensity: float):
	if not camera:
		return
	
	var shake_amount = intensity * 10.0
	var original_offset = camera.offset
	
	for i in range(8):
		await camera.get_tree().create_timer(0.02).timeout
		if is_instance_valid(camera):
			var shake_x = randf_range(-shake_amount, shake_amount)
			var shake_y = randf_range(-shake_amount, shake_amount)
			camera.offset = original_offset + Vector2(shake_x, shake_y)
			shake_amount *= 0.7
	
	if is_instance_valid(camera):
		camera.offset = original_offset

# ========================================
# 时间缩放（打击停顿）
# ========================================

static func trigger_hit_pause(source_node: Node, duration: float = 0.05):
	if not source_node:
		return
	
	var tree = source_node.get_tree()
	if tree:
		Engine.time_scale = 0.3
		await tree.create_timer(duration * Engine.time_scale).timeout
		Engine.time_scale = 1.0

# ========================================
# 闪烁效果
# ========================================

static func trigger_flash(sprite: Node, color: Color, duration: float = 0.1):
	if not sprite or not sprite is CanvasItem:
		return
	
	var original_modulate = sprite.modulate
	sprite.modulate = color
	
	await sprite.get_tree().create_timer(duration).timeout
	
	if is_instance_valid(sprite):
		sprite.modulate = original_modulate

# ========================================
# 淡出效果
# ========================================

static func fade_out(node: CanvasItem, duration: float = 0.5):
	if not node:
		return
	
	var steps = 10
	var step_time = duration / steps
	var alpha_step = 1.0 / steps
	
	for i in range(steps):
		await node.get_tree().create_timer(step_time).timeout
		if is_instance_valid(node):
			node.modulate.a -= alpha_step
	
	if is_instance_valid(node):
		node.queue_free()

# ========================================
# 缩放动画
# ========================================

static func scale_pulse(node: Node2D, from_scale: float, to_scale: float, duration: float = 0.3):
	if not node:
		return
	
	var steps = 10
	var step_time = duration / steps
	var scale_diff = to_scale - from_scale
	var scale_step = scale_diff / steps
	
	for i in range(steps):
		await node.get_tree().create_timer(step_time).timeout
		if is_instance_valid(node):
			var current_scale = from_scale + scale_step * i
			node.scale = Vector2(current_scale, current_scale)

# ========================================
# 发光效果
# ========================================

static func create_glow_background(size: Vector2, color: Color, alpha: float = 0.0) -> ColorRect:
	var glow = ColorRect.new()
	glow.name = "GlowBackground"
	glow.color = color
	glow.color.a = alpha
	glow.size = size
	glow.z_index = -1
	return glow

static func pulse_glow(glow: ColorRect, base_alpha: float, pulse_amount: float, time: float):
	if not glow or not is_instance_valid(glow):
		return
	
	glow.color.a = base_alpha + sin(time * GameConstants.Values.GLOW_PULSE_SPEED) * pulse_amount

# ========================================
# 边框创建
# ========================================

static func create_border(size: Vector2, color: Color, width: int = 2) -> Panel:
	var border = Panel.new()
	border.name = "Border"
	border.size = size
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color.TRANSPARENT
	style.border_color = color
	style.border_width_left = width
	style.border_width_right = width
	style.border_width_top = width
	style.border_width_bottom = width
	
	border.add_theme_stylebox_override("panel", style)
	return border

# ========================================
# 占位纹理创建
# ========================================

static func create_placeholder_texture(size: Vector2) -> PlaceholderTexture2D:
	var placeholder = PlaceholderTexture2D.new()
	placeholder.size = size
	return placeholder

static func load_texture_or_placeholder(path: String, placeholder_size: Vector2 = Vector2(64, 64)) -> Texture2D:
	if ResourceLoader.exists(path):
		return load(path)
	else:
		return create_placeholder_texture(placeholder_size)

# ========================================
# 粒子效果创建
# ========================================

static func create_simple_particle(pos: Vector2, color: Color, size: float, parent: Node):
	if not parent:
		return
	
	var particle = Sprite2D.new()
	particle.position = pos
	particle.scale = Vector2(size, size)
	particle.modulate = color
	particle.z_index = 10
	particle.texture = create_placeholder_texture(Vector2(8, 8))
	
	parent.call_deferred("add_child", particle)
	fade_out(particle, 0.5)

# ========================================
# 范围指示器
# ========================================

static func create_range_indicator(radius: float, color: Color, parent: Node) -> Sprite2D:
	var indicator = Sprite2D.new()
	indicator.scale = Vector2(radius / 32.0, radius / 32.0)
	indicator.modulate = color
	indicator.z_index = 5
	indicator.texture = create_placeholder_texture(Vector2(64, 64))
	
	if parent:
		parent.call_deferred("add_child", indicator)
	
	return indicator
