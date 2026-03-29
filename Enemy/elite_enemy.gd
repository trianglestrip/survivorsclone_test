class_name EliteEnemy
extends BaseEnemy

## 精英敌人
## 拥有特殊能力的强大敌人
## 
## 设计：从enemy_config.json加载配置和特殊能力

var attack_cooldown: float = 3.0
var attack_timer: float = 0.0
var attack_range: float = 150.0
var special_abilities: Array = []
var ability_timer: float = 0.0
var ability_cooldown: float = 5.0
var target_player: Node = null
var hurt_box: Area2D = null
var hit_box: Area2D = null
var attack_damage: int = 25

func _ready():
	super._ready()
	_setup_hurt_box()
	_setup_hit_box()

func load_config(config: Dictionary):
	super.load_config(config)
	attack_range = config.get("attack_range", 150.0)
	attack_cooldown = config.get("attack_cooldown", 3.0)
	attack_damage = config.get("damage", 25)
	special_abilities = config.get("special_abilities", [])
	
	# 根据特殊能力调整
	_setup_special_abilities()

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
		shape.radius = 20.0
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
	hit_circle.radius = 22.0
	hit_shape.shape = hit_circle
	
	hit_box.add_child(hit_shape)
	add_child(hit_box)
	
	hit_box.damage = attack_damage
	hit_box.angle = Vector2.ZERO
	hit_box.knockback_amount = 2

func _on_hurt(dmg, angle, knockback):
	take_damage(dmg, angle)

func _setup_special_abilities():
	for ability in special_abilities:
		var ability_type = ability.get("type", "")
		
		match ability_type:
			"ice_aura":
				_create_ice_aura(ability)
			"fire_trail":
				_enable_fire_trail(ability)

func _create_ice_aura(ability: Dictionary):
	var aura_radius = ability.get("radius", 100.0)
	
	# 创建光环视觉效果
	var aura = Sprite2D.new()
	aura.texture = VisualEffectsHelper.create_glow_background(Vector2(aura_radius * 2, aura_radius * 2), Color(0.5, 0.7, 1.0))
	aura.modulate = Color(0.5, 0.7, 1.0, 0.3)
	aura.z_index = -1
	add_child(aura)
	
	# 旋转动画
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(aura, "rotation", TAU, 4.0)

func _enable_fire_trail(_ability: Dictionary):
	# 火焰轨迹将在移动时创建
	pass

func _physics_process(delta: float):
	if not is_inside_tree():
		return
	
	if not target_player:
		target_player = get_tree().get_first_node_in_group("player")
	
	if not target_player:
		return
	
	if attack_timer > 0:
		attack_timer -= delta
	
	if ability_timer > 0:
		ability_timer -= delta
	
	_update_movement(delta)
	_update_attack(delta)
	_update_abilities(delta)

func _update_movement(_delta: float):
	if not is_instance_valid(target_player):
		return
	
	var direction = (target_player.global_position - global_position).normalized()
	velocity = direction * movement_speed
	move_and_slide()

func _update_attack(_delta: float):
	if not is_instance_valid(target_player):
		return
	
	var distance = global_position.distance_to(target_player.global_position)
	
	if distance <= attack_range and attack_timer <= 0:
		_perform_special_attack()

func _perform_special_attack():
	attack_timer = attack_cooldown
	
	# 根据配置执行特殊攻击
	for ability in special_abilities:
		var ability_type = ability.get("type", "")
		
		match ability_type:
			"ice_projectile":
				_shoot_ice_projectiles(ability)
			"explosion_on_death":
				pass  # 死亡时触发

func _shoot_ice_projectiles(ability: Dictionary):
	var count = ability.get("count", 3)
	var damage_mult = ability.get("damage_multiplier", 1.5)
	
	for i in range(count):
		var angle = (TAU / count) * i
		var direction = Vector2(cos(angle), sin(angle))
		
		var projectile = _create_ice_projectile(direction, damage_mult)
		
		if get_parent():
			get_parent().call_deferred("add_child", projectile)

func _create_ice_projectile(direction: Vector2, damage_mult: float) -> Area2D:
	var projectile = Area2D.new()
	projectile.global_position = global_position
	projectile.collision_layer = 2
	projectile.collision_mask = 1
	projectile.add_to_group("attack")
	
	var shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = 10.0
	shape.shape = circle
	projectile.add_child(shape)
	
	var sprite = Sprite2D.new()
	sprite.texture = VisualEffectsHelper.create_placeholder_texture(Vector2(20, 20))
	sprite.modulate = Color(0.5, 0.7, 1.0)
	projectile.add_child(sprite)
	
	var auto_projectile_script = load("res://Utility/auto_projectile.gd")
	projectile.set_script(auto_projectile_script)
	projectile.set("direction", direction)
	projectile.set("speed", 120.0)
	projectile.set("damage", int(attack_damage * damage_mult))
	projectile.set("lifetime", 5.0)
	
	return projectile

func _update_abilities(_delta: float):
	if ability_timer > 0:
		return
	
	# 定期触发特殊能力
	for ability in special_abilities:
		var ability_type = ability.get("type", "")
		
		match ability_type:
			"ice_aura":
				_apply_ice_aura_effect(ability)

func _apply_ice_aura_effect(ability: Dictionary):
	ability_timer = ability_cooldown
	
	var aura_radius = ability.get("radius", 100.0)
	var slow_percent = ability.get("slow_percent", 0.3)
	
	# 获取范围内的玩家
	if is_instance_valid(target_player):
		var distance = global_position.distance_to(target_player.global_position)
		if distance <= aura_radius:
			print("[EliteEnemy] 冰霜光环减速玩家")

func on_death():
	# 检查死亡时触发的能力
	for ability in special_abilities:
		var ability_type = ability.get("type", "")
		
		match ability_type:
			"explosion_on_death":
				_create_death_explosion(ability)
	
	super.on_death()
	queue_free()

func _create_death_explosion(ability: Dictionary):
	var explosion_radius = ability.get("radius", 80.0)
	var explosion_damage = ability.get("damage", 40)
	
	# 创建爆炸效果
	var explosion = Sprite2D.new()
	explosion.global_position = global_position
	explosion.texture = VisualEffectsHelper.create_glow_background(Vector2(explosion_radius * 2, explosion_radius * 2), Color(1.0, 0.3, 0.0))
	explosion.modulate = Color(1.0, 0.3, 0.0, 0.8)
	explosion.z_index = 10
	
	if get_parent():
		get_parent().call_deferred("add_child", explosion)
	
	# 造成范围伤害
	if is_inside_tree():
		var players = get_tree().get_nodes_in_group("player")
		for player_node in players:
			var distance = global_position.distance_to(player_node.global_position)
			if distance <= explosion_radius:
				print("[EliteEnemy] 死亡爆炸伤害玩家: ", explosion_damage)
	
	# 添加淡出脚本
	var fade_script = load("res://Utility/auto_fade_sprite.gd")
	explosion.set_script(fade_script)
	explosion.set("fade_duration", 0.5)
