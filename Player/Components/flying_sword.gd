class_name FlyingSword
extends Node2D

## 暖雪风格飞剑：飞出追踪敌人，召回时高速返回玩家并在路径上造成 1.5 倍伤害

const RECALL_DAMAGE_MULT := 1.5
const RECALL_SPEED_MULT := 1.8
const PICKUP_DISTANCE := 22.0

enum Mode { OUTBOUND, RECALL }

var player: Node2D
var manager: Node = null
var mode: int = Mode.OUTBOUND
var velocity_dir: Vector2 = Vector2.RIGHT
var speed: float = 420.0
var base_damage: int = 8
var knockback: int = 50
var hit_radius: float = 20.0
var max_travel: float = 320.0
var _traveled: float = 0.0
var _homing_strength: float = 5.0
var _out_hit: Dictionary = {}
var _recall_hit: Dictionary = {}


func setup(p_player: Node2D, p_manager: Node, start_dir: Vector2, dmg: int, kb: int, spd: float, range_max: float) -> void:
	player = p_player
	manager = p_manager
	velocity_dir = start_dir.normalized() if start_dir != Vector2.ZERO else Vector2.RIGHT
	base_damage = dmg
	knockback = kb
	speed = spd
	max_travel = range_max
	global_position = p_player.global_position
	z_index = 5
	_add_visual()
	add_to_group("flying_swords")


func recall() -> void:
	if mode == Mode.RECALL:
		return
	mode = Mode.RECALL
	speed *= RECALL_SPEED_MULT


func _add_visual() -> void:
	var sprite := Sprite2D.new()
	var tex := VisualEffectsHelper.create_placeholder_texture(Vector2(14, 28))
	sprite.texture = tex
	sprite.modulate = Color(0.75, 0.9, 1.0, 0.95)
	sprite.name = "Blade"
	add_child(sprite)


func _process(delta: float) -> void:
	if not player or not is_instance_valid(player):
		queue_free()
		return

	if mode == Mode.OUTBOUND:
		_steer_homing(delta)
		var move_o := velocity_dir * speed * delta
		global_position += move_o
		_traveled += move_o.length()
		if _traveled >= max_travel:
			queue_free()
			return
		_try_hits(false)
	else:
		var to_p := player.global_position - global_position
		if to_p.length() <= PICKUP_DISTANCE:
			queue_free()
			return
		velocity_dir = to_p.normalized()
		global_position += velocity_dir * speed * delta
		_try_hits(true)

	rotation = velocity_dir.angle()


func _steer_homing(delta: float) -> void:
	var nearest := _find_nearest_enemy(260.0)
	if nearest:
		var to_enemy := (nearest.global_position - global_position).normalized()
		velocity_dir = (velocity_dir + to_enemy * _homing_strength * delta).normalized()


func _find_nearest_enemy(radius: float) -> Node2D:
	var best: Node2D = null
	var best_d := radius
	for e in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(e):
			continue
		var d := global_position.distance_to(e.global_position)
		if d < best_d:
			best_d = d
			best = e
	return best


func _try_hits(is_recall: bool) -> void:
	var mult := RECALL_DAMAGE_MULT if is_recall else 1.0
	var hit_dict := _recall_hit if is_recall else _out_hit
	var kb_dir := velocity_dir * float(knockback)
	var enemies = get_tree().get_nodes_in_group("enemies")
	for e in enemies:
		if not is_instance_valid(e):
			continue
		var id := e.get_instance_id()
		if hit_dict.has(id):
			continue
		var dist = global_position.distance_to(e.global_position)
		if dist > hit_radius:
			continue
		hit_dict[id] = true
		var final_dmg = int(ceil(base_damage * mult))
		if e.has_method("take_damage"):
			e.take_damage(final_dmg, kb_dir)
		elif "hp" in e:
			e.hp -= final_dmg
