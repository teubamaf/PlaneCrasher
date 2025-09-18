extends CharacterBody2D
class_name Player

@export var base_speed: float = 300.0
@export var acceleration: float = 1500.0
@export var friction: float = 1200.0

# Références aux systèmes
var level_system: LevelSystem
var powerup_system: PowerupSystem

@export var base_lifepoint = 3
@export var shoot_timer = 0.0
@export var base_shoot_cooldown: float = 0.5
@export var bullet_speed: float = 400.0
var bullet_scene = preload("res://Scenes/Projectiles/Projectile.tscn")

# Variables calculées dynamiquement
var speed: float
var lifepoint: int
var max_lifepoint: int
var shoot_cooldown: float

var input_vector : Vector2 = Vector2.ZERO
var touch_position: Vector2 = Vector2.ZERO
var is_touching: bool = false

func _ready():

	add_to_group("player")

	# Initialiser les systèmes
	level_system = LevelSystem.new()
	powerup_system = PowerupSystem.new()
	add_child(level_system)
	add_child(powerup_system)

	# Connecter les signaux
	level_system.level_up.connect(_on_level_up)
	powerup_system.powerup_applied.connect(_on_powerup_applied)

	# Initialiser les stats
	update_stats()

	var hitbox = $Hitbox
	hitbox.area_entered.connect(_on_hitbox_area_entered)

	print("Joueur initialisé avec ", lifepoint, " points de vie")


func _physics_process(delta):
	input_vector = Vector2.ZERO
	
	# Contrôles clavier (PC)
	if Input.is_action_pressed("move_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("move_right"):
		input_vector.x += 1
	if Input.is_action_pressed("move_up"):
		input_vector.y -= 1
	if Input.is_action_pressed("move_down"):
		input_vector.y += 1
	
	# Contrôles tactiles (Mobile)
	if is_touching:
		var direction = (touch_position - global_position).normalized()
		var distance = global_position.distance_to(touch_position)
		
		# Zone morte pour éviter les micro-mouvements
		if distance > 30:
			input_vector = direction
	
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
		shoot_timer = shoot_cooldown

func shoot():
	var projectile_count = powerup_system.get_projectile_count()
	var damage_multiplier = powerup_system.get_damage_multiplier()

	for i in range(projectile_count):
		var bullet = bullet_scene.instantiate()
		get_parent().add_child(bullet)

		# Position de départ avec espacement pour plusieurs projectiles
		var offset_x = 0
		if projectile_count > 1:
			offset_x = (i - (projectile_count - 1) * 0.5) * 20

		bullet.position = position + Vector2(offset_x, -40)
		bullet.velocity = Vector2(0, -bullet_speed)

		# Appliquer les dégâts améliorés
		if bullet.has_method("set_damage"):
			bullet.set_damage(int(bullet.damage * damage_multiplier))


func take_damage(amount: int = 1):
	lifepoint -= amount
	print("Vie restante: ", lifepoint)
	
	modulate = Color.RED
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.2)
	
	if lifepoint <= 0:
		die()

func die():
	print("Game Over !")
	queue_free()
	
func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			is_touching = true
			touch_position = event.position
		else:
			is_touching = false
	
	elif event is InputEventScreenDrag:
		if is_touching:
			touch_position = event.position

func _on_hitbox_area_entered(area):
	print("Collision détectée avec: ", area.name)

func update_stats():
	# Calculer les stats modifiées par les powerups
	speed = base_speed * powerup_system.get_move_speed_multiplier()
	shoot_cooldown = base_shoot_cooldown / powerup_system.get_attack_speed_multiplier()
	max_lifepoint = base_lifepoint + powerup_system.get_bonus_health()

	# Ajuster les points de vie si powerup
	if lifepoint == 0 or lifepoint > max_lifepoint:
		lifepoint = max_lifepoint

func _on_level_up(new_level: int):
	print("Level up! Nouveau niveau: ", new_level)

func _on_powerup_applied(powerup):
	update_stats()
	print("Powerup appliqué: ", powerup.name)

func gain_xp(amount: int):
	level_system.add_xp(amount)
