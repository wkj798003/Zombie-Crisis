extends Control

class_name PauseMenu

var _resume_down = true  # 初始 true 避免创建时按键未释放即恢复

func _ready():
	process_mode = PROCESS_MODE_WHEN_PAUSED
	
	var overlay = ColorRect.new()
	overlay.position = Vector2(-2000, -2000)
	overlay.size = Vector2(6000, 6000)
	overlay.color = Color(0, 0, 0, 0.55)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(overlay)
	
	size = Vector2(320, 280)
	position = Vector2(480, 220)
	
	var panel = ColorRect.new()
	panel.size = size
	panel.position = Vector2.ZERO
	panel.color = Color(0.08, 0.08, 0.15, 0.95)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(panel)
	
	var title = Label.new()
	title.text = "游 戏 暂 停"
	title.position = Vector2(0, 30)
	title.size = Vector2(320, 40)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 26)
	title.add_theme_color_override("font_color", Color(1, 1, 0.6))
	add_child(title)
	
	var resume_btn = Button.new()
	resume_btn.position = Vector2(70, 100)
	resume_btn.size = Vector2(180, 44)
	resume_btn.text = "继续游戏 (ESC)"
	resume_btn.add_theme_color_override("font_color", Color(1, 1, 1))
	resume_btn.pressed.connect(_on_resume)
	add_child(resume_btn)
	
	var menu_btn = Button.new()
	menu_btn.position = Vector2(70, 165)
	menu_btn.size = Vector2(180, 44)
	menu_btn.text = "返回主菜单"
	menu_btn.add_theme_color_override("font_color", Color(1, 1, 1))
	menu_btn.pressed.connect(_on_menu)
	add_child(menu_btn)
	
	var hint = Label.new()
	hint.text = "ESC / Space 继续游戏"
	hint.position = Vector2(0, 240)
	hint.size = Vector2(320, 24)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 11)
	hint.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	add_child(hint)

func _process(_delta):
	if Input.is_key_pressed(KEY_ESCAPE) or Input.is_key_pressed(KEY_SPACE):
		if not _resume_down:
			_resume_down = true
			_on_resume()
	else:
		_resume_down = false

func _on_resume():
	get_tree().paused = false
	queue_free()

func _on_menu():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
