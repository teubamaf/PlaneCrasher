extends Control
class_name PowerupSelectionUI

signal powerup_selected(powerup: PowerupSystem.Powerup)

@onready var powerup_container: HBoxContainer = $VBoxContainer/PowerupContainer
@onready var title_label: Label = $VBoxContainer/TitleLabel

var available_powerups: Array[PowerupSystem.Powerup] = []
var powerup_system: PowerupSystem
var is_showing: bool = false

func _ready():
	visible = false
	# S'assure que l'UI peut recevoir les inputs
	mouse_filter = Control.MOUSE_FILTER_STOP
	process_mode = Node.PROCESS_MODE_ALWAYS
	adapt_to_screen_size()

func show_powerup_selection(p_powerup_system: PowerupSystem):
	if is_showing:
		print("PowerupUI: Déjà en cours d'affichage, ignoré")
		return

	is_showing = true
	powerup_system = p_powerup_system
	available_powerups = powerup_system.get_random_powerups(3)

	# S'assure qu'on a exactement 3 powerups
	if available_powerups.size() > 3:
		available_powerups = available_powerups.slice(0, 3)

	print("PowerupUI: Affichage de l'UI de sélection avec ", available_powerups.size(), " powerups")

	# Nettoie les anciens boutons
	for child in powerup_container.get_children():
		child.queue_free()

	# Attendre un frame pour que supprimés les enfants
	await get_tree().process_frame

	# Adapter la taille à l'écran
	adapt_to_screen_size()

	# Créer les boutons de powerup
	for powerup in available_powerups:
		create_powerup_button(powerup)

	# S'assure que l'UI est au premier plan
	move_to_front()
	visible = true
	get_tree().paused = true

	print("PowerupUI: UI visible et jeu en pause")

func create_powerup_button(powerup: PowerupSystem.Powerup):
	var button = Button.new()

	# Taille responsive selon l'écran
	var viewport_size = get_viewport().get_visible_rect().size
	var button_width = 140
	var button_height = 80

	# Adapter pour mobile
	if viewport_size.x < viewport_size.y:  # Mode portrait
		button_width = min(viewport_size.x / 3.5, 130)
		button_height = max(button_width * 0.7, 70)

	button.custom_minimum_size = Vector2(button_width, button_height)
	button.text = powerup.name + "\n" + powerup.description

	# S'assurer que le bouton soit clicable
	button.mouse_filter = Control.MOUSE_FILTER_STOP

	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	button.add_theme_stylebox_override("normal", create_powerup_style(Color(0.2, 0.3, 0.6, 0.9)))
	button.add_theme_stylebox_override("hover", create_powerup_style(Color(0.3, 0.4, 0.8, 0.9)))
	button.add_theme_stylebox_override("pressed", create_powerup_style(Color(0.4, 0.5, 1.0, 0.9)))

	# Connecter le signal avec debug
	button.pressed.connect(_on_powerup_button_pressed.bind(powerup))
	print("PowerupUI: Signal connecté pour ", powerup.name)

	powerup_container.add_child(button)
	print("PowerupUI: Bouton créé pour ", powerup.name, " (", button_width, "x", button_height, ")")

func create_powerup_style(color: Color) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = Color.WHITE
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	return style

func _on_powerup_button_pressed(powerup: PowerupSystem.Powerup):
	print("PowerupUI: Bouton cliqué pour ", powerup.name)
	powerup_selected.emit(powerup)
	hide_selection()

func hide_selection():
	visible = false
	get_tree().paused = false
	is_showing = false
	print("PowerupUI: UI cachée, jeu repris")

func adapt_to_screen_size():
	var viewport_size = get_viewport().get_visible_rect().size
	var vbox = $VBoxContainer

	# Calculer les dimensions responsives
	var container_width = min(viewport_size.x * 0.9, 500)  # 90% de la largeur max 500px
	var container_height = min(viewport_size.y * 0.6, 300)  # 60% de la hauteur max 300px

	# Pour écran très petit
	if viewport_size.x < 700:
		container_width = viewport_size.x * 0.95
		container_height = min(viewport_size.y * 0.4, 250)

	vbox.position.x = (viewport_size.x - container_width) / 2
	vbox.position.y = (viewport_size.y - container_height) / 2
	vbox.size.x = container_width
	vbox.size.y = container_height

	print("PowerupUI: Viewport ", viewport_size, " -> Container pos: ", vbox.position, " size: ", vbox.size)
