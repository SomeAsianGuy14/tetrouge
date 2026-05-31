class_name KeystoneSelection
extends Control

signal keystone_chosen(keystone: Keystone)

@onready var options_container: HBoxContainer = $Panel/VBox/Options
@onready var title_label: Label = $Panel/VBox/Title

var _offered: Array = []
var starter_only: bool = false

func _ready() -> void:
	title_label.text = "Choose a Keystone"
	_offered = _draw_three_keystones()
	_populate_options()

func _draw_three_keystones() -> Array:
	var all_keystones := []
	for ks in ResourceRegistry.all_keystones:
		if ks.id not in RunState.used_keystone_ids:
			if ks.is_starter == starter_only:
				if ks.requires_keystone_id == "" or ks.requires_keystone_id in RunState.used_keystone_ids:
					all_keystones.append(ks)
	RunState.seeded_shuffle(all_keystones)
	return all_keystones.slice(0, 3)

func _populate_options() -> void:
	for child in options_container.get_children():
		child.queue_free()
	options_container.alignment = BoxContainer.ALIGNMENT_CENTER
	for keystone in _offered:
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(200, 180)
		btn.connect("pressed", _on_keystone_selected.bind(keystone))

		var vbox := VBoxContainer.new()
		vbox.anchor_right = 1.0
		vbox.anchor_bottom = 1.0
		vbox.offset_left = 8
		vbox.offset_top = 8
		vbox.offset_right = -8
		vbox.offset_bottom = -8
		vbox.alignment = BoxContainer.ALIGNMENT_BEGIN
		vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE

		var name_lbl := Label.new()
		name_lbl.text = keystone.display_name
		name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_lbl.add_theme_font_size_override("font_size", 16)
		name_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE

		var desc_lbl := Label.new()
		desc_lbl.text = keystone.description
		desc_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
		desc_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		desc_lbl.size_flags_vertical = Control.SIZE_EXPAND_FILL
		desc_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE

		vbox.add_child(name_lbl)
		vbox.add_child(desc_lbl)
		btn.add_child(vbox)
		options_container.add_child(btn)

func _on_keystone_selected(keystone: Keystone) -> void:
	RunState.add_keystone(keystone)
	hide()
	emit_signal("keystone_chosen", keystone)
	queue_free()
