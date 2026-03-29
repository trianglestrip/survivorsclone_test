class_name FlyingSwordManager
extends Node

## 管理存活飞剑，响应召回输入并播放反馈

const FlyingSwordScene := preload("res://Player/Components/flying_sword.gd")
const GameConstants := preload("res://Utility/game_constants.gd")

var player: Node2D = null
var input_manager: Node = null
var max_active_swords: int = 4
var _active: Array = []


func set_player(p: Node2D) -> void:
	player = p


func set_input_manager(im: Node) -> void:
	if input_manager and input_manager.recall_sword.is_connected(_on_recall_sword_pressed):
		input_manager.recall_sword.disconnect(_on_recall_sword_pressed)
	input_manager = im
	if input_manager:
		input_manager.recall_sword.connect(_on_recall_sword_pressed)


func set_max_active_swords(max_count: int) -> void:
	max_active_swords = max_count


func spawn_sword(direction: Vector2, damage: int, knockback: int, projectile_speed: float, max_range: float, collision_radius: float = 22.0, lifetime: float = 5.0) -> Node2D:
	if get_active_sword_count() >= max_active_swords:
		return null
	if not player or not player.get_parent():
		return null
	var sword: Node2D = FlyingSwordScene.new()
	sword.name = "FlyingSword"
	player.get_parent().add_child(sword)
	if sword.has_method("setup"):
		sword.call("setup", player, self, direction, damage, knockback, projectile_speed, max_range)
		if "hit_radius" in sword:
			sword.hit_radius = collision_radius
	_active.append(sword)
	sword.tree_exiting.connect(_on_sword_exiting.bind(sword))
	return sword


func _on_sword_exiting(sword: Node) -> void:
	_active.erase(sword)


func _on_recall_sword_pressed() -> void:
	recall_all_swords()


func recall_all_swords() -> void:
	var any := false
	for s in _active:
		if is_instance_valid(s) and s.has_method("recall"):
			s.recall()
			any = true
	if any and player:
		VisualEffectsHelper.trigger_screen_shake(player, GameConstants.Values.SHAKE_ATTACK * 0.55)


func get_active_sword_count() -> int:
	var n := 0
	for s in _active:
		if is_instance_valid(s):
			n += 1
	return n
