class_name VisualEffectsHelper
extends Object

## 视觉特效工具类
## 封装所有重复的特效创建代码

const GameConstants = preload("res://Utility/game_constants.gd")

## Q 技能（弹射物 / 单体打击）精灵基础缩放，适配不同分辨率下体量适中
const Q_SKILL_VISUAL_SCALE_MIN := 1.2
const Q_SKILL_VISUAL_SCALE_MAX := 1.5
const Q_SKILL_VISUAL_SCALE_DEFAULT := 1.35

## E 技能圆形领域：视觉缩放 = 半径 / 参考半径（与碰撞半径同量级）
const E_SKILL_RADIUS_REFERENCE := 100.0

## R 技能终极：视觉缩放 = 半径 / 参考半径（比 E 略大，强化存在感）
const R_SKILL_RADIUS_REFERENCE := 150.0

## 火墙矩形领域：纹理按默认宽高对齐碰撞盒（与 sect 默认 width/height 一致）
const E_SKILL_FIRE_WALL_REF_SIZE := Vector2(200.0, 80.0)

static func q_skill_scale_vector(custom: float = 0.0) -> Vector2:
	var s: float = custom if custom > 0.0 else Q_SKILL_VISUAL_SCALE_DEFAULT
	s = clampf(s, Q_SKILL_VISUAL_SCALE_MIN, Q_SKILL_VISUAL_SCALE_MAX)
	return Vector2(s, s)

static func e_skill_scale_from_radius(radius: float) -> float:
	return radius / E_SKILL_RADIUS_REFERENCE

static func e_skill_scale_vector(radius: float) -> Vector2:
	var s := e_skill_scale_from_radius(radius)
	return Vector2(s, s)

static func r_skill_scale_from_radius(radius: float) -> float:
	return radius / R_SKILL_RADIUS_REFERENCE

static func r_skill_scale_vector(radius: float) -> Vector2:
	var s := r_skill_scale_from_radius(radius)
	return Vector2(s, s)

static func e_skill_fire_wall_scale(width: float, height: float) -> Vector2:
	return Vector2(width / E_SKILL_FIRE_WALL_REF_SIZE.x, height / E_SKILL_FIRE_WALL_REF_SIZE.y)

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
	if not camera or not is_instance_valid(camera):
		return
	
	var shake_amount = intensity * 10.0
	var original_offset = camera.offset
	var tree = camera.get_tree()
	if not tree:
		return
	
	for i in range(8):
		await tree.create_timer(0.02).timeout
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
	
	# 等待节点加入场景树
	if not node.is_inside_tree():
		await node.tree_entered
	
	if not is_instance_valid(node) or not node.is_inside_tree():
		return
	
	var tree = node.get_tree()
	if not tree:
		return
	
	var steps = 10
	var step_time = duration / steps
	var alpha_step = 1.0 / steps
	
	for i in range(steps):
		await tree.create_timer(step_time).timeout
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

static func create_glow_background(bg_size: Vector2, color: Color, alpha: float = 0.0) -> ColorRect:
	var glow = ColorRect.new()
	glow.name = "GlowBackground"
	glow.color = color
	glow.color.a = alpha
	glow.size = bg_size
	glow.z_index = -1
	return glow

static func pulse_glow(glow: ColorRect, base_alpha: float, pulse_amount: float, time: float):
	if not glow or not is_instance_valid(glow):
		return
	
	glow.color.a = base_alpha + sin(time * GameConstants.Values.GLOW_PULSE_SPEED) * pulse_amount

# ========================================
# 边框创建
# ========================================

static func create_border(border_size: Vector2, color: Color, width: int = 2) -> Panel:
	var border = Panel.new()
	border.name = "Border"
	border.size = border_size
	
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

static func create_placeholder_texture(texture_size: Vector2) -> PlaceholderTexture2D:
	var placeholder = PlaceholderTexture2D.new()
	placeholder.size = texture_size
	return placeholder

static func create_gradient_texture(texture_size: Vector2, center_color: Color, edge_color: Color) -> ImageTexture:
	var image = Image.create(int(texture_size.x), int(texture_size.y), false, Image.FORMAT_RGBA8)
	var center = texture_size / 2.0
	var max_dist = center.length()
	
	for x in range(int(texture_size.x)):
		for y in range(int(texture_size.y)):
			var pos = Vector2(x, y)
			var dist = pos.distance_to(center)
			var t = clamp(dist / max_dist, 0.0, 1.0)
			var color = center_color.lerp(edge_color, t)
			image.set_pixel(x, y, color)
	
	return ImageTexture.create_from_image(image)

static func create_circle_texture(texture_size: Vector2, color: Color, soft_edge: bool = true) -> ImageTexture:
	var image = Image.create(int(texture_size.x), int(texture_size.y), false, Image.FORMAT_RGBA8)
	var center = texture_size / 2.0
	var radius = min(center.x, center.y)
	
	for x in range(int(texture_size.x)):
		for y in range(int(texture_size.y)):
			var pos = Vector2(x, y)
			var dist = pos.distance_to(center)
			
			if soft_edge:
				var edge_softness = radius * 0.2
				var alpha = 1.0 - clamp((dist - radius + edge_softness) / edge_softness, 0.0, 1.0)
				var pixel_color = color
				pixel_color.a *= alpha
				image.set_pixel(x, y, pixel_color)
			else:
				if dist <= radius:
					image.set_pixel(x, y, color)
				else:
					image.set_pixel(x, y, Color(0, 0, 0, 0))
	
	return ImageTexture.create_from_image(image)

static func load_texture_or_placeholder(path: String, placeholder_size: Vector2 = Vector2(64, 64)) -> Texture2D:
	if ResourceLoader.exists(path):
		return load(path)
	else:
		return create_placeholder_texture(placeholder_size)

# ========================================
# 粒子效果创建
# ========================================

static func create_simple_particle(pos: Vector2, color: Color, particle_size: float, parent: Node):
	if not parent:
		return
	
	var particle = Sprite2D.new()
	particle.position = pos
	particle.scale = Vector2(particle_size, particle_size)
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
