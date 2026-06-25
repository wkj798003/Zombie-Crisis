extends Area2D

class_name Grenade

var direction = Vector2.RIGHT
var speed = 450
var damage = 40
var explosion_radius = 120
var life_time = 3.0
var age = 0.0
var _knockback_force = 0.0

func _ready():
	body_entered.connect(_on_hit)
	var col = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(14, 10)
	col.shape = shape
	add_child(col)
	collision_layer = 4
	collision_mask = 2 + 8

func _draw():
	draw_rect(Rect2(-7, -5, 14, 10), Color(0.3, 0.55, 0.2))
	draw_rect(Rect2(-4, -3, 8, 6), Color(0.35, 0.65, 0.25))

func _process(delta):
	age += delta
	position += direction * speed * delta
	if age > life_time:
		_explode()
		queue_free()

func setup(origin, dir, stats):
	global_position = origin
	direction = dir.normalized()
	rotation = dir.angle()
	damage = stats.get("damage", 40)
	speed = stats.get("bullet_speed", 450)
	explosion_radius = stats.get("explosion_radius", 120)
	_knockback_force = stats.get("knockback", 100)

func _on_hit(body):
	_explode()
	queue_free()

func _explode():
	var enemies = get_tree().get_nodes_in_group("enemy")
	for e in enemies:
		if not is_instance_valid(e):
			continue
		var dist = global_position.distance_to(e.global_position)
		if dist <= explosion_radius:
			var dir = (e.global_position - global_position).normalized()
			if e.has_method("take_damage"):
				e.take_damage(damage, _knockback_force, dir)
	# 爆炸视觉效果
	var exp = load("res://scripts/ExplosionEffect.gd").new()
	exp.setup(global_position, explosion_radius)
	get_parent().add_child(exp)
