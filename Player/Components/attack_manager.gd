extends Node
class_name AttackManager

# 攻击管理器 - 统一管理所有技能的攻击逻辑
# 职责：
# - 管理技能计时器
# - 触发技能攻击
# - 处理技能弹药逻辑

var player: Node = null
var skill_instance_mgr: Node = null

# 技能计时器
var skill_timers: Dictionary = {}

func set_player(p: Node):
	player = p

func set_skill_instance_manager(mgr: Node):
	skill_instance_mgr = mgr

func _ready():
	_initialize_skill_timers()

func _initialize_skill_timers():
	# 初始化所有技能计时器
	_register_skill_timer("icespear", 1.5, _on_icespear_timer_timeout)
	_register_skill_timer("tornado", 3.0, _on_tornado_timer_timeout)

func _register_skill_timer(skill_id: String, base_wait_time: float, callback: Callable):
	var timer = Timer.new()
	timer.name = skill_id + "_timer"
	timer.wait_time = base_wait_time
	timer.timeout.connect(callback)
	add_child(timer)
	skill_timers[skill_id] = timer

func start_attacks():
	# 启动所有已解锁技能的攻击
	if skill_instance_mgr.get_skill_level("icespear") > 0:
		start_skill_attack("icespear")
	
	if skill_instance_mgr.get_skill_level("tornado") > 0:
		start_skill_attack("tornado")
	
	if skill_instance_mgr.get_skill_level("javelin") > 0:
		spawn_javelin()

func start_skill_attack(skill_id: String):
	if not skill_timers.has(skill_id):
		return
	
	var timer = skill_timers[skill_id]
	if timer.is_stopped():
		timer.start()

func update_skill_cooldown(skill_id: String, cooldown_multiplier: float):
	if not skill_timers.has(skill_id):
		return
	
	var base_speed = skill_instance_mgr.get_skill_attack_speed(skill_id)
	skill_timers[skill_id].wait_time = base_speed * (1 - cooldown_multiplier)

func _on_icespear_timer_timeout():
	if not skill_instance_mgr or not player:
		return
	
	var base_ammo = skill_instance_mgr.get_skill_base_ammo("icespear")
	var additional_attacks = player.stats.additional_attacks if player and player.has("stats") else 0
	var total_ammo = base_ammo + additional_attacks
	
	skill_instance_mgr.set_skill_ammo("icespear", total_ammo)
	
	# 发射所有弹药
	for i in range(total_ammo):
		skill_instance_mgr.spawn_skill_with_behavior("icespear")

func _on_tornado_timer_timeout():
	if not skill_instance_mgr or not player:
		return
	
	var base_ammo = skill_instance_mgr.get_skill_base_ammo("tornado")
	var additional_attacks = player.stats.additional_attacks if player and player.has("stats") else 0
	var total_ammo = base_ammo + additional_attacks
	
	skill_instance_mgr.set_skill_ammo("tornado", total_ammo)
	
	# 发射所有弹药
	for i in range(total_ammo):
		skill_instance_mgr.spawn_skill_with_behavior("tornado")

func spawn_javelin():
	if not skill_instance_mgr or not player:
		return
	
	var javelin_ammo = skill_instance_mgr.get_skill_base_ammo("javelin")
	var additional_attacks = player.stats.additional_attacks if player and player.has("stats") else 0
	var total_ammo = javelin_ammo + additional_attacks
	
	# 标枪特殊实现 - 暂时保持现有逻辑
	# 注意：标枪未来也应该迁移到 GPU 实例化
	pass
