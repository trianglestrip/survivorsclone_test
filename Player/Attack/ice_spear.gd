extends Area2D

var level = 1
var hp = 1
var speed = 100
var damage = 5
var knockback_amount = 100
var attack_size = 1.0

var target = Vector2.ZERO
var angle = Vector2.ZERO

@onready var player = get_tree().get_first_node_in_group("player")
signal remove_from_array(object)

func _ready():
	_load_skill_config()
	angle = global_position.direction_to(target)
	rotation = angle.angle() + deg_to_rad(135)

	var tween = create_tween()
	tween.tween_property(self,"scale",Vector2(1,1)*attack_size,1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()

func _load_skill_config():
	var cfg = ConfigFile.new()
	if cfg.load("res://config/skill_config.ini") != OK:
		return
	var section = "IceSpear"
	speed = cfg.get_value(section, "base_speed", speed)
	knockback_amount = cfg.get_value(section, "base_knockback_amount", knockback_amount)
	attack_size = cfg.get_value(section, "base_attack_size", attack_size) * (1 + player.spell_size)
	hp = cfg.get_value(section, "level%d_hp" % level, hp)
	damage = cfg.get_value(section, "level%d_damage" % level, damage)

func _physics_process(delta):
	position += angle*speed*delta

func enemy_hit(charge = 1):
	hp -= charge
	if hp <= 0:
		emit_signal("remove_from_array",self)
		queue_free()


func _on_timer_timeout():
	emit_signal("remove_from_array",self)
	queue_free()
