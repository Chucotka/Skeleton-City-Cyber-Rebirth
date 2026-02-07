extends Node3D

@export var is_locked: bool = true
@onready var anim_player: AnimationPlayer = get_node_or_null("AnimationPlayer")

func unlock() -> void:
	is_locked = false
	print("Door unlocked!")
	open()

func open() -> void:
	if is_locked:
		print("Door is locked.")
		return

	print("Opening door...")
	if anim_player:
		anim_player.play("open")
	else:
		# Fallback: simple movement or hide
		hide()
		set_process_mode(PROCESS_MODE_DISABLED)
