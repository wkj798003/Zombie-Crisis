extends CanvasLayer

class_name GameManager

var level = 1
var xp = 0
var game_time = 0.0
var game_running = false
var total_kills = 0
var player = null

var _hp_bar: ColorRect
var _hp_label: Label
var _xp_bar: ColorRect
var _level_label: Label
var _time_label: Label
var _weapon_label: Label
var _ammo_label: Label
var _reload_label: Label
var _cam: Camera2D = null
# scope overlay removed

func _ready():
	Global.xp_changed.connect(_on_xp_changed)
	Global.enemy_killed.connect(_on_enemy_killed)
	Global.upgrade_selected.connect(_on_upgrade_selected)
	Global.player_damaged.connect(_on_player_damaged)
	Global.ammo_changed.connect(_on_ammo_changed)
	Global.reloading.connect(_on_reloading)
	Global.weapon_switched.connect(_on_weapon_switched)
	Global.scope_changed.connect(_on_scope_changed)
	Global.player_died.connect(_on_player_died)
	
	_create_hud()
	await get_tree().process_frame
	start_game()

func _create_hud():
	var hp_bg = ColorRect.new()
	hp_bg.position = Vector2(20, 20); hp_bg.size = Vector2(204, 18); hp_bg.color = Color(0.2, 0.05, 0.05)
	add_child(hp_bg)
	_hp_bar = ColorRect.new()
	_hp_bar.position = Vector2(22, 22); _hp_bar.size = Vector2(200, 14); _hp_bar.color = Color(0.9, 0.15, 0.15)
	add_child(_hp_bar)
	_hp_label = Label.new()
	_hp_label.position = Vector2(25, 20); _hp_label.size = Vector2(200, 18)
	_hp_label.add_theme_color_override("font_color", Color(1, 1, 1))
	add_child(_hp_label)
	
	var xp_bg = ColorRect.new()
	xp_bg.position = Vector2(20, 44); xp_bg.size = Vector2(204, 14); xp_bg.color = Color(0.05, 0.05, 0.2)
	add_child(xp_bg)
	_xp_bar = ColorRect.new()
	_xp_bar.position = Vector2(22, 46); _xp_bar.size = Vector2(200, 10); _xp_bar.color = Color(0.2, 0.4, 0.9)
	add_child(_xp_bar)
	
	_level_label = Label.new()
	_level_label.position = Vector2(240, 20); _level_label.size = Vector2(160, 20)
	_level_label.add_theme_color_override("font_color", Color(1, 1, 1))
	_level_label.add_theme_font_size_override("font_size", 16)
	add_child(_level_label)
	
	_time_label = Label.new()
	_time_label.position = Vector2(1100, 20); _time_label.size = Vector2(160, 24)
	_time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_time_label.add_theme_color_override("font_color", Color(1, 1, 0.4))
	_time_label.add_theme_font_size_override("font_size", 18)
	add_child(_time_label)
	
	_weapon_label = Label.new()
	_weapon_label.position = Vector2(540, 660); _weapon_label.size = Vector2(200, 20)
	_weapon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_weapon_label.add_theme_color_override("font_color", Color(1, 1, 0.6))
	add_child(_weapon_label)
	_ammo_label = Label.new()
	_ammo_label.position = Vector2(540, 680); _ammo_label.size = Vector2(200, 20)
	_ammo_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_ammo_label.add_theme_color_override("font_color", Color(1, 1, 1))
	add_child(_ammo_label)
	_reload_label = Label.new()
	_reload_label.position = Vector2(540, 700); _reload_label.size = Vector2(200, 20)
	_reload_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_reload_label.add_theme_color_override("font_color", Color(1, 0.8, 0.2))
	_reload_label.add_theme_font_size_override("font_size", 12)
	_reload_label.visible = false
	add_child(_reload_label)

func start_game():
	game_running = true; game_time = 0.0; level = 1; xp = 0
	_cam = get_node("/root/Main/Camera2D")
	var player_scene = load("res://scenes/player.tscn")
	if player_scene:
		player = player_scene.instantiate()
		var world = get_node("/root/Main/World")
		if world: world.add_child(player)
		else: get_tree().current_scene.add_child(player)
		player.global_position = Vector2.ZERO
		update_hud()

func _process(delta):
	if not game_running: return
	game_time += delta
	update_hud()
	if _cam and player and is_instance_valid(player):
		_cam.global_position = player.global_position
	if game_time >= GameBalance.game_duration: end_game()

func update_hud():
	if not player: return
	var pct = float(player.hp) / float(player.max_hp) * 100.0
	_hp_bar.size.x = max(0, pct * 2.0)
	_hp_label.text = "HP: " + str(player.hp) + "/" + str(player.max_hp)
	var needed = GameBalance.get_xp_for_level(level)
	var xp_pct = float(xp) / float(needed) * 100.0 if needed > 0 else 100.0
	_xp_bar.size.x = max(0, xp_pct * 2.0)
	_level_label.text = "Lv." + str(level) + "  XP: " + str(xp) + "/" + str(needed)
	# Wall mode display
	if player and (player._wall_mode or (player.weapon_mgr and player.weapon_mgr.current_weapon_id == "wall")):
		_weapon_label.text = "[防御墙体]"
		_ammo_label.text = "剩余: " + str(player._walls_remaining)
	var remaining = max(0, GameBalance.game_duration - game_time)
	_time_label.text = "%02d:%02d" % [int(remaining)/60, int(remaining)%60]

# === 狙击镜 ===
func _on_scope_changed(_is_scoped):
	pass
func _on_level_up(_new_level):
	show_upgrade_ui()
func show_upgrade_ui():
	var opts = _generate_options()
	Global.upgrade_offered.emit(opts)
	var ui = UpgradeUI.new()
	add_child(ui)
	# 延迟传参确保 UI 已 ready
	await get_tree().process_frame
	Global.upgrade_offered.emit(opts)

func _generate_options() -> Array:
	var all_weapons = ["pistol", "smg", "shotgun", "sniper", "energy_rifle", "grenade_launcher", "wall"]
	var owned = player.weapon_mgr.weapon_order if player else []
	var new_avail = []
	var upgrades = []
	
	for wid in all_weapons:
		var wd = GameBalance.weapon_data.get(wid, {})
		var req = wd.get("level_required", 1)
		if wid not in owned and level >= req:
			new_avail.append(wid)
		if wid in owned:
			var ulv = player.weapon_mgr.get_upgrade_level(wid)
			if ulv < 3:
				upgrades.append({"type":"upgrade", "id":wid, "level":ulv+1, "name": wd.get("name", wid) + " Lv." + str(ulv+1)})
	
	var result = []
	# 选项A
	if new_avail.size() > 0:
		var pick = new_avail[randi() % new_avail.size()]
		var d = GameBalance.weapon_data.get(pick, {})
		result.append({"type":"weapon", "id":pick, "name":d.get("name", pick),
			"desc":_weapon_desc(pick), "level":1})
	elif upgrades.size() > 0:
		var pick = upgrades[randi() % upgrades.size()]
		result.append(pick)
		upgrades.erase(pick)
	else:
		result.append({"type":"upgrade", "id":"pistol", "name":"手枪 Lv.1", "desc":"伤害+3", "level":1})
	# 选项B（升级）
	if upgrades.size() > 0:
		var pick = upgrades[randi() % upgrades.size()]
		result.append(pick)
	elif new_avail.size() > 1:
		var pick2 = new_avail[randi() % new_avail.size()]
		var d2 = GameBalance.weapon_data.get(pick2, {})
		result.append({"type":"weapon", "id":pick2, "name":d2.get("name", pick2),
			"desc":_weapon_desc(pick2), "level":1})
	else:
		result.append({"type":"upgrade", "id":"pistol", "name":"手枪 Lv.1", "desc":"伤害+3", "level":1})
	
	# 给选项添加 display name
	for r in result:
		if not r.has("name"):
			var d = GameBalance.weapon_data.get(r.get("id",""), {})
			r["name"] = str(r.get("name", "")) if r.get("name", "") else str(d.get("name", r["id"]) if d else r["id"])
		if not r.has("desc") and r["type"] == "upgrade":
			r["desc"] = str(get_upgrade_desc(r["id"], r.get("level", 1)))
	return result

func _weapon_desc(wid: String) -> String:
	var d = GameBalance.weapon_data.get(wid, {})
	var dmg = d.get("damage", 0)
	var bc = d.get("bullet_count", 1)
	var fr = d.get("fire_rate", 0.5)
	var auto_txt = "自动" if d.get("auto", false) else "单发"
	var dmg_txt = str(dmg) + ("x" + str(bc) if bc > 1 else "")
	return "伤害:" + dmg_txt + "
射速:" + str(fr) + "s
" + auto_txt

func get_upgrade_desc(wid: String, lv: int) -> String:
	match wid:
		"pistol": return ["伤害+3","弹匣+4","射速提升"][min(lv-1,2)]
		"smg":    return ["伤害+2","弹匣+6","射速提升"][min(lv-1,2)]
		"shotgun":return ["伤害+2/弹","弹匣+2","射速提升"][min(lv-1,2)]
		"sniper": return ["伤害+15","射速提升","弹匣+2"][min(lv-1,2)]
		"energy_rifle": return ["伤害+4","弹匣+5","穿透+1"][min(lv-1,2)]
		"grenade_launcher": return ["伤害+8","弹匣+1","爆炸范围+30"][min(lv-1,2)]
		"wall": return ["墙体上限+1","墙体HP+100","墙体尺寸+16"][min(lv-1,2)]
	return "强化"

# === 常规回调 ===
func _on_weapon_switched(weapon_id, weapon_name):
	_weapon_label.text = "[" + weapon_name + "]"
func _on_ammo_changed(weapon_id, current, max_ammo):
	if weapon_id == player.weapon_mgr.current_weapon_id:
		_ammo_label.text = "弹药: ∞" if weapon_id=="pistol" else "弹药: "+str(current)+"/"+str(max_ammo)
func _on_reloading(weapon_id, is_reloading):
	if weapon_id == player.weapon_mgr.current_weapon_id:
		_reload_label.visible = is_reloading
		_ammo_label.text = "弹药: 换弹中..." if is_reloading else _get_ammo_text()
func _get_ammo_text() -> String:
	var w = player.weapon_mgr.current_weapon_id
	if w=="pistol": return "弹药: ∞"
	return "弹药: "+str(player.weapon_mgr.ammo.get(w,0))+"/"+str(player.weapon_mgr.get_current_weapon().get("ammo_max",12))
func _on_player_damaged(amount, new_hp):
	update_hud()
	if new_hp <= 0:
		show_game_over()
func _on_xp_changed(amount, _total, _level):
	xp += amount
	var needed = GameBalance.get_xp_for_level(level)
	while xp >= needed and level < GameBalance.max_level:
		xp -= needed; level += 1; needed = GameBalance.get_xp_for_level(level)
		Global.level_up.emit(level)
		_on_level_up(level)
	update_hud()

func _on_enemy_killed(enemy_type, pos): pass
func _on_upgrade_selected(_type, _id, _upgrade_level):
	if _type == "weapon":
		if _id == "wall":
			if player:
				player._walls_remaining += 3
		if player and player.weapon_mgr: player.weapon_mgr.add_weapon(_id)
	elif _type == "upgrade":
		if player and player.weapon_mgr: player.weapon_mgr.upgrade_weapon(_id)
	# 切到狙击枪时自动取消开镜
	if _id == "sniper" and player:
		player._ads_mode = false
		_on_scope_changed(false)
	update_hud()

func show_game_over():
	var go = load("res://scripts/GameOver.gd").new()
	add_child(go)

func _on_player_died():
	show_game_over()

func end_game():
	game_running = false; Global.game_over.emit()
	await get_tree().create_timer(2.0).timeout
	get_tree().reload_current_scene()
