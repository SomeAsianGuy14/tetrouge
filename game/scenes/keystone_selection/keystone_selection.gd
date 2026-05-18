class_name KeystoneSelection
extends Control

signal keystone_chosen(keystone: Keystone)

@onready var options_container: HBoxContainer = $Panel/VBox/Options
@onready var title_label: Label = $Panel/VBox/Title

var _offered: Array = []

func _ready() -> void:
	title_label.text = "Choose a Keystone"
	_offered = _draw_three_keystones()
	_populate_options()

func _draw_three_keystones() -> Array:
	var dir := DirAccess.open("res://resources/data/keystones/")
	var all_keystones := []
	if dir:
		dir.list_dir_begin()
		var f := dir.get_next()
		while f != "":
			if f.ends_with(".tres"):
				var ks: Keystone = load("res://resources/data/keystones/" + f)
				if ks and ks.id not in RunState.used_keystone_ids:
					all_keystones.append(ks)
			f = dir.get_next()
	all_keystones.shuffle()
	return all_keystones.slice(0, 3)

func _populate_options() -> void:
	for child in options_container.get_children():
		child.queue_free()
	for keystone in _offered:
		var btn := Button.new()
		btn.text = "%s\n%s" % [keystone.display_name, keystone.description]
		btn.custom_minimum_size = Vector2(260, 120)
		btn.connect("pressed", _on_keystone_selected.bind(keystone))
		options_container.add_child(btn)

func _on_keystone_selected(keystone: Keystone) -> void:
	RunState.add_keystone(keystone)
	queue_free()
	emit_signal("keystone_chosen", keystone)
