extends Node

# 音频管理器 - 控制游戏音效和音乐

var sound_enabled = false  # 默认关闭声音

func _ready():
	_apply_sound_settings()

# 切换声音开关
func toggle_sound() -> bool:
	sound_enabled = !sound_enabled
	_apply_sound_settings()
	return sound_enabled

# 设置声音状态
func set_sound_enabled(enabled: bool):
	sound_enabled = enabled
	_apply_sound_settings()

# 应用声音设置
func _apply_sound_settings():
	var master_bus_idx = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_mute(master_bus_idx, !sound_enabled)
	
	if sound_enabled:
		print("🔊 声音已开启")
	else:
		print("🔇 声音已关闭")

# 获取当前状态
func is_sound_enabled() -> bool:
	return sound_enabled
