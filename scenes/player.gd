extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var is_attacking = false
var attack_cooldown = 0.0
const ATTACK_COOLDOWN_TIME = 0.5  # 0.5 seconds cooldown

# Health system
var max_health = 3
var current_health = 3
var is_dead = false
@onready var label: Label = $"../Label"

# Signal for health changes
signal health_changed(new_health: int)

func _ready():
	# Add player to group so enemies can find it
	add_to_group("player")

func _physics_process(delta: float) -> void:
	# Don't process movement if dead
	if is_dead:
		return
		
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Handle attack
	if Input.is_action_just_pressed("attack") and not is_attacking and attack_cooldown <= 0:
		is_attacking = true
		attack_cooldown = ATTACK_COOLDOWN_TIME
		# Use different attack animation based on whether player is in air or on ground
		if not is_on_floor():
			animated_sprite.play("air_attack")
		else:
			animated_sprite.play("attack")
		# Stop horizontal movement during attack
		velocity.x = 0
		# Attack nearby enemies
		attack_enemies()
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction and not is_attacking:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
	# Update cooldown timer
	if attack_cooldown > 0:
		attack_cooldown -= delta
	
	# Handle animations
	update_animation()

func update_animation():
	# Don't change animation if attacking
	if is_attacking:
		# Check if attack animation finished
		var current_anim = animated_sprite.animation
		var frame_count = animated_sprite.sprite_frames.get_frame_count(current_anim)
		if animated_sprite.frame == frame_count - 1 and animated_sprite.frame_progress >= 0.9:
			is_attacking = false
		return
	
	# Jump animation takes priority
	if not is_on_floor():
		if animated_sprite.animation != "jump":
			animated_sprite.play("jump")
		# Flip sprite based on direction while jumping
		if abs(velocity.x) > 0.1:
			animated_sprite.flip_h = velocity.x < 0
	# Moving horizontally
	elif abs(velocity.x) > 0.1:
		if animated_sprite.animation != "run":
			animated_sprite.play("run")
		# Flip sprite based on direction
		animated_sprite.flip_h = velocity.x < 0
	# Idle when not moving
	else:
		if animated_sprite.animation != "idle":
			animated_sprite.play("idle")

# Health system functions
func take_damage(damage: int = 1):
	if is_dead:
		return
		
	current_health -= damage
	print("Player took damage! Health: ", current_health)
	health_changed.emit(current_health)
	label.text = str(current_health) + "/ 3"
	
	if current_health <= 0:
		die()

func die():
	if is_dead:
		get_tree().change_scene_to_file("res://scenes/start.tscn")
		
	is_dead = true
	current_health = 0
	print("Player died!")
	
	# Play death animation if available
	if animated_sprite:
		animated_sprite.play("death")
	
	# Reload scene after a delay
	await get_tree().create_timer(2.0).timeout
	get_tree().reload_current_scene()

func heal(amount: int = 1):
	if is_dead:
		return
		
	current_health = min(current_health + amount, max_health)
	print("Player healed! Health: ", current_health)
	health_changed.emit(current_health)

func get_current_health() -> int:
	return current_health

func attack_enemies():
	const ATTACK_RANGE = 80.0  # Attack range in pixels
	
	# Get all enemies in the scene
	var enemies = get_tree().get_nodes_in_group("enemy")
	
	for enemy in enemies:
		if enemy and is_instance_valid(enemy) and enemy.has_method("take_damage"):
			var distance = global_position.distance_to(enemy.global_position)
			if distance <= ATTACK_RANGE:
				enemy.take_damage(1)
				print("Player attacked enemy!")
