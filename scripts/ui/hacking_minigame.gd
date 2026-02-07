extends Control

signal minigame_completed(success: bool)

@export var speed: float = 2.0
@export var success_zone_center: float = 0.5
@export var success_zone_width: float = 0.15

@onready var slider: ColorRect = $ProgressBar/Slider
@onready var progress_bar: Control = $ProgressBar
@onready var success_zone_ui: ColorRect = $ProgressBar/SuccessZone

var current_pos: float = 0.0
var direction: int = 1
var is_active: bool = false

func _ready() -> void:
	hide()
	# Set up success zone visual
	success_zone_ui.anchor_left = success_zone_center - (success_zone_width / 2.0)
	success_zone_ui.anchor_right = success_zone_center + (success_zone_width / 2.0)

func start() -> void:
	current_pos = 0.0
	direction = 1
	is_active = true
	show()

func _process(delta: float) -> void:
	if not is_active:
		return

	current_pos += speed * direction * delta
	if current_pos >= 1.0:
		current_pos = 1.0
		direction = -1
	elif current_pos <= 0.0:
		current_pos = 0.0
		direction = 1

	slider.anchor_left = current_pos - 0.01
	slider.anchor_right = current_pos + 0.01

func _input(event: InputEvent) -> void:
	if not is_active:
		return

	if event.is_action_pressed("ui_accept") or event.is_action_pressed("interact"):
		finish_game()

func finish_game() -> void:
	is_active = false
	var is_success = abs(current_pos - success_zone_center) <= (success_zone_width / 2.0)

	if is_success:
		print("Hack Success!")
	else:
		print("Hack Failed!")

	minigame_completed.emit(is_success)
	hide()
