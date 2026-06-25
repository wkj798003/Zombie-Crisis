extends Node2D
class_name MainMenu
func _ready(): create_ui()
func create_ui():
	var bg = ColorRect.new()
	bg.position = Vector2(-2000, -2000); bg.size = Vector2(6000, 6000)
	bg.color = Color(0.06, 0.06, 0.12); bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	var t = Label.new(); t.text = "PROJECT Z"
	t.position = Vector2(0, 80); t.size = Vector2(1280, 100)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t.add_theme_font_size_override("font_size", 56)
	t.add_theme_color_override("font_color", Color(0.9, 0.15, 0.15))
	add_child(t)
	var s = Label.new(); s.text = "ZOMBIE CRISIS"
	s.position = Vector2(0, 150); s.size = Vector2(1280, 50)
	s.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	s.add_theme_font_size_override("font_size", 22)
	s.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	add_child(s)
	var h = Label.new()
	h.text = "WASD: move | Q/E: switch | R: reload | ESC: pause"
	h.position = Vector2(0, 250); h.size = Vector2(1280, 30)
	h.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	h.add_theme_font_size_override("font_size", 13)
	h.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	add_child(h)
	var btn = Button.new()
	btn.position = Vector2(490, 320); btn.size = Vector2(300, 50)
	btn.text = "START GAME"
	btn.add_theme_font_size_override("font_size", 18)
	btn.add_theme_color_override("font_color", Color(1, 1, 1))
	btn.add_theme_stylebox_override("normal", _bs(Color(0.15, 0.15, 0.25)))
	btn.add_theme_stylebox_override("hover", _bs(Color(0.2, 0.2, 0.35)))
	btn.add_theme_stylebox_override("pressed", _bs(Color(0.1, 0.1, 0.2)))
	btn.pressed.connect(_on_start)
	add_child(btn)
func _bs(c):
	var st = StyleBoxFlat.new(); st.bg_color = c; st.set_corner_radius_all(6); return st
func _on_start():
	get_tree().change_scene_to_file("res://scenes/main.tscn")
