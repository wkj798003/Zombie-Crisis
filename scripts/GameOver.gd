extends Control
class_name GameOver

func _ready():
	process_mode = PROCESS_MODE_WHEN_PAUSED
	get_tree().paused = true
	
	var ov = ColorRect.new()
	ov.position = Vector2(-2000, -2000)
	ov.size = Vector2(6000, 6000)
	ov.color = Color(0, 0, 0, 0.7)
	ov.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(ov)
	
	size = Vector2(400, 360)
	position = Vector2(440, 180)
	
	var panel = ColorRect.new()
	panel.size = size
	panel.position = Vector2.ZERO
	panel.color = Color(0.08, 0.08, 0.15, 0.95)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(panel)
	
	var title = Label.new()
	title.text = "GAME OVER"
	title.position = Vector2(0, 25)
	title.size = Vector2(400, 45)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color(0.9, 0.2, 0.2))
	add_child(title)
	
	var gm = get_node("/root/Main/GameManager")
	var gt = str(int(gm.game_time if gm else 0))
	var lv = str(gm.level if gm else 0)
	var kl = str(gm.total_kills if gm else 0)
	var m = int(gt) / 60
	var s2 = int(gt) % 60
	var ts = str(s2)
	if ts.length() == 1:
		ts = "0" + ts
	
	var st = Label.new()
	st.text = "Survived: " + str(m) + ":" + ts + "  |  Level: " + lv + "  |  Kills: " + kl
	st.position = Vector2(50, 90)
	st.size = Vector2(300, 100)
	st.add_theme_font_size_override("font_size", 16)
	st.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	add_child(st)
	
	var btn_texts = ["Return to Menu", "Retry"]
	for i in range(btn_texts.size()):
		var txt = btn_texts[i]
		var b = Button.new()
		b.position = Vector2(100, 210 + i * 60)
		b.size = Vector2(200, 44)
		b.text = txt
		b.add_theme_color_override("font_color", Color(1, 1, 1))
		b.add_theme_stylebox_override("normal", _st(Color(0.15, 0.15, 0.25)))
		b.add_theme_stylebox_override("hover", _st(Color(0.2, 0.2, 0.35)))
		if i == 0:
			b.pressed.connect(_on_menu)
		else:
			b.pressed.connect(_on_retry)
		add_child(b)

func _st(c):
	var s = StyleBoxFlat.new()
	s.bg_color = c
	s.set_corner_radius_all(4)
	return s

func _on_menu():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_retry():
	get_tree().paused = false
	get_tree().reload_current_scene()
