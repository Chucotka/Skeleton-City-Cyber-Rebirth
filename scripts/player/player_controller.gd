extends CharacterBody3D

## HD-2D Player Controller for Skeleton City: Cyber Rebirth
## Handles 2D movement, states, and combat for the Mechanized Skeleton.

enum State { IDLE, MOVE, JUMP, ATTACK, HURT, DEAD }

@export_group("Movement")
@export var speed: float = 5.0
@export var jump_velocity: float = 5.0
@export var acceleration: float = 20.0
@export var friction: float = 15.0

@export_group("Combat")
@export var attack_duration: float = 0.4
@export var attack_cooldown: float = 0.2

@export_group("Interaction")
@export var interaction_range: float = 2.0

@onready var sprite: Sprite3D = $Sprite3D
@onready var interaction_ray: RayCast3D = $InteractionRay
@onready var hitbox: Hitbox3D = $Hitbox3D

signal interaction_triggered(interactable: Node)
signal state_changed(new_state: State)

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var current_state: State = State.IDLE
var attack_timer: float = 0.0
var cooldown_timer: float = 0.0

func _ready() -> void:
	# Ensure Z-axis locking is enabled for HD-2D movement
	axis_lock_linear_z = true
	if hitbox:
		hitbox.monitoring = false

func _physics_process(delta: float) -> void:
	# Timers
	if attack_timer > 0:
		attack_timer -= delta
		if attack_timer <= 0:
			end_attack()

	if cooldown_timer > 0:
		cooldown_timer -= delta

	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle states
	match current_state:
		State.IDLE, State.MOVE, State.JUMP:
			handle_standard_movement(delta)
			if Input.is_action_just_pressed("attack") and cooldown_timer <= 0:
				start_attack()
		State.ATTACK:
			# Slow down or stop movement during attack
			velocity.x = move_toward(velocity.x, 0, friction * delta)

	# Safety: Force Z position to 0 to prevent drift
	global_position.z = 0

	move_and_slide()

	# Interaction check
	if Input.is_action_just_pressed("interact"):
		check_interaction()

func handle_standard_movement(delta: float) -> void:
	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		change_state(State.JUMP)

	# Get input direction
	var input_dir := Input.get_axis("move_left", "move_right")

	# Handle horizontal movement
	if input_dir != 0:
		velocity.x = move_toward(velocity.x, input_dir * speed, acceleration * delta)
		# Flip sprite, raycast, and hitbox based on direction
		sprite.flip_h = input_dir < 0
		interaction_ray.target_position.x = input_dir * interaction_range
		if hitbox:
			hitbox.position.x = abs(hitbox.position.x) * (1 if input_dir > 0 else -1)

		if is_on_floor():
			change_state(State.MOVE)
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		if is_on_floor():
			change_state(State.IDLE)

func change_state(new_state: State) -> void:
	if current_state == new_state:
		return
	current_state = new_state
	state_changed.emit(current_state)

func start_attack() -> void:
	change_state(State.ATTACK)
	attack_timer = attack_duration
	if hitbox:
		hitbox.monitoring = true
	print("Melee Attack Started")

func end_attack() -> void:
	if hitbox:
		hitbox.monitoring = false
	cooldown_timer = attack_cooldown
	if is_on_floor():
		change_state(State.IDLE)
	else:
		change_state(State.JUMP)
	print("Melee Attack Ended")

func check_interaction() -> void:
	if interaction_ray.is_colliding():
		var collider = interaction_ray.get_collider()
		if collider:
			var interactable = null
			if collider.has_method("interact"):
				interactable = collider
			elif collider.get_parent().has_method("interact"):
				interactable = collider.get_parent()

			if interactable:
				interactable.interact()
				interaction_triggered.emit(interactable)
				print("Interacted with: ", interactable.name)
