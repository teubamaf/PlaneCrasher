extends Area2D

@export var speed: float = 500.0
@export var lifetime: float = 5.0  # Durée de vie
@export var damage: int = 1

var direction: Vector2 = Vector2.UP
var velocity: Vector2

func _ready():
	# Timer pour détruire le projectile après un certain temps
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
	
	rotation = direction.angle() + PI/2  # +PI/2 si le sprite pointe vers le haut par défaut

func check_screen_bounds():
	var viewport = get_viewport_rect()
	var margin = 50 
	
	if position.x < -margin or position.x > viewport.size.x + margin or \
	   position.y < -margin or position.y > viewport.size.y + margin:
		queue_free()

func _on_lifetime_timeout():
	queue_free()

func _on_area_entered(area):
	if area.has_method("take_damage"):
		area.take_damage(damage)
	queue_free()

func _on_body_entered(body):
	if body.has_method("take_damage") and body != get_parent():
		body.take_damage(damage)
	queue_free()
