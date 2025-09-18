extends Area2D
class_name Enemy

@export var health: int = 3
@export var move_speed: float = 100.0
@export var movement_pattern: String = "straight"
@export var xp_reward: int = 40  

var initial_position: Vector2
var time_alive: float = 0.0
var position_initialized: bool = false

signal enemy_destroyed(enemy)

func _ready():
	area_entered.connect(_on_area_entered)
	
	var patterns = ["straight", "zigzag", "circular"]
	movement_pattern = patterns[randi() % patterns.size()]
	print("Ennemi créé avec pattern: ", movement_pattern)

func _physics_process(delta):
	time_alive += delta
	
	if not position_initialized:
		initial_position = position
		position_initialized = true
		print("Position initiale : ", initial_position)
	
	# Différents patterns de mouvement
	match movement_pattern:
		"straight": 
			position.y += move_speed * delta
		"zigzag": 
			position.y += move_speed * delta
			position.x = initial_position.x + sin(time_alive * 3.0) * 50
		"circular":
			var radius = 30
			position.x = initial_position.x + cos(time_alive * 2.0) * radius
			position.y += move_speed * delta * 0.5
	
	# Destroy si sorti de l'écran pour libérer la ram
	if position.y > get_viewport_rect().size.y + 50:
		queue_free()

func take_damage(amount: int):
	health -= amount
	
	#Effet visuel de dégât
	modulate = Color.RED
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)
	
	if health <= 0:
		die()

func die():
	enemy_destroyed.emit(self)

	# Donner de l'XP au joueur
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0 and players[0].has_method("gain_xp"):
		players[0].gain_xp(xp_reward)

	# Effet de destruction
	var tween = create_tween()
	tween.parallel().tween_property(self, "scale", Vector2.ZERO, 0.2)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.2)
	tween.tween_callback(queue_free)

func _on_area_entered(area):
	if area.get_parent() is Player:
		if area.get_parent().has_method("take_damage"):
			area.get_parent().take_damage(1)
		die()
