extends Area2D

@export_enum("Cooldown","HitOnce","DisableHitBox") var HurtBoxType = 0

@onready var collision = $CollisionShape2D
@onready var disableTimer = $DisableTimer

signal hurt(damage, angle, knockback)

var hit_once_array = []

func _on_area_entered(area):
	if area.is_in_group("attack"):
		# 尝试获取伤害值（支持属性和元数据两种方式）
		var damage_value = null
		if area.get("damage") != null:
			damage_value = area.get("damage")
		elif area.has_meta("damage"):
			damage_value = area.get_meta("damage")
		
		if damage_value != null:
			match HurtBoxType:
				0: #Cooldown
					collision.call_deferred("set","disabled",true)
					disableTimer.start()
				1: #HitOnce
					if hit_once_array.has(area) == false:
						hit_once_array.append(area)
						if area.has_signal("remove_from_array"):
							if not area.is_connected("remove_from_array",Callable(self,"remove_from_list")):
								area.connect("remove_from_array",Callable(self,"remove_from_list"))
					else:
						return
				2: #DisableHitBox
					if area.has_method("tempdisable"):
						area.tempdisable()
			
			var angle = Vector2.ZERO
			var knockback = 1
			
			# 获取角度（支持属性和元数据）
			if area.get("angle") != null:
				angle = area.get("angle")
			elif area.has_meta("angle"):
				angle = area.get_meta("angle")
			
			# 获取击退（支持属性和元数据）
			if area.get("knockback_amount") != null:
				knockback = area.get("knockback_amount")
			elif area.has_meta("knockback"):
				knockback = area.get_meta("knockback")
			
			emit_signal("hurt", damage_value, angle, knockback)
			if area.has_method("enemy_hit"):
				area.enemy_hit(1)

func remove_from_list(object):
	if hit_once_array.has(object):
		hit_once_array.erase(object)

func _on_disable_timer_timeout():
	collision.call_deferred("set","disabled",false)
