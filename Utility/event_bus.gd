extends Node

# 游戏事件总线 - 用于解耦各个系统之间的通信

# 敌人相关事件
signal enemy_killed(enemy_type: String, position: Vector2, experience: int)
signal enemy_spawned(enemy_type: String, position: Vector2)
signal enemy_damaged(enemy_type: String, damage: int)

# 玩家相关事件
signal player_leveled_up(new_level: int)
signal player_damaged(damage: int, current_hp: int)
signal player_healed(amount: int, current_hp: int)
signal player_died()

# 技能相关事件
signal skill_upgraded(skill_name: String, new_level: int)
signal skill_activated(skill_name: String)
signal skill_unlocked(skill_name: String)

# 升级相关事件
signal upgrade_collected(upgrade_id: String)
signal upgrade_available(upgrade_options: Array)

# 游戏流程事件
signal wave_started(wave_number: int)
signal wave_completed(wave_number: int)
signal boss_spawned(boss_type: String)
signal game_started()
signal game_won()
signal game_lost()

# 经验相关事件
signal experience_collected(amount: int)
signal experience_gem_spawned(position: Vector2, amount: int)

# 时间相关事件
signal time_changed(current_time: int)

# 工具方法：发送事件的便捷方法
func emit_enemy_killed(enemy_type: String, pos: Vector2, exp: int):
	emit_signal("enemy_killed", enemy_type, pos, exp)

func emit_player_leveled_up(new_level: int):
	emit_signal("player_leveled_up", new_level)

func emit_skill_upgraded(skill_name: String, new_level: int):
	emit_signal("skill_upgraded", skill_name, new_level)

func emit_upgrade_collected(upgrade_id: String):
	emit_signal("upgrade_collected", upgrade_id)
