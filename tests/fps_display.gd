extends Label

# FPS 显示组件

var frame_count = 0
var elapsed_time = 0.0
var fps = 0.0

func _ready():
	# 设置标签样式
	add_theme_font_size_override("font_size", 24)
	add_theme_color_override("font_color", Color.YELLOW)
	add_theme_color_override("font_outline_color", Color.BLACK)
	add_theme_constant_override("outline_size", 2)
	
	# 设置位置（左下角）
	# 使用 anchors 确保在不同分辨率下都在左下角
	anchor_top = 1.0
	anchor_bottom = 1.0
	offset_left = 10.0
	offset_top = -40.0
	offset_right = 150.0
	offset_bottom = -10.0
	z_index = 100

func _process(delta):
	frame_count += 1
	elapsed_time += delta
	
	# 每 0.5 秒更新一次 FPS 显示
	if elapsed_time >= 0.5:
		fps = frame_count / elapsed_time
		text = "FPS: %.1f" % fps
		frame_count = 0
		elapsed_time = 0.0
