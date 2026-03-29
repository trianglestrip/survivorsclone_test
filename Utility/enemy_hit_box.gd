extends Area2D

## 敌人HitBox - 用于对玩家造成伤害

var damage: int = 10
var angle: Vector2 = Vector2.ZERO
var knockback_amount: int = 1

func setup(dmg: int, kb_angle: Vector2 = Vector2.ZERO, kb_amount: int = 1):
	damage = dmg
	angle = kb_angle
	knockback_amount = kb_amount
