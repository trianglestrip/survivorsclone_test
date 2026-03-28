extends Sprite2D

var use_object_pool = true
var pool_name = "explosion"

func _ready():
	$AnimationPlayer.play("explode")

func _on_animation_player_animation_finished(_anim_name):
	if use_object_pool:
		var object_pool = get_node_or_null("/root/ObjectPool")
		if object_pool:
			object_pool.return_object(pool_name, self)
			return
	queue_free()

# 对象池重置方法
func reset_state():
	$AnimationPlayer.stop()
	visible = true
	scale = Vector2.ONE
