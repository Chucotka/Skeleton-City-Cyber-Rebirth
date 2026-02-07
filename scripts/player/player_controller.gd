extends CharacterBody3D

## HD-2D Player Controller for Skeleton City: Cyber Rebirth
## Handles 2D movement in a 3D environment for the Mechanized Skeleton protagonist.

@export_group("Movement")
@export var speed: float = 5.0
@export var jump_velocity: float = 5.0
@export var acceleration: float = 20.0
@export var friction: float = 15.0

@export_group("Interaction")
@export var interaction_range: float = 2.0

@onready var sprite: Sprite3D = $Sprite3D
@onready var interaction_ray: RayCast3D = $InteractionRay

signal interaction_triggered(interactable: Node)

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	# Ensure Z-axis locking is enabled for HD-2D movement
	axis_lock_linear_z = true

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	# Get input direction
	var input_dir := Input.get_axis("ui_left", "ui_right")

	# Handle horizontal movement
	if input_dir != 0:
		velocity.x = move_toward(velocity.x, input_dir * speed, acceleration * delta)
		# Flip sprite and raycast based on direction
		sprite.flip_h = input_dir < 0
		interaction_ray.target_position.x = input_dir * interaction_range
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)

	# Safety: Force Z position to 0 to prevent drift
	global_position.z = 0

	move_and_slide()

	# Interaction check
	if Input.is_action_just_pressed("interact"):
		check_interaction()

func check_interaction() -> void:
	if interaction_ray.is_colliding():
		var collider = interaction_ray.get_collider()
		if collider:
			var interactable = null

			# Check for interact method on the collider or its parent
			if collider.has_method("interact"):
				interactable = collider
			elif collider.get_parent().has_method("interact"):
				interactable = collider.get_parent()

			if interactable:
				interactable.interact()
				interaction_triggered.emit(interactable)
				print("Interacted with: ", interactable.name)
			else:
				print("Object in range but not interactable: ", collider.name)
