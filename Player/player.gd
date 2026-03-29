extends CharacterBody2D

# 重构后的玩家类 - 使用组件化架构

# 组件
var stats
var upgrade_mgr
var exp_mgr
var attack_mgr
var dash_mgr
var active_skill_mgr
var sect_mgr

# 基础变量
var last_movement = Vector2.UP
var time = 0

# 敌人检测
var enemy_close = []

# 节点引用
@onready var sprite = $Sprite2D
@onready var walkTimer = get_node("%walkTimer")
@onready var hurt_box = $HurtBox

# 受击特效
var _hit_frames: Array = []

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
	_load_hit_frames()
	await _initialize_components()
	_connect_signals()
	_initial_setup()

func _load_hit_frames():
	for i in range(8):
		var texture_path = "res://Textures/Placeholder/Effects/Hit/hit_%d.png" % i
		if ResourceLoader.exists(texture_path):
			var texture = load(texture_path)
			_hit_frames.append(texture)

func _initialize_components():
	# 创建组件
	var stats_script = load("res://Player/Components/player_stats.gd")
	stats = stats_script.new()
	add_child(stats)
	
	# 创建输入管理器
	var input_mgr_script = load("res://Player/Components/input_manager.gd")
	var input_mgr = input_mgr_script.new()
	add_child(input_mgr)
	
	var upgrade_mgr_script = load("res://Player/Components/upgrade_manager.gd")
	upgrade_mgr = upgrade_mgr_script.new()
	upgrade_mgr.set_player_stats(stats)
	add_child(upgrade_mgr)
	
	var exp_mgr_script = load("res://Player/Components/experience_manager.gd")
	exp_mgr = exp_mgr_script.new()
	exp_mgr.set_player_stats(stats)
	add_child(exp_mgr)
	
	# 创建攻击管理器
	var attack_mgr_script = load("res://Player/Components/attack_manager.gd")
	attack_mgr = attack_mgr_script.new()
	attack_mgr.set_player(self)
	attack_mgr.set_input_manager(input_mgr)
	add_child(attack_mgr)
	
	# 创建冲刺管理器
	var dash_mgr_script = load("res://Player/Components/dash_manager.gd")
	dash_mgr = dash_mgr_script.new()
	dash_mgr.set_player(self)
	dash_mgr.set_input_manager(input_mgr)
	add_child(dash_mgr)
	
	# 创建主动技能管理器
	var active_skill_mgr_script = load("res://Player/Components/active_skill_manager.gd")
	active_skill_mgr = active_skill_mgr_script.new()
	active_skill_mgr.set_player(self)
	active_skill_mgr.set_input_manager(input_mgr)
	add_child(active_skill_mgr)
	
	# 创建宗派管理器
	var sect_mgr_script = load("res://Player/Components/sect_manager.gd")
	sect_mgr = sect_mgr_script.new()
	sect_mgr.set_player(self)
	sect_mgr.set_active_skill_manager(active_skill_mgr)
	add_child(sect_mgr)

func _connect_signals():
	exp_mgr.level_up.connect(_on_level_up)
	exp_mgr.experience_changed.connect(_on_experience_changed)
	if dash_mgr:
		dash_mgr.dash_started.connect(_on_dash_started)
		dash_mgr.dash_ended.connect(_on_dash_ended)
		dash_mgr.dash_cooldown_updated.connect(_on_dash_cooldown_updated)
	if active_skill_mgr:
		active_skill_mgr.skill_cast.connect(_on_skill_cast)
		active_skill_mgr.skill_cooldown_updated.connect(_on_skill_cooldown_updated)

func _on_dash_started():
	if hurt_box and hurt_box.has_node("CollisionShape2D"):
		hurt_box.get_node("CollisionShape2D").disabled = true

func _on_dash_ended():
	if hurt_box and hurt_box.has_node("CollisionShape2D"):
		hurt_box.get_node("CollisionShape2D").disabled = false

func _on_dash_cooldown_updated(current_cooldown: float, max_cooldown: float):
	var skill_bar_ui = get_node_or_null("%SkillBarUI")
	if skill_bar_ui and skill_bar_ui.has_method("update_skill_cooldown"):
		skill_bar_ui.update_skill_cooldown("shift", current_cooldown, max_cooldown)

func _on_skill_cast(skill_id: String):
	if GameConfig.DEBUG_LOGGING:
		print("玩家释放技能: %s" % skill_id.to_upper())
	
	match skill_id:
		"q":
			_cast_q_skill()
		"e":
			_cast_e_skill()
		"r":
			_cast_r_skill()

func _on_skill_cooldown_updated(skill_id: String, current: float, max_cd: float):
	var skill_bar_ui = get_node_or_null("%SkillBarUI")
	if skill_bar_ui and skill_bar_ui.has_method("update_skill_cooldown"):
		skill_bar_ui.update_skill_cooldown(skill_id, current, max_cd)

func _cast_q_skill():
	if not sect_mgr or not sect_mgr.has_selected_sect():
		print("请先选择宗派")
		return
	
	var skill_config = sect_mgr.get_skill_config("q")
	if skill_config.is_empty():
		return
	
	_spawn_active_skill(skill_config)

func _cast_e_skill():
	if not sect_mgr or not sect_mgr.has_selected_sect():
		print("请先选择宗派")
		return
	
	var skill_config = sect_mgr.get_skill_config("e")
	if skill_config.is_empty():
		return
	
	_spawn_active_skill(skill_config)

func _cast_r_skill():
	if not sect_mgr or not sect_mgr.has_selected_sect():
		print("请先选择宗派")
		return
	
	var skill_config = sect_mgr.get_skill_config("r")
	if skill_config.is_empty():
		return
	
	_spawn_active_skill(skill_config)

func _spawn_active_skill(skill_config: Dictionary):
	var skill_id = skill_config.get("id", "")
	var skill_script_path = "res://Skills/ActiveSkills/%s.gd" % skill_id
	
	if not ResourceLoader.exists(skill_script_path):
		if GameConfig.DEBUG_LOGGING:
			print("技能脚本不存在: %s" % skill_script_path)
		return
	
	var skill_script = load(skill_script_path)
	var skill_instance = skill_script.new()
	skill_instance.initialize(skill_config, self, sect_mgr)
	
	if get_parent():
		get_parent().call_deferred("add_child", skill_instance)
	
	skill_instance.cast(global_position, last_movement)

func _initial_setup():
	set_expbar(stats.experience, exp_mgr.calculate_experience_cap())
	_on_hurt_box_hurt(0, 0, 0)
	
	if sect_mgr:
		sect_mgr.select_sect("ice")

func _physics_process(_delta):
	movement()

func movement():
	if dash_mgr and dash_mgr.is_dashing:
		return
	
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

func _on_hurt_box_hurt(damage, _angle, _knockback):
	var _actual_damage = stats.take_damage(damage)
	healthBar.max_value = stats.maxhp
	healthBar.value = stats.hp
	
	_play_hit_effect(global_position)
	VisualEffectsHelper.trigger_screen_shake(self, GameConstants.Values.SHAKE_HURT)
	VisualEffectsHelper.trigger_flash(sprite, GameConstants.Colors.EFFECT_HURT_FLASH, GameConstants.Values.HURT_FLASH_DURATION)
	
	if not stats.is_alive():
		death()

func _play_hit_effect(position: Vector2):
	if _hit_frames.is_empty():
		return
	
	var effect_node = Node2D.new()
	effect_node.name = "HitEffect"
	effect_node.position = position
	effect_node.z_index = 10
	
	var sprite = Sprite2D.new()
	sprite.texture = _hit_frames[0]
	sprite.scale = Vector2(1.0, 1.0)
	effect_node.add_child(sprite)
	
	if get_parent():
		get_parent().call_deferred("add_child", effect_node)
	
	_animate_hit_effect(sprite, effect_node)

func _animate_hit_effect(sprite_node: Sprite2D, effect_node: Node2D):
	for i in range(_hit_frames.size()):
		await get_tree().create_timer(0.035).timeout
		if is_instance_valid(sprite_node):
			if i < _hit_frames.size():
				sprite_node.texture = _hit_frames[i]
				sprite_node.scale = Vector2(1.2, 1.2) * (1.0 + i * 0.08)
	
	await get_tree().create_timer(0.08).timeout
	if is_instance_valid(effect_node):
		effect_node.queue_free()


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
	
	# 检查是否达到胜利条件
	if time >= GameConfig.GAME_DURATION:
		death()

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
	
	if time >= GameConfig.GAME_DURATION:
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
			return stats.spell_size if stats != null else 0.0
		"spell_cooldown":
			return stats.spell_cooldown if stats != null else 0.0
		"additional_attacks":
			return stats.additional_attacks if stats != null else 0
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
