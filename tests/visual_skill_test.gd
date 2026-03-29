extends Node2D

## 可视化技能特效测试
## 在屏幕上展示所有技能的动画帧

const SkillTextureLoader = preload("res://Utility/skill_texture_loader.gd")
const AnimatedSkillSprite = preload("res://Utility/animated_skill_sprite.gd")

var texture_loader = null
var skill_displays = []

func _ready():
	texture_loader = SkillTextureLoader.new()
	add_child(texture_loader)
	
	_create_skill_gallery()
	
	# 添加说明文本
	var label = Label.new()
	label.position = Vector2(20, 20)
	label.text = "技能特效展示 - 所有动画帧\n按ESC退出"
	label.add_theme_font_size_override("font_size", 20)
	add_child(label)

func _create_skill_gallery():
	var skills = [
		# 冰心宗
		{"name": "ice_shard", "display": "冰晶碎片(Q)", "color": Color(0.4, 0.8, 1.0)},
		{"name": "ice_field", "display": "冰封领域(E)", "color": Color(0.4, 0.8, 1.0)},
		{"name": "ice_storm", "display": "冰霜风暴(R)", "color": Color(0.4, 0.8, 1.0)},
		# 雷鸣宗
		{"name": "thunder_strike", "display": "雷霆一击(Q)", "color": Color(0.6, 0.4, 1.0)},
		{"name": "thunder_field", "display": "雷电领域(E)", "color": Color(0.6, 0.4, 1.0)},
		{"name": "thunder_god", "display": "雷神降世(R)", "color": Color(0.6, 0.4, 1.0)},
		# 烈焰宗
		{"name": "fire_ball", "display": "火球术(Q)", "color": Color(1.0, 0.5, 0.2)},
		{"name": "fire_wall", "display": "火墙(E)", "color": Color(1.0, 0.5, 0.2)},
		{"name": "fire_meteor", "display": "流星火雨(R)", "color": Color(1.0, 0.5, 0.2)},
		# 毒瘴宗
		{"name": "poison_dart", "display": "毒镖(Q)", "color": Color(0.4, 1.0, 0.4)},
		{"name": "poison_cloud", "display": "毒云(E)", "color": Color(0.4, 1.0, 0.4)},
		{"name": "poison_plague", "display": "瘟疫(R)", "color": Color(0.4, 1.0, 0.4)}
	]
	
	var cols = 4
	var start_x = 150
	var start_y = 100
	var spacing_x = 250
	var spacing_y = 200
	
	for i in range(skills.size()):
		var skill = skills[i]
		var col = i % cols
		var row = i / cols
		var pos = Vector2(start_x + col * spacing_x, start_y + row * spacing_y)
		
		_create_skill_display(skill["name"], skill["display"], skill["color"], pos)

func _create_skill_display(skill_name: String, display_name: String, color: Color, pos: Vector2):
	var container = Node2D.new()
	container.position = pos
	add_child(container)
	
	# 标题
	var title = Label.new()
	title.text = display_name
	title.position = Vector2(-60, -80)
	title.add_theme_font_size_override("font_size", 14)
	title.add_theme_color_override("font_color", color)
	container.add_child(title)
	
	# 动画精灵
	var sprite = AnimatedSkillSprite.new()
	sprite.scale = Vector2(3.0, 3.0)
	sprite.fps = 8.0
	sprite.loop = true
	
	# 加载动画帧
	var frames = texture_loader.load_skill_frames(skill_name)
	if frames.size() > 0:
		sprite.set_frames(frames)
		sprite.play()
		
		# 帧数信息
		var info = Label.new()
		info.text = "%d frames" % frames.size()
		info.position = Vector2(-30, 60)
		info.add_theme_font_size_override("font_size", 12)
		info.modulate = Color(0.7, 0.7, 0.7)
		container.add_child(info)
	else:
		# 显示错误
		var error = Label.new()
		error.text = "No frames"
		error.position = Vector2(-30, 0)
		error.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
		container.add_child(error)
	
	container.add_child(sprite)
	skill_displays.append(container)

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
