extends CharacterBody2D

# 重构后的玩家类 - 使用组件化架构

# 组件
var stats
var skill_mgr
var upgrade_mgr
var exp_mgr

# 基础变量
var last_movement = Vector2.UP
var time = 0

# 技能预加载
var iceSpear = preload("res://Player/Attack/ice_spear.tscn")
var tornado = preload("res://Player/Attack/tornado.tscn")
var javelin = preload("res://Player/Attack/javelin.tscn")

# 敌人检测
var enemy_close = []

# 节点引用
@onready var sprite = $Sprite2D
@onready var walkTimer = get_node("%walkTimer")

# 技能计时器
@onready var iceSpearTimer = get_node("%IceSpearTimer")
@onready var iceSpearAttackTimer = get_node("%IceSpearAttackTimer")
@onready var tornadoTimer = get_node("%TornadoTimer")
@onready var tornadoAttackTimer = get_node("%TornadoAttackTimer")
@onready var javelinBase = get_node("%JavelinBase")

# GUI
@onready var expBar = get_node("%ExperienceBar")
@onready var lblLevel = get_node("%lbl_level")
@onready var levelPanel = get_node("%LevelUp")
@onready var upgradeOptions = get_node("%UpgradeOptions")
@onready var itemOptions = preload("res://Utility/item_option.tscn")
@onready var sndLevelUp = get_node("%snd_levelup")
@onready var healthBar = get_node("%HealthBar")
@onready var lblTimer = get_node("%lblTimer")
@onready var collectedWeapons = get_node("%CollectedWeapons")
@onready var collectedUpgrades = get_node("%CollectedUpgrades")
@onready var itemContainer = preload("res://Player/GUI/item_container.tscn")

@onready var deathPanel = get_node("%DeathPanel")
@onready var lblResult = get_node("%lbl_Result")
@onready var sndVictory = get_node("%snd_victory")
@onready var sndLose = get_node("%snd_lose")

signal playerdeath

func _ready():
	_initialize_components()
	_connect_signals()
	_initial_setup()

func _initialize_components():
	# 创建组件
	var stats_script = load("res://Player/Components/player_stats.gd")
	stats = stats_script.new()
	add_child(stats)
	
	var skill_mgr_script = load("res://Player/Components/skill_manager.gd")
	skill_mgr = skill_mgr_script.new()
	skill_mgr.set_player(self)
	add_child(skill_mgr)
	
	var upgrade_mgr_script = load("res://Player/Components/upgrade_manager.gd")
	upgrade_mgr = upgrade_mgr_script.new()
	upgrade_mgr.set_player_stats(stats)
	upgrade_mgr.set_skill_manager(skill_mgr)
	add_child(upgrade_mgr)
	
	var exp_mgr_script = load("res://Player/Components/experience_manager.gd")
	exp_mgr = exp_mgr_script.new()
	exp_mgr.set_player_stats(stats)
	add_child(exp_mgr)

func _connect_signals():
	exp_mgr.level_up.connect(_on_level_up)
	exp_mgr.experience_changed.connect(_on_experience_changed)

func _initial_setup():
	upgrade_character("icespear1")
	attack()
	set_expbar(stats.experience, exp_mgr.calculate_experience_cap())
	_on_hurt_box_hurt(0, 0, 0)

func _physics_process(_delta):
	movement()

func movement():
	var x_mov = Input.get_action_strength("right") - Input.get_action_strength("left")
	var y_mov = Input.get_action_strength("down") - Input.get_action_strength("up")
	var mov = Vector2(x_mov, y_mov)
	
	if mov.x > 0:
		sprite.flip_h = true
	elif mov.x < 0:
		sprite.flip_h = false

	if mov != Vector2.ZERO:
		last_movement = mov
		if walkTimer.is_stopped():
			if sprite.frame >= sprite.hframes - 1:
				sprite.frame = 0
			else:
				sprite.frame += 1
			walkTimer.start()
	
	velocity = mov.normalized() * stats.get_movement_speed()
	move_and_slide()

func attack():
	var icespear_level = skill_mgr.get_skill_level("icespear")
	print("[DEBUG] attack() - icespear_level: ", icespear_level)
	if icespear_level > 0:
		var attack_speed = skill_mgr.get_skill_attack_speed("icespear")
		iceSpearTimer.wait_time = attack_speed * (1 - stats.spell_cooldown)
		print("[DEBUG] 启动 IceSpearTimer, wait_time: ", iceSpearTimer.wait_time)
		if iceSpearTimer.is_stopped():
			iceSpearTimer.start()
			print("[DEBUG] IceSpearTimer 已启动")
	
	var tornado_level = skill_mgr.get_skill_level("tornado")
	if tornado_level > 0:
		var attack_speed = skill_mgr.get_skill_attack_speed("tornado")
		tornadoTimer.wait_time = attack_speed * (1 - stats.spell_cooldown)
		if tornadoTimer.is_stopped():
			tornadoTimer.start()
	
	var javelin_level = skill_mgr.get_skill_level("javelin")
	if javelin_level > 0:
		spawn_javelin()

func _on_hurt_box_hurt(damage, _angle, _knockback):
	var actual_damage = stats.take_damage(damage)
	healthBar.max_value = stats.maxhp
	healthBar.value = stats.hp
	
	if not stats.is_alive():
		death()

func _on_ice_spear_timer_timeout():
	print("[DEBUG] IceSpearTimer 超时触发")
	var base_ammo = skill_mgr.get_skill_base_ammo("icespear")
	var total_ammo = base_ammo + stats.additional_attacks
	print("[DEBUG] base_ammo: ", base_ammo, " additional_attacks: ", stats.additional_attacks, " total: ", total_ammo)
	skill_mgr.set_skill_ammo("icespear", total_ammo)
	iceSpearAttackTimer.start()
	print("[DEBUG] IceSpearAttackTimer 已启动")

func _on_ice_spear_attack_timer_timeout():
	print("[DEBUG] IceSpearAttackTimer 超时触发")
	var ammo = skill_mgr.get_skill_ammo("icespear")
	print("[DEBUG] 当前弹药: ", ammo)
	if ammo > 0:
		print("[DEBUG] 发射冰矛！")
		var icespear_attack = iceSpear.instantiate()
		icespear_attack.position = position
		icespear_attack.target = get_random_target()
		icespear_attack.level = skill_mgr.get_skill_level("icespear")
		add_child(icespear_attack)
		skill_mgr.set_skill_ammo("icespear", ammo - 1)
		
		if skill_mgr.get_skill_ammo("icespear") > 0:
			iceSpearAttackTimer.start()
		else:
			iceSpearAttackTimer.stop()

func _on_tornado_timer_timeout():
	var base_ammo = skill_mgr.get_skill_base_ammo("tornado")
	skill_mgr.set_skill_ammo("tornado", base_ammo + stats.additional_attacks)
	tornadoAttackTimer.start()

func _on_tornado_attack_timer_timeout():
	var ammo = skill_mgr.get_skill_ammo("tornado")
	if ammo > 0:
		var tornado_attack = tornado.instantiate()
		tornado_attack.position = position
		tornado_attack.last_movement = last_movement
		tornado_attack.level = skill_mgr.get_skill_level("tornado")
		add_child(tornado_attack)
		skill_mgr.set_skill_ammo("tornado", ammo - 1)
		
		if skill_mgr.get_skill_ammo("tornado") > 0:
			tornadoAttackTimer.start()
		else:
			tornadoAttackTimer.stop()

func spawn_javelin():
	var javelin_ammo = skill_mgr.get_skill_ammo("javelin")
	var get_javelin_total = javelinBase.get_child_count()
	var calc_spawns = (javelin_ammo + stats.additional_attacks) - get_javelin_total
	
	while calc_spawns > 0:
		var javelin_spawn = javelin.instantiate()
		javelin_spawn.global_position = global_position
		javelinBase.add_child(javelin_spawn)
		calc_spawns -= 1
	
	var get_javelins = javelinBase.get_children()
	for i in get_javelins:
		if i.has_method("update_javelin"):
			i.update_javelin()

func get_random_target():
	if enemy_close.size() > 0:
		return enemy_close.pick_random().global_position
	else:
		return Vector2.UP

func _on_enemy_detection_area_body_entered(body):
	if not enemy_close.has(body):
		enemy_close.append(body)

func _on_enemy_detection_area_body_exited(body):
	if enemy_close.has(body):
		enemy_close.erase(body)

func _on_grab_area_area_entered(area):
	if area.is_in_group("loot"):
		area.target = self

func _on_collect_area_area_entered(area):
	if area.is_in_group("loot"):
		var gem_exp = area.collect()
		exp_mgr.add_experience(gem_exp)

func _on_level_up(new_level: int):
	sndLevelUp.play()
	lblLevel.text = str("等级：", new_level)
	
	var tween = levelPanel.create_tween()
	tween.tween_property(levelPanel, "position", Vector2(220, 50), 0.2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	tween.play()
	levelPanel.visible = true
	
	# 生成升级选项
	var options = 0
	var optionsmax = 3
	while options < optionsmax:
		var option_choice = itemOptions.instantiate()
		var random_item = upgrade_mgr.get_random_upgrade()
		option_choice.item = random_item
		upgradeOptions.add_child(option_choice)
		options += 1
	
	get_tree().paused = true

func _on_experience_changed(current_exp: int, required_exp: int):
	set_expbar(current_exp, required_exp)

func set_expbar(set_value: int = 1, set_max_value: int = 100):
	expBar.value = set_value
	expBar.max_value = set_max_value

func upgrade_character(upgrade_id: String):
	upgrade_mgr.apply_upgrade(upgrade_id)
	adjust_gui_collection(upgrade_id)
	attack()
	
	# 清除升级选项 UI
	var option_children = upgradeOptions.get_children()
	for i in option_children:
		i.queue_free()
	upgrade_mgr.clear_upgrade_options()
	
	levelPanel.visible = false
	levelPanel.position = Vector2(800, 50)
	get_tree().paused = false
	exp_mgr.add_experience(0)

func change_time(argtime: int = 0):
	time = argtime
	var get_m = int(time / 60.0)
	var get_s = time % 60
	if get_m < 10:
		get_m = str(0, get_m)
	if get_s < 10:
		get_s = str(0, get_s)
	lblTimer.text = str(get_m, ":", get_s)

func adjust_gui_collection(upgrade_id: String):
	var upgrade_db = get_node_or_null("/root/UpgradeDb")
	if upgrade_db == null:
		return
	
	# 安全检查：确保升级存在
	if not upgrade_db.UPGRADES.has(upgrade_id):
		push_warning("升级不存在: %s" % upgrade_id)
		return
	
	var upgrade_data = upgrade_db.UPGRADES[upgrade_id]
	var get_upgraded_displayname = upgrade_data["displayname"]
	var get_type = upgrade_data["type"]
	
	if get_type != "item":
		var get_collected_displaynames = []
		for i in upgrade_mgr.collected_upgrades:
			if upgrade_db.UPGRADES.has(i):
				get_collected_displaynames.append(upgrade_db.UPGRADES[i]["displayname"])
		
		if not get_upgraded_displayname in get_collected_displaynames:
			var new_item = itemContainer.instantiate()
			new_item.upgrade = upgrade_id
			match get_type:
				"weapon":
					collectedWeapons.add_child(new_item)
				"upgrade":
					collectedUpgrades.add_child(new_item)

func death():
	deathPanel.visible = true
	emit_signal("playerdeath")
	if has_node("/root/EventBus"):
		get_node("/root/EventBus").emit_signal("player_died")
	get_tree().paused = true
	
	var tween = deathPanel.create_tween()
	tween.tween_property(deathPanel, "position", Vector2(220, 50), 3.0).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()
	
	if time >= 300:
		lblResult.text = "你赢了"
		sndVictory.play()
		if has_node("/root/EventBus"):
			get_node("/root/EventBus").emit_signal("game_won")
	else:
		lblResult.text = "你输了"
		sndLose.play()
		if has_node("/root/EventBus"):
			get_node("/root/EventBus").emit_signal("game_lost")

func _on_btn_menu_click_end():
	get_tree().paused = false
	var _level = get_tree().change_scene_to_file("res://TitleScreen/menu.tscn")

# 兼容性属性访问器（供技能使用）
func _get(property):
	match property:
		"spell_size":
			return stats.spell_size if stats else 0
		"spell_cooldown":
			return stats.spell_cooldown if stats else 0
		"additional_attacks":
			return stats.additional_attacks if stats else 0
		"javelin_level":
			return skill_mgr.get_skill_level("javelin") if skill_mgr else 0
		"icespear_level":
			return skill_mgr.get_skill_level("icespear") if skill_mgr else 0
		"tornado_level":
			return skill_mgr.get_skill_level("tornado") if skill_mgr else 0
	return null

func _set(property, value):
	match property:
		"movement_speed":
			if stats:
				stats.movement_speed = value
			return true
		"hp":
			if stats:
				stats.hp = value
			return true
		"armor":
			if stats:
				stats.armor = value
			return true
	return false
