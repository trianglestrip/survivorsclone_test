extends Node

# 游戏事件总线 - 用于解耦各个系统之间的通信
# 注意：部分信号为未来功能预留，暂未使用

# 敌人相关事件
signal enemy_killed(enemy_type: String, position: Vector2, experience: int)
# signal enemy_spawned(enemy_type: String, position: Vector2)  # 预留：敌人生成统计
# signal enemy_damaged(enemy_type: String, damage: int)  # 预留：伤害统计

# 玩家相关事件
signal player_leveled_up(new_level: int)
signal player_died()
# signal player_damaged(damage: int, current_hp: int)  # 预留：伤害反馈
# signal player_healed(amount: int, current_hp: int)  # 预留：治疗效果

# 技能相关事件
signal skill_upgraded(skill_name: String, new_level: int)
signal skill_activated(skill_name: String)  # 预留：技能激活效果
signal skill_unlocked(skill_name: String)  # 预留：技能解锁提示

# 升级相关事件
signal upgrade_collected(upgrade_id: String)
signal upgrade_available(upgrade_options: Array)  # 预留：升级选项生成

# 游戏流程事件
signal game_won()
signal game_lost()
# signal wave_started(wave_number: int)  # 预留：波次开始提示
# signal wave_completed(wave_number: int)  # 预留：波次完成奖励
# signal boss_spawned(boss_type: String)  # 预留：Boss 出现警告
# signal game_started()  # 预留：游戏开始事件

# 经验相关事件
# signal experience_collected(amount: int)  # 预留：经验收集反馈
# signal experience_gem_spawned(position: Vector2, amount: int)  # 预留：宝石生成

# 时间相关事件
# signal time_changed(current_time: int)  # 预留：时间显示更新

# 工具方法：发送事件的便捷方法
func emit_enemy_killed(enemy_type: String, pos: Vector2, experience: int):
	emit_signal("enemy_killed", enemy_type, pos, experience)

func emit_player_leveled_up(new_level: int):
	emit_signal("player_leveled_up", new_level)

func emit_skill_upgraded(skill_name: String, new_level: int):
	emit_signal("skill_upgraded", skill_name, new_level)

func emit_upgrade_collected(upgrade_id: String):
	emit_signal("upgrade_collected", upgrade_id)
