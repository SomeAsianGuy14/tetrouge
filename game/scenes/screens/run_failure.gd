class_name RunFailure
extends Control

@onready var message_label: Label = $Panel/VBox/MessageLabel
@onready var restart_button: Button = $Panel/VBox/RestartButton
@onready var menu_button: Button = $Panel/VBox/MenuButton

func setup(ante: int, round_index: int) -> void:
	message_label.text = "Run ended at Ante %d — %s\n\nQuota not met in time." % [ante, RunState.ROUND_NAMES[round_index]]
	restart_button.connect("pressed", _on_restart)
	menu_button.connect("pressed", _on_menu)

func _on_restart() -> void:
	get_tree().change_scene_to_file("res://scenes/game/run_manager.tscn")

func _on_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")
