extends Node2D

@export var enemy_scene: PackedScene
var spawn_timer: float = 2.0
var spawn_paused: bool = false
var game_manager: GameManager

func _ready():
	game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager:
		game_manager.enemy_spawn_paused.connect(_on_enemy_spawn_paused)
		game_manager.enemy_spawn_resumed.connect(_on_enemy_spawn_resumed)

func _process(delta):
	if spawn_paused:
		return

	spawn_timer -= delta
	if spawn_timer <= 0:
		spawn_enemy()
		spawn_timer = randf_range(1.0, 3.0)

func spawn_enemy():
	if spawn_paused:
		return

	var enemy = enemy_scene.instantiate()
	add_child(enemy)
	var screen_rect = get_viewport().get_visible_rect()
	var spawn_x = randf() * screen_rect.size.x

	enemy.position = Vector2(spawn_x, -50)

	# Connecter l'ennemi au GameManager
	if game_manager:
		game_manager.connect_enemy(enemy)

func _on_enemy_spawn_paused():
	spawn_paused = true
	print("Spawn des ennemis en pause")

func _on_enemy_spawn_resumed():
	spawn_paused = false
	print("Spawn des ennemis repris")
