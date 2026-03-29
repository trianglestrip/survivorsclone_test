extends Node2D

## 简单敌人生成器 - 暖雪风格
## 配置驱动的波次生成系统

@export var enemy_scene: PackedScene
@export var spawn_interval: float = 2.0
@export var spawn_distance: float = 400.0
@export var max_enemies: int = 20

var spawn_timer: float = 0.0
var player: Node = null

func _ready():
	if not enemy_scene:
		enemy_scene = load("res://Enemy/simple_enemy.tscn")

func _process(delta: float):
	if not player:
		player = get_tree().get_first_node_in_group("player")
		if not player:
			return
	
	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		spawn_timer = 0.0
		_spawn_enemy()

func _spawn_enemy():
	var current_enemies = get_tree().get_nodes_in_group("enemies")
	if current_enemies.size() >= max_enemies:
		return
	
	if not enemy_scene or not player:
		return
	
	var angle = randf() * TAU
	var offset = Vector2(cos(angle), sin(angle)) * spawn_distance
	var spawn_pos = player.global_position + offset
	
	var enemy = enemy_scene.instantiate()
	enemy.global_position = spawn_pos
	
	var world = player.get_parent()
	if world:
		var enemies_container = world.get_node_or_null("Enemies")
		if enemies_container:
			enemies_container.call_deferred("add_child", enemy)
		else:
			world.call_deferred("add_child", enemy)
