extends Node
class_name IDamageable

## Base class (Interface) for objects that can receive damage in Skeleton City.

@export var max_health: float = 100.0
@onready var current_health: float = max_health

signal health_changed(new_health: float)
signal damaged(amount: float, impact_point: Vector3)
signal died()

func take_damage(amount: float, impact_point: Vector3 = Vector3.ZERO) -> void:
	current_health -= amount
	current_health = max(0, current_health)

	print(get_parent().name if get_parent() else name, " took ", amount, " damage. Health: ", current_health)

	damaged.emit(amount, impact_point)
	health_changed.emit(current_health)

	if current_health <= 0:
		die()

func die() -> void:
	print(get_parent().name if get_parent() else name, " died.")
	died.emit()
	# Default behavior: queue_free() or disable
