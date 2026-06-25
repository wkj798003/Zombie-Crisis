extends Node

var weapon_data = {
	"pistol": {
		"damage": 12, "fire_rate": 0.45, "ammo_max": 12,
		"ammo_per_shot": 1, "reload_time": 1.5, "spread": 0.03,
		"bullet_speed": 800, "crit_chance": 0.1, "crit_multiplier": 2.0,
		"bullet_count": 1, "auto": false, "knockback": 50,
		"name": "手枪", "level_required": 1
	},
	"smg": {
		"damage": 8, "fire_rate": 0.08, "ammo_max": 30,
		"ammo_per_shot": 1, "reload_time": 1.8, "spread": 0.08,
		"bullet_speed": 700, "crit_chance": 0.05, "crit_multiplier": 1.8,
		"bullet_count": 1, "auto": true,"knockback": 30,
		"name": "冲锋枪", "level_required": 1
	},
	"shotgun": {
		"damage": 6, "fire_rate": 0.70, "ammo_max": 6,
		"ammo_per_shot": 1, "reload_time": 2.0, "spread": 0.15,
		"bullet_speed": 600, "crit_chance": 0.05, "crit_multiplier": 1.5,
		"bullet_count": 6, "auto": false, "knockback": 350,
		"name": "霰弹枪", "level_required": 2
	},
	"sniper": {
		"damage": 55, "fire_rate": 1.20, "ammo_max": 4,
		"ammo_per_shot": 1, "reload_time": 2.5, "spread": 0.06,
		"bullet_speed": 1500, "crit_chance": 0.3, "crit_multiplier": 2.5,
		"bullet_count": 1, "auto": false, "knockback": 50,
		"name": "狙击枪", "level_required": 3,
		"spread_no_scope": 0.15
	},
	"energy_rifle": {
		"damage": 18, "fire_rate": 0.25, "ammo_max": 20,
		"ammo_per_shot": 1, "reload_time": 1.8, "spread": 0.02,
		"bullet_speed": 1200, "crit_chance": 0.1, "crit_multiplier": 2.0,
		"bullet_count": 1, "auto": true,
		"name": "能量步枪", "level_required": 4,
		"knockback": 40, "max_penetrations": 3,
		"bullet_color": Color(0.2, 0.8, 1.0)
	},
	"grenade_launcher": {
		"damage": 40, "fire_rate": 1.50, "ammo_max": 3,
		"ammo_per_shot": 1, "reload_time": 2.5, "spread": 0.05,
		"bullet_speed": 450, "crit_chance": 0.0, "crit_multiplier": 1.0,
		"bullet_count": 1, "auto": false,
		"name": "榴弹发射器", "level_required": 5,
		"knockback": 100, "explosion_radius": 120
	},
	"wall": {
		"name": "防御墙体", "level_required": 3, "wall_hp": 2000, "wall_count": 3, "wall_size": 48
	}
}

var enemy_data = {
	"walker": { "hp": 40, "speed": 80.0, "damage": 8, "xp_reward": 15, "color": Color(0.6, 0.8, 0.3) },
	"runner": { "hp": 25, "speed": 180.0, "damage": 6, "xp_reward": 20, "color": Color(0.9, 0.4, 0.3) },
	"brute": { "hp": 150, "speed": 50.0, "damage": 20, "xp_reward": 35, "color": Color(0.6, 0.1, 0.05), "knockback_resistance": 0.7, "size": 36 }
}

var xp_thresholds = [100, 180, 300, 460, 680, 960, 1300, 1700, 2200]
var max_level = 10

var hp_mult_per_min = 0.06
var dmg_mult_per_min = 0.04
var spd_mult_per_min = 0.015
var spawn_interval_min = 6.0
var spawn_interval_max = 15.0

var player_max_hp = 100
var player_speed = 200.0
var dodge_distance = 120.0
var dodge_cooldown = 2.5
var game_duration = 900.0

func get_weapon_stat(id, stat, default_val = 0):
	if weapon_data.has(id) and weapon_data[id].has(stat):
		return weapon_data[id][stat]
	return default_val

func get_enemy_stat(id, stat, default_val = 0):
	if enemy_data.has(id) and enemy_data[id].has(stat):
		return enemy_data[id][stat]
	return default_val

func get_hp_multiplier(game_time):
	return 1.0 + game_time / 60.0 * hp_mult_per_min

func get_dmg_multiplier(game_time):
	return 1.0 + game_time / 60.0 * dmg_mult_per_min

func get_xp_for_level(level):
	if level < 1 or level >= max_level:
		return 99999
	return xp_thresholds[level - 1]
