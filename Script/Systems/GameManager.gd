extends Node
class_name GameManager

var player: Player
var powerup_ui: PowerupSelectionUI

# Boss management
@export var boss_scene: PackedScene = preload("res://Scenes/Boss/Boss_1.tscn")
var enemies_killed: int = 0
var enemies_needed_for_boss: int = 10
var boss_active: bool = false
var current_boss: Boss = null

signal boss_spawned
signal boss_defeated
signal enemy_spawn_paused
signal enemy_spawn_resumed

func _ready():
	add_to_group("game_manager")

	#Permet que tous les nodes soient initialisés
	await get_tree().process_frame
	initialize_connections()

func initialize_connections():
	player = get_tree().get_first_node_in_group("player")
	powerup_ui = get_tree().get_first_node_in_group("powerup_ui")

	print("GameManager: Player trouvé: ", player != null)
	print("GameManager: PowerupUI trouvé: ", powerup_ui != null)

	if player and player.level_system:
		player.level_system.level_up.connect(_on_player_level_up)
		print("GameManager: Signal level_up connecté")
	else:
		print("GameManager: Impossible de connecter level_up - Player ou level_system manquant")

	if powerup_ui:
		powerup_ui.powerup_selected.connect(_on_powerup_selected)
		print("GameManager: Signal powerup_selected connecté")
	else:
		print("GameManager: Impossible de connecter powerup_selected - PowerupUI manquant")

func _on_player_level_up(new_level: int):
	print("GameManager: Level up détecté! Niveau: ", new_level)
	if powerup_ui and player and player.powerup_system:
		print("GameManager: Affichage de l'UI de sélection de powerup")
		powerup_ui.show_powerup_selection(player.powerup_system)
	else:
		print("GameManager: Impossible d'afficher l'UI - composants manquants")

func _on_powerup_selected(powerup: PowerupSystem.Powerup):
	print("GameManager: Powerup sélectionné: ", powerup.name)
	if player and player.powerup_system:
		player.powerup_system.apply_powerup(powerup)
	else:
		print("GameManager: Impossible d'appliquer le powerup - player manquant")

func on_enemy_destroyed():
	enemies_killed += 1
	print("Ennemis tués: ", enemies_killed, "/", enemies_needed_for_boss)

	if enemies_killed >= enemies_needed_for_boss and not boss_active:
		spawn_boss()

func spawn_boss():
	if boss_active or not boss_scene:
		return

	boss_active = true
	enemy_spawn_paused.emit()

	current_boss = boss_scene.instantiate()
	get_parent().add_child(current_boss)

	# Position du boss en haut de l'écran
	var screen_rect = get_viewport().get_visible_rect()
	current_boss.position = Vector2(screen_rect.size.x / 2, 100)

	current_boss.boss_destroyed.connect(_on_boss_destroyed)
	boss_spawned.emit()

	print("Boss qui spawn.")

func _on_boss_destroyed():
	boss_active = false
	current_boss = null
	enemies_killed = 0  # Reset le compteur

	boss_defeated.emit()
	enemy_spawn_resumed.emit()

	print("Boss vaincu!")

func connect_enemy(enemy: Enemy):
	if enemy:
		enemy.enemy_destroyed.connect(_on_enemy_destroyed_wrapper)

func _on_enemy_destroyed_wrapper(enemy):
	on_enemy_destroyed()
