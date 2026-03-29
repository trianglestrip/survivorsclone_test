class_name RangedEnemy
extends BaseEnemy

## 远程敌人
## 与玩家保持距离并发射弹射物
## 
## 设计：从enemy_config.json加载配置

var attack_cooldown: float = 2.5
var attack_timer: float = 0.0
var attack_range: float = 200.0
var projectile_speed: float = 150.0
var keep_distance: float = 150.0
var target_player: Node = null
var hurt_box: Area2D = null
var attack_damage: int = 8

func _ready():
	super._ready()
	_setup_hurt_box()

func load_config(config: Dictionary):
	super.load_config(config)
	attack_range = config.get("attack_range", 200.0)
	attack_cooldown = config.get("attack_cooldown", 2.5)
	projectile_speed = config.get("projectile_speed", 150.0)
	attack_damage = config.get("damage", 8)
	keep_distance = attack_range * 0.7

func _setup_hurt_box():
	var hurt_box_scene = load("res://Utility/hurt_box.tscn")
	hurt_box = hurt_box_scene.instantiate()
	hurt_box.name = "HurtBox"
	hurt_box.collision_layer = 2
	hurt_box.collision_mask = 0
	hurt_box.HurtBoxType = 0
	
	add_child(hurt_box)
	
	var collision_shape = hurt_box.get_node("CollisionShape2D")
	if collision_shape:
		var shape = CircleShape2D.new()
		shape.radius = 14.0
		collision_shape.shape = shape
	
	hurt_box.hurt.connect(_on_hurt)

func _on_hurt(dmg, angle, knockback):
	take_damage(dmg, angle)

func _physics_process(delta: float):
	if not is_inside_tree():
		return
	
	if not target_player:
		target_player = get_tree().get_first_node_in_group("player")
	
	if not target_player:
		return
	
	if attack_timer > 0:
		attack_timer -= delta
	
	_update_movement(delta)
	_update_attack(delta)

func _update_movement(_delta: float):
	if not is_instance_valid(target_player):
		return
	
	var distance = global_position.distance_to(target_player.global_position)
	var direction = (target_player.global_position - global_position).normalized()
	
	# 保持距离：太近则后退，太远则前进
	if distance < keep_distance * 0.8:
		# 后退
		velocity = -direction * movement_speed
	elif distance > keep_distance * 1.2:
		# 前进
		velocity = direction * movement_speed
	else:
		# 保持距离，横向移动
		var perpendicular = Vector2(-direction.y, direction.x)
		velocity = perpendicular * movement_speed * 0.5
	
	move_and_slide()

func _update_attack(_delta: float):
	if not target_player or not is_instance_valid(target_player):
		return
	
	var distance = global_position.distance_to(target_player.global_position)
	
	# 在攻击范围内且冷却完成
	if distance <= attack_range and attack_timer <= 0:
		_shoot_projectile()

func _shoot_projectile():
	attack_timer = attack_cooldown
	
	var direction = (target_player.global_position - global_position).normalized()
	
	# 创建弹射物
	var projectile = _create_projectile(direction)
	
	if get_parent():
		get_parent().call_deferred("add_child", projectile)
	
	print("[RangedEnemy] 发射弹射物")

func _create_projectile(direction: Vector2) -> Area2D:
	var projectile = Area2D.new()
	projectile.global_position = global_position
	projectile.collision_layer = 2
	projectile.collision_mask = 1
	projectile.add_to_group("attack")
	
	# 添加碰撞形状
	var shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = 8.0
	shape.shape = circle
	projectile.add_child(shape)
	
	# 添加视觉
	var sprite = Sprite2D.new()
	sprite.texture = VisualEffectsHelper.create_placeholder_texture(Vector2(16, 16))
	sprite.modulate = Color(1.0, 0.5, 0.5)
	projectile.add_child(sprite)
	
	# 添加自动移动脚本
	var auto_projectile_script = load("res://Utility/auto_projectile.gd")
	projectile.set_script(auto_projectile_script)
	projectile.set("direction", direction)
	projectile.set("speed", projectile_speed)
	projectile.set("damage", attack_damage)
	projectile.set("lifetime", 5.0)
	
	return projectile

func on_death():
	super.on_death()
	queue_free()
