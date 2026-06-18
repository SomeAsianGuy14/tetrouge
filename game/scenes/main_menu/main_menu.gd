class_name MainMenu
extends Control

@onready var continue_button: Button = $Panel/VBox/ContinueButton
@onready var new_run_button: Button = $Panel/VBox/NewRunButton
@onready var stats_button: Button = $Panel/VBox/StatsButton
@onready var settings_button: Button = $Panel/VBox/SettingsButton
@onready var quit_button: Button = $Panel/VBox/QuitButton

func _ready() -> void:
	continue_button.visible = RunSave.exists()
	continue_button.connect("pressed", _on_continue)
	new_run_button.connect("pressed", _on_new_run)
	stats_button.connect("pressed", _on_stats)
	settings_button.connect("pressed", _on_settings)
	quit_button.connect("pressed", _on_quit)

func _on_continue() -> void:
	if not RunSave.load_into_state():
		continue_button.visible = false
		return
	var run_scene: PackedScene = load("res://scenes/game/run_manager.tscn")
	var run := run_scene.instantiate()
	get_tree().root.add_child(run)
	queue_free()
	run.continue_run()

func _on_new_run() -> void:
	RunSave.delete()
	if ProfileSave.highest_beaten >= 0:
		var selector_scene: PackedScene = load("res://scenes/screens/ascension_selector.tscn")
		var selector = selector_scene.instantiate()
		add_child(selector)
		selector.connect("level_selected", _on_ascension_selected)
	else:
		_start_run(0)

func _on_ascension_selected(level: int) -> void:
	_start_run(level)

func _start_run(level: int) -> void:
	AscensionManager.current_level = level
	var run_scene: PackedScene = load("res://scenes/game/run_manager.tscn")
	var run := run_scene.instantiate()
	get_tree().root.add_child(run)
	queue_free()
	run.start_run()

func _on_stats() -> void:
	var stats_scene: PackedScene = load("res://scenes/screens/stats_screen.tscn")
	add_child(stats_scene.instantiate())

func _on_settings() -> void:
	var settings_scene: PackedScene = load("res://scenes/screens/settings.tscn")
	add_child(settings_scene.instantiate())

func _on_quit() -> void:
	get_tree().quit()
