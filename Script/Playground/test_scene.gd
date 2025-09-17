extends Node2D

@export var enemy_scene: PackedScene
var spawn_timer: float = 2.0

func _process(delta):
	spawn_timer -= delta
	if spawn_timer <= 0:
		spawn_enemy()
		spawn_timer = randf_range(1.0, 3.0)

func spawn_enemy():
	var enemy = enemy_scene.instantiate()
	add_child(enemy)
	var screen_rect = get_viewport().get_visible_rect()
	var spawn_x = randf() * screen_rect.size.x
	
	enemy.position = Vector2(spawn_x, -50)
