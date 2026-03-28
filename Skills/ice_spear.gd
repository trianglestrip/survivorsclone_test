extends "res://Skills/base_skill.gd"

## 冰矛技能 - 追踪型弹道
## 行为：发射时指向目标，持续追踪敌人

func get_spawn_params() -> Dictionary:
	if not player or not player.has_method("get_random_target"):
		return super.get_spawn_params()
	
	var target = player.get_random_target()
	var angle = player.position.direction_to(target)
	
	return {
		"position": player.position,
		"velocity": angle * 200.0,  # 从配置读取
		"rotation": angle.angle() + deg_to_rad(135),
		"target": target
	}

func update_skill_instance(inst: Dictionary, delta: float) -> Dictionary:
	# 持续追踪目标
	if inst.target != Vector2.ZERO:
		var dir = inst.position.direction_to(inst.target)
		inst.velocity = dir * 200.0  # 追踪速度
		inst.rotation = dir.angle() + deg_to_rad(135)
	
	inst.position += inst.velocity * delta
	return inst
