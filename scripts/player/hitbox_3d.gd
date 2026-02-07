extends Area3D
class_name Hitbox3D

## Hitbox for melee attacks. Detects IDamageable objects and spawns spark particles.

@export var damage: float = 20.0
@export var spark_prefab: PackedScene = preload("res://scenes/prefabs/spark_particles.tscn")

func _ready() -> void:
	# Start disabled, will be enabled by animations or state machine
	monitoring = false
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)

func _on_area_entered(area: Area3D) -> void:
	_check_damageable(area)

func _on_body_entered(body: Node3D) -> void:
	_check_damageable(body)

func _check_damageable(target: Node) -> void:
	# Calculate impact point
	var impact_point = target.global_position if target is Node3D else global_position

	var damageable = _find_damageable(target)
	if damageable:
		damageable.take_damage(damage, impact_point)

	# Always spawn sparks for visual feedback, even for walls
	spawn_sparks(impact_point)

func _find_damageable(node: Node) -> IDamageable:
	# Check children for IDamageable
	for child in node.get_children():
		if child is IDamageable:
			return child
	# Check if node itself is IDamageable
	if node is IDamageable:
		return node
	# Check parent if it's a component-like structure
	if node.get_parent() is IDamageable:
		return node.get_parent()
	return null

func spawn_sparks(pos: Vector3) -> void:
	if spark_prefab:
		var sparks = spark_prefab.instantiate()
		get_tree().root.add_child(sparks)
		sparks.global_position = pos
		if sparks is GPUParticles3D or sparks is CPUParticles3D:
			sparks.emitting = true
			# Auto-free after emission is done if configured in prefab
