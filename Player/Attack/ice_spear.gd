extends "res://Utility/base_skill.gd"

var target = Vector2.ZERO
var angle = Vector2.ZERO

func _init():
	config_section = "IceSpear"
	skill_name = "IceSpear"

func on_skill_ready():
	angle = global_position.direction_to(target)
	rotation = angle.angle() + deg_to_rad(135)

	var tween = create_tween()
	tween.tween_property(self,"scale",Vector2(1,1)*attack_size,1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()

func _physics_process(delta):
	position += angle*speed*delta

func _on_timer_timeout():
	on_skill_destroyed()
