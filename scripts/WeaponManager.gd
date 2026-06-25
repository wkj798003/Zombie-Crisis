extends Node

class_name WeaponManager

var weapons: Dictionary = {}
var current_weapon_id: String = "pistol"
var weapon_order: Array[String] = ["pistol"]
var ammo: Dictionary = {}
var can_shoot: bool = true
var is_switching: bool = false
var is_reloading: bool = false
var _upgrade_levels: Dictionary = {}

signal weapon_changed(weapon_id)

func _ready():
	add_weapon("pistol")

func add_weapon(weapon_id: String):
	if weapons.has(weapon_id):
		return
	var stats = GameBalance.weapon_data.get(weapon_id, {})
	if stats.is_empty():
		return
	weapons[weapon_id] = stats.duplicate()
	if not ammo.has(weapon_id):
		ammo[weapon_id] = stats.get("ammo_max", 12)
	if weapon_id not in weapon_order:
		weapon_order.append(weapon_id)
	if not _upgrade_levels.has(weapon_id):
		_upgrade_levels[weapon_id] = 0

func upgrade_weapon(weapon_id: String):
	_upgrade_levels[weapon_id] = _upgrade_levels.get(weapon_id, 0) + 1
	var lv = _upgrade_levels[weapon_id]
	var stats = weapons.get(weapon_id)
	if not stats:
		return
	match weapon_id:
		"pistol":
			if lv >= 1: stats["damage"] = stats.get("damage", 12) + 3
			if lv >= 2: stats["ammo_max"] = stats.get("ammo_max", 12) + 4
			if lv >= 3: stats["fire_rate"] = max(0.1, stats.get("fire_rate", 0.45) - 0.1)
		"smg":
			if lv >= 1: stats["damage"] = stats.get("damage", 8) + 2
			if lv >= 2: stats["ammo_max"] = stats.get("ammo_max", 30) + 6
			if lv >= 3: stats["fire_rate"] = max(0.04, stats.get("fire_rate", 0.08) - 0.02)
		"shotgun":
			if lv >= 1: stats["damage"] = stats.get("damage", 6) + 2
			if lv >= 2: stats["ammo_max"] = stats.get("ammo_max", 6) + 2
			if lv >= 3: stats["fire_rate"] = max(0.3, stats.get("fire_rate", 0.7) - 0.1)
		"sniper":
			if lv >= 1: stats["damage"] = stats.get("damage", 55) + 15
			if lv >= 2: stats["fire_rate"] = max(0.5, stats.get("fire_rate", 1.2) - 0.15)
			if lv >= 3: stats["ammo_max"] = stats.get("ammo_max", 4) + 2
		"energy_rifle":
			if lv >= 1: stats["damage"] = stats.get("damage", 18) + 4
			if lv >= 2: stats["ammo_max"] = stats.get("ammo_max", 20) + 5
			if lv >= 3: stats["max_penetrations"] = stats.get("max_penetrations", 3) + 1
		"grenade_launcher":
			if lv >= 1: stats["damage"] = stats.get("damage", 40) + 8
			if lv >= 2: stats["ammo_max"] = stats.get("ammo_max", 3) + 1
			if lv >= 3: stats["explosion_radius"] = stats.get("explosion_radius", 120) + 30
		"wall":
			if lv >= 1: stats["wall_hp"] = stats.get("wall_hp", 2000) + 500
			if lv >= 2: stats["wall_count"] = stats.get("wall_count", 3) + 1
			if lv >= 3: stats["wall_size"] = stats.get("wall_size", 48) + 8
	if ammo.has(weapon_id):
		ammo[weapon_id] = stats.get("ammo_max", 12)
	emit_ammo()

func get_current_weapon() -> Dictionary:
	return weapons.get(current_weapon_id, {})

func get_upgrade_level(weapon_id: String) -> int:
	return _upgrade_levels.get(weapon_id, 0)

func switch_to(weapon_id: String):
	if not weapons.has(weapon_id) or is_switching or is_reloading:
		return
	if weapon_id == current_weapon_id:
		return
	is_switching = true
	current_weapon_id = weapon_id
	can_shoot = false
	await get_tree().create_timer(0.35).timeout
	can_shoot = true
	is_switching = false
	weapon_changed.emit(weapon_id)
	emit_ammo()
	Global.weapon_switched.emit(weapon_id, GameBalance.weapon_data.get(weapon_id, {}).get("name", weapon_id))

func switch_next():
	if weapon_order.is_empty():
		return
	var idx = weapon_order.find(current_weapon_id)
	idx = (idx + 1) % weapon_order.size()
	switch_to(weapon_order[idx])

func switch_prev():
	if weapon_order.is_empty():
		return
	var idx = weapon_order.find(current_weapon_id)
	idx = (idx - 1 + weapon_order.size()) % weapon_order.size()
	switch_to(weapon_order[idx])

func can_fire() -> bool:
	if is_switching or not can_shoot or is_reloading:
		return false
	var stats = get_current_weapon()
	if stats.is_empty():
		return false
	if current_weapon_id == "pistol":
		return true
	var cur_ammo = ammo.get(current_weapon_id, 0)
	return cur_ammo > 0

func fire():
	if not can_fire():
		return null
	var stats = get_current_weapon()
	if current_weapon_id != "pistol":
		var cost = stats.get("ammo_per_shot", 1)
		ammo[current_weapon_id] = ammo.get(current_weapon_id, 0) - cost
		if ammo[current_weapon_id] < 0:
			ammo[current_weapon_id] = 0
	emit_ammo()
	return stats

func emit_ammo():
	if not current_weapon_id:
		return
	var stats = get_current_weapon()
	var cur = ammo.get(current_weapon_id, 0)
	var max_ammo = stats.get("ammo_max", 12)
	Global.ammo_changed.emit(current_weapon_id, cur, max_ammo)

func reload():
	if is_reloading or is_switching:
		return
	var stats = get_current_weapon()
	if stats.is_empty():
		return
	if current_weapon_id == "pistol":
		return
	var max_ammo = stats.get("ammo_max", 12)
	if ammo.get(current_weapon_id, 0) >= max_ammo:
		return
	is_reloading = true
	var reload_time = stats.get("reload_time", 1.5)
	Global.reloading.emit(current_weapon_id, true)
	await get_tree().create_timer(reload_time).timeout
	if not is_instance_valid(self):
		return
	ammo[current_weapon_id] = max_ammo
	is_reloading = false
	Global.reloading.emit(current_weapon_id, false)
	emit_ammo()
