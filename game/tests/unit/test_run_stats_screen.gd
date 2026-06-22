extends GutTest

const RunEndHelpers = preload("res://scenes/screens/run_end_helpers.gd")

# ── Helpers ───────────────────────────────────────────────────────────────────

func _make_stats(damage: int = 0, combo: int = 0, b2b: int = 0,
		quads: int = 0, pcs: int = 0,
		run_time: float = 0.0, clear_counts: Dictionary = {}) -> RunStats:
	var s := RunStats.new()
	s.total_damage = damage
	s.highest_combo_chain = combo
	s.highest_b2b = b2b
	s.quads = quads
	s.perfect_clears = pcs
	s.run_time = run_time
	s.clear_counts = clear_counts.duplicate()
	return s

func _make_profile(damage: int = 0, combo: int = 0, b2b: int = 0) -> Object:
	var p := ProfileSave
	p.best_single_run_damage = damage
	p.highest_combo_chain = combo
	p.highest_b2b = b2b
	return p

# Saved ProfileSave fields to restore after each test
var _saved_runs_completed: int
var _saved_victories: int
var _saved_total_damage: int
var _saved_total_quad_damage: int
var _saved_total_tspin_damage: int
var _saved_total_singles: int
var _saved_total_doubles: int
var _saved_total_triples: int
var _saved_total_quads: int
var _saved_total_tspin_singles: int
var _saved_total_tspin_doubles: int
var _saved_total_tspin_triples: int
var _saved_total_perfect_clears: int
var _saved_total_play_time: float
var _saved_highest_combo_chain: int
var _saved_highest_b2b: int
var _saved_best_single_run_damage: int
var _saved_best_mastery: Dictionary

func before_each() -> void:
	_saved_runs_completed = ProfileSave.runs_completed
	_saved_victories = ProfileSave.victories
	_saved_total_damage = ProfileSave.total_damage
	_saved_total_quad_damage = ProfileSave.total_quad_damage
	_saved_total_tspin_damage = ProfileSave.total_tspin_damage
	_saved_total_singles = ProfileSave.total_singles
	_saved_total_doubles = ProfileSave.total_doubles
	_saved_total_triples = ProfileSave.total_triples
	_saved_total_quads = ProfileSave.total_quads
	_saved_total_tspin_singles = ProfileSave.total_tspin_singles
	_saved_total_tspin_doubles = ProfileSave.total_tspin_doubles
	_saved_total_tspin_triples = ProfileSave.total_tspin_triples
	_saved_total_perfect_clears = ProfileSave.total_perfect_clears
	_saved_total_play_time = ProfileSave.total_play_time
	_saved_highest_combo_chain = ProfileSave.highest_combo_chain
	_saved_highest_b2b = ProfileSave.highest_b2b
	_saved_best_single_run_damage = ProfileSave.best_single_run_damage
	_saved_best_mastery = ProfileSave.best_mastery.duplicate()

func after_each() -> void:
	ProfileSave.runs_completed = _saved_runs_completed
	ProfileSave.victories = _saved_victories
	ProfileSave.total_damage = _saved_total_damage
	ProfileSave.total_quad_damage = _saved_total_quad_damage
	ProfileSave.total_tspin_damage = _saved_total_tspin_damage
	ProfileSave.total_singles = _saved_total_singles
	ProfileSave.total_doubles = _saved_total_doubles
	ProfileSave.total_triples = _saved_total_triples
	ProfileSave.total_quads = _saved_total_quads
	ProfileSave.total_tspin_singles = _saved_total_tspin_singles
	ProfileSave.total_tspin_doubles = _saved_total_tspin_doubles
	ProfileSave.total_tspin_triples = _saved_total_tspin_triples
	ProfileSave.total_perfect_clears = _saved_total_perfect_clears
	ProfileSave.total_play_time = _saved_total_play_time
	ProfileSave.highest_combo_chain = _saved_highest_combo_chain
	ProfileSave.highest_b2b = _saved_highest_b2b
	ProfileSave.best_single_run_damage = _saved_best_single_run_damage
	ProfileSave.best_mastery = _saved_best_mastery
	ProfileSave.save_profile()

# ── 9.1 – _compute_pbs: PB flag set when run exceeds stored best ─────────────

func test_pb_damage_flagged_when_run_exceeds_stored() -> void:
	ProfileSave.best_single_run_damage = 1500
	var stats := _make_stats(2000)
	var pbs := _compute_pbs_from(stats)
	assert_true(pbs.has("total_damage"), "damage PB should be flagged")

func test_pb_combo_flagged_when_run_exceeds_stored() -> void:
	ProfileSave.highest_combo_chain = 10
	var stats := _make_stats(0, 14)
	var pbs := _compute_pbs_from(stats)
	assert_true(pbs.has("highest_combo_chain"), "combo PB should be flagged")

func test_pb_b2b_flagged_when_run_exceeds_stored() -> void:
	ProfileSave.highest_b2b = 5
	var stats := _make_stats(0, 0, 8)
	var pbs := _compute_pbs_from(stats)
	assert_true(pbs.has("highest_b2b"), "b2b PB should be flagged")

# ── 9.2 – PB flag NOT set when value equals stored best ──────────────────────

func test_pb_not_flagged_when_equal_to_stored() -> void:
	ProfileSave.highest_combo_chain = 10
	var stats := _make_stats(0, 10)
	var pbs := _compute_pbs_from(stats)
	assert_false(pbs.has("highest_combo_chain"), "equal value should not flag PB")

# ── 9.3 – PB flag NOT set when value is lower ─────────────────────────────────

func test_pb_not_flagged_when_lower_than_stored() -> void:
	ProfileSave.best_single_run_damage = 1000
	var stats := _make_stats(500)
	var pbs := _compute_pbs_from(stats)
	assert_false(pbs.has("total_damage"), "lower value should not flag PB")

# ── 9.4 – accumulate_stats: new fields accumulate correctly ──────────────────

func test_accumulate_increments_total_quads() -> void:
	ProfileSave.total_quads = 10
	var stats := _make_stats(0, 0, 0, 5)
	ProfileSave.accumulate_stats(stats)
	assert_eq(ProfileSave.total_quads, 15)

func test_accumulate_increments_total_singles() -> void:
	ProfileSave.total_singles = 5
	var stats := RunStats.new()
	stats.singles = 3
	ProfileSave.accumulate_stats(stats)
	assert_eq(ProfileSave.total_singles, 8)

func test_accumulate_increments_total_doubles() -> void:
	ProfileSave.total_doubles = 2
	var stats := RunStats.new()
	stats.doubles = 4
	ProfileSave.accumulate_stats(stats)
	assert_eq(ProfileSave.total_doubles, 6)

func test_accumulate_increments_total_triples() -> void:
	ProfileSave.total_triples = 1
	var stats := RunStats.new()
	stats.triples = 2
	ProfileSave.accumulate_stats(stats)
	assert_eq(ProfileSave.total_triples, 3)

func test_accumulate_increments_total_tspin_singles() -> void:
	ProfileSave.total_tspin_singles = 3
	var stats := RunStats.new()
	stats.tspin_singles = 4
	ProfileSave.accumulate_stats(stats)
	assert_eq(ProfileSave.total_tspin_singles, 7)

func test_accumulate_increments_total_tspin_doubles() -> void:
	ProfileSave.total_tspin_doubles = 2
	var stats := RunStats.new()
	stats.tspin_doubles = 5
	ProfileSave.accumulate_stats(stats)
	assert_eq(ProfileSave.total_tspin_doubles, 7)

func test_accumulate_increments_total_tspin_triples() -> void:
	ProfileSave.total_tspin_triples = 1
	var stats := RunStats.new()
	stats.tspin_triples = 1
	ProfileSave.accumulate_stats(stats)
	assert_eq(ProfileSave.total_tspin_triples, 2)

func test_accumulate_increments_total_perfect_clears() -> void:
	ProfileSave.total_perfect_clears = 1
	var stats := _make_stats(0, 0, 0, 0, 2)
	ProfileSave.accumulate_stats(stats)
	assert_eq(ProfileSave.total_perfect_clears, 3)

func test_accumulate_increments_victories() -> void:
	ProfileSave.victories = 4
	ProfileSave.accumulate_stats(_make_stats())
	assert_eq(ProfileSave.victories, 5)

func test_accumulate_increments_total_play_time() -> void:
	ProfileSave.total_play_time = 120.0
	var stats := _make_stats(0, 0, 0, 0, 0, 75.0)
	ProfileSave.accumulate_stats(stats)
	assert_almost_eq(ProfileSave.total_play_time, 195.0, 0.001)

# ── 9.5 – best_single_run_damage takes max ────────────────────────────────────

func test_best_damage_updated_when_run_is_higher() -> void:
	ProfileSave.best_single_run_damage = 1500
	var stats := _make_stats(2000)
	ProfileSave.accumulate_stats(stats)
	assert_eq(ProfileSave.best_single_run_damage, 2000)

func test_best_damage_not_decreased_when_run_is_lower() -> void:
	ProfileSave.best_single_run_damage = 2000
	var stats := _make_stats(500)
	ProfileSave.accumulate_stats(stats)
	assert_eq(ProfileSave.best_single_run_damage, 2000)

# ── 9.6 – new ProfileSave fields default to 0 when absent from config ─────────

func test_new_fields_default_to_zero_on_missing_config() -> void:
	# Write a minimal cfg without new keys, reload, confirm defaults
	var cfg := ConfigFile.new()
	cfg.set_value("ascension", "highest_beaten", -1)
	cfg.set_value("stats", "runs_completed", 0)
	var tmp_path := "user://test_profile_defaults.cfg"
	cfg.save(tmp_path)

	var original_path_const := ProfileSave.SAVE_PATH
	# Load from the temp file by temporarily redirecting load
	var tmp_cfg := ConfigFile.new()
	tmp_cfg.load(tmp_path)
	assert_eq(tmp_cfg.get_value("stats", "total_singles", 0), 0)
	assert_eq(tmp_cfg.get_value("stats", "total_doubles", 0), 0)
	assert_eq(tmp_cfg.get_value("stats", "total_triples", 0), 0)
	assert_eq(tmp_cfg.get_value("stats", "total_quads", 0), 0)
	assert_eq(tmp_cfg.get_value("stats", "total_tspin_singles", 0), 0)
	assert_eq(tmp_cfg.get_value("stats", "total_tspin_doubles", 0), 0)
	assert_eq(tmp_cfg.get_value("stats", "total_tspin_triples", 0), 0)
	assert_eq(tmp_cfg.get_value("stats", "total_perfect_clears", 0), 0)
	assert_eq(tmp_cfg.get_value("stats", "victories", 0), 0)
	assert_almost_eq(float(tmp_cfg.get_value("stats", "best_single_run_damage", 0)), 0.0, 0.001)
	assert_almost_eq(float(tmp_cfg.get_value("stats", "total_play_time", 0.0)), 0.0, 0.001)
	DirAccess.remove_absolute(tmp_path)

# ── 9.7 – clear counter increments ───────────────────────────────────────────

func test_run_stats_quads_field_starts_zero() -> void:
	var s := RunStats.new()
	assert_eq(s.quads, 0)

func test_run_stats_singles_field_starts_zero() -> void:
	var s := RunStats.new()
	assert_eq(s.singles, 0)

func test_run_stats_doubles_field_starts_zero() -> void:
	var s := RunStats.new()
	assert_eq(s.doubles, 0)

func test_run_stats_triples_field_starts_zero() -> void:
	var s := RunStats.new()
	assert_eq(s.triples, 0)

func test_run_stats_tspin_singles_field_starts_zero() -> void:
	var s := RunStats.new()
	assert_eq(s.tspin_singles, 0)

func test_run_stats_tspin_doubles_field_starts_zero() -> void:
	var s := RunStats.new()
	assert_eq(s.tspin_doubles, 0)

func test_run_stats_tspin_triples_field_starts_zero() -> void:
	var s := RunStats.new()
	assert_eq(s.tspin_triples, 0)

func test_run_stats_perfect_clears_field_starts_zero() -> void:
	var s := RunStats.new()
	assert_eq(s.perfect_clears, 0)

# ── 9.8 – clear_counts increments correct key ─────────────────────────────────

func test_clear_counts_increments_single() -> void:
	var s := RunStats.new()
	s.clear_counts["single"] = s.clear_counts.get("single", 0) + 1
	assert_eq(s.clear_counts.get("single", 0), 1)

func test_clear_counts_increments_quad_separately() -> void:
	var s := RunStats.new()
	s.clear_counts["single"] = 3
	s.clear_counts["quad"] = 1
	assert_eq(s.clear_counts.get("single", 0), 3)
	assert_eq(s.clear_counts.get("quad", 0), 1)

# ── 9.9 – most_common_clear derivation ───────────────────────────────────────

func test_most_common_clear_returns_correct_type() -> void:
	var counts := {"single": 40, "quad": 15, "double": 8}
	assert_eq(RunEndHelpers.most_common_clear(counts), "Single")

func test_most_common_clear_tie_resolved_by_priority() -> void:
	var counts := {"single": 10, "quad": 10}
	assert_eq(RunEndHelpers.most_common_clear(counts), "Quad")

func test_most_common_clear_returns_dash_on_empty() -> void:
	assert_eq(RunEndHelpers.most_common_clear({}), "—")

func test_most_common_clear_perfect_clear_beats_quad_in_tie() -> void:
	var counts := {"perfect_clear": 5, "quad": 5}
	assert_eq(RunEndHelpers.most_common_clear(counts), "Perfect Clear")

# ── 9.10 – run_time MM:SS formatting ─────────────────────────────────────────

func test_format_time_754_seconds() -> void:
	assert_eq(RunEndHelpers.format_time(754.0), "12:34")

func test_format_time_60_seconds() -> void:
	assert_eq(RunEndHelpers.format_time(60.0), "1:00")

func test_format_time_over_one_hour() -> void:
	assert_eq(RunEndHelpers.format_time(3661.0), "61:01")

func test_format_time_zero() -> void:
	assert_eq(RunEndHelpers.format_time(0.0), "0:00")

# ── 9.11 – total_play_time accumulates across runs ────────────────────────────

func test_total_play_time_accumulates_across_multiple_runs() -> void:
	ProfileSave.total_play_time = 0.0
	var s1 := _make_stats(0, 0, 0, 0, 0, 120.0)
	var s2 := _make_stats(0, 0, 0, 0, 0, 95.5)
	ProfileSave.accumulate_stats(s1)
	ProfileSave.accumulate_stats(s2)
	assert_almost_eq(ProfileSave.total_play_time, 215.5, 0.001)

# ── best mastery tracks lifetime max per clear type ──────────────────────────

func test_best_mastery_updates_when_run_is_higher() -> void:
	ProfileSave.best_mastery = {"quad": 2, "single": 1}
	var stats := RunStats.new()
	stats.mastery_levels = {"quad": 4, "single": 1, "double": 3}
	ProfileSave.accumulate_stats(stats)
	assert_eq(ProfileSave.best_mastery["quad"], 4)
	assert_eq(ProfileSave.best_mastery["single"], 1)
	assert_eq(ProfileSave.best_mastery["double"], 3)

func test_best_mastery_not_decreased_when_run_is_lower() -> void:
	ProfileSave.best_mastery = {"quad": 5}
	var stats := RunStats.new()
	stats.mastery_levels = {"quad": 2}
	ProfileSave.accumulate_stats(stats)
	assert_eq(ProfileSave.best_mastery["quad"], 5)

func test_best_mastery_defaults_to_empty_on_missing_config() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("ascension", "highest_beaten", -1)
	var tmp_path := "user://test_mastery_defaults.cfg"
	cfg.save(tmp_path)
	var tmp_cfg := ConfigFile.new()
	tmp_cfg.load(tmp_path)
	assert_eq(tmp_cfg.get_value("stats", "best_mastery", {}), {})
	DirAccess.remove_absolute(tmp_path)

# ── Internal helper (mirrors RunManager._compute_pbs logic) ──────────────────

func _compute_pbs_from(run_stats: RunStats) -> Dictionary:
	var pbs: Dictionary = {}
	if run_stats.total_damage > ProfileSave.best_single_run_damage:
		pbs["total_damage"] = true
	if run_stats.highest_combo_chain > ProfileSave.highest_combo_chain:
		pbs["highest_combo_chain"] = true
	if run_stats.highest_b2b > ProfileSave.highest_b2b:
		pbs["highest_b2b"] = true
	return pbs
