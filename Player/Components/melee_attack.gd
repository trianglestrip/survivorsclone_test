class_name MeleeAttack
extends BaseAttack

## 近战攻击实现
## 继承 BaseAttack，实现具体攻击逻辑

var _last_movement: Vector2 = Vector2.RIGHT

func set_last_movement(dir: Vector2):
	if dir != Vector2.ZERO:
		_last_movement = dir

func get_attack_direction() -> Vector2:
	if player and "last_movement" in player:
		var player_dir = player.last_movement
		if player_dir != Vector2.ZERO:
			return player_dir.normalized()
	return _last_movement.normalized()

func play_attack_animation():
	if player and player.has_node("Sprite2D"):
		var sprite = player.get_node("Sprite2D")
		if sprite.frame < sprite.hframes - 1:
			sprite.frame = 1

func spawn_attack_effect(position: Vector2, direction: Vector2):
	if player:
		var hit_box = Area2D.new()
		hit_box.name = "MeleeAttackHitbox"
		hit_box.collision_layer = 4
		hit_box.collision_mask = 4
		hit_box.position = position
		hit_box.add_to_group("attack")
		
		var shape = CollisionShape2D.new()
		var rect = RectangleShape2D.new()
		rect.size = Vector2(range, range * 0.6)
		shape.shape = rect
		shape.rotation = direction.angle()
		hit_box.add_child(shape)
		
		if player.get_parent():
			player.get_parent().add_child(hit_box)
		
		hit_box.area_entered.connect(_on_attack_hit.bind(damage, knockback, direction))
		
		await get_tree().create_timer(0.1).timeout
		if is_instance_valid(hit_box):
			hit_box.queue_free()

func _on_attack_hit(area: Area2D, dmg: int, kb: int, dir: Vector2):
	if area.has_signal("hurt"):
		area.emit_signal("hurt", dmg, dir, kb)
