extends Area2D

@export var experience = 1

var spr_green = preload("res://Textures/Items/Gems/Gem_green.png")
var spr_blue = preload("res://Textures/Items/Gems/Gem_blue.png")
var spr_red = preload("res://Textures/Items/Gems/Gem_red.png")

var target = null
var speed = -1
var use_object_pool = true
var pool_name = "experience_gem"

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D
@onready var sound = $snd_collected

func _ready():
	_update_sprite()

func _update_sprite():
	if experience < 5:
		sprite.texture = spr_green
	elif experience < 25:
		sprite.texture = spr_blue
	else:
		sprite.texture = spr_red

func _physics_process(delta: float):
	if target != null:
		global_position = global_position.move_toward(target.global_position, speed)
		speed += 2.0 * delta

func collect():
	sound.play()
	collision.call_deferred("set", "disabled", true)
	sprite.visible = false
	return experience

func _on_snd_collected_finished():
	if use_object_pool:
		var object_pool = get_node_or_null("/root/ObjectPool")
		if object_pool:
			object_pool.return_object(pool_name, self)
			return
	queue_free()

# 对象池重置方法
func reset_state():
	target = null
	speed = -1
	sprite.visible = true
	collision.disabled = false
	_update_sprite()
