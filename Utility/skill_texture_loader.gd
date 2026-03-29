extends Node

## 技能纹理加载器
## 加载和管理技能动画帧纹理

const SKILL_ASSETS_PATH = "res://Assets/Skills/"

## 技能纹理缓存
var texture_cache: Dictionary = {}

## 加载技能动画帧
## @param skill_name: 技能名称（如 "ice_shard", "fire_ball"）
## @param frame_index: 帧索引（0开始）
## @return: Texture2D 或 null
func load_skill_frame(skill_name: String, frame_index: int = 0) -> Texture2D:
	var cache_key = "%s_%d" % [skill_name, frame_index]
	
	# 检查缓存
	if texture_cache.has(cache_key):
		return texture_cache[cache_key]
	
	# 构建路径
	var texture_path = "%s%s_frame_%d.png" % [SKILL_ASSETS_PATH, skill_name, frame_index]
	
	# 尝试加载
	if ResourceLoader.exists(texture_path):
		var texture = load(texture_path) as Texture2D
		if texture:
			texture_cache[cache_key] = texture
			return texture
	
	# 如果加载失败，返回null（调用者应使用占位纹理）
	return null

## 加载技能所有动画帧
## @param skill_name: 技能名称
## @param max_frames: 最大帧数（默认12）
## @return: Array[Texture2D]
func load_skill_frames(skill_name: String, max_frames: int = 12) -> Array:
	var frames = []
	
	for i in range(max_frames):
		var texture = load_skill_frame(skill_name, i)
		if texture:
			frames.append(texture)
		else:
			break  # 没有更多帧
	
	return frames

## 预加载所有技能纹理（可选，用于减少运行时加载）
func preload_all_skills():
	var skills = [
		# 冰心宗
		{"name": "ice_shard", "frames": 4},
		{"name": "ice_field", "frames": 8},
		{"name": "ice_storm", "frames": 12},
		# 雷鸣宗
		{"name": "thunder_strike", "frames": 4},
		{"name": "thunder_field", "frames": 8},
		{"name": "thunder_god", "frames": 12},
		# 烈焰宗
		{"name": "fire_ball", "frames": 4},
		{"name": "fire_wall", "frames": 8},
		{"name": "fire_meteor", "frames": 12},
		# 毒瘴宗
		{"name": "poison_dart", "frames": 4},
		{"name": "poison_cloud", "frames": 8},
		{"name": "poison_plague", "frames": 12}
	]
	
	for skill in skills:
		for i in range(skill["frames"]):
			load_skill_frame(skill["name"], i)
	
	print("[SkillTextureLoader] Preloaded %d textures" % texture_cache.size())

## 清除缓存
func clear_cache():
	texture_cache.clear()
