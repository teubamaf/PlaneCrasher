extends Node
class_name LevelSystem

signal level_up(new_level)
signal xp_gained(amount)

@export var current_level: int = 1
@export var current_xp: int = 0
@export var base_xp_requirement: int = 100

# Formule: base_xp * (level^1.1) pour une progression exponentielle
func get_xp_required_for_level(level: int) -> int:
	return int(base_xp_requirement * pow(level, 1.1))

func get_xp_required_for_next_level() -> int:
	return get_xp_required_for_level(current_level)

func add_xp(amount: int):
	current_xp += amount
	xp_gained.emit(amount)

	check_level_up()

func check_level_up():
	var xp_required = get_xp_required_for_next_level()

	while current_xp >= xp_required:
		current_xp -= xp_required
		current_level += 1
		level_up.emit(current_level)

		print("Level Up! Nouveau niveau: ", current_level)

		# Recalculer pour le prochain niveau
		xp_required = get_xp_required_for_next_level()

func get_xp_progress() -> float:
	var required = get_xp_required_for_next_level()
	return float(current_xp) / float(required)
