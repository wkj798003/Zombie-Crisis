extends StaticBody2D
class_name DeployableWall

var hp = 2000
var max_hp = 2000
var wall_size = 48

func _ready():
	collision_layer = 16
	collision_mask = 0
	var col = CollisionShape2D.new()
	var s = RectangleShape2D.new()
	s.size = Vector2(wall_size, wall_size)
	col.shape = s
	add_child(col)
	add_to_group("deployable_walls")

func _draw():
	draw_rect(Rect2(-wall_size/2, -wall_size/2, wall_size, wall_size), Color(0.4, 0.5, 0.6))
	draw_rect(Rect2(-wall_size/2+3, -wall_size/2+3, wall_size-6, wall_size-6), Color(0.3, 0.4, 0.5))
	draw_line(Vector2(-wall_size/4, -wall_size/2), Vector2(-wall_size/4, wall_size/2), Color(0.5, 0.6, 0.7), 1.5)
	draw_line(Vector2(wall_size/4, -wall_size/2), Vector2(wall_size/4, wall_size/2), Color(0.5, 0.6, 0.7), 1.5)
	# HP bar
	var bw = wall_size - 4
	var bh = 4
	var bx = -wall_size/2 + 2
	var by = -wall_size/2 - 8
	draw_rect(Rect2(bx, by, bw, bh), Color(0.15, 0.15, 0.15))
	var pct = float(hp) / float(max_hp)
	draw_rect(Rect2(bx, by, bw * pct, bh), Color(0.3, 0.8, 0.3))

func wall_take_damage(amount):
	hp -= amount
	if hp <= 0:
		queue_free()
		return
	modulate = Color(1.0, 0.5, 0.5)
	queue_redraw()
	await get_tree().create_timer(0.08).timeout
	modulate = Color.WHITE
