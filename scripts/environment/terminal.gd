extends Interactable

## Example Terminal Interactable

@export var terminal_name: String = "Main Terminal"

func _on_interact() -> void:
	print("Accessing terminal: ", terminal_name)
	# Logic for opening a door or revealing data
