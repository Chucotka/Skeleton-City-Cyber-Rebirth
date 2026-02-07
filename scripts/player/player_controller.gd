extends CharacterBody3D

## HD-2D Monolithic Player Controller: Skeleton City - Cyber Rebirth
## A unified script for Movement, Combat, Interactions, and Environment Auto-Setup.

# --- Parameters ---
@export_group("Physics")
@export var speed: float = 7.0
@export_range(0, 1000) var acceleration: float = 100.0
@export_range(0, 1000) var friction: float = 80.0
@export var jump_velocity: float = 11.0
@export var gravity: float = 30.0

@export_group("Combat")
@export var attack_range: float = 2.5
@export var attack_cooldown: float = 0.4
@export var attack_damage: float = 10.0
@export var spark_prefab: PackedScene = preload("res://scenes/prefabs/spark_particles.tscn")

@export_group("Interaction")
@export var interaction_range: float = 2.0

# --- Nodes ---
@onready var sprite: Sprite3D = get_node_or_null("Sprite3D")
@onready var anim_player: AnimationPlayer = get_node_or_null("AnimationPlayer")
@onready var interaction_ray: RayCast3D = get_node_or_null("InteractionRay")

# --- State ---
var is_attacking: bool = false
var can_attack: bool = true

func _ready() -> void:
	# Wait one frame to ensure nodes are fully initialized in the tree
	await get_tree().process_frame

	_initialize_hd2d_world()
	_configure_player_visuals()
	_setup_physics_constraints()

func _physics_process(delta: float) -> void:
	# 1. Apply Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# 2. Input Handling
	_handle_combat_input()
	_handle_interaction_input()

	# 3. Movement Logic (Blocked during attack for weight)
	if not is_attacking:
		_handle_movement(delta)
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)

	# 4. Z-Axis Lock (Crucial for 2.5D stability)
	velocity.z = 0
	global_position.z = 0

	move_and_slide()
	_update_visual_state()

func _handle_movement(delta: float) -> void:
	var input_dir := Input.get_axis("move_left", "move_right")
	if input_dir == 0: input_dir = Input.get_axis("ui_left", "ui_right")

	if input_dir != 0:
		velocity.x = move_toward(velocity.x, input_dir * speed, acceleration * delta)
		if sprite:
			sprite.flip_h = input_dir < 0
			# Orient interaction ray based on facing
			if interaction_ray:
				interaction_ray.target_position.x = sign(input_dir) * interaction_range
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)

	if (Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("ui_up")) and is_on_floor():
		velocity.y = jump_velocity

# --- Core Mechanics ---

func _handle_combat_input() -> void:
	# Triggered by Left Click, J key (as defined in project.godot), or ui_accept
	if (Input.is_action_just_pressed("attack") or Input.is_action_just_pressed("ui_accept")) and can_attack:
		perform_attack()

func _handle_interaction_input() -> void:
	if Input.is_action_just_pressed("interact") or Input.is_action_just_pressed("ui_focus_next"):
		if interaction_ray and interaction_ray.is_colliding():
			var collider = interaction_ray.get_collider()
			if collider.has_method("interact"):
				collider.interact()
			elif collider.get_parent().has_method("interact"):
				collider.get_parent().interact()

func perform_attack() -> void:
	is_attacking = true
	can_attack = false

	# Visual Feedback: Flash Red
	if sprite:
		var tween = create_tween()
		tween.tween_property(sprite, "modulate", Color.RED, 0.1)
		tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)

	if anim_player and anim_player.has_animation("attack"):
		anim_player.play("attack")

	# Hitbox Detection (Using Physics Space State)
	_execute_hitscan_attack()

	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true
	is_attacking = false

func _execute_hitscan_attack() -> void:
	var space_state = get_world_3d().direct_space_state
	var direction = -1.0 if (sprite and sprite.flip_h) else 1.0

	var start = global_position + Vector3(0, 1, 0)
	var end = start + Vector3(direction * attack_range, 0, 0)

	var query = PhysicsRayQueryParameters3D.create(start, end)
	query.exclude = [get_rid()]

	var result = space_state.intersect_ray(query)
	if result:
		var target = result.collider
		_spawn_sparks(result.position)

		# Damage target directly or via IDamageable child
		if target.has_method("take_damage"):
			target.take_damage(attack_damage)
		else:
			var damage_node = target.find_child("IDamageable")
			if damage_node and damage_node.has_method("take_damage"):
				damage_node.take_damage(attack_damage)

func _spawn_sparks(pos: Vector3) -> void:
	if spark_prefab:
		var sparks = spark_prefab.instantiate()
		get_parent().add_child(sparks)
		sparks.global_position = pos

# --- Visual & Setup Helpers ---

func _initialize_hd2d_world() -> void:
	# 1. Dark Atmosphere Setup
	var env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.01, 0.01, 0.03) # Cyberpunk Night
	env.glow_enabled = true
	env.glow_bloom = 0.15

	if get_viewport().world_3d:
		get_viewport().world_3d.environment = env

	# 2. Camera Snap
	var cam = get_viewport().get_camera_3d()
	if cam:
		cam.global_position = Vector3(global_position.x, global_position.y + 2, 10)
		cam.look_at(global_position + Vector3(0, 1.5, 0))

	# 3. Cleanup Directional Lights for moody aesthetic
	for child in get_tree().root.find_children("*", "DirectionalLight3D", true, false):
		child.queue_free()

func _configure_player_visuals() -> void:
	if sprite:
		sprite.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
		if sprite.texture == null:
			var default_tex = load("res://icon.svg")
			if default_tex:
				sprite.texture = default_tex
				print("Loaded default res://icon.svg")

func _setup_physics_constraints() -> void:
	axis_lock_linear_z = true
	axis_lock_angular_x = true
	axis_lock_angular_y = true
	axis_lock_angular_z = true

func _update_visual_state() -> void:
	if not anim_player: return
	if is_attacking: return

	if not is_on_floor():
		if velocity.y > 0:
			if anim_player.has_animation("jump"): anim_player.play("jump")
		else:
			if anim_player.has_animation("fall"): anim_player.play("fall")
	elif abs(velocity.x) > 0.1:
		if anim_player.has_animation("run"): anim_player.play("run")
	else:
		if anim_player.has_animation("idle"): anim_player.play("idle")
