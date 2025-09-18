extends Node

# Script de test pour forcer un level up rapidement

var player: Player

func _ready():
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")

	if player:
		print("TestLevelUp: Player trouvé, ajout de XP pour test...")
		await get_tree().create_timer(2.0).timeout
		player.gain_xp(500)  
	else:
		print("TestLevelUp: Player non trouvé!")

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_L and player:
			print("TestLevelUp: Ajout de 200 XP (touche L)")
			player.gain_xp(200)
