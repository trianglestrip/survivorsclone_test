extends Control

var level = "res://World/world.tscn"

@onready var btn_sound = $btn_sound

func _ready():
	_update_sound_button()

func _on_btn_play_click_end():
	var _level = get_tree().change_scene_to_file(level)

func _on_btn_exit_click_end():
	get_tree().quit()

func _on_btn_sound_click_end():
	AudioManager.toggle_sound()
	_update_sound_button()

func _update_sound_button():
	if btn_sound != null:
		if AudioManager.is_sound_enabled():
			btn_sound.text = "声音：开"
		else:
			btn_sound.text = "声音：关"
