extends SceneTree

func _init() -> void:
	# When run via `--script` the project autoloads are not added automatically.
	# Bootstrap them manually if they're absent so all test files can compile.
	if not root.has_node("RunState"):
		_bootstrap_autoloads()

	var gut = load("res://addons/gut/gut.gd").new()
	root.add_child(gut)
	gut.log_level = 1
	gut.add_directory("res://tests/unit/")
	gut.test_scripts()
	await gut.end_run
	quit(gut.get_fail_count())

func _bootstrap_autoloads() -> void:
	var defs := [
		["Economy",          "res://autoloads/economy.gd"],
		["RunState",         "res://autoloads/run_state.gd"],
		["ResourceRegistry", "res://autoloads/resource_registry.gd"],
		["ProfileSave",      "res://scripts/profile_save.gd"],
		["AscensionManager", "res://autoloads/ascension_manager.gd"],
		# DevConsole is a scene-based debug UI; tests never reference it directly.
	]
	for al in defs:
		var node: Node = load(al[1]).new()
		node.name = al[0]
		root.add_child(node)
