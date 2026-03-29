class_name GameConstants
extends Object

## 游戏常量定义
## 所有硬编码的数值、颜色、路径都定义在这里

# ========================================
# 颜色常量
# ========================================

class Colors:
	# 宗派颜色
	const SECT_ICE := Color(0.302, 0.816, 0.882)  # #4DD0E1
	const SECT_THUNDER := Color(1.0, 0.835, 0.310)  # #FFD54F
	const SECT_FIRE := Color(1.0, 0.431, 0.251)  # #FF6E40
	const SECT_POISON := Color(0.612, 0.8, 0.396)  # #9CCC65
	
	# UI颜色
	const UI_GOLD := Color(0.9, 0.85, 0.6, 1.0)
	const UI_BORDER := Color(0.8, 0.7, 0.3, 1.0)
	const UI_BG_DARK := Color(0.05, 0.05, 0.1, 0.95)
	const UI_BG_CARD := Color(0.1, 0.1, 0.15, 1.0)
	const UI_TEXT_NORMAL := Color(0.7, 0.7, 0.7, 1.0)
	const UI_TEXT_TITLE := Color(0.9, 0.85, 0.6, 1.0)
	
	# 特效颜色
	const EFFECT_DASH_TRAIL := Color(0.5, 0.8, 1.0, 0.6)
	const EFFECT_HURT_FLASH := Color(1.0, 0.3, 0.3, 0.5)
	const EFFECT_SLASH := Color(0.5, 0.8, 1.0, 0.8)
	
	# 血条颜色
	const HEALTH_HIGH := Color(0.2, 0.8, 0.3, 1.0)
	const HEALTH_MID := Color(0.9, 0.8, 0.2, 1.0)
	const HEALTH_LOW := Color(0.9, 0.2, 0.2, 1.0)

# ========================================
# 路径常量
# ========================================

class Paths:
	# 配置文件
	const CONFIG_CONTROLS := "res://config/stage1_controls.json"
	const CONFIG_SECTS := "res://config/sect_config.json"
	const CONFIG_SKILLS := "res://config/skill_registry.json"
	const CONFIG_ENEMIES := "res://config/enemy_registry.json"
	const CONFIG_UPGRADES := "res://config/upgrade_config.json"
	
	# 资源路径
	const ASSETS_UI := "res://Assets/UI/"
	const ASSETS_EFFECTS := "res://Assets/Effects/"
	const ASSETS_SKILLS := "res://Assets/Effects/Skills/"
	const ASSETS_SECTS := "res://Assets/UI/Sects/"
	
	# 脚本路径
	const SCRIPTS_ACTIVE_SKILLS := "res://Skills/ActiveSkills/"
	const SCRIPTS_COMPONENTS := "res://Player/Components/"

# ========================================
# 数值常量
# ========================================

class Values:
	# 时间常量
	const FRAME_TIME := 1.0 / 60.0
	const HIT_PAUSE_DURATION := 0.05
	const HURT_FLASH_DURATION := 0.1
	const EFFECT_FADE_TIME := 0.5
	
	# 屏幕震动强度
	const SHAKE_ATTACK := 0.2
	const SHAKE_HIT := 0.4
	const SHAKE_DASH := 0.3
	const SHAKE_HURT := 0.5
	
	# UI尺寸
	const SKILL_SLOT_SIZE := 64
	const SKILL_SLOT_SPACING := 8
	const HEALTH_BAR_WIDTH := 200
	const HEALTH_BAR_HEIGHT := 24
	const SECT_CARD_WIDTH := 160
	const SECT_CARD_HEIGHT := 240
	
	# 效果参数
	const DASH_TRAIL_ALPHA := 0.6
	const GLOW_PULSE_SPEED := 2.0
	const ANIMATION_SCALE_MIN := 0.8
	const ANIMATION_SCALE_MAX := 1.2

# ========================================
# 技能类型枚举
# ========================================

enum SkillType {
	PASSIVE,      # 被动技能（自动释放）
	ACTIVE_Q,     # 主动技能Q
	ACTIVE_E,     # 主动技能E
	ACTIVE_R,     # 主动技能R
	WEAPON        # 武器技能
}

# ========================================
# 攻击类型枚举
# ========================================

enum AttackType {
	MELEE,        # 近战
	RANGED,       # 远程
	MAGIC,        # 法术
	SUMMON        # 召唤
}

# ========================================
# 状态效果类型
# ========================================

enum StatusEffectType {
	SLOW,         # 减速
	FREEZE,       # 冻结
	BURN,         # 灼烧
	POISON,       # 中毒
	STUN,         # 眩晕
	WEAKEN        # 虚弱
}

# ========================================
# 宗派类型
# ========================================

enum SectType {
	ICE,          # 冰心宗
	THUNDER,      # 雷鸣宗
	FIRE,         # 烈焰宗
	POISON        # 毒瘴宗
}
