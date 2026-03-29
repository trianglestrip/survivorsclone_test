extends Node

## 游戏全局配置
## 所有全局常量和配置项的中心化管理

# ========================================
# 调试配置
# ========================================

## 是否启用调试日志（编辑器模式下建议关闭以加快启动）
const DEBUG_LOGGING := true

## 是否显示性能统计（FPS、内存等）
const SHOW_PERFORMANCE_STATS := false

## 是否显示碰撞调试信息
const DEBUG_COLLISION := false

# ========================================
# 性能配置
# ========================================

## 是否使用 GPU 实例化渲染敌人
const USE_GPU_INSTANCING := true

## 最大敌人数量（GPU 模式下可以更高）
const MAX_ENEMIES := 1000 if USE_GPU_INSTANCING else 200

## 对象池预热数量
const OBJECT_POOL_PREWARM_SIZE := 20

# ========================================
# 游戏规则配置
# ========================================

## 游戏时长（秒）- 达到此时间即胜利
const GAME_DURATION := 300

## 玩家初始生命值
const PLAYER_INITIAL_HP := 100

## 经验宝石收集范围
const GEM_COLLECT_RANGE := 50.0

# ========================================
# 碰撞层定义（与 project.godot 保持一致）
# ========================================

enum CollisionLayer {
	WORLD = 1,          # Layer 1: 世界静态物体
	PLAYER = 2,         # Layer 2: 玩家 + 敌人攻击
	ENEMY = 4,          # Layer 3: 敌人 + 武器
	LOOT = 8,           # Layer 4: 拾取物
}

# ========================================
# 动画配置
# ========================================

## 敌人动画帧时长（秒/帧）
const ENEMY_ANIM_FRAME_DURATION := 0.3

## 敌人动画随机偏移范围（秒）
const ENEMY_ANIM_OFFSET_RANGE := 0.6

# ========================================
# 路径配置
# ========================================

const PATH_ENEMY_CONFIG := "res://config/enemy_config.json"
const PATH_ENEMY_REGISTRY := "res://config/enemy_registry.json"
const PATH_SKILL_REGISTRY := "res://config/skill_registry.json"
const PATH_SKILL_CONFIG := "res://config/skill_config.json"
const PATH_UPGRADE_CONFIG := "res://config/upgrade_config.json"
const PATH_SPAWN_WAVES := "res://config/spawn_waves.json"

# ========================================
# 辅助函数
# ========================================

## 根据碰撞层枚举获取位掩码值
static func get_layer_mask(layer: CollisionLayer) -> int:
	return layer

## 打印调试信息（仅在 DEBUG_LOGGING 启用时）
static func debug_print(message: String):
	if DEBUG_LOGGING:
		print(message)

## 打印调试信息（格式化，仅在 DEBUG_LOGGING 启用时）
static func debug_printf(format: String, values: Array):
	if DEBUG_LOGGING:
		print(format % values)
