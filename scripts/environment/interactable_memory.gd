extends Interactable

## Interactable object that gives the player a Memory Fragment.

@export var memory_data: MemoryFragment

func _on_interact() -> void:
	if memory_data:
		MemoryManager.collect_memory(memory_data)
		# Deactivate after collection
		is_enabled = false
		# In a real game, you might want to play an animation or destroy the object
		hide()
	else:
		push_warning("InteractableMemory has no memory data assigned!")
