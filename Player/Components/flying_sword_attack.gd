class_name FlyingSwordAttack
extends BaseAttack

## 右键飞剑副攻击：发射可召回的飞剑

const GameConstants := preload("res://Utility/game_constants.gd")
const VisualEffectsHelper := preload("res://Utility/visual_effects_helper.gd")

var flying_sword_manager: Node = null
var projectile_speed: float = 420.0
var max_active_swords: int = 3
var collision_radius: float = 22.0
var lifetime: float = 5.0


func set_flying_sword_manager(m: Node) -> void:
	flying_sword_manager = m


func load_config(config: Dictionary) -> void:
	super.load_config(config)
	projectile_speed = config.get("move_speed", 420.0)
	max_active_swords = config.get("max_active_swords", 3)
	collision_radius = config.get("collision_radius", 22.0)
	lifetime = config.get("lifetime", 5.0)


func can_attack() -> bool:
	if not super.can_attack():
		return false
	if flying_sword_manager and flying_sword_manager.has_method("get_active_sword_count"):
		return flying_sword_manager.get_active_sword_count() < max_active_swords
	return true


func get_attack_direction() -> Vector2:
	if player:
		var mouse_pos: Vector2 = player.get_global_mouse_position()
		return (mouse_pos - player.global_position).normalized()
	return Vector2.RIGHT


func play_attack_animation() -> void:
	pass


func spawn_attack_effect(_attack_position: Vector2, attack_direction: Vector2) -> void:
	if flying_sword_manager and flying_sword_manager.has_method("spawn_sword"):
		flying_sword_manager.spawn_sword(attack_direction, damage, knockback, projectile_speed, attack_range, collision_radius, lifetime)
	VisualEffectsHelper.trigger_screen_shake(self, GameConstants.Values.SHAKE_ATTACK * 0.45)
