extends Interactable

## Terminal that triggers a hacking minigame.

@export var linked_object: Node3D # Door or terminal to unlock
@export var alarm_light: OmniLight3D

var hacking_ui: Control

func _ready() -> void:
	interact_text = "Hack"
	# Find hacking UI - ideally this would be injected or globally accessible
	# For now, we search in the current scene's UI layer
	hacking_ui = get_tree().root.find_child("HackingMinigame", true, false)

func _on_interact() -> void:
	if hacking_ui:
		if not hacking_ui.is_connected("minigame_completed", _on_hacking_completed):
			hacking_ui.minigame_completed.connect(_on_hacking_completed, CONNECT_ONE_SHOT)
		hacking_ui.start()
	else:
		push_error("Hacking UI not found in scene!")

func _on_hacking_completed(success: bool) -> void:
	if success:
		_handle_success()
	else:
		_handle_failure()

func _handle_success() -> void:
	print("Terminal successfully hacked!")
	if linked_object and linked_object.has_method("unlock"):
		linked_object.unlock()
	# Disable this terminal
	is_enabled = false
	interact_text = "Hacked"

func _handle_failure() -> void:
	print("Hack failed! Security alert triggered.")
	if alarm_light:
		alarm_light.light_color = Color(1, 0, 0)
		alarm_light.light_energy = 10.0
		# In a real game, you would trigger a sound and possibly enemies
