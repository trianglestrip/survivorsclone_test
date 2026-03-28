extends SceneTree

# 测试技能与玩家的交互

func _init():
	print("\n=== 技能-玩家交互测试 ===\n")
	
	# 创建模拟玩家（使用实际的 player 脚本）
	var player_script = load("res://Player/player.gd")
	var mock_player = player_script.new()
	
	# 注意：不能调用 _ready()，因为它需要场景树节点
	# 所以我们手动初始化组件
	var stats_script = load("res://Player/Components/player_stats.gd")
	mock_player.stats = stats_script.new()
	mock_player.stats.spell_size = 0.5
	
	print("【测试】BaseSkill.apply_player_modifiers()")
	print("  玩家 spell_size: ", mock_player.stats.spell_size)
	print("  通过 _get 访问: ", mock_player.spell_size)
	
	# 创建技能
	var base_skill_script = load("res://Utility/base_skill.gd")
	var skill = base_skill_script.new()
	skill.player = mock_player
	skill.attack_size = 1.0
	
	print("  技能初始 attack_size: ", skill.attack_size)
	
	# 调试：检查 player 中是否有 stats
	print("  'stats' in player: ", "stats" in mock_player)
	print("  player.stats: ", mock_player.stats if "stats" in mock_player else "N/A")
	if "stats" in mock_player and mock_player.stats != null:
		print("  player.stats.spell_size: ", mock_player.stats.spell_size)
	
	skill.apply_player_modifiers()
	
	print("  应用修正后 attack_size: ", skill.attack_size)
	print("  预期值: ", 1.0 * (1 + 0.5), " = 1.5")
	
	if abs(skill.attack_size - 1.5) < 0.01:
		print("  ✓ 测试通过！")
		quit(0)
	else:
		print("  ✗ 测试失败！")
		quit(1)
