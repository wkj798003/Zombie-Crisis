extends CharacterBody2D
class_name Enemy
var enemy_type = "walker"
var hp = 40
var max_hp = 40
var move_speed = 80.0
var damage = 8
var xp_value = 15
var attack_cooldown = 1.2
var _attack_timer = 0.0
var player = null
var _color = Color(0.6, 0.8, 0.3)
var _size = 24
var knockback_resistance = 0.0
var _dead = false
var _knockback = Vector2.ZERO  # 防止霰弹枪多发同时命中
func _ready():
	collision_layer = 2; collision_mask = 1 + 8 + 16
	add_to_group("enemy")
	var col = CollisionShape2D.new()
	var shape = RectangleShape2D.new(); shape.size = Vector2(_size, _size); col.shape = shape
	add_child(col)
func _draw():
	draw_rect(Rect2(-_size/2, -_size/2, _size, _size), _color)
func setup(type_id, game_time):
	enemy_type = type_id
	var data = GameBalance.enemy_data.get(type_id, {})
	hp = int(data.get("hp", 40) * GameBalance.get_hp_multiplier(game_time))
	max_hp = hp
	move_speed = data.get("speed", 80.0) * (1.0 + game_time / 60.0 * 0.015)
	damage = int(data.get("damage", 8) * GameBalance.get_dmg_multiplier(game_time))
	xp_value = data.get("xp_reward", 15)
	if data.has("color"): _color = data["color"]
	if data.has("size"): _size = data["size"]
	if data.has("knockback_resistance"): knockback_resistance = data["knockback_resistance"]
func _process(delta):
	# 击退效果（霰弹枪专用）
	if _knockback.length() > 1.0:
		velocity = _knockback
		move_and_slide()
		_knockback = _knockback.move_toward(Vector2.ZERO, 800.0 * delta)
		rotation = velocity.angle()
		return
	
	_attack_timer = max(0, _attack_timer - delta)
	if not is_instance_valid(player):
		var nodes = get_tree().get_nodes_in_group("player")
		player = nodes[0] if nodes.size() > 0 else null
		if not player: return
	var dir = (player.global_position - global_position).normalized()
	velocity = dir * move_speed; move_and_slide(); rotation = dir.angle()
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() == player and _attack_timer <= 0:
			if player.has_method("take_damage"): player.take_damage(damage)
			_attack_timer = attack_cooldown
		elif c.get_collider().has_method("wall_take_damage") and _attack_timer <= 0:
			c.get_collider().wall_take_damage(damage)
			_attack_timer = attack_cooldown
func take_damage(amount, knockback_force = 0.0, knockback_dir = Vector2.ZERO):
	if _dead: return
	hp -= amount
	if knockback_force > 0:
		_knockback = knockback_dir * knockback_force * (1.0 - knockback_resistance)
	if hp <= 0:
		_dead = true; die(); return
	modulate = Color(1.0, 0.5, 0.5)
	await get_tree().create_timer(0.08).timeout
	modulate = Color.WHITE
func die():
	Global.enemy_killed.emit(enemy_type, global_position); spawn_xp(); _roll_health(); queue_free()
func _roll_health():
	var chance = 0.08 if enemy_type == "walker" else 0.12
	if randf() < chance:
		var h = HealthPickup.new(); h.setup(global_position)
		h.global_position += Vector2(randf_range(-12,12), randf_range(-12,12))
		get_parent().add_child(h)
func spawn_xp():
	if enemy_type == "walker":
		var s = XPPickup.new(); s.setup(10, global_position, "small")
		s.global_position += Vector2(randf_range(-8,8), randf_range(-8,8))
		get_parent().add_child(s)
		if randf() < 0.10:
			var m = XPPickup.new(); m.setup(50, global_position, "medium")
			m.global_position += Vector2(randf_range(-10,10), randf_range(-10,10))
			get_parent().add_child(m)
	elif enemy_type == "runner":
		var m = XPPickup.new(); m.setup(50, global_position, "medium")
		m.global_position += Vector2(randf_range(-8,8), randf_range(-8,8))
		get_parent().add_child(m)
		if randf() < 0.15:
			var l = XPPickup.new(); l.setup(200, global_position, "large")
			l.global_position += Vector2(randf_range(-6,6), randf_range(-6,6))
			get_parent().add_child(l)
	else:
		var s = XPPickup.new(); s.setup(xp_value, global_position, "small")
		get_parent().add_child(s)
