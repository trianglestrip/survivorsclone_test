extends Sprite2D

## 动画技能精灵
## 自动播放技能动画帧

## 动画帧数组
var frames: Array = []
## 当前帧索引
var current_frame: int = 0
## 帧率（FPS）
var fps: float = 10.0
## 是否循环
var loop: bool = true
## 播放完成后是否自动销毁
var auto_destroy: bool = false

var frame_timer: float = 0.0
var is_playing: bool = false

func _ready():
	if frames.size() > 0:
		play()

func _process(delta):
	if not is_playing or frames.size() == 0:
		return
	
	frame_timer += delta
	var frame_duration = 1.0 / fps
	
	if frame_timer >= frame_duration:
		frame_timer = 0.0
		current_frame += 1
		
		if current_frame >= frames.size():
			if loop:
				current_frame = 0
			else:
				is_playing = false
				if auto_destroy:
					var parent = get_parent()
					if parent:
						parent.queue_free()
				return
		
		_update_texture()

func _update_texture():
	if current_frame >= 0 and current_frame < frames.size():
		texture = frames[current_frame]

## 设置动画帧
func set_frames(new_frames: Array):
	frames = new_frames
	current_frame = 0
	if frames.size() > 0:
		_update_texture()

## 播放动画
func play():
	is_playing = true
	current_frame = 0
	frame_timer = 0.0
	_update_texture()

## 停止动画
func stop():
	is_playing = false

## 从技能名称加载动画帧
func load_from_skill(skill_name: String, texture_loader: Node = null):
	if not texture_loader:
		# 尝试查找全局加载器（只在已加入场景树时）
		if is_inside_tree():
			texture_loader = get_node_or_null("/root/SkillTextureLoader")
		
		# 如果没有全局加载器，创建临时加载器
		if not texture_loader:
			texture_loader = load("res://Utility/skill_texture_loader.gd").new()
	
	if texture_loader and texture_loader.has_method("load_skill_frames"):
		var loaded_frames = texture_loader.load_skill_frames(skill_name)
		if loaded_frames.size() > 0:
			set_frames(loaded_frames)
			return true
	
	return false
