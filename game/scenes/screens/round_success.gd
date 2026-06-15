class_name RoundSuccess
extends Control

signal proceed

@onready var base_label: Label = $Panel/VBox/BaseLabel
@onready var technique_label: Label = $Panel/VBox/TechniqueLabel
@onready var enhancement_label: Label = $Panel/VBox/EnhancementLabel
@onready var total_label: Label = $Panel/VBox/TotalLabel
@onready var proceed_button: Button = $Panel/VBox/ProceedButton

func setup(base_payout: int, technique_income: int, enhancement_income: int) -> void:
	base_label.text = "Base Payout:      +%d" % base_payout

	technique_label.text = "Tech/Keystone:    +%d" % technique_income
	technique_label.visible = technique_income != 0

	enhancement_label.text = "Enhancements:     +%d" % enhancement_income
	enhancement_label.visible = enhancement_income != 0

	var total := base_payout + technique_income + enhancement_income
	total_label.text = "Total:            +%d" % total

	proceed_button.connect("pressed", _on_proceed)

func _on_proceed() -> void:
	emit_signal("proceed")
	queue_free()
