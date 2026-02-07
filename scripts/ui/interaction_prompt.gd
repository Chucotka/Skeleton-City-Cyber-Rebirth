extends Control

@onready var label: Label = $Label

func _ready() -> void:
	hide()

func display(text: String) -> void:
	label.text = text
	show()

func dismiss() -> void:
	hide()
