class_name MeleeAttack
extends BaseAttack

## 近战攻击实现
## 继承 BaseAttack，实现具体攻击逻辑

var _last_movement: Vector2 = Vector2.RIGHT
var _slash_frames: Array = []
var _current_frame: int = 0

func _ready():
	_load_slash_frames()

func _load_slash_frames():
	for i in range(8):
		var texture_path = "res://Textures/Placeholder/Effects/Slash/slash_%d.png" % i
		if ResourceLoader.exists(texture_path):
			var texture = load(texture_path)
			_slash_frames.append(texture)

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
		
		_play_slash_effect(position, direction)
		
		await get_tree().create_timer(0.1).timeout
		if is_instance_valid(hit_box):
			hit_box.queue_free()

func _play_slash_effect(position: Vector2, direction: Vector2):
	if _slash_frames.is_empty():
		return
	
	var effect_node = Node2D.new()
	effect_node.name = "SlashEffect"
	effect_node.position = position
	effect_node.rotation = direction.angle()
	effect_node.z_index = 10
	
	var sprite = Sprite2D.new()
	sprite.texture = _slash_frames[0]
	sprite.scale = Vector2(0.8, 0.8)
	effect_node.add_child(sprite)
	
	if player and player.get_parent():
		player.get_parent().add_child(effect_node)
	
	_animate_slash(sprite, effect_node)

func _animate_slash(sprite: Sprite2D, effect_node: Node2D):
	for i in range(_slash_frames.size()):
		await get_tree().create_timer(0.05).timeout
		if is_instance_valid(sprite):
			if i < _slash_frames.size():
				sprite.texture = _slash_frames[i]
	
	await get_tree().create_timer(0.1).timeout
	if is_instance_valid(effect_node):
		effect_node.queue_free()

func _on_attack_hit(area: Area2D, dmg: int, kb: int, dir: Vector2):
	if area.has_signal("hurt"):
		area.emit_signal("hurt", dmg, dir, kb)
