extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 100.0  # Slower than player (Reduced from 150.0 as requested)
const DETECTION_DISTANCE = 200.0  # Distance to detect player
const ATTACK_DISTANCE = 50.0  # Distance to attack player
const ATTACK_COOLDOWN_TIME = 2.0  # Time between attacks

# Health system
var max_health = 1
var current_health = 1
var is_dead = false

# AI variables
var player = null
var is_attacking = false
var attack_cooldown = 0.0
var is_chasing = false

func _ready():
	# Add venom to enemy group
	add_to_group("enemy")
	
	# Find the player node
	player = get_tree().get_first_node_in_group("player")
	if not player:
		# If no player in group, try to find by name
		player = get_node("../Player")  # Adjust path as needed

func _physics_process(delta: float) -> void:
	if is_dead:
		return
		
	# Add gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Update attack cooldown
	if attack_cooldown > 0:
		attack_cooldown -= delta
	
	# AI behavior
	if player and not is_dead:
		handle_ai(delta)
	
	move_and_slide()
	update_animation()

func handle_ai(_delta: float):
	if not player or not is_instance_valid(player):
		return
		
	var distance_to_player = global_position.distance_to(player.global_position)
	
	# Check if player is in detection range
	if distance_to_player <= DETECTION_DISTANCE:
		is_chasing = true
		
		# Check if player is in attack range
		if distance_to_player <= ATTACK_DISTANCE and attack_cooldown <= 0:
			attack_player()
		else:
			# Chase the player
			chase_player()
	else:
		is_chasing = false
		# Stop moving if not chasing
		velocity.x = move_toward(velocity.x, 0, SPEED)

func chase_player():
	if not player or not is_instance_valid(player) or is_attacking:
		return
		
	var direction = 1
	if player.global_position.x < global_position.x:
		direction = -1
	
	velocity.x = direction * SPEED
	
	# Flip sprite based on direction
	if animated_sprite_2d:
		animated_sprite_2d.flip_h = direction < 0

func attack_player():
	if is_attacking or attack_cooldown > 0:
		return
		
	if not player or not is_instance_valid(player):
		return
		
	is_attacking = true
	attack_cooldown = ATTACK_COOLDOWN_TIME
	velocity.x = 0  # Stop moving during attack
	
	# Play attack animation
	if animated_sprite_2d:
		animated_sprite_2d.play("attack")
		print("Venom playing ATTACK animation")
	
	# Wait for attack animation to reach damage frame
	await get_tree().create_timer(0.4).timeout  # Attack now plays at 12 fps
	
	# Deal damage to player at the right moment
	if player and is_instance_valid(player) and player.has_method("take_damage"):
		player.take_damage(2) # <--- الضرر 2
		print("Venom dealt damage to player!")
	
	# Wait for animation to complete
	await get_tree().create_timer(0.4).timeout
	is_attacking = false
	print("Venom attack finished")
	
	# التصحيح النهائي: إعادة تعيين السرعة يدوياً لضمان استئناف الحركة بعد الهجوم
	var direction = 1
	if player.global_position.x < global_position.x:
		direction = -1
	velocity.x = direction * SPEED

func update_animation():
	if not animated_sprite_2d:
		return
		
	# Don't change animation while attacking
	if is_attacking:
		return
		
	var is_moving = abs(velocity.x) > 0.1 # Check if the venom is actually moving
	
	if is_chasing and is_moving:
		if animated_sprite_2d.animation != "walk":
			animated_sprite_2d.play("walk")
	# تم إزالة حالة 'idle' كما طلبت، مما يعني أن العدو سيتوقف عن الرسوم المتحركة عندما لا يتحرك
	
# Health system
func take_damage(damage: int = 1):
	if is_dead:
		return
		
	current_health -= damage
	print("Venom took damage! Health: ", current_health)
	
	if current_health <= 0:
		die()

func die():
	if is_dead:
		return
		
	is_dead = true
	current_health = 0
	print("Venom died!")
	
	# Play death animation if available
	if animated_sprite_2d:
		animated_sprite_2d.play("death")
	
	# Remove venom after death animation
	await get_tree().create_timer(1.0).timeout
	queue_free()
