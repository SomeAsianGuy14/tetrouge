extends GutTest

var _log: Node

var _saved_techniques: Array
var _saved_keystones: Array
var _saved_consumables: Array

func before_each() -> void:
	_saved_techniques = RunState.techniques.duplicate()
	_saved_keystones = RunState.keystones.duplicate()
	_saved_consumables = RunState.consumables.duplicate()
	RunState.techniques = []
	RunState.keystones = []
	RunState.consumables = []
	_log = preload("res://autoloads/damage_log.gd").new()
	_log._enabled = false
	add_child(_log)

func after_each() -> void:
	_log.queue_free()
	RunState.techniques = _saved_techniques
	RunState.keystones = _saved_keystones
	RunState.consumables = _saved_consumables

# ── 4.1 – Disabled state performs no I/O ─────────────────────────────────────

func test_disabled_log_attack_does_not_create_file() -> void:
	_log._enabled = false
	_log.log_attack(1, "Small", "quad", 4, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 0, 4)
	assert_null(_log._file, "no file should be opened when disabled")
	assert_eq(_log._round_sum_base, 0, "accumulators should stay at zero")

# ── 4.2 – log_attack accumulates round sums ──────────────────────────────────

func test_log_attack_accumulates_round_sums() -> void:
	_log._enabled = true
	if not DirAccess.dir_exists_absolute("user://damage_logs"):
		DirAccess.make_dir_absolute("user://damage_logs")
	_log._file = FileAccess.open("user://damage_logs/_test_accum.csv", FileAccess.WRITE)
	_log._reset_accumulators()

	_log.log_attack(1, "Small", "quad", 4, 2, 1, 0, 3, 0, 1.0, 1.5, 1.0, 0, 15)
	_log.log_attack(1, "Small", "single", 0, 0, 0, 1, 0, 0, 1.0, 1.0, 1.0, 0, 1)

	assert_eq(_log._round_sum_base, 4, "base should sum across attacks")
	assert_eq(_log._round_sum_technique, 2)
	assert_eq(_log._round_sum_mastery, 1)
	assert_eq(_log._round_sum_honed, 1)
	assert_eq(_log._round_sum_keystone_flat, 3)
	assert_eq(_log._round_sum_consumable_flat, 0)
	assert_eq(_log._round_sum_tag_bonus, 0)
	assert_eq(_log._round_sum_final, 16)

	_log._file.close()
	_log._file = null
	DirAccess.remove_absolute("user://damage_logs/_test_accum.csv")

# ── 4.3 – log_round_end resets accumulators and adds to run total ────────────

func test_log_round_end_resets_and_accumulates_run_total() -> void:
	_log._enabled = true
	if not DirAccess.dir_exists_absolute("user://damage_logs"):
		DirAccess.make_dir_absolute("user://damage_logs")
	_log._file = FileAccess.open("user://damage_logs/_test_round.csv", FileAccess.WRITE)
	_log._reset_accumulators()

	_log.log_attack(1, "Small", "quad", 4, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 0, 4)
	_log.log_round_end(1, "Small", 20, 45.0, 12)

	assert_eq(_log._run_total_damage, 4, "run total should include round final sum")
	assert_eq(_log._round_sum_base, 0, "round accumulators should reset")
	assert_eq(_log._round_sum_final, 0)

	_log._file.close()
	_log._file = null
	DirAccess.remove_absolute("user://damage_logs/_test_round.csv")

# ── 4.4 – log_run_end tracks correct total across multiple rounds ────────────

func test_log_run_end_correct_total_across_rounds() -> void:
	_log._enabled = true
	if not DirAccess.dir_exists_absolute("user://damage_logs"):
		DirAccess.make_dir_absolute("user://damage_logs")
	_log._file = FileAccess.open("user://damage_logs/_test_run.csv", FileAccess.WRITE)
	_log._reset_accumulators()

	_log.log_attack(1, "Small", "quad", 4, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 0, 10)
	_log.log_round_end(1, "Small", 20, 30.0, 8)

	_log.log_attack(1, "Big", "tspin_double", 4, 2, 0, 0, 0, 0, 1.0, 1.0, 1.0, 0, 6)
	_log.log_attack(1, "Big", "quad", 4, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 0, 4)
	_log.log_round_end(1, "Big", 32, 50.0, 15)

	assert_eq(_log._run_total_damage, 20, "run total should sum across both rounds")

	_log._file.close()
	_log._file = null
	DirAccess.remove_absolute("user://damage_logs/_test_run.csv")

# ── 4.5 – build_changed signal emitted from RunState mutations ──────────────

func test_build_changed_emitted_on_add_technique() -> void:
	var t := Technique.new()
	t.id = "test_tech"
	watch_signals(RunState)
	RunState.add_technique(t)
	assert_signal_emitted(RunState, "build_changed")
	RunState.techniques.erase(t)

func test_build_changed_emitted_on_remove_technique() -> void:
	var t := Technique.new()
	t.id = "test_tech"
	RunState.techniques.append(t)
	watch_signals(RunState)
	RunState.remove_technique(t)
	assert_signal_emitted(RunState, "build_changed")

func test_build_changed_emitted_on_add_keystone() -> void:
	var ks := Keystone.new()
	ks.id = "test_ks"
	ks.replaces_keystone_id = ""
	watch_signals(RunState)
	RunState.add_keystone(ks)
	assert_signal_emitted(RunState, "build_changed")
	RunState.keystones.erase(ks)

func test_build_changed_emitted_on_add_consumable() -> void:
	RunState.consumable_capacity = 3
	var c := Consumable.new()
	c.id = "test_con"
	watch_signals(RunState)
	RunState.add_consumable(c)
	assert_signal_emitted(RunState, "build_changed")
	RunState.consumables.erase(c)

func test_build_changed_emitted_on_remove_consumable() -> void:
	var c := Consumable.new()
	c.id = "test_con"
	RunState.consumables.append(c)
	watch_signals(RunState)
	RunState.remove_consumable(c)
	assert_signal_emitted(RunState, "build_changed")
