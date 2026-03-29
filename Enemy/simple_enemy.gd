class_name SimpleEnemy
extends BaseEnemy

## 简单敌人 - 用于测试
## 基础近战敌人，追逐玩家并造成接触伤害

const GameConstants = preload("res://Utility/game_constants.gd")

var chase_range: float = 500.0
var attack_damage: int = 10

func _ready():
	super._ready()
	hp = 30
	movement_speed = 50.0
	
	# 设置碰撞体
	if not has_node("CollisionShape2D"):
		var collision = CollisionShape2D.new()
		var shape = CircleShape2D.new()
		shape.radius = 16.0
		collision.shape = shape
		add_child(collision)
	
	# 设置精灵
	if not has_node("Sprite2D"):
		var sprite = Sprite2D.new()
		sprite.texture = _create_enemy_texture()
		sprite.modulate = Color(1.0, 0.5, 0.5)
		add_child(sprite)

func _create_enemy_texture() -> Texture2D:
	var img = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.8, 0.3, 0.3, 1.0))
	return ImageTexture.create_from_image(img)

func _physics_process(delta: float):
	if not is_inside_tree():
		return
	
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	
	var distance = global_position.distance_to(player.global_position)
	if distance > chase_range:
		return
	
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * movement_speed
	move_and_slide()

func take_damage(dmg: float, knockback_dir: Vector2 = Vector2.ZERO):
	super.take_damage(dmg, knockback_dir)

func on_death():
	super.on_death()
	queue_free()
