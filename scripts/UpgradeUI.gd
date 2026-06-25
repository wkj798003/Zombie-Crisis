extends Control

class_name UpgradeUI

var options = []  # 从 GameManager 传入

func _ready():
	process_mode = PROCESS_MODE_WHEN_PAUSED
	Engine.time_scale = 0.05
	get_tree().paused = true
	
	# 从 Global 信号接收选项
	Global.upgrade_offered.connect(_on_data)
	
	var overlay = ColorRect.new()
	overlay.position = Vector2(-2000, -2000)
	overlay.size = Vector2(6000, 6000)
	overlay.color = Color(0, 0, 0, 0.6)
	overlay.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(overlay)
	
	size = Vector2(420, 340)
	position = Vector2(430, 190)
	mouse_filter = MOUSE_FILTER_STOP
	queue_redraw()

func _on_data(opts):
	options = opts
	queue_redraw()

func _draw():
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.08, 0.08, 0.15, 0.95))
	if options.size() < 2:
		return
	_draw_option(0, Vector2(20, 80))
	_draw_option(1, Vector2(220, 80))
	
	var f = ThemeDB.get_fallback_font()
	var fs = ThemeDB.get_fallback_font_size()
	# 倒计时
	var timer = "剩余: " + str(ceil(_time_left)) + " 秒"
	draw_string(f, Vector2(210 - f.get_string_size(str(timer), HORIZONTAL_ALIGNMENT_CENTER, -1, fs + 2).x / 2, size.y - 25), str(timer), HORIZONTAL_ALIGNMENT_CENTER, -1, fs + 2, Color(1, 0.8, 0.2))

func _draw_option(idx: int, pos: Vector2):
	var opt = options[idx]
	var f = ThemeDB.get_fallback_font()
	var fs = ThemeDB.get_fallback_font_size()
	
	var bg = Color(0.15, 0.25, 0.15) if idx == 0 else Color(0.15, 0.15, 0.25)
	draw_rect(Rect2(pos, Vector2(180, 180)), bg)
	draw_rect(Rect2(pos + Vector2(8, 8), Vector2(164, 164)), bg * 0.7)
	
	var title = opt.get("name", "???")
	var desc = opt.get("desc", "")
	var t_color = Color(0.8, 1.0, 0.8) if idx == 0 else Color(0.8, 0.8, 1.0)
	
	draw_string(f, Vector2(pos.x + 10, pos.y + 35), str(title), HORIZONTAL_ALIGNMENT_LEFT, -1, fs + 2, t_color)
	if desc:
		var lines = desc.split("\n")
		for li in range(min(lines.size(), 4)):
			draw_string(f, Vector2(pos.x + 10, pos.y + 65 + li * 22), str(lines[li]), HORIZONTAL_ALIGNMENT_LEFT, -1, fs - 2, t_color * 0.8)

var _time_left = 8.0
var _chosen = false

func _gui_input(event):
	if _chosen:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var r0 = Rect2(20, 80, 180, 180)
		var r1 = Rect2(220, 80, 180, 180)
		if r0.has_point(event.position) and options.size() >= 1:
			select_option(0)
		elif r1.has_point(event.position) and options.size() >= 2:
			select_option(1)

func _process(_delta):
	if _chosen:
		return
	_time_left -= _delta * 20.0
	if _time_left <= 0:
		select_option(0)
	else:
		queue_redraw()

func _exit_tree():
	Engine.time_scale = 1.0
	get_tree().paused = false

func select_option(index):
	if _chosen:
		return
	_chosen = true
	var opt = options[index] if index < options.size() else {}
	Global.upgrade_selected.emit(opt.get("type", "upgrade"), opt.get("id", "pistol"), opt.get("level", 1))
	queue_free()
