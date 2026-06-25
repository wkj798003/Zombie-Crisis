extends Area2D

class_name Bullet

var direction = Vector2.RIGHT
var speed = 800
var damage = 12
var life_time = 2.0
var age = 0.0
var _knockback_force = 0.0
var _bullet_color = Color(1.0, 0.9, 0.3)
var _max_pen = 0
var _pen_left = 0

func _ready():
	body_entered.connect(_on_hit)
	var col = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(8, 4)
	col.shape = shape
	add_child(col)
	collision_layer = 4
	collision_mask = 2 + 8

func _draw():
	if _max_pen > 0:
		draw_rect(Rect2(-6, -2, 12, 4), _bullet_color * 0.4)
		draw_rect(Rect2(-5, -1, 10, 2), _bullet_color)
	else:
		draw_rect(Rect2(-4, -2, 8, 4), _bullet_color)

func _process(delta):
	age += delta
	position += direction * speed * delta
	if age > life_time:
		queue_free()

func setup(origin, dir, stats):
	global_position = origin
	direction = dir.normalized()
	rotation = dir.angle()
	damage = stats.get("damage", 12)
	speed = stats.get("bullet_speed", 800)
	_knockback_force = stats.get("knockback", 0.0)
	_max_pen = stats.get("max_penetrations", 0)
	_pen_left = _max_pen
	_bullet_color = stats.get("bullet_color", Color(1.0, 0.9, 0.3))
	if stats.get("crit", false):
		damage = int(damage * stats.get("crit_multiplier", 2.0))
	queue_redraw()

func _on_hit(body):
	if body.has_method("take_damage"):
		body.take_damage(damage, _knockback_force, direction)
		if _pen_left > 0:
			_pen_left -= 1
			damage = max(1, int(damage * 0.7))
			# 不销毁，继续穿透飞行
		else:
			queue_free()
	else:
		queue_free()
