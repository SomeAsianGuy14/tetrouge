class_name MainMenu
extends Control

@onready var new_run_button: Button = $Panel/VBox/NewRunButton
@onready var settings_button: Button = $Panel/VBox/SettingsButton
@onready var quit_button: Button = $Panel/VBox/QuitButton

func _ready() -> void:
	new_run_button.connect("pressed", _on_new_run)
	settings_button.connect("pressed", _on_settings)
	quit_button.connect("pressed", _on_quit)

func _on_new_run() -> void:
	var run_scene: PackedScene = load("res://scenes/game/run_manager.tscn")
	var run := run_scene.instantiate()
	get_tree().root.add_child(run)
	queue_free()
	run.start_run()

func _on_settings() -> void:
	var settings_scene: PackedScene = load("res://scenes/screens/settings.tscn")
	add_child(settings_scene.instantiate())

func _on_quit() -> void:
	get_tree().quit()
