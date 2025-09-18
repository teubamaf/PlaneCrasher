extends Node
class_name PowerupSystem

enum PowerupType {
	ATTACK_SPEED,
	PROJECTILE_COUNT,
	MOVE_SPEED,
	DAMAGE,
	HEALTH
}

class Powerup:
	var type: PowerupType
	var name: String
	var description: String
	var icon_path: String
	var effect_value: float

	func _init(p_type: PowerupType, p_name: String, p_description: String, p_effect_value: float, p_icon_path: String = ""):
		type = p_type
		name = p_name
		description = p_description
		effect_value = p_effect_value
		icon_path = p_icon_path

# Dictionnaire pour stocker les améliorations actives
var active_powerups: Dictionary = {}

signal powerup_applied(powerup: Powerup)

func _ready():
	# Initialise le compteurs de powerups
	for powerup_type in PowerupType.values():
		active_powerups[powerup_type] = 0

func get_available_powerups() -> Array[Powerup]:
	var powerups: Array[Powerup] = []

	powerups.append(Powerup.new(
		PowerupType.ATTACK_SPEED,
		"Cadence de tir rapide",
		"Augmente la vitesse de tir de 20%",
		0.2
	))

	powerups.append(Powerup.new(
		PowerupType.PROJECTILE_COUNT,
		"Tirs multiples",
		"Ajoute un projectile supplémentaire",
		1
	))

	powerups.append(Powerup.new(
		PowerupType.MOVE_SPEED,
		"Vitesse améliorée",
		"Augmente la vitesse de déplacement de 15%",
		0.15
	))

	powerups.append(Powerup.new(
		PowerupType.DAMAGE,
		"Dégâts renforcés",
		"Augmente les dégâts de 50%",
		0.5
	))

	powerups.append(Powerup.new(
		PowerupType.HEALTH,
		"Armure renforcée",
		"Ajoute 1 point de vie",
		1
	))

	return powerups

func get_random_powerups(count: int = 3) -> Array[Powerup]:
	var all_powerups = get_available_powerups()
	var selected: Array[Powerup] = []

	# permet de mélanger
	all_powerups.shuffle()

	for i in range(min(count, all_powerups.size())):
		selected.append(all_powerups[i])

	return selected

func apply_powerup(powerup: Powerup):
	active_powerups[powerup.type] += 1
	powerup_applied.emit(powerup)
	print("Powerup appliqué: ", powerup.name, " (Total: ", active_powerups[powerup.type], ")")

func get_powerup_level(type: PowerupType) -> int:
	return active_powerups.get(type, 0)

# Fonctions pour calculer les valeurs modifiées
func get_attack_speed_multiplier() -> float:
	var level = get_powerup_level(PowerupType.ATTACK_SPEED)
	return 1.0 + (level * 0.2)  # 20% par niveau

func get_projectile_count() -> int:
	return 1 + get_powerup_level(PowerupType.PROJECTILE_COUNT)

func get_move_speed_multiplier() -> float:
	var level = get_powerup_level(PowerupType.MOVE_SPEED)
	return 1.0 + (level * 0.15)  # 15% par niveau

func get_damage_multiplier() -> float:
	var level = get_powerup_level(PowerupType.DAMAGE)
	return 1.0 + (level * 0.5)  # 50% par niveau

func get_bonus_health() -> int:
	return get_powerup_level(PowerupType.HEALTH)
