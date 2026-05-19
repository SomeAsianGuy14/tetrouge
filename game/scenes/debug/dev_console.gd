class_name DevConsole
extends CanvasLayer

@onready var panel: PanelContainer = $Panel
@onready var log_label: RichTextLabel = $Panel/VBox/LogLabel
@onready var cmd_input: LineEdit = $Panel/VBox/CmdInput

var run_manager = null   # set by RunManager after instantiation
var _log_lines: Array[String] = []
const MAX_LOG_LINES := 20

func _ready() -> void:
	panel.visible = false
	layer = 20
	cmd_input.connect("text_submitted", _on_command_submitted)

func set_run_manager(rm) -> void:
	run_manager = rm

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_F1:
			_toggle()
			get_viewport().set_input_as_handled()

func _toggle() -> void:
	panel.visible = not panel.visible
	if panel.visible:
		cmd_input.grab_focus()
		if run_manager and run_manager.current_board:
			run_manager.current_board.set_process_input(false)
	else:
		if run_manager and run_manager.current_board:
			run_manager.current_board.set_process_input(true)

func _on_command_submitted(text: String) -> void:
	cmd_input.clear()
	text = text.strip_edges()
	if text.is_empty():
		return
	_log("> " + text)
	_dispatch(text)

func _dispatch(text: String) -> void:
	var parts: PackedStringArray = text.split(" ", false)
	if parts.is_empty():
		return
	var cmd: String = parts[0].to_lower()
	var args: PackedStringArray = parts.slice(1)

	match cmd:
		"help":
			_cmd_help()
		"skip_round":
			_cmd_skip_round()
		"set_stage":
			_cmd_set_stage(args)
		"add_coins":
			_cmd_add_coins(args)
		"give_keystone":
			_cmd_give_keystone(args)
		"give_technique":
			_cmd_give_technique(args)
		"insert_garbage":
			_cmd_insert_garbage(args)
		"set_quota":
			_cmd_set_quota(args)
		_:
			_log("Unknown command: %s. Type 'help' for commands." % cmd)

# ── Commands ──────────────────────────────────────────────────────────────

func _cmd_help() -> void:
	_log("Available commands:")
	_log("  help                  — show this list")
	_log("  skip_round            — end current round as success")
	_log("  set_stage <n>         — set current stage (1-5)")
	_log("  add_coins <n>         — add n coins to balance")
	_log("  give_keystone <id>    — activate a keystone by id")
	_log("  give_technique <id>   — activate a technique by id")
	_log("  insert_garbage <n>    — insert n garbage rows into board")
	_log("  set_quota <n>         — set current round quota to n")

func _cmd_skip_round() -> void:
	if run_manager:
		_toggle()  # close console first so board input is restored
		run_manager._end_round(true)
		_log("Round skipped.")
	else:
		_log("Error: no active run.")

func _cmd_set_stage(args: PackedStringArray) -> void:
	if args.is_empty() or not args[0].is_valid_int():
		_log("Usage: set_stage <1-5>")
		return
	var n: int = clampi(int(args[0]), 1, 5)
	RunState.stage = n
	_log("Stage set to %d." % n)

func _cmd_add_coins(args: PackedStringArray) -> void:
	if args.is_empty() or not args[0].is_valid_int():
		_log("Usage: add_coins <n>")
		return
	var n: int = int(args[0])
	Economy.add_coins(n)
	_log("Added %d coins. Balance: %d" % [n, Economy.coins])

func _cmd_give_keystone(args: PackedStringArray) -> void:
	if args.is_empty():
		_log("Usage: give_keystone <id>")
		return
	var id := args[0]
	var ks := _find_resource("res://resources/data/keystones/", id)
	if ks == null:
		_log("Keystone not found: " + id)
		return
	RunState.add_keystone(ks)
	_log("Keystone '%s' activated." % ks.display_name)

func _cmd_give_technique(args: PackedStringArray) -> void:
	if args.is_empty():
		_log("Usage: give_technique <id>")
		return
	var id := args[0]
	var t := _find_resource("res://resources/data/techniques/", id)
	if t == null:
		_log("Technique not found: " + id)
		return
	RunState.add_technique(t)
	_log("Technique '%s' activated." % t.display_name)

func _cmd_insert_garbage(args: PackedStringArray) -> void:
	if args.is_empty() or not args[0].is_valid_int():
		_log("Usage: insert_garbage <n>")
		return
	var n: int = int(args[0])
	if run_manager == null or run_manager.current_board == null:
		_log("Error: no active board.")
		return
	for _i in n:
		run_manager.current_board.insert_garbage_row()
	_log("Inserted %d garbage row(s)." % n)

func _cmd_set_quota(args: PackedStringArray) -> void:
	if args.is_empty() or not args[0].is_valid_int():
		_log("Usage: set_quota <n>")
		return
	var n: int = int(args[0])
	if run_manager == null or run_manager.current_config == null:
		_log("Error: no active round config.")
		return
	run_manager.current_config.quota = n
	_log("Quota set to %d." % n)

# ── Helpers ───────────────────────────────────────────────────────────────

func _find_resource(dir_path: String, id: String) -> Resource:
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return null
	dir.list_dir_begin()
	var f := dir.get_next()
	while f != "":
		if f.ends_with(".tres"):
			var res: Resource = load(dir_path + f)
			if res and res.get("id") == id:
				return res
		f = dir.get_next()
	return null

func _log(line: String) -> void:
	_log_lines.append(line)
	if _log_lines.size() > MAX_LOG_LINES:
		_log_lines.pop_front()
	log_label.text = "\n".join(_log_lines)
	log_label.scroll_to_line(log_label.get_line_count())
