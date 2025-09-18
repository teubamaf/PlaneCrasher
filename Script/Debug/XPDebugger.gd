extends Control

var player: Player
var label: Label

func _ready():
	# Créer un label pour afficher l'XP
	label = Label.new()
	label.position = Vector2(10, 10)
	add_child(label)

	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")

	if player and player.level_system:
		player.level_system.xp_gained.connect(_on_xp_gained)
		player.level_system.level_up.connect(_on_level_up)

func _process(_delta):
	if player and player.level_system:
		var current_xp = player.level_system.current_xp
		var required_xp = player.level_system.get_xp_required_for_next_level()
		var current_level = player.level_system.current_level

		label.text = "Level: %d\nXP: %d/%d" % [current_level, current_xp, required_xp]

func _on_xp_gained(amount: int):
	print("XPDebugger: +", amount, " XP")

func _on_level_up(new_level: int):
	print("XPDebugger: LEVEL UP! Niveau ", new_level)