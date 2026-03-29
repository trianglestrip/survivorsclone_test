extends Node

## 关卡管理器
## 管理关卡进度、房间切换和Boss战
## 
## 设计原则：
## 1. 从JSON配置加载关卡数据
## 2. 管理房间切换和进度
## 3. 触发Boss战和奖励

signal room_started(room_id: String)
signal room_completed(room_id: String)
signal level_completed(level_id: String)
signal boss_spawned(boss_id: String)

const GameConstants = preload("res://Utility/game_constants.gd")

var levels: Dictionary = {}
var bosses: Dictionary = {}
var current_level_id: String = ""
var current_room_index: int = 0
var room_timer: float = 0.0
var room_duration: float = 60.0
var room_active: bool = false

func _ready():
	_load_level_config()

func _load_level_config():
	var config_path = "res://config/level_config.json"
	var file = FileAccess.open(config_path, FileAccess.READ)
	
	if not file:
		push_error("无法加载关卡配置: " + config_path)
		return
	
	var json_text = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_text)
	
	if parse_result != OK:
		push_error("关卡配置JSON解析失败")
		return
	
	var config = json.get_data()
	
	if config.has("levels"):
		levels = config["levels"]
		print("[LevelManager] 加载了 %d 个关卡配置" % levels.size())
	
	if config.has("bosses"):
		bosses = config["bosses"]
		print("[LevelManager] 加载了 %d 个Boss配置" % bosses.size())

func _process(delta: float):
	if not room_active:
		return
	
	room_timer += delta
	
	# 检查房间是否完成
	if room_timer >= room_duration:
		_complete_current_room()

## 开始关卡
func start_level(level_id: String):
	if not levels.has(level_id):
		push_warning("关卡不存在: " + level_id)
		return false
	
	current_level_id = level_id
	current_room_index = 0
	
	print("[LevelManager] 开始关卡: ", levels[level_id].get("name", level_id))
	
	_start_current_room()
	return true

## 开始当前房间
func _start_current_room():
	var level = levels.get(current_level_id, {})
	if level.is_empty():
		return
	
	var rooms = level.get("rooms", [])
	if current_room_index >= rooms.size():
		_complete_level()
		return
	
	var room = rooms[current_room_index]
	var room_id = room.get("id", "")
	var room_type = room.get("type", "combat")
	
	room_duration = room.get("duration", 60.0)
	room_timer = 0.0
	room_active = true
	
	print("[LevelManager] 开始房间: ", room.get("name", room_id), " (", room_type, ")")
	
	emit_signal("room_started", room_id)
	
	# 如果是Boss房间，生成Boss
	if room_type == "boss":
		var boss_id = room.get("boss", "")
		if not boss_id.is_empty():
			_spawn_boss(boss_id)

## 完成当前房间
func _complete_current_room():
	var level = levels.get(current_level_id, {})
	if level.is_empty():
		return
	
	var rooms = level.get("rooms", [])
	if current_room_index >= rooms.size():
		return
	
	var room = rooms[current_room_index]
	var room_id = room.get("id", "")
	
	room_active = false
	
	print("[LevelManager] 完成房间: ", room.get("name", room_id))
	
	emit_signal("room_completed", room_id)
	
	# 给予奖励
	_give_room_rewards(room)
	
	# 进入下一房间
	current_room_index += 1
	
	# 短暂延迟后开始下一房间
	await get_tree().create_timer(2.0).timeout
	_start_current_room()

## 完成关卡
func _complete_level():
	print("[LevelManager] 完成关卡: ", levels[current_level_id].get("name", current_level_id))
	emit_signal("level_completed", current_level_id)

## 生成Boss
func _spawn_boss(boss_id: String):
	if not bosses.has(boss_id):
		push_warning("Boss不存在: " + boss_id)
		return
	
	var boss_config = bosses[boss_id]
	
	print("[LevelManager] 生成Boss: ", boss_config.get("name", boss_id))
	
	emit_signal("boss_spawned", boss_id)

## 给予房间奖励
func _give_room_rewards(room: Dictionary):
	var rewards = room.get("rewards", {})
	
	var exp_mult = rewards.get("exp_multiplier", 1.0)
	var relic_chance = rewards.get("relic_chance", 0.0)
	var guaranteed_relic = rewards.get("guaranteed_relic", "")
	
	print("[LevelManager] 房间奖励: 经验x%.1f, 圣物几率%.1f%%" % [exp_mult, relic_chance * 100])

## 获取当前房间信息
func get_current_room() -> Dictionary:
	var level = levels.get(current_level_id, {})
	if level.is_empty():
		return {}
	
	var rooms = level.get("rooms", [])
	if current_room_index >= rooms.size():
		return {}
	
	return rooms[current_room_index]

## 获取关卡信息
func get_level(level_id: String) -> Dictionary:
	if levels.has(level_id):
		return levels[level_id]
	return {}

## 获取Boss信息
func get_boss(boss_id: String) -> Dictionary:
	if bosses.has(boss_id):
		return bosses[boss_id]
	return {}
