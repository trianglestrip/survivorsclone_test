extends Node2D

## 圣物生成器
## 定期在随机位置生成圣物掉落
## 
## 设计：简化版本，用于测试

@export var spawn_interval: float = 15.0
@export var spawn_distance: float = 300.0
@export var max_relics: int = 3

var spawn_timer: float = 0.0
var player: Node = null
var relic_registry: Node = null
var spawned_count: int = 0

func _ready():
	_find_player()
	_find_relic_registry()

func _find_player():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]

func _find_relic_registry():
	if player and player.has_node("RelicRegistry"):
		relic_registry = player.get_node("RelicRegistry")

func _process(delta: float):
	if not player or not relic_registry:
		return
	
	if spawned_count >= max_relics:
		return
	
	spawn_timer += delta
	
	if spawn_timer >= spawn_interval:
		spawn_timer = 0.0
		_spawn_relic()

func _spawn_relic():
	if not player:
		return
	
	# 随机选择一个圣物
	var all_relics = relic_registry.relics.keys()
	if all_relics.is_empty():
		return
	
	var relic_id = all_relics[randi() % all_relics.size()]
	var relic = relic_registry.get_relic(relic_id)
	
	# 在玩家周围随机位置生成
	var angle = randf() * TAU
	var distance = randf_range(spawn_distance * 0.5, spawn_distance)
	var spawn_pos = player.global_position + Vector2(cos(angle), sin(angle)) * distance
	
	_create_relic_drop(spawn_pos, relic_id, relic.get("name", ""))
	spawned_count += 1
	
	print("[RelicSpawner] 生成圣物: ", relic.get("name", relic_id), " 于 ", spawn_pos)

func _create_relic_drop(pos: Vector2, r_id: String, r_name: String):
	var relic_drop_script = load("res://Objects/relic_drop.gd")
	var relic_drop = Area2D.new()
	relic_drop.set_script(relic_drop_script)
	relic_drop.global_position = pos
	relic_drop.name = "RelicDrop_" + r_id
	
	get_parent().call_deferred("add_child", relic_drop)
	
	# 等待添加到场景树后再设置
	await relic_drop.tree_entered
	relic_drop.setup(r_id, r_name)
