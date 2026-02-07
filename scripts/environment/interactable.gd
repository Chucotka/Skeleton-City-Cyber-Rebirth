extends Node3D
class_name Interactable

## Base class for interactable objects in Skeleton City.
## Can be attached to StaticBody3D, Area3D, or a parent Node3D.

signal interacted(body: Node3D)

@export var interact_text: String = "Interact"
@export var is_enabled: bool = true

func interact() -> void:
	if not is_enabled:
		return

	print("Interacting with ", name)
	interacted.emit(self)
	_on_interact()

## To be overridden by subclasses
func _on_interact() -> void:
	pass
