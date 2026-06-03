class_name RoundSuccess
extends Control

signal proceed

@onready var base_label: Label = $Panel/VBox/BaseLabel
@onready var speed_label: Label = $Panel/VBox/SpeedLabel
@onready var technique_label: Label = $Panel/VBox/TechniqueLabel
@onready var total_label: Label = $Panel/VBox/TotalLabel
@onready var proceed_button: Button = $Panel/VBox/ProceedButton

func setup(base_payout: int) -> void:
	base_label.text = "Payout: +%d" % base_payout
	speed_label.visible = false
	technique_label.visible = false
	total_label.visible = false
	proceed_button.connect("pressed", _on_proceed)

func _on_proceed() -> void:
	emit_signal("proceed")
	queue_free()
