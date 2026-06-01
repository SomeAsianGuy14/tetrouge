class_name RunVictory
extends Control

@onready var message_label: Label = $Panel/VBox/MessageLabel
@onready var coins_label: Label = $Panel/VBox/CoinsLabel
@onready var ascension_label: Label = $Panel/VBox/AscensionLabel
@onready var restart_button: Button = $Panel/VBox/RestartButton
@onready var menu_button: Button = $Panel/VBox/MenuButton

func setup(final_coins: int, beaten_level: int) -> void:
	message_label.text = "Victory!\nAll 5 stages cleared."
	coins_label.text = "Final coins: %d" % final_coins
	var next_level := beaten_level + 1
	if next_level <= 6:
		ascension_label.text = "Ascension %d unlocked!" % next_level
	else:
		ascension_label.text = "All ascension levels cleared!"
	restart_button.connect("pressed", _on_restart)
	menu_button.connect("pressed", _on_menu)

func _on_restart() -> void:
	get_tree().change_scene_to_file("res://scenes/game/run_manager.tscn")

func _on_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")
