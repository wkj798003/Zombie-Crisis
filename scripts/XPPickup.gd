extends Area2D

class_name XPPickup

var xp_value = 10
var target = null
var lifetime = 8.0
var age = 0.0
var _type = "small"   # "small" | "medium" | "large"

func _ready():
	call_deferred("_add_collision")

func _add_collision():
	var size = 8
	match _type:
		"medium": size = 12
		"large": size = 16
	var col = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(size, size)
	col.shape = shape
	add_child(col)

func _draw():
	match _type:
		"small":
			draw_rect(Rect2(-4, -4, 8, 8), Color(0.3, 1.0, 0.3))
		"medium":
			var p = PackedVector2Array([
				Vector2(0, -7), Vector2(7, 0),
				Vector2(0, 7), Vector2(-7, 0)
			])
			draw_polygon(p, [Color(0.2, 0.5, 1.0)])
			draw_polygon(scale_poly(p, 0.6), [Color(0.4, 0.7, 1.0)])
		"large":
			var p = PackedVector2Array()
			for i in range(6):
				var a = deg_to_rad(i * 60 - 90)
				p.append(Vector2(cos(a) * 10, sin(a) * 10))
			draw_polygon(p, [Color(1.0, 0.6, 0.1)])
			var inner = PackedVector2Array()
			for i in range(6):
				var a = deg_to_rad(i * 60 - 90)
				inner.append(Vector2(cos(a) * 6, sin(a) * 6))
			draw_polygon(inner, [Color(1.0, 0.8, 0.2)])

func scale_poly(poly: PackedVector2Array, factor: float) -> PackedVector2Array:
	var out = PackedVector2Array()
	for v in poly:
		out.append(v * factor)
	return out

func _process(delta):
	age += delta
	if age > lifetime:
		queue_free()
		return
	
	if not is_instance_valid(target):
		var players = get_tree().get_nodes_in_group("player")
		target = players[0] if players.size() > 0 else null
	
	if target:
		var dist = global_position.distance_to(target.global_position)
		if dist < 200:
			var spd = lerp(50.0, 400.0, 1.0 - dist / 200.0)
			var dir = (target.global_position - global_position).normalized()
			global_position += dir * spd * delta
			if dist < 8:
				Global.xp_changed.emit(xp_value, 0, 0)
				queue_free()

func setup(val, pos, type_str = "small"):
	global_position = pos
	xp_value = val
	_type = type_str
	queue_redraw()
