extends Node2D

## 自动清理节点脚本
## 在指定时间后自动淡出并清理节点

@export var lifetime: float = 5.0  # 生存时间
@export var fade_duration: float = 0.6  # 淡出时间

var elapsed_time: float = 0.0

func _ready():
	set_process(true)

func _process(delta: float):
	elapsed_time += delta
	
	if elapsed_time >= lifetime:
		_start_cleanup()
		set_process(false)

func _start_cleanup():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, fade_duration)
	tween.tween_callback(queue_free)
