extends Node2D

## 自动移动和爆炸的火球
## 命中敌人或到达最大距离时爆炸

var direction: Vector2 = Vector2.RIGHT
var speed: float = 300.0
var max_range: float = 300.0
var skill_instance: Node = null
var hit_radius: float = 20.0

var distance_traveled: float = 0.0

func _process(delta: float):
	if not is_inside_tree():
		return
	
	var move_delta = direction * speed * delta
	position += move_delta
	distance_traveled += move_delta.length()
	
	# 检查命中
	var hit = false
	if skill_instance and skill_instance.has_method("_check_fireball_hit"):
		hit = skill_instance._check_fireball_hit(position)
	
	if hit or distance_traveled >= max_range:
		if skill_instance and skill_instance.has_method("_explode"):
			skill_instance._explode(position)
		queue_free()
