extends CharacterBody2D

class_name Player

var hp = 100
var max_hp = 100
var speed = 200.0
var time_since_dodge = 2.5
var dodging = false
var dodge_dir = Vector2.ZERO
var weapon_mgr
var _fire_cooldown = 0.0
var _mouse_was_down = false
var _right_was_down = false
var _pause_down = false
var _wall_mode = false
var _walls_remaining = 3
var _wall_key_down = false
var _ads_mode = false  # 狙击镜模式
var _prev_speed = 200.0

func _ready():
	collision_layer = 1
	collision_mask = 2 + 8 + 16
	max_hp = GameBalance.player_max_hp
	hp = max_hp
	speed = GameBalance.player_speed
	_prev_speed = speed
	add_to_group("player")
	
	var col = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(24, 24)
	col.shape = shape
	add_child(col)
	
	var wm = WeaponManager.new()
	wm.name = "WeaponManager"
	add_child(wm)
	weapon_mgr = wm

func _draw():
	draw_rect(Rect2(-12, -12, 24, 24), Color(0.2, 0.6, 1.0))
	draw_line(Vector2(12, 0), Vector2(20, 0), Color(1.0, 0.8, 0.2), 2.0)
	
	# 狙击镜瞄准线
	if _ads_mode and weapon_mgr.current_weapon_id == "sniper":
		draw_line(Vector2(16, 0), Vector2(10000, 0), Color(1, 0.3, 0.3, 0.25), 1.5)
		draw_circle(Vector2(20, 0), 2.5, Color(1, 0.2, 0.2, 0.9))

func _process(delta):
	time_since_dodge += delta
	
	# 右键切换狙击镜
	var _now_right = Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)
	if _now_right and not _right_was_down:
		if weapon_mgr.current_weapon_id == "sniper":
			_ads_mode = not _ads_mode
			Global.scope_changed.emit(_ads_mode)
			if _ads_mode:
				speed = _prev_speed * 0.4  # 开镜减速
			else:
				speed = _prev_speed
			queue_redraw()
	
	var move_vec = Vector2.ZERO
	if Input.is_key_pressed(KEY_D): move_vec.x += 1
	if Input.is_key_pressed(KEY_A): move_vec.x -= 1
	if Input.is_key_pressed(KEY_S): move_vec.y += 1
	if Input.is_key_pressed(KEY_W): move_vec.y -= 1
	if move_vec.length_squared() > 0.001:
		move_vec = move_vec.normalized()
	
	if dodging:
		velocity = dodge_dir * 400.0
	else:
		velocity = move_vec * speed
	
	move_and_slide()
	
	var mouse_pos = get_global_mouse_position()
	var dir = (mouse_pos - global_position).normalized()
	rotation = dir.angle()
	
	var mouse_down = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	if weapon_mgr.current_weapon_id == "wall":
		if not _wall_mode:
			_wall_mode = true
	elif _wall_mode:
		_wall_mode = false

	var is_wall = _wall_mode or weapon_mgr.current_weapon_id == "wall"
	if is_wall:
		if mouse_down and not _mouse_was_down:
			deploy_wall()
	
	elif mouse_down:
		if _mouse_was_down and not weapon_mgr.get_current_weapon().get("auto", false):
			pass  # single fire — fall through to try_shoot
		else:
			try_shoot()
	_mouse_was_down = mouse_down
	_fire_cooldown = max(0, _fire_cooldown - delta)
	
	if Input.is_key_pressed(KEY_SHIFT) and time_since_dodge >= GameBalance.dodge_cooldown and not dodging:
		start_dodge()
	if Input.is_key_pressed(KEY_R):
		weapon_mgr.reload()
	if Input.is_key_pressed(KEY_Q):
		weapon_mgr.switch_prev()
	if Input.is_key_pressed(KEY_E):
		weapon_mgr.switch_next()
	if Input.is_key_pressed(KEY_1):
		weapon_mgr.switch_to("pistol")
	if Input.is_key_pressed(KEY_2):
		weapon_mgr.switch_to("smg")
	if Input.is_key_pressed(KEY_3):
		weapon_mgr.switch_to("shotgun")
		# ESC / Space 暂停
	if (Input.is_key_pressed(KEY_ESCAPE) or Input.is_key_pressed(KEY_SPACE)) and not _pause_down:
		_pause_down = true
		get_tree().paused = true
		var pm = load("res://scripts/PauseMenu.gd").new()
		var gm = get_node("/root/Main/GameManager")
		if gm: gm.add_child(pm)
		return
	elif not Input.is_key_pressed(KEY_ESCAPE) and not Input.is_key_pressed(KEY_SPACE):
		_pause_down = false
	
	if Input.is_key_pressed(KEY_4):
		weapon_mgr.switch_to("sniper")
		# 切到狙击枪时自动关镜
		_ads_mode = false
		Global.scope_changed.emit(false)
		speed = _prev_speed
		queue_redraw()
	# 开镜时每帧刷新瞄准线
	if _ads_mode:
		queue_redraw()
	_right_was_down = _now_right
	if Input.is_key_pressed(KEY_5):
		weapon_mgr.switch_to("energy_rifle")
		_ads_mode = false
		Global.scope_changed.emit(false)
		speed = _prev_speed
		queue_redraw()
	if Input.is_key_pressed(KEY_6):
		weapon_mgr.switch_to("grenade_launcher")
		_ads_mode = false
		Global.scope_changed.emit(false)
		speed = _prev_speed
		queue_redraw()
	if (Input.is_key_pressed(KEY_7)) and not _wall_key_down:
		_wall_key_down = true
		_wall_mode = not _wall_mode
		if _wall_mode:
			_ads_mode = false
			Global.scope_changed.emit(false)
			speed = _prev_speed
			queue_redraw()
	elif not Input.is_key_pressed(KEY_7):
		_wall_key_down = false




func try_shoot():
	var stats = weapon_mgr.get_current_weapon()
	if stats.is_empty():
		return
	if _fire_cooldown > 0:
		return
	if not weapon_mgr.can_fire():
		return
	
	_fire_cooldown = stats.get("fire_rate", 0.45)
	var fire_data = weapon_mgr.fire()
	if fire_data == null:
		return
	# 弹夹打空自动换弹（手枪无限弹夹除外）
	var _ar_wid = weapon_mgr.current_weapon_id
	if _ar_wid != "pistol":
		var _ar_cur = weapon_mgr.ammo.get(_ar_wid, 0)
		if _ar_cur <= 0:
			weapon_mgr.reload()

	
	var mpos = get_global_mouse_position()
	var base_dir = (mpos - global_position).normalized()
	var wid = weapon_mgr.current_weapon_id
	
	# 弹道散布
	var spread = stats.get("spread", 0.03)
	if wid == "sniper":
		if _ads_mode:
			spread = 0.003  # 开镜几乎无散布
		else:
			spread = stats.get("spread_no_scope", 0.15)  # 不开镜散布大
	
	var bullet_count = stats.get("bullet_count", 1)
	for i in range(bullet_count):
		var d = base_dir.rotated(randf_range(-spread, spread))
		if wid == "grenade_launcher":
			var g = load("res://scripts/Grenade.gd").new()
			g.setup(global_position + d * 20, d, fire_data)
			get_parent().add_child(g)
		else:
			var b = Bullet.new()
			b.setup(global_position + d * 16, d, fire_data)
			get_parent().add_child(b)

func deploy_wall():
	if _walls_remaining <= 0:
		return
	var wall = load("res://scripts/DeployableWall.gd").new()
	wall.position = get_global_mouse_position()
	get_parent().add_child(wall)
	_walls_remaining -= 1

func heal(amount):
	var old_hp = hp
	hp = min(max_hp, hp + amount)
	modulate = Color(0.5, 1.0, 0.5)
	await get_tree().create_timer(0.12).timeout
	modulate = Color.WHITE
	Global.player_damaged.emit(hp - old_hp, hp)

func start_dodge():
	if dodging:
		return
	dodging = true
	time_since_dodge = 0.0
	var input_dir = Vector2(
		(1.0 if Input.is_key_pressed(KEY_D) else 0.0) - (1.0 if Input.is_key_pressed(KEY_A) else 0.0),
		(1.0 if Input.is_key_pressed(KEY_S) else 0.0) - (1.0 if Input.is_key_pressed(KEY_W) else 0.0)
	)
	if input_dir.length() < 0.1:
		dodge_dir = Vector2.RIGHT.rotated(rotation)
	else:
		dodge_dir = input_dir.normalized()
	await get_tree().create_timer(0.2).timeout
	dodging = false

func take_damage(amount):
	hp -= amount
	hp = max(0, hp)
	modulate = Color(1.0, 0.5, 0.5)
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE
	Global.player_damaged.emit(amount, hp)
	if hp <= 0:
		Global.player_died.emit()
		queue_free()
