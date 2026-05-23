class_name RunFailure
extends Control

@onready var message_label: Label = $Panel/VBox/MessageLabel
@onready var restart_button: Button = $Panel/VBox/RestartButton
@onready var menu_button: Button = $Panel/VBox/MenuButton

func setup(ante: int, round_index: int) -> void:
	message_label.text = "Run ended at Stage %d — %s\n\nQuota not met in time." % [ante, RunState.ROUND_NAMES[round_index]]
	restart_button.connect("pressed", _on_restart)
	menu_button.connect("pressed", _on_menu)

func _on_restart() -> void:
	RunSave.delete()
	var run_scene: PackedScene = load("res://scenes/game/run_manager.tscn")
	var run := run_scene.instantiate()
	get_tree().root.add_child(run)
	get_parent().queue_free()
	run.start_run()

func _on_menu() -> void:
	RunState.reset()
	Economy.reset()
	var scene: PackedScene = load("res://scenes/main_menu/main_menu.tscn")
	get_tree().root.add_child(scene.instantiate())
	get_parent().queue_free()
