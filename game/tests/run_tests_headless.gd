extends Node

func _ready() -> void:
	var gut: Node = load("res://addons/gut/gut.gd").new()
	gut.log_level = 1
	add_child(gut)
	gut.add_directory("res://tests/unit/")
	gut.test_scripts()
	await gut.end_run
	get_tree().quit(gut.get_fail_count())
