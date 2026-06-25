extends Node2D

class_name ExplosionEffect

var _radius = 100
var _duration = 0.4
var _age = 0.0

func setup(pos, r):
	global_position = pos
	_radius = r

func _draw():
	var t = _age / _duration
	var r = _radius * (0.3 + t * 0.7)
	var alpha = 1.0 - t
	draw_circle(Vector2.ZERO, r, Color(1.0, 0.5, 0.1, alpha * 0.35))
	draw_circle(Vector2.ZERO, r * 0.5, Color(1.0, 0.8, 0.2, alpha * 0.55))

func _process(delta):
	_age += delta
	if _age > _duration:
		queue_free()
	else:
		queue_redraw()
