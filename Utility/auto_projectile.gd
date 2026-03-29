extends Node2D

## 自动移动和清理的弹射物
## 用于简化技能弹射物的生命周期管理

var direction: Vector2 = Vector2.RIGHT
var speed: float = 400.0
var max_range: float = 250.0
var skill_instance: Node = null

var distance_traveled: float = 0.0

func _process(delta: float):
	if not is_inside_tree():
		return
	
	var move_delta = direction * speed * delta
	position += move_delta
	distance_traveled += move_delta.length()
	
	if skill_instance and skill_instance.has_method("_check_projectile_hit"):
		skill_instance._check_projectile_hit(self)
	
	if distance_traveled >= max_range:
		queue_free()
