extends Sprite2D

## 自动淡出的精灵
## 加入场景树后自动淡出并删除

const VisualEffectsHelper = preload("res://Utility/visual_effects_helper.gd")
const GameConstants = preload("res://Utility/game_constants.gd")

@export var fade_duration: float = 1.0

func _ready():
	_start_fade()

func _start_fade():
	await VisualEffectsHelper.fade_out(self, fade_duration)
