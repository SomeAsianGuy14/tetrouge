class_name RunVictory
extends Control

const RunEndHelpers = preload("res://scenes/screens/run_end_helpers.gd")

@onready var header_label: Label = $Panel/ScrollContainer/VBox/HeaderLabel
@onready var coins_label: Label = $Panel/ScrollContainer/VBox/CoinsLabel
@onready var ascension_label: Label = $Panel/ScrollContainer/VBox/AscensionLabel
@onready var stats_container: VBoxContainer = $Panel/ScrollContainer/VBox/StatsContainer
@onready var build_container: VBoxContainer = $Panel/ScrollContainer/VBox/BuildContainer
@onready var restart_button: Button = $Panel/ScrollContainer/VBox/RestartButton
@onready var menu_button: Button = $Panel/ScrollContainer/VBox/MenuButton

func setup(run_stats: RunStats, pbs: Dictionary, final_coins: int, beaten_level: int) -> void:
	header_label.text = "Victory!\nAll 5 stages cleared."
	coins_label.text = "Final coins: %d" % final_coins
	var next_level := beaten_level + 1
	if next_level <= 6:
		ascension_label.text = "Ascension %d unlocked!" % next_level
	else:
		ascension_label.text = "All ascension levels cleared!"

	RunEndHelpers.add_stats_section(stats_container, run_stats, pbs)
	RunEndHelpers.add_build_section(build_container)

	restart_button.connect("pressed", _on_restart)
	menu_button.connect("pressed", _on_menu)

func _on_restart() -> void:
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
