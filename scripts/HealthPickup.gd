extends Area2D

class_name HealthPickup

var heal_amount = 25
var lifetime = 60.0
var age = 0.0
var _pulse = 0.0

func _ready():
	body_entered.connect(_on_body_entered)
	call_deferred("_add_collision")

func _add_collision():
	var col = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(14, 14)
	col.shape = shape
	add_child(col)

func _draw():
	# 外框（白色半透明）
	draw_rect(Rect2(-3, -7, 6, 14), Color(1, 1, 1, 0.3))
	draw_rect(Rect2(-7, -3, 14, 6), Color(1, 1, 1, 0.3))
	# 红色十字
	draw_rect(Rect2(-2, -6, 4, 12), Color(0.9, 0.15, 0.15))
	draw_rect(Rect2(-6, -2, 12, 4), Color(0.9, 0.15, 0.15))
	# 中心高光
	draw_rect(Rect2(-1, -1, 2, 2), Color(1.0, 0.4, 0.4))

func _process(delta):
	age += delta
	_pulse += delta
	if age > lifetime:
		queue_free()
		return
	# 呼吸灯效果：透明度轻微波动
	modulate.a = 0.8 + sin(_pulse * 3.0) * 0.2

func _on_body_entered(body):
	if body.has_method("heal"):
		body.heal(heal_amount)
		queue_free()

func setup(pos):
	global_position = pos
	heal_amount = 25
