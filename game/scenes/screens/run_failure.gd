class_name RunFailure
extends Control

const RunEndHelpers = preload("res://scenes/screens/run_end_helpers.gd")

@onready var location_label: Label = $Panel/ScrollContainer/VBox/LocationLabel
@onready var stats_container: VBoxContainer = $Panel/ScrollContainer/VBox/StatsContainer
@onready var build_container: VBoxContainer = $Panel/ScrollContainer/VBox/BuildContainer
@onready var restart_button: Button = $Panel/ScrollContainer/VBox/RestartButton
@onready var menu_button: Button = $Panel/ScrollContainer/VBox/MenuButton

func setup(run_stats: RunStats, pbs: Dictionary, floor: int) -> void:
	location_label.text = "Floor %d — Failed to defeat the enemy in time." % floor

	RunEndHelpers.add_stats_section(stats_container, run_stats, pbs)
	RunEndHelpers.add_build_section(build_container)

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
