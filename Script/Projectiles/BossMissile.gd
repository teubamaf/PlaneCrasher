extends Area2D
class_name BossMissile

@export var speed: float = 300.0
@export var lifetime: float = 5.0
@export var damage: int = 2

var direction: Vector2 = Vector2.DOWN
var velocity: Vector2

func _ready():
	# Timer pour détruire le missile après un certain temps
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = lifetime
	timer.one_shot = true
	timer.timeout.connect(_on_lifetime_timeout)
	timer.start()

	# Connecter le signal de collision
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)

func _physics_process(delta):
	velocity = direction * speed
	position += velocity * delta

	check_screen_bounds()

func setup(new_direction: Vector2, new_speed: float):
	direction = new_direction.normalized()
	speed = new_speed

	rotation = direction.angle() + PI/2

func check_screen_bounds():
	var viewport = get_viewport_rect()
	var margin = 50

	if position.x < -margin or position.x > viewport.size.x + margin or \
	   position.y < -margin or position.y > viewport.size.y + margin:
		queue_free()

func _on_lifetime_timeout():
	queue_free()

func _on_area_entered(area):
	# Ne touche que les hitbox du joueur
	if area.get_parent() is Player:
		if area.get_parent().has_method("take_damage"):
			area.get_parent().take_damage(damage)
		queue_free()

func _on_body_entered(body):
	# Touche directement le joueur s'il est un CharacterBody2D
	if body is Player:
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free()

func set_damage(new_damage: int):
	damage = new_damage
