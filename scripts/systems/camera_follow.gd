extends Camera3D

## Smooth Camera Follow for HD-2D Platformer
## Follows a target on the X and Y axes while maintaining a fixed Z distance.

@export_group("Target")
@export var target_path: NodePath
@export var smooth_speed: float = 5.0
@export var offset: Vector3 = Vector3(0, 2, 8)

var target: Node3D

func _ready() -> void:
	if target_path:
		target = get_node(target_path)

	# Initial position
	if target:
		global_position = target.global_position + offset

func _physics_process(delta: float) -> void:
	if not target:
		return

	# Calculate target position based on player's X/Y and fixed offset Z
	var target_pos = target.global_position + offset

	# Use lerp for smooth interpolation
	# We use physics_process to stay in sync with character movement
	global_position.x = lerp(global_position.x, target_pos.x, smooth_speed * delta)
	global_position.y = lerp(global_position.y, target_pos.y, smooth_speed * delta)

	# Z remains fixed to the offset value to maintain the HD-2D perspective depth
	global_position.z = offset.z
