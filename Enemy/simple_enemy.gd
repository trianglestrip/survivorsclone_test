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
	
	# 设置碰撞体（用于物理移动）
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
	
	# 添加HurtBox（用于接收玩家攻击）
	_setup_hurt_box()
	
	# 添加HitBox（用于攻击玩家）
	_setup_hit_box()

func _setup_hurt_box():
	# 使用标准的HurtBox场景
	var hurt_box_scene = load("res://Utility/hurt_box.tscn")
	var hurt_box = hurt_box_scene.instantiate()
	hurt_box.name = "HurtBox"
	hurt_box.collision_layer = 2  # 敌人层
	hurt_box.collision_mask = 0   # 不检测碰撞，只被检测
	hurt_box.HurtBoxType = 0  # Cooldown类型
	
	add_child(hurt_box)
	
	# 设置碰撞形状（hurt_box.tscn的CollisionShape2D没有shape）
	var collision_shape = hurt_box.get_node("CollisionShape2D")
	if collision_shape:
		var shape = CircleShape2D.new()
		shape.radius = 16.0
		collision_shape.shape = shape
	
	# 连接hurt信号到敌人的受伤处理
	hurt_box.hurt.connect(_on_hurt)

func _setup_hit_box():
	var hit_box_script = load("res://Utility/enemy_hit_box.gd")
	var hit_box = Area2D.new()
	hit_box.set_script(hit_box_script)
	hit_box.name = "HitBox"
	hit_box.collision_layer = 2  # 敌人层
	hit_box.collision_mask = 1   # 检测玩家层（HurtBox）
	hit_box.add_to_group("attack")  # 玩家HurtBox检查"attack"组
	
	var hit_shape = CollisionShape2D.new()
	var hit_circle = CircleShape2D.new()
	hit_circle.radius = 18.0
	hit_shape.shape = hit_circle
	
	hit_box.add_child(hit_shape)
	add_child(hit_box)
	
	# 设置伤害属性
	hit_box.damage = attack_damage
	hit_box.angle = Vector2.ZERO
	hit_box.knockback_amount = 1

func _on_hurt(dmg, angle, knockback):
	take_damage(dmg, angle)

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
