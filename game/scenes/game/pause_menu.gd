class_name PauseMenu
extends Control

const SCENE_SETTINGS := "res://scenes/screens/settings.tscn"

@onready var resume_button: Button = $CenterContainer/VBox/ResumeButton
@onready var settings_button: Button = $CenterContainer/VBox/SettingsButton
@onready var quit_button: Button = $CenterContainer/VBox/QuitButton

signal resume_requested
signal quit_requested

func _ready() -> void:
	resume_button.connect("pressed", func(): emit_signal("resume_requested"))
	settings_button.connect("pressed", _on_settings_pressed)
	quit_button.connect("pressed", func(): emit_signal("quit_requested"))

func _on_settings_pressed() -> void:
	var settings_scene: PackedScene = load(SCENE_SETTINGS)
	var settings := settings_scene.instantiate()
	add_child(settings)
	settings_button.disabled = true
	settings.connect("tree_exited", func(): settings_button.disabled = false)
