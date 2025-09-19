extends Area2D
class_name Boss

@export var health: int = 50
@export var move_speed: float = 150.0
@export var horizontal_range: float = 300.0
@export var vertical_range: float = 100.0
@export var missile_cooldown: float = 2.0
@export var missiles_per_shot: int = 3

var missile_scene = preload("res://Scenes/Projectiles/BossMissile.tscn")
var initial_position: Vector2
var time_alive: float = 0.0
var missile_timer: float = 0.0
var moving_right: bool = true
var moving_forward: bool = true

signal boss_destroyed

func _ready():
	area_entered.connect(_on_area_entered)
	initial_position = position
	missile_timer = missile_cooldown

func _physics_process(delta):
	time_alive += delta
	missile_timer -= delta

	var screen_rect = get_viewport().get_visible_rect()

	# Mouvement horizontal (gauche-droite)
	if moving_right:
		position.x += move_speed * delta
		if position.x > screen_rect.size.x - 100: 
			moving_right = false
	else:
		position.x -= move_speed * delta
		if position.x < 100: 
			moving_right = true

	# Mouvement vertical (avant-arrière)
	var vertical_offset = sin(time_alive * 1.5) * 50  
	position.y = initial_position.y + vertical_offset

	# S'assurer que le boss reste dans les limites verticales
	if position.y < 50:
		position.y = 50
	elif position.y > screen_rect.size.y * 0.4:
		position.y = screen_rect.size.y * 0.4

	# Tir de missiles
	if missile_timer <= 0:
		shoot_missiles()
		missile_timer = missile_cooldown

func shoot_missiles():
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return

	for i in range(missiles_per_shot):
		var missile = missile_scene.instantiate()
		get_parent().add_child(missile)

		# Position de spawn avec léger décalage
		var spawn_offset = Vector2((i - 1) * 30, 50)
		missile.position = position + spawn_offset

		# Direction vers le joueur avec un arc
		var direction_to_player = (player.position - missile.position).normalized()
		var arc_angle = (i - 1) * 0.2  
		var rotated_direction = direction_to_player.rotated(arc_angle)

		missile.setup(rotated_direction, 300.0)
		missile.set_damage(2)

func take_damage(amount: int):
	health -= amount

	# Effet visuel de dégât
	modulate = Color.RED
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)

	if health <= 0:
		die()

func die():
	boss_destroyed.emit()

	# récompense pour le kill du boss
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0 and players[0].has_method("gain_xp"):
		players[0].gain_xp(500)

	# Effet de destruction
	var tween = create_tween()
	tween.parallel().tween_property(self, "scale", Vector2.ZERO, 0.5)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(queue_free)

func _on_area_entered(area):
	if area.get_parent() is Player:
		if area.get_parent().has_method("take_damage"):
			area.get_parent().take_damage(3)
