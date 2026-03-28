extends Node
class_name ExperienceManager

# 经验管理器 - 管理玩家经验值和等级

var player_stats = null

signal level_up(new_level: int)
signal experience_changed(current_exp: int, required_exp: int)

func set_player_stats(stats):
	player_stats = stats

# 计算经验值上限
func calculate_experience_cap() -> int:
	if player_stats == null:
		return 100
	
	var level = player_stats.experience_level
	var exp_cap = level
	
	if level < 20:
		exp_cap = level * 5
	elif level < 40:
		exp_cap = 95 + (level - 19) * 8
	else:
		exp_cap = 255 + (level - 39) * 12
	
	return exp_cap

# 添加经验值
func add_experience(amount: int):
	if player_stats == null:
		return
	
	var exp_required = calculate_experience_cap()
	player_stats.collected_experience += amount
	
	while player_stats.experience + player_stats.collected_experience >= exp_required:
		# 升级
		player_stats.collected_experience -= exp_required - player_stats.experience
		player_stats.experience_level += 1
		player_stats.experience = 0
		exp_required = calculate_experience_cap()
		
		# 触发升级事件
		emit_signal("level_up", player_stats.experience_level)
		if has_node("/root/EventBus"):
			get_node("/root/EventBus").emit_player_leveled_up(player_stats.experience_level)
	
	# 添加剩余经验
	player_stats.experience += player_stats.collected_experience
	player_stats.collected_experience = 0
	
	# 发送经验变化事件
	emit_signal("experience_changed", player_stats.experience, exp_required)

# 获取当前经验值
func get_current_experience() -> int:
	if player_stats:
		return player_stats.experience
	return 0

# 获取当前等级
func get_current_level() -> int:
	if player_stats:
		return player_stats.experience_level
	return 1

# 获取经验值进度（0-1）
func get_experience_progress() -> float:
	if player_stats == null:
		return 0.0
	
	var required = calculate_experience_cap()
	if required == 0:
		return 1.0
	
	return float(player_stats.experience) / float(required)
