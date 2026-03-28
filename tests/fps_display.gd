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
	
	# 设置位置（左上角）
	position = Vector2(10, 10)
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
