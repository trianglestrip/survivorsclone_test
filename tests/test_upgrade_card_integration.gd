extends SceneTree

## 自动化测试：UpgradeCardUI 与升级流程集成
## 验证：升级时 UI 显示、暂停、选卡应用升级、恢复

var _results: Array = []

func _init():
	print("\n========================================")
	print("UpgradeCardUI 集成测试")
	print("========================================\n")
	await process_frame
	await process_frame
	await _run_all()
	_print_summary()
	quit(0 if _all_passed() else 1)

func _log(name: String, ok: bool, detail: String):
	_results.append({"name": name, "ok": ok, "detail": detail})
	var mark = "✓" if ok else "✗"
	print("  %s [%s] %s" % [mark, name, detail])

func _all_passed() -> bool:
	for r in _results:
		if not r.ok:
			return false
	return true

func _print_summary():
	print("\n========================================")
	print("汇总: %d 项" % _results.size())
	for r in _results:
		print("  %s %s" % ["PASS" if r.ok else "FAIL", r.name])
	print("========================================\n")

func _run_all():
	await _test_world_has_upgrade_ui()
	await _test_level_up_shows_cards_and_pauses()
	await _test_select_applies_upgrade_and_unpauses()
	await _test_rarity_colors_on_card_data()

func _test_world_has_upgrade_ui():
	print("\n[1] World 场景节点与信号连接")
	var world = load("res://World/world.tscn").instantiate()
	root.add_child(world)
	for i in range(30):
		await process_frame
	var ui = world.get_node_or_null("UpgradeCardLayer/UpgradeCardUI")
	var player = world.get_node_or_null("Player")
	var ok = ui != null and player != null
	if ok and ui.has_signal("card_selected"):
		ok = ui.card_selected.is_connected(Callable(player, "upgrade_character"))
	_log("world_upgrade_ui", ok, "UpgradeCardLayer/UpgradeCardUI 存在且 card_selected 已连到 upgrade_character")
	world.queue_free()
	await process_frame

func _test_level_up_shows_cards_and_pauses():
	print("\n[2] 升级时卡牌显示与暂停")
	var world = load("res://World/world.tscn").instantiate()
	root.add_child(world)
	for i in range(40):
		await process_frame
	var player = world.get_node_or_null("Player")
	var ui = world.get_node_or_null("UpgradeCardLayer/UpgradeCardUI")
	if player == null or ui == null:
		_log("level_up_ui", false, "缺少 Player 或 UI")
		world.queue_free()
		await process_frame
		return
	# 直接触发升级，避免单次加大量经验导致连续多级 level_up
	player.call("_on_level_up", 2)
	for i in range(5):
		await process_frame
	var visible_ok = ui.visible
	var paused_ok = paused
	_log("level_up_visible", visible_ok, "UpgradeCardUI.visible 在升级后应为 true")
	_log("level_up_paused", paused_ok, "get_tree().paused 在选卡时应为 true")
	world.queue_free()
	await process_frame
	paused = false

func _test_select_applies_upgrade_and_unpauses():
	print("\n[3] 选择卡牌后应用升级并解除暂停")
	paused = false
	var world = load("res://World/world.tscn").instantiate()
	root.add_child(world)
	for i in range(40):
		await process_frame
	var player = world.get_node_or_null("Player")
	var ui = world.get_node_or_null("UpgradeCardLayer/UpgradeCardUI")
	var upgrade_mgr = null
	for c in player.get_children():
		var sc = c.get_script()
		if sc and sc.get_global_name() == "UpgradeManager":
			upgrade_mgr = c
			break
	if player == null or ui == null or upgrade_mgr == null:
		_log("select_upgrade", false, "缺少 Player、UI 或 UpgradeManager")
		world.queue_free()
		await process_frame
		return
	var db = root.get_node_or_null("/root/UpgradeDb")
	var ids: Array = []
	if db:
		for k in db.UPGRADES:
			var row: Dictionary = db.UPGRADES[k]
			if row.get("type", "") != "item":
				ids.append(k)
			if ids.size() >= 3:
				break
	if ids.size() < 1:
		_log("select_upgrade", false, "UpgradeDb 无可用非 item 升级")
		world.queue_free()
		await process_frame
		return
	var payload: Array = []
	for uid in ids:
		var row: Dictionary = db.UPGRADES[uid].duplicate(true)
		if not row.has("id") or str(row.get("id", "")).is_empty():
			row["id"] = uid
		payload.append(row)
	ui.show_upgrade_options(payload)
	await process_frame
	var before = upgrade_mgr.collected_upgrades.size()
	var card0 = ui.cards[0] if ui.cards.size() > 0 else null
	if card0 == null:
		_log("select_upgrade", false, "未生成卡牌")
		world.queue_free()
		paused = false
		await process_frame
		return
	await ui._on_card_selected(card0)
	for i in range(10):
		await process_frame
	var applied = upgrade_mgr.collected_upgrades.size() > before
	var unpaused = not paused
	var hidden = not ui.visible
	_log("upgrade_applied", applied, "collected_upgrades 应增加")
	_log("unpaused_after_pick", unpaused, "选卡后 paused 应为 false")
	_log("ui_hidden_after_pick", hidden, "选卡后 UI 应隐藏")
	world.queue_free()
	await process_frame
	paused = false

func _test_rarity_colors_on_card_data():
	print("\n[4] 稀有度颜色映射")
	var inst = load("res://UI/upgrade_card_ui.tscn").instantiate()
	root.add_child(inst)
	var rare_color = inst.call("_get_rarity_color", "rare")
	var legendary_color = inst.call("_get_rarity_color", "legendary")
	inst.queue_free()
	await process_frame
	var ok = rare_color != legendary_color and rare_color is Color
	_log("rarity_colors", ok, "rare 与 legendary 颜色应不同且为 Color")
