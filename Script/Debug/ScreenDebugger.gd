extends Control

var debug_label: Label

func _ready():
	# Créer un label de debug en haut à gauche
	debug_label = Label.new()
	debug_label.position = Vector2(10, 10)
	add_child(debug_label)

	# Plein écran pour le debug
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func _process(_delta):
	if debug_label:
		var viewport_size = get_viewport().get_visible_rect().size
		var player = get_tree().get_first_node_in_group("player")
		var powerup_ui = get_tree().get_first_node_in_group("powerup_ui")

		var text = "Écran: %s\n" % str(viewport_size)

		if player:
			text += "Player pos: %s\n" % str(player.global_position)

		if powerup_ui:
			text += "UI visible: %s\n" % str(powerup_ui.visible)
			text += "UI pos: %s\n" % str(powerup_ui.global_position)

		debug_label.text = text
