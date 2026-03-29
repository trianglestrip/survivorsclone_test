extends Node

## 验证技能动画 PNG 能否被 Godot 资源系统正常加载（增强脚本之后可用）。

const ANIM_DIR := "res://Textures/Skills/Animations/"

const SKILLS := [
	{"name": "ice_shard", "frames": 4},
	{"name": "ice_field", "frames": 8},
	{"name": "ice_storm", "frames": 12},
	{"name": "thunder_strike", "frames": 4},
	{"name": "thunder_field", "frames": 8},
	{"name": "thunder_god", "frames": 12},
	{"name": "fire_ball", "frames": 4},
	{"name": "fire_wall", "frames": 8},
	{"name": "fire_meteor", "frames": 12},
	{"name": "poison_dart", "frames": 4},
	{"name": "poison_cloud", "frames": 8},
	{"name": "poison_plague", "frames": 12},
]


func _ready() -> void:
	var ok := 0
	var fail := 0
	for skill in SKILLS:
		var skill_name: String = skill["name"]
		var max_f: int = skill["frames"]
		for i in range(max_f):
			var path := "%s%s_frame_%d.png" % [ANIM_DIR, skill_name, i]
			if not ResourceLoader.exists(path):
				push_error("缺少或无法解析: %s" % path)
				fail += 1
				continue
			var tex = load(path)
			if tex == null:
				push_error("load 返回 null: %s" % path)
				fail += 1
				continue
			if not (tex is Texture2D):
				push_error("非 Texture2D: %s" % path)
				fail += 1
				continue
			var t2: Texture2D = tex
			var sz := t2.get_size()
			if sz.x <= 0 or sz.y <= 0:
				push_error("无效尺寸 %s: %s" % [path, sz])
				fail += 1
				continue
			ok += 1
	print("[test_skill_animation_load] 通过: %d, 失败: %d" % [ok, fail])
	get_tree().quit(0 if fail == 0 else 1)
