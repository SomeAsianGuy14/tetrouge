extends SceneTree

func _init() -> void:
	var gut = load("res://addons/gut/gut.gd").new()
	root.add_child(gut)
	gut.log_level = 1
	gut.add_directory("res://tests/unit/")
	await gut.test_scripts_async()
	quit(gut.get_fail_count())
