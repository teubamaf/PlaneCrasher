extends Node
class_name GameManager

var player: Player
var powerup_ui: PowerupSelectionUI

func _ready():
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
		#print("GameManager: Affichage de l'UI de sélection de powerup")
		powerup_ui.show_powerup_selection(player.powerup_system)
	else:
		print("GameManager: Impossible d'afficher l'UI - composants manquants")

func _on_powerup_selected(powerup: PowerupSystem.Powerup):
	print("GameManager: Powerup sélectionné: ", powerup.name)
	if player and player.powerup_system:
		player.powerup_system.apply_powerup(powerup)
	else:
		print("GameManager: Impossible d'appliquer le powerup - player manquant")
