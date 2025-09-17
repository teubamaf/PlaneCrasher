extends CharacterBody2D

@export var speed: float = 300.0
@export var acceleration: float = 1500.0
@export var friction: float = 1200.0

@export var shoot_timer = 0.0


@export var bullet_speed: float = 400.0
var bullet_scene = preload("res://Scenes/Projectiles/Projectile.tscn")


var input_vector : Vector2 = Vector2.ZERO

func _physics_process(delta):
	input_vector = Vector2.ZERO
	
	if Input.is_action_pressed("move_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("move_right"):
		input_vector.x += 1
	if Input.is_action_pressed("move_up"):
		input_vector.y -= 1
	if Input.is_action_pressed("move_down"):
		input_vector.y += 1
	
	if input_vector.length() > 0:
		input_vector = input_vector.normalized()
		velocity = velocity.move_toward(input_vector * speed, acceleration * delta)
	else:
		# Friction quand aucune touche n'est pressée
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		
	move_and_slide()

	
	shoot_timer -= delta
	if shoot_timer <= 0:
		shoot()
		shoot_timer = 0.5

func shoot():
	
	var bullet = bullet_scene.instantiate()
	
	get_parent().add_child(bullet)

	bullet.position = position + Vector2(0, -40)

	bullet.velocity = Vector2(0, -bullet_speed)
