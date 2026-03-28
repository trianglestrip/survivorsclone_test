extends Area2D
class_name BaseSkill

# 技能基类 - 所有技能的通用属性和方法

# 基础属性
var level: int = 1
var hp: int = 1
var speed: float = 100.0
var damage: int = 5
var knockback_amount: int = 100
var attack_size: float = 1.0

# 配置相关
var skill_name: String = ""
var config_section: String = ""

# 引用
@onready var player = get_tree().get_first_node_in_group("player")

signal remove_from_array(object)

func _ready():
	if config_section != "":
		load_skill_config()
	apply_player_modifiers()
	on_skill_ready()

# 子类重写此方法来加载特定配置
func load_skill_config():
	if config_section == "":
		return
	
	var cfg = ConfigFile.new()
	if cfg.load("res://config/skill_config.ini") != OK:
		push_error("Failed to load skill config for: %s" % config_section)
		return
	
	if not cfg.has_section(config_section):
		push_warning("Config section not found: %s" % config_section)
		return
	
	# 加载基础属性
	hp = cfg.get_value(config_section, "base_hp", hp)
	speed = cfg.get_value(config_section, "base_speed", speed)
	damage = cfg.get_value(config_section, "base_damage", damage)
	knockback_amount = cfg.get_value(config_section, "base_knockback_amount", knockback_amount)
	attack_size = cfg.get_value(config_section, "base_attack_size", attack_size)
	
	# 加载等级相关属性
	load_level_config(cfg)

# 加载等级相关配置
func load_level_config(cfg: ConfigFile):
	var level_hp_key = "level%d_hp" % level
	var level_damage_key = "level%d_damage" % level
	var level_knockback_key = "level%d_knockback_amount" % level
	
	if cfg.has_section_key(config_section, level_hp_key):
		hp = cfg.get_value(config_section, level_hp_key, hp)
	
	if cfg.has_section_key(config_section, level_damage_key):
		damage = cfg.get_value(config_section, level_damage_key, damage)
	
	if cfg.has_section_key(config_section, level_knockback_key):
		knockback_amount = cfg.get_value(config_section, level_knockback_key, knockback_amount)

# 应用玩家的全局修正器
func apply_player_modifiers():
	if player == null:
		return
	
	# 尝试通过多种方式获取 spell_size
	var spell_size = 0.0
	
	# 方法 1：直接访问 stats 组件（新架构）
	if player.has_node("PlayerStats") or (player.get("stats") != null):
		var stats = player.get("stats")
		if stats and stats.get("spell_size") != null:
			spell_size = stats.spell_size
	# 方法 2：直接属性访问（旧架构）
	elif "spell_size" in player:
		spell_size = player.spell_size
	
	attack_size *= (1 + spell_size)

# 子类可以重写此方法来执行初始化逻辑
func on_skill_ready():
	pass

# 子类可以重写此方法来实现特定的移动逻辑
func skill_movement(_delta: float):
	pass

# 处理敌人命中
func enemy_hit(charge: int = 1):
	hp -= charge
	if hp <= 0:
		on_skill_destroyed()

# 技能销毁时调用
func on_skill_destroyed():
	emit_signal("remove_from_array", self)
	queue_free()

# 获取技能伤害（可被子类重写）
func get_damage() -> int:
	return damage

# 获取击退量（可被子类重写）
func get_knockback() -> int:
	return knockback_amount
