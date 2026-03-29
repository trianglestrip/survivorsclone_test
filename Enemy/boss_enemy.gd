class_name BossEnemy
extends BaseEnemy

## Boss敌人
## 拥有多个阶段和强大技能的Boss
## 
## 设计：从level_config.json的bosses配置加载

var attack_cooldown: float = 2.0
var attack_timer: float = 0.0
var attack_range: float = 100.0
var target_player: Node = null
var hurt_box: Area2D = null
var hit_box: Area2D = null
var attack_damage: int = 30

var phases: Array = []
var current_phase: int = 0
var abilities: Array = []
var ability_timer: float = 0.0
var ability_cooldown: float = 3.0

var max_hp: int = 500

func _ready():
	super._ready()
	max_hp = hp
	_setup_hurt_box()
	_setup_hit_box()
	_setup_boss_visual()

func load_config(config: Dictionary):
	super.load_config(config)
	attack_range = config.get("attack_range", 100.0)
	attack_cooldown = config.get("attack_cooldown", 2.0)
	attack_damage = config.get("damage", 30)
	phases = config.get("phases", [])
	max_hp = hp
	
	# 加载初始阶段的能力
	_update_phase()

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
		shape.radius = 30.0
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
	hit_circle.radius = 35.0
	hit_shape.shape = hit_circle
	
	hit_box.add_child(hit_shape)
	add_child(hit_box)
	
	hit_box.damage = attack_damage
	hit_box.angle = Vector2.ZERO
	hit_box.knockback_amount = 3

func _setup_boss_visual():
	# 添加Boss光环
	var aura = Sprite2D.new()
	aura.texture = VisualEffectsHelper.create_glow_background(Vector2(200, 200), Color(1.0, 0.5, 0.5))
	aura.modulate = Color(1.0, 0.5, 0.5, 0.4)
	aura.z_index = -1
	add_child(aura)
	
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(aura, "rotation", TAU, 5.0)

func _on_hurt(dmg, angle, knockback):
	take_damage(dmg, angle)
	_check_phase_transition()

func _check_phase_transition():
	var hp_percent = float(hp) / float(max_hp)
	
	for i in range(phases.size()):
		if i > current_phase:
			var phase = phases[i]
			var threshold = phase.get("hp_threshold", 0.0)
			
			if hp_percent <= threshold:
				current_phase = i
				_update_phase()
				print("[Boss] 进入阶段 %d (HP: %.1f%%)" % [current_phase + 1, hp_percent * 100])
				break

func _update_phase():
	if current_phase >= phases.size():
		return
	
	var phase = phases[current_phase]
	abilities = phase.get("abilities", [])

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
		_perform_attack()

func _perform_attack():
	attack_timer = attack_cooldown
	
	if not hit_box:
		return
	
	var direction = (target_player.global_position - global_position).normalized()
	hit_box.damage = attack_damage
	hit_box.angle = direction
	
	print("[Boss] 攻击玩家")

func _update_abilities(_delta: float):
	if ability_timer > 0:
		return
	
	if abilities.is_empty():
		return
	
	ability_timer = ability_cooldown
	
	# 随机使用一个能力
	var ability_name = abilities[randi() % abilities.size()]
	_use_ability(ability_name)

func _use_ability(ability_name: String):
	print("[Boss] 使用能力: ", ability_name)
	
	match ability_name:
		"ice_wave":
			_cast_ice_wave()
		"ice_spike":
			_cast_ice_spike()
		"ice_storm":
			_cast_ice_storm()
		"lightning_strike":
			_cast_lightning_strike()
		"chain_lightning":
			_cast_chain_lightning()
		"thunder_field":
			_cast_thunder_field()
		"thunder_rage":
			_cast_thunder_rage()

func _cast_ice_wave():
	# 创建冰波效果（环形扩散）
	var wave = Sprite2D.new()
	wave.global_position = global_position
	wave.texture = VisualEffectsHelper.create_glow_background(Vector2(100, 100), Color(0.5, 0.7, 1.0))
	wave.modulate = Color(0.5, 0.7, 1.0, 0.6)
	wave.z_index = 5
	
	if get_parent():
		get_parent().call_deferred("add_child", wave)
	
	# 扩散动画
	var tween = create_tween()
	tween.tween_property(wave, "scale", Vector2(5.0, 5.0), 1.5)
	tween.parallel().tween_property(wave, "modulate:a", 0.0, 1.5)
	tween.tween_callback(wave.queue_free)

func _cast_ice_spike():
	if not is_instance_valid(target_player):
		return
	
	# 在玩家位置创建冰刺
	var spike = Sprite2D.new()
	spike.global_position = target_player.global_position
	spike.texture = VisualEffectsHelper.create_placeholder_texture(Vector2(40, 40))
	spike.modulate = Color(0.5, 0.7, 1.0)
	spike.z_index = 5
	
	if get_parent():
		get_parent().call_deferred("add_child", spike)
	
	var fade_script = load("res://Utility/auto_fade_sprite.gd")
	spike.set_script(fade_script)
	spike.set("fade_duration", 1.0)

func _cast_ice_storm():
	print("[Boss] 冰霜风暴")

func _cast_lightning_strike():
	if not is_instance_valid(target_player):
		return
	
	# 闪电打击
	var lightning = Line2D.new()
	lightning.add_point(global_position)
	lightning.add_point(target_player.global_position)
	lightning.width = 5.0
	lightning.default_color = Color(1.0, 1.0, 0.5)
	lightning.z_index = 10
	
	if get_parent():
		get_parent().call_deferred("add_child", lightning)
	
	var fade_script = load("res://Utility/auto_fade_sprite.gd")
	lightning.set_script(fade_script)
	lightning.set("fade_duration", 0.3)

func _cast_chain_lightning():
	print("[Boss] 连锁闪电")

func _cast_thunder_field():
	print("[Boss] 雷电领域")

func _cast_thunder_rage():
	print("[Boss] 雷霆之怒")

func on_death():
	print("[Boss] Boss被击败！")
	super.on_death()
	queue_free()
