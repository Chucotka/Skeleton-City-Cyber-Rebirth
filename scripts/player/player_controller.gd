extends CharacterBody3D

## HD-2D Player Controller for Skeleton City: Cyber Rebirth
## A robust platformer controller handling 2D movement in a 3D world.

# --- Signals ---
signal state_changed(new_state: State)
signal interaction_triggered(interactable: Node)

# --- Enums ---
enum State { IDLE, MOVE, JUMP, ATTACK, HURT, DEAD }

# --- Export Variables ---
@export_group("Movement Parameters")
@export var speed: float = 7.0
@export var acceleration: float = 100.0
@export var friction: float = 80.0
@export var jump_velocity: float = 11.0
@export var gravity: float = 30.0

@export_group("Combat & Interaction")
@export var attack_duration: float = 0.4
@export var interaction_range: float = 2.0

@export_group("Node References")
@export var sprite_path: NodePath = "Sprite3D"
@export var animation_player_path: NodePath = "AnimationPlayer"
@export var ray_path: NodePath = "InteractionRay"
@export var hitbox_path: NodePath = "Hitbox3D"

# --- Onready Variables ---
@onready var sprite: Sprite3D = get_node_or_null(sprite_path)
@onready var anim_player: AnimationPlayer = get_node_or_null(animation_player_path)
@onready var interaction_ray: RayCast3D = get_node_or_null(ray_path)
@onready var hitbox: Hitbox3D = get_node_or_null(hitbox_path)
@onready var interaction_prompt: Control = get_node_or_null("UI/InteractionPrompt")

# --- Internal Variables ---
var current_state: State = State.IDLE
var attack_timer: float = 0.0

func _ready() -> void:
	# Constraints: Ensure we are locked to the X/Y plane.
	axis_lock_linear_z = true
	axis_lock_angular_x = true
	axis_lock_angular_y = true
	axis_lock_angular_z = true

	if hitbox:
		hitbox.monitoring = false

func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_update_timers(delta)

	match current_state:
		State.ATTACK:
			_handle_attack_state(delta)
		_:
			_handle_movement_state(delta)

	# Enforce 2D plane safety (Z-Lock)
	velocity.z = 0
	global_position.z = 0

	move_and_slide()

	_update_interactions()
	_update_animation()

# --- Internal Methods ---

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

func _update_timers(delta: float) -> void:
	if attack_timer > 0:
		attack_timer -= delta
		if attack_timer <= 0:
			_end_attack()

func _handle_movement_state(delta: float) -> void:
	# Jump Input
	if (Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("ui_accept")) and is_on_floor():
		velocity.y = jump_velocity
		_change_state(State.JUMP)

	# Combat Input
	if Input.is_action_just_pressed("attack"):
		_start_attack()
		return

	# Horizontal Movement
	var input_dir := Input.get_axis("move_left", "move_right")
	if input_dir == 0:
		input_dir = Input.get_axis("ui_left", "ui_right")

	if input_dir != 0:
		velocity.x = move_toward(velocity.x, input_dir * speed, acceleration * delta)
		_flip_character(input_dir)
		if is_on_floor():
			_change_state(State.MOVE)
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		if is_on_floor():
			_change_state(State.IDLE)

func _handle_attack_state(delta: float) -> void:
	# Reduce horizontal momentum during attack
	velocity.x = move_toward(velocity.x, 0, friction * delta)

func _start_attack() -> void:
	_change_state(State.ATTACK)
	attack_timer = attack_duration
	if hitbox:
		hitbox.monitoring = true
	print("Attack initiated")

func _end_attack() -> void:
	if hitbox:
		hitbox.monitoring = false
	_change_state(State.IDLE if is_on_floor() else State.JUMP)

func _flip_character(dir: float) -> void:
	if sprite:
		sprite.flip_h = dir < 0

	# Orient interaction ray and hitbox
	if interaction_ray:
		interaction_ray.target_position.x = sign(dir) * interaction_range
	if hitbox:
		hitbox.position.x = sign(dir) * abs(hitbox.position.x)

func _change_state(new_state: State) -> void:
	if current_state == new_state:
		return
	current_state = new_state
	state_changed.emit(current_state)

func _update_animation() -> void:
	if not anim_player:
		return

	match current_state:
		State.IDLE:
			anim_player.play("idle")
		State.MOVE:
			anim_player.play("run")
		State.JUMP:
			if velocity.y > 0:
				anim_player.play("jump")
			else:
				anim_player.play("fall")
		State.ATTACK:
			anim_player.play("attack")
		State.HURT:
			anim_player.play("hurt")
		State.DEAD:
			anim_player.play("dead")

func _update_interactions() -> void:
	if not interaction_ray:
		return

	var is_near_interactable = false
	if interaction_ray.is_colliding():
		var collider = interaction_ray.get_collider()
		var interactable = _find_interactable(collider)
		if interactable:
			is_near_interactable = true
			if interaction_prompt:
				interaction_prompt.display("Press E to " + interactable.interact_text)

			if Input.is_action_just_pressed("interact"):
				interactable.interact()
				interaction_triggered.emit(interactable)

	if not is_near_interactable and interaction_prompt:
		interaction_prompt.dismiss()

func _find_interactable(node: Node) -> Node:
	if not node: return null
	if node.has_method("interact"): return node
	if node.get_parent() and node.get_parent().has_method("interact"): return node.get_parent()
	return null
