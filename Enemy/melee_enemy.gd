class_name MeleeEnemy
extends BaseEnemy

## 近战敌人
## 追逐玩家并进行近战攻击
## 
## 设计：从enemy_config.json加载配置

var attack_cooldown: float = 1.5
var attack_timer: float = 0.0
var attack_range: float = 25.0
var target_player: Node = null
var hit_box: Area2D = null
var hurt_box: Area2D = null
var attack_damage: int = 10

func _ready():
	super._ready()
	_setup_hurt_box()
	_setup_hit_box()

func load_config(config: Dictionary):
	super.load_config(config)
	attack_range = config.get("attack_range", 25.0)
	attack_cooldown = config.get("attack_cooldown", 1.5)
	attack_damage = config.get("damage", 10)

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
		shape.radius = 16.0
		collision_shape.shape = shape
	
	hurt_box.hurt.connect(_on_hurt)

func _setup_hit_box():
	var hit_box_script = load("res://Utility/enemy_hit_box.gd")
	hit_box = Area2D.new()
	hit_box.set_script(hit_box_script)
	hit_box.name = "HitBox"
	hit_box.collision_layer = 2
	hit_box.collision_mask = 1
	hit_box.add_to_group("attack")
	
	var hit_shape = CollisionShape2D.new()
	var hit_circle = CircleShape2D.new()
	hit_circle.radius = 18.0
	hit_shape.shape = hit_circle
	
	hit_box.add_child(hit_shape)
	add_child(hit_box)
	
	hit_box.damage = attack_damage
	hit_box.angle = Vector2.ZERO
	hit_box.knockback_amount = 1

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
	var direction = (target_player.global_position - global_position).normalized()
	velocity = direction * movement_speed
	move_and_slide()

func _update_attack(_delta: float):
	if not target_player or not is_instance_valid(target_player):
		return
	
	var distance = global_position.distance_to(target_player.global_position)
	
	# 在攻击范围内且冷却完成
	if distance <= attack_range and attack_timer <= 0:
		_perform_attack()

func _perform_attack():
	attack_timer = attack_cooldown
	
	if not hit_box:
		return
	
	# 更新HitBox伤害
	var direction = (target_player.global_position - global_position).normalized()
	hit_box.damage = attack_damage
	hit_box.angle = direction
	
	print("[MeleeEnemy] 攻击玩家，伤害: ", attack_damage)

func on_death():
	super.on_death()
	queue_free()
