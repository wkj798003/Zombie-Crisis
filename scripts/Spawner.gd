extends Node

class_name Spawner

var spawn_timer = 0.0
var game_time = 0.0
var arena_rect = Rect2(-400, -300, 800, 600)

func _process(delta):
	game_time += delta
	
	# 调试用：每 3 秒一波
	var interval = 3.0
	
	spawn_timer += delta
	if spawn_timer >= interval:
		spawn_timer = 0.0
		spawn_wave()

func spawn_wave():
	var count = 1 + int(game_time / 120.0) + 1
	for i in range(count):
		spawn_enemy()

func spawn_enemy():
	var type_id = pick_enemy_type()
	var enemy = Enemy.new()
	var edge = randi() % 4
	var pos = Vector2.ZERO
	match edge:
		0: pos = Vector2(arena_rect.position.x, randf_range(arena_rect.position.y, arena_rect.end.y))
		1: pos = Vector2(arena_rect.end.x, randf_range(arena_rect.position.y, arena_rect.end.y))
		2: pos = Vector2(randf_range(arena_rect.position.x, arena_rect.end.x), arena_rect.position.y)
		3: pos = Vector2(randf_range(arena_rect.position.x, arena_rect.end.x), arena_rect.end.y)
	
	enemy.setup(type_id, game_time)
	enemy.position = pos
	add_child(enemy)

func pick_enemy_type():
	if game_time < 120:
		return "walker"
	elif game_time < 240:
		return "walker" if randf() < 0.7 else "runner"
	elif game_time < 360:
		var r = randf()
		return "walker" if r < 0.4 else ("runner" if r < 0.7 else "brute")
	else:
		var r = randf()
		return "runner" if r < 0.35 else ("walker" if r < 0.65 else "brute")
