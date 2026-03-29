extends Node

## 技能视觉效果统一标准：从 JSON 加载；通过自动加载单例 VisualEffectsStandard 访问

const CONFIG_PATH := "res://config/visual_effects_standard.json"

var _data: Dictionary = {}
var _loaded: bool = false


func _ensure_loaded() -> void:
	if _loaded:
		return
	_loaded = true
	_data = {}
	if not FileAccess.file_exists(CONFIG_PATH):
		push_warning("VisualEffectsStandard: missing %s, using defaults." % CONFIG_PATH)
		return
	var f := FileAccess.open(CONFIG_PATH, FileAccess.READ)
	if f == null:
		push_warning("VisualEffectsStandard: could not open %s" % CONFIG_PATH)
		return
	var json := JSON.new()
	if json.parse(f.get_as_text()) != OK:
		push_warning("VisualEffectsStandard: JSON parse error in %s" % CONFIG_PATH)
		return
	if json.data is Dictionary:
		_data = json.data


func reload() -> void:
	_loaded = false
	_data = {}
	_ensure_loaded()


func get_skill_visual_config(skill_type: String) -> Dictionary:
	_ensure_loaded()
	var types: Dictionary = _data.get("skill_types", {})
	var cfg: Variant = types.get(skill_type, types.get("area", {}))
	return cfg if cfg is Dictionary else {}


func _hex_to_color(hex: String, fallback: Color = Color.WHITE) -> Color:
	if hex.is_empty():
		return fallback
	return Color.html(hex)


func get_sect_color_scheme(sect: String) -> Dictionary:
	_ensure_loaded()
	var schemes: Dictionary = _data.get("sect_colors", {})
	var raw: Variant = schemes.get(sect, {})
	if raw is Dictionary and not raw.is_empty():
		return {
			"primary": _hex_to_color(str(raw.get("primary", "#FFFFFF"))),
			"secondary": _hex_to_color(str(raw.get("secondary", "#FFFFFF"))),
			"glow": _hex_to_color(str(raw.get("glow", "#FFFFFF"))),
		}
	return {
		"primary": Color.WHITE,
		"secondary": Color.WHITE,
		"glow": Color.WHITE,
	}


func infer_sect_from_skill_id(skill_id_str: String) -> String:
	if skill_id_str.begins_with("ice_"):
		return "ice"
	if skill_id_str.begins_with("thunder_"):
		return "thunder"
	if skill_id_str.begins_with("fire_"):
		return "fire"
	if skill_id_str.begins_with("poison_"):
		return "poison"
	return ""


func apply_standard_modulate(
	canvas_item: CanvasItem,
	skill_type: String,
	sect: String = ""
) -> void:
	if canvas_item == null:
		return
	var std := get_skill_visual_config(skill_type)
	var glow_i: float = float(std.get("glow_intensity", 0.5))
	var base_a: float = float(std.get("base_alpha", 1.0))
	var cur := canvas_item.modulate
	var tint := Color.WHITE
	if not sect.is_empty():
		var primary: Color = get_sect_color_scheme(sect).get("primary", Color.WHITE)
		tint = Color.WHITE.lerp(primary, glow_i)
	canvas_item.modulate = Color(cur.r * tint.r, cur.g * tint.g, cur.b * tint.b, base_a)


func apply_standard_visual_node(node: Node, skill_type: String, sect: String = "") -> void:
	if node == null or not node is CanvasItem:
		return
	apply_standard_modulate(node as CanvasItem, skill_type, sect)
	var std := get_skill_visual_config(skill_type)
	if node is Node2D:
		var bs: float = float(std.get("base_scale", 1.0))
		if absf(bs - 1.0) > 0.001:
			(node as Node2D).scale *= Vector2(bs, bs)
	var fps_mul: float = 1.0
	if skill_type == "projectile":
		fps_mul = float(std.get("animation_speed", 1.0))
	else:
		fps_mul = float(std.get("pulse_speed", 1.0))
	if absf(fps_mul - 1.0) > 0.001:
		var scr: Variant = node.get_script()
		if scr is GDScript and str((scr as GDScript).resource_path).ends_with("animated_skill_sprite.gd"):
			var cur_fps: float = float(node.get("fps"))
			node.set("fps", cur_fps * fps_mul)


func _resolve_visual_category(cfg) -> String:
	if cfg.visual_category != null and str(cfg.visual_category).length() > 0:
		return str(cfg.visual_category)
	if int(cfg.node_type) == 0:
		return "projectile"
	return "area"


func apply_to_skill_node_config(cfg, skill_id_str: String) -> void:
	if cfg.skip_visual_standard:
		return
	var category := _resolve_visual_category(cfg)
	var std := get_skill_visual_config(category)
	var sect := str(cfg.visual_sect)
	if sect.is_empty():
		sect = infer_sect_from_skill_id(skill_id_str)

	var bs: float = float(std.get("base_scale", 1.0))
	cfg.animation_scale *= Vector2(bs, bs)

	var fps_mul: float = float(std.get("animation_speed" if category == "projectile" else "pulse_speed", 1.0))
	cfg.animation_fps *= fps_mul

	var glow_i: float = float(std.get("glow_intensity", 0.5))
	var base_a: float = float(std.get("base_alpha", 1.0))
	var tint := Color.WHITE
	if not sect.is_empty():
		var primary: Color = get_sect_color_scheme(sect).get("primary", Color.WHITE)
		tint = Color.WHITE.lerp(primary, glow_i)
	var m: Color = cfg.animation_modulate
	cfg.animation_modulate = Color(m.r * tint.r, m.g * tint.g, m.b * tint.b, base_a)

	if not sect.is_empty():
		cfg.fallback_color = get_sect_color_scheme(sect).get("primary", cfg.fallback_color)
	cfg.fallback_color.a = base_a
