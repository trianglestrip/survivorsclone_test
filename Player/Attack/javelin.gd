extends "res://Utility/base_skill.gd"

var paths = 1
var attack_speed = 5.0

var target = Vector2.ZERO
var target_array = []

var angle = Vector2.ZERO
var reset_pos = Vector2.ZERO

var spr_jav_reg = preload("res://Textures/Items/Weapons/javelin_3_new.png")
var spr_jav_atk = preload("res://Textures/Items/Weapons/javelin_3_new_attack.png")

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D
@onready var attackTimer = get_node("%AttackTimer")
@onready var changeDirectionTimer = get_node("%ChangeDirection")
@onready var resetPosTimer = get_node ("%ResetPosTimer")
@onready var snd_attack = $snd_attack

func _init():
	config_section = "Javelin"
	skill_name = "Javelin"

func load_skill_config():
	super.load_skill_config()
	
	var cfg = ConfigFile.new()
	if cfg.load("res://config/skill_config.ini") != OK:
		return
	
	attack_speed = cfg.get_value(config_section, "base_attack_speed", attack_speed)

func apply_player_modifiers():
	super.apply_player_modifiers()
	if player:
		attack_speed = attack_speed * (1 - player.spell_cooldown)

func on_skill_ready():
	update_javelin()
	_on_reset_pos_timer_timeout()

func update_javelin():
	load_skill_config()
	apply_player_modifiers()
	
	level = player.javelin_level
	var cfg = ConfigFile.new()
	if cfg.load("res://config/skill_config.ini") != OK:
		return
	
	var level_paths_key = "level%d_paths" % level
	var level_damage_key = "level%d_damage" % level
	var level_knockback_key = "level%d_knockback_amount" % level
	
	if cfg.has_section_key(config_section, level_paths_key):
		paths = cfg.get_value(config_section, level_paths_key, paths)
	if cfg.has_section_key(config_section, level_damage_key):
		damage = cfg.get_value(config_section, level_damage_key, damage)
	if cfg.has_section_key(config_section, level_knockback_key):
		knockback_amount = cfg.get_value(config_section, level_knockback_key, knockback_amount)
	
	scale = Vector2(1.0,1.0) * attack_size
	attackTimer.wait_time = attack_speed

func _physics_process(delta):
	if target_array.size() > 0:
		position += angle*speed*delta
	else:
		var player_angle = global_position.direction_to(reset_pos)
		var distance_dif = global_position - player.global_position
		var return_speed = 20
		if abs(distance_dif.x) > 500 or abs(distance_dif.y) > 500:
			return_speed = 100
		position += player_angle*return_speed*delta
		rotation = global_position.direction_to(player.global_position).angle() + deg_to_rad(135)

func add_paths():
	snd_attack.play()
	emit_signal("remove_from_array",self)
	target_array.clear()
	var counter = 0
	while counter < paths:
		var new_path = player.get_random_target()
		target_array.append(new_path)
		counter += 1
	enable_attack(true)
	target = target_array[0]
	process_path()

func process_path():
	angle = global_position.direction_to(target)
	changeDirectionTimer.start()
	var tween = create_tween()
	var new_rotation_degrees = angle.angle() + deg_to_rad(135)
	tween.tween_property(self,"rotation",new_rotation_degrees,0.25).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()

func enable_attack(atk = true):
	if atk:
		collision.call_deferred("set","disabled",false)
		sprite.texture = spr_jav_atk
	else:
		collision.call_deferred("set","disabled",true)
		sprite.texture = spr_jav_reg

func _on_attack_timer_timeout():
	add_paths()

func _on_change_direction_timeout():
	if target_array.size() > 0:
		target_array.remove_at(0)
		if target_array.size() > 0:
			target = target_array[0]
			process_path()
			snd_attack.play()
			emit_signal("remove_from_array",self)
		else:
			changeDirectionTimer.stop()
			attackTimer.start()
			enable_attack(false)
	else:
		changeDirectionTimer.stop()
		attackTimer.start()
		enable_attack(false)


func _on_reset_pos_timer_timeout():
	var choose_direction = randi() % 4
	reset_pos = player.global_position
	match choose_direction:
		0:
			reset_pos.x += 50
		1:
			reset_pos.x -= 50
		2:
			reset_pos.y += 50
		3:
			reset_pos.y -= 50
