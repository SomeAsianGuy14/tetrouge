class_name DebuffDisplay
extends Control

var _burn_row: HBoxContainer
var _burn_label: Label
var _poison_row: HBoxContainer
var _poison_label: Label

func _ready() -> void:
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	add_child(vbox)

	_burn_row = _make_row(vbox, Color(0.9, 0.4, 0.05), "Burn")
	_burn_label = _burn_row.get_child(1)
	_burn_row.visible = false

	_poison_row = _make_row(vbox, Color(0.2, 0.7, 0.1), "Poison")
	_poison_label = _poison_row.get_child(1)
	_poison_row.visible = false

func _make_row(parent: VBoxContainer, color: Color, text: String) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)

	var icon := ColorRect.new()
	icon.custom_minimum_size = Vector2(12, 12)
	icon.color = color
	row.add_child(icon)

	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 12)
	lbl.modulate = color
	row.add_child(lbl)

	parent.add_child(row)
	return row

func update_debuffs(burn_active: bool, burn_remaining: float, poison_active: bool, poison_remaining: float) -> void:
	_burn_row.visible = burn_active
	if burn_active:
		if burn_remaining < 0.0:
			_burn_label.text = "Burn"
		else:
			_burn_label.text = "Burn %ds" % ceili(burn_remaining)

	_poison_row.visible = poison_active
	if poison_active:
		if poison_remaining < 0.0:
			_poison_label.text = "Poison"
		else:
			_poison_label.text = "Poison %ds" % ceili(poison_remaining)
