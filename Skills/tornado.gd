extends "res://Skills/base_skill.gd"

## 龙卷风技能 - 之字形弹道
## 行为：根据玩家移动方向生成，之字形移动，速度逐渐加快

# 实例级变量（每个技能实例独立）
var direction_timer := 0.0
var angle_less := Vector2.ZERO
var angle_more := Vector2.ZERO
var current_angle := Vector2.ZERO

func get_spawn_params() -> Dictionary:
	if not player or not player.has("last_movement"):
		return super.get_spawn_params()
	
	var last_movement = player.last_movement
	var zigzag_range = 500.0
	
	# 计算之字形的两个方向
	var move_to_less = Vector2.ZERO
	var move_to_more = Vector2.ZERO
	
	match last_movement:
		Vector2.UP, Vector2.DOWN:
			move_to_less = player.position + Vector2(randf_range(-1, -0.25), last_movement.y) * zigzag_range
			move_to_more = player.position + Vector2(randf_range(0.25, 1), last_movement.y) * zigzag_range
		Vector2.RIGHT, Vector2.LEFT:
			move_to_less = player.position + Vector2(last_movement.x, randf_range(-1, -0.25)) * zigzag_range
			move_to_more = player.position + Vector2(last_movement.x, randf_range(0.25, 1)) * zigzag_range
		_:
			move_to_less = player.position + Vector2(last_movement.x, last_movement.y * randf_range(0, 0.75)) * zigzag_range
			move_to_more = player.position + Vector2(last_movement.x * randf_range(0, 0.75), last_movement.y) * zigzag_range
	
	angle_less = player.position.direction_to(move_to_less)
	angle_more = player.position.direction_to(move_to_more)
	current_angle = angle_less if randi() % 2 == 0 else angle_more
	
	return {
		"position": player.position,
		"velocity": current_angle * (100.0 * 0.2),  # 初始速度慢
		"rotation": 0.0,
		"target": Vector2.ZERO
	}

func update_skill_instance(inst: Dictionary, delta: float) -> Dictionary:
	# 初始化实例数据
	if not inst.has("direction_timer"):
		inst["direction_timer"] = 0.0
		inst["current_speed"] = 100.0 * 0.2
		inst["angle_less"] = angle_less
		inst["angle_more"] = angle_more
		inst["current_angle"] = current_angle
	
	inst["direction_timer"] += delta
	
	# 每 2 秒切换方向
	if inst["direction_timer"] >= 2.0:
		inst["direction_timer"] = 0.0
		inst["current_angle"] = inst["angle_more"] if inst["current_angle"] == inst["angle_less"] else inst["angle_less"]
	
	# 速度逐渐增加
	inst["current_speed"] = min(inst["current_speed"] + 50.0 * delta, 100.0)
	
	inst.velocity = inst["current_angle"] * inst["current_speed"]
	inst.position += inst.velocity * delta
	
	return inst
