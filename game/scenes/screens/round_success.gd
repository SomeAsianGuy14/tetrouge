class_name RoundSuccess
extends Control

signal proceed

@onready var base_label: Label = $Panel/VBox/BaseLabel
@onready var speed_label: Label = $Panel/VBox/SpeedLabel
@onready var technique_label: Label = $Panel/VBox/TechniqueLabel
@onready var total_label: Label = $Panel/VBox/TotalLabel
@onready var proceed_button: Button = $Panel/VBox/ProceedButton

func setup(base_payout: int, speed_bonus: int, technique_income: int) -> void:
	base_label.text = "Base Payout:      +%d" % base_payout
	speed_label.text = "Speed Bonus:      +%d" % speed_bonus
	technique_label.text = "Technique Income: +%d" % technique_income
	total_label.text = "Total:            +%d" % (base_payout + speed_bonus + technique_income)
	proceed_button.connect("pressed", _on_proceed)

func _on_proceed() -> void:
	queue_free()
	emit_signal("proceed")
