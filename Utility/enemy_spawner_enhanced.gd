extends Node2D

# 增强的敌人生成器 - 支持波次配置

@export var use_wave_config: bool = false
@export var spawns: Array[Spawn_info] = []

@onready var player = get_tree().get_first_node_in_group("player")

@export var time = 0

signal changetime(time)

var wave_config = {}
var boss_events = {}

func _ready():
	connect("changetime", Callable(player, "change_time"))
	
	if use_wave_config:
		_load_wave_config()

func _load_wave_config():
	var cfg = ConfigFile.new()
	if cfg.load("res://config/spawn_waves.ini") != OK:
		push_warning("无法加载 spawn_waves.ini，使用默认生成规则")
		return
	
	for section in cfg.get_sections():
		if section.begins_with("wave_"):
			_parse_wave_config(cfg, section)
		elif section.begins_with("boss_event_"):
			_parse_boss_event(cfg, section)

func _parse_wave_config(cfg: ConfigFile, section: String):
	var wave_data = {
		"name": cfg.get_value(section, "name", ""),
		"start_time": cfg.get_value(section, "start_time", 0),
		"end_time": cfg.get_value(section, "end_time", 999),
		"enemy_types": cfg.get_value(section, "enemy_type", "").split(",", false),
		"spawn_count": cfg.get_value(section, "spawn_count", 1),
		"spawn_delay": cfg.get_value(section, "spawn_delay", 2),
		"description": cfg.get_value(section, "description", "")
	}
	wave_config[section] = wave_data

func _parse_boss_event(cfg: ConfigFile, section: String):
	var boss_data = {
		"name": cfg.get_value(section, "name", ""),
		"trigger_time": cfg.get_value(section, "trigger_time", 300),
		"enemy_type": cfg.get_value(section, "enemy_type", ""),
		"spawn_count": cfg.get_value(section, "spawn_count", 1),
		"is_boss": cfg.get_value(section, "is_boss", true),
		"description": cfg.get_value(section, "description", "")
	}
	boss_events[section] = boss_data

func _on_timer_timeout():
	time += 1
	
	if use_wave_config:
		_spawn_from_wave_config()
	else:
		_spawn_from_spawn_info()
	
	emit_signal("changetime", time)

func _spawn_from_wave_config():
	var enemy_registry = get_node_or_null("/root/EnemyRegistry")
	if enemy_registry == null:
		return
	
	# 处理波次生成
	for wave_id in wave_config:
		var wave = wave_config[wave_id]
		if time >= wave["start_time"] and time <= wave["end_time"]:
			if time % wave["spawn_delay"] == 0:
				for enemy_type in wave["enemy_types"]:
					enemy_type = enemy_type.strip_edges()
					for i in range(wave["spawn_count"]):
						_spawn_enemy(enemy_type, enemy_registry)
	
	# 处理 Boss 事件
	for boss_id in boss_events:
		var boss = boss_events[boss_id]
		if time == boss["trigger_time"]:
			if has_node("/root/EventBus"):
				get_node("/root/EventBus").emit_signal("boss_spawned", boss["enemy_type"])
			
			for i in range(boss["spawn_count"]):
				_spawn_enemy(boss["enemy_type"], enemy_registry)

func _spawn_enemy(enemy_type: String, enemy_registry):
	var enemy = enemy_registry.instantiate_enemy(enemy_type)
	if enemy:
		enemy.global_position = get_random_position()
		add_child(enemy)

func _spawn_from_spawn_info():
	# 原始的生成逻辑
	var enemy_spawns = spawns
	for i in enemy_spawns:
		if time >= i.time_start and time <= i.time_end:
			if i.spawn_delay_counter < i.enemy_spawn_delay:
				i.spawn_delay_counter += 1
			else:
				i.spawn_delay_counter = 0
				var new_enemy = i.enemy
				var counter = 0
				while counter < i.enemy_num:
					var enemy_spawn = new_enemy.instantiate()
					enemy_spawn.global_position = get_random_position()
					add_child(enemy_spawn)
					counter += 1

func get_random_position():
	var vpr = get_viewport_rect().size * randf_range(1.1, 1.4)
	var top_left = Vector2(player.global_position.x - vpr.x/2, player.global_position.y - vpr.y/2)
	var top_right = Vector2(player.global_position.x + vpr.x/2, player.global_position.y - vpr.y/2)
	var bottom_left = Vector2(player.global_position.x - vpr.x/2, player.global_position.y + vpr.y/2)
	var bottom_right = Vector2(player.global_position.x + vpr.x/2, player.global_position.y + vpr.y/2)
	var pos_side = ["up", "down", "right", "left"].pick_random()
	var spawn_pos1 = Vector2.ZERO
	var spawn_pos2 = Vector2.ZERO
	
	match pos_side:
		"up":
			spawn_pos1 = top_left
			spawn_pos2 = top_right
		"down":
			spawn_pos1 = bottom_left
			spawn_pos2 = bottom_right
		"right":
			spawn_pos1 = top_right
			spawn_pos2 = bottom_right
		"left":
			spawn_pos1 = top_left
			spawn_pos2 = bottom_left
	
	var x_spawn = randf_range(spawn_pos1.x, spawn_pos2.x)
	var y_spawn = randf_range(spawn_pos1.y, spawn_pos2.y)
	return Vector2(x_spawn, y_spawn)
