class_name WeaponResource
extends Resource

@export var id: String = "pistol"
@export var display_name: String = "手枪"
@export var damage: int = 12
@export var fire_rate: float = 0.45
@export var ammo_max: int = 12
@export var ammo_per_shot: int = 1
@export var reload_time: float = 1.5
@export var spread: float = 0.03
@export var bullet_speed: int = 800
@export var crit_chance: float = 0.1
@export var crit_multiplier: float = 2.0
@export var bullet_count: int = 1
@export var auto: bool = false
@export var bullet_color: Color = Color(0.8, 0.8, 0.2)
@export var upgrade_level: int = 0
