extends Node2D

## 高级敌人生成器
## 支持波次系统和多种敌人类型
## 
## 设计：从enemy_config.json读取波次配置

@export var spawn_interval: float = 2.0
@export var max_enemies: int = 30
@export var spawn_distance: float = 400.0
@export var enabled: bool = true

var spawn_timer: float = 0.0
var player: Node = null
var enemy_registry: Node = null
var current_wave: int = 1
var wave_timer: float = 0.0
var wave_duration: float = 30.0

# 敌人场景映射
var enemy_scenes: Dictionary = {
	"melee": "res://Enemy/melee_enemy.tscn",
	"ranged": "res://Enemy/ranged_enemy.tscn",
	"elite": "res://Enemy/elite_enemy.tscn"
}

func _ready():
	_find_player()
	_find_enemy_registry()
	_load_wave_config()

func _find_player():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]

func _find_enemy_registry():
	if not enemy_registry:
		enemy_registry = Node.new()
		var script = load("res://Utility/enemy_registry.gd")
		enemy_registry.set_script(script)
		add_child(enemy_registry)

func _load_wave_config():
	if not enemy_registry:
		return
	
	var wave_config = enemy_registry.get_wave(current_wave)
	if not wave_config.is_empty():
		wave_duration = wave_config.get("duration", 30.0)
		print("[AdvancedEnemySpawner] 波次 %d 开始，持续 %.1fs" % [current_wave, wave_duration])

func _process(delta: float):
	if not enabled or not player or not enemy_registry:
		return
	
	wave_timer += delta
	
	# 检查是否进入下一波
	if wave_timer >= wave_duration:
		_advance_wave()
	
	# 检查敌人数量
	var current_enemies = get_tree().get_nodes_in_group("enemies")
	if current_enemies.size() >= max_enemies:
		return
	
	spawn_timer += delta
	
	if spawn_timer >= spawn_interval:
		spawn_timer = 0.0
		_spawn_enemy()

func _advance_wave():
	current_wave += 1
	wave_timer = 0.0
	
	var wave_config = enemy_registry.get_wave(current_wave)
	if wave_config.is_empty():
		print("[AdvancedEnemySpawner] 所有波次完成")
		enabled = false
		return
	
	wave_duration = wave_config.get("duration", 30.0)
	print("[AdvancedEnemySpawner] 波次 %d 开始，持续 %.1fs" % [current_wave, wave_duration])

func _spawn_enemy():
	if not player:
		return
	
	# 根据当前波次随机选择敌人
	var enemy_id = enemy_registry.get_random_enemy_from_wave(current_wave)
	if enemy_id.is_empty():
		return
	
	var enemy_config = enemy_registry.get_enemy(enemy_id)
	if enemy_config.is_empty():
		return
	
	# 在玩家周围随机位置生成
	var angle = randf() * TAU
	var spawn_pos = player.global_position + Vector2(cos(angle), sin(angle)) * spawn_distance
	
	_create_enemy(spawn_pos, enemy_config)

func _create_enemy(pos: Vector2, config: Dictionary):
	var enemy_type = config.get("type", "melee")
	var scene_path = ""
	
	# 根据类型选择场景
	if enemy_type == "elite":
		scene_path = enemy_scenes.get("elite", "res://Enemy/simple_enemy.tscn")
	elif enemy_type == "ranged":
		scene_path = enemy_scenes.get("ranged", "res://Enemy/simple_enemy.tscn")
	else:
		scene_path = enemy_scenes.get("melee", "res://Enemy/simple_enemy.tscn")
	
	# 如果专用场景不存在，使用simple_enemy
	if not ResourceLoader.exists(scene_path):
		scene_path = "res://Enemy/simple_enemy.tscn"
	
	var enemy_scene = load(scene_path)
	var enemy = enemy_scene.instantiate()
	enemy.global_position = pos
	
	# 加载配置
	if enemy.has_method("load_config"):
		enemy.load_config(config)
	
	get_parent().call_deferred("add_child", enemy)
