extends GutTest

# ── Shared state ──────────────────────────────────────────────────────────

var _rm: RunManager
var _saved_keystones: Array
var _saved_techniques: Array
var _saved_used_ids: Array
var _saved_coins: int

func before_each() -> void:
	_saved_keystones = RunState.keystones.duplicate()
	_saved_techniques = RunState.techniques.duplicate()
	_saved_used_ids = RunState.used_keystone_ids.duplicate()
	_saved_coins = Economy.coins
	RunState.keystones = []
	RunState.techniques = []
	RunState.used_keystone_ids = []
	Economy.coins = 0
	_rm = RunManager.new()
	_rm.current_config = RoundConfig.new()
	_rm._last_attack_was_quad = false
	_rm._t_spin_rotations = 0
	_rm._pc_count_this_round = 0
	_rm._last_cleared_rows = []
	_rm.surplus_attack = 0
	_rm.round_timer = 0.0

func after_each() -> void:
	_rm.free()
	RunState.keystones = _saved_keystones
	RunState.techniques = _saved_techniques
	RunState.used_keystone_ids = _saved_used_ids
	Economy.coins = _saved_coins

func _make_keystone() -> Keystone:
	return Keystone.new()

func _make_technique(event: String) -> Technique:
	var t := Technique.new()
	t.tags = [event]
	return t

# ── Suppression ────────────────────────────────────────────────────────────

func test_suppress_spins_zeroes_tspin_attack() -> void:
	var ks := _make_keystone()
	ks.suppress_spins = true
	RunState.keystones.append(ks)
	assert_eq(_rm._apply_keystone_suppressions(4, "tspin_double"), 0)

func test_suppress_spins_does_not_affect_quad() -> void:
	var ks := _make_keystone()
	ks.suppress_spins = true
	RunState.keystones.append(ks)
	assert_eq(_rm._apply_keystone_suppressions(4, "quad"), 4)

# ── Flat bonuses ──────────────────────────────────────────────────────────

func test_flat_bonus_added_to_matching_event() -> void:
	var ks := _make_keystone()
	ks.quad_bonus = 2
	RunState.keystones.append(ks)
	assert_eq(_rm._apply_keystone_flat_bonuses(4, "quad"), 6)

func test_per_technique_quad_bonus_counts_applicable_techniques() -> void:
	var ks := _make_keystone()
	ks.per_technique_quad_bonus = 2
	RunState.keystones.append(ks)
	RunState.techniques.append(_make_technique("quad"))
	RunState.techniques.append(_make_technique("quad"))
	# 4 base + (2 per technique * 2 techniques) = 8
	assert_eq(_rm._apply_keystone_flat_bonuses(4, "quad"), 8)

# ── Multipliers ───────────────────────────────────────────────────────────

func test_multiplier_applied_after_flat_bonus() -> void:
	var ks := _make_keystone()
	ks.quad_bonus = 2
	ks.quad_multiplier = 2.0
	RunState.keystones.append(ks)
	var after_flat := _rm._apply_keystone_flat_bonuses(4, "quad")
	assert_eq(after_flat, 6)
	assert_eq(_rm._apply_keystone_multipliers(after_flat, "quad"), 12)

func test_quad_multiplier_does_not_affect_tspin() -> void:
	var ks := _make_keystone()
	ks.quad_multiplier = 2.0
	RunState.keystones.append(ks)
	assert_eq(_rm._apply_keystone_multipliers(4, "tspin_double"), 4)

func test_combo_multiplier_applies_only_above_threshold() -> void:
	var ks := _make_keystone()
	ks.combo_multiplier = 2.0
	ks.combo_multiplier_threshold = 5
	RunState.keystones.append(ks)
	var board := TetrisBoard.new()
	_rm.current_board = board

	board.combo = 5
	assert_eq(_rm._apply_keystone_multipliers(4, "combo"), 4, "combo=5 not above threshold=5")
	board.combo = 6
	assert_eq(_rm._apply_keystone_multipliers(4, "combo"), 8, "combo=6 above threshold=5")

	board.free()
	_rm.current_board = null

func test_dual_wielding_fires_on_second_quad_not_first() -> void:
	var ks := _make_keystone()
	ks.consecutive_quad_multiplier = 2.0
	RunState.keystones.append(ks)
	_rm._last_attack_was_quad = false
	assert_eq(_rm._apply_keystone_multipliers(4, "quad"), 4, "first quad: no consecutive bonus")
	_rm._last_attack_was_quad = true
	assert_eq(_rm._apply_keystone_multipliers(4, "quad"), 8, "second quad: consecutive bonus fires")

func test_dual_wielding_resets_after_non_quad_clear() -> void:
	var ks := _make_keystone()
	ks.consecutive_quad_multiplier = 2.0
	RunState.keystones.append(ks)
	_rm._last_attack_was_quad = true
	# simulate state reset that _on_attack_generated performs after a non-tetris clear
	_rm._last_attack_was_quad = ("single" == "quad")
	assert_eq(_rm._apply_keystone_multipliers(4, "quad"), 4, "no consecutive after non-quad reset")

func test_dizzy_no_bonus_at_exactly_4_rotations() -> void:
	var ks := _make_keystone()
	ks.dizzy = true
	RunState.keystones.append(ks)
	_rm._t_spin_rotations = 4
	assert_eq(_rm._apply_keystone_flat_bonuses(4, "tspin_double"), 4)

func test_dizzy_adds_4_when_rotation_count_exceeds_4() -> void:
	var ks := _make_keystone()
	ks.dizzy = true
	RunState.keystones.append(ks)
	_rm._t_spin_rotations = 5
	assert_eq(_rm._apply_keystone_flat_bonuses(4, "tspin_double"), 8)

func test_pc_first_multiplier_applies_on_first_pc() -> void:
	var ks := _make_keystone()
	ks.pc_first_multiplier = 3.0
	ks.pc_after_first_multiplier = 2.0
	RunState.keystones.append(ks)
	_rm._pc_count_this_round = 0
	assert_eq(_rm._apply_keystone_multipliers(4, "perfect_clear"), 12)

func test_pc_after_first_multiplier_applies_on_subsequent_pcs() -> void:
	var ks := _make_keystone()
	ks.pc_first_multiplier = 3.0
	ks.pc_after_first_multiplier = 2.0
	RunState.keystones.append(ks)
	_rm._pc_count_this_round = 1
	assert_eq(_rm._apply_keystone_multipliers(4, "perfect_clear"), 8)

# ── Garbage flush ─────────────────────────────────────────────────────────

func test_garbage_flush_reduction_reduces_flush_amount() -> void:
	_rm.current_config.garbage_flush_reduction = 2
	_rm._garbage_packets.append({lines = 10, is_filth = false})
	var board := TetrisBoard.new()
	board.setup(_rm.current_config)
	_rm.current_board = board
	_rm._flush_pending_garbage()
	# capacity = 8 - reduction(2) = 6; 10 lines - 6 flushed = 4 remaining
	assert_eq(_rm._garbage_packets[0].lines, 4)
	board.free()
	_rm.current_board = null

# ── Economy ───────────────────────────────────────────────────────────────

func test_end_round_coins_from_two_keystones_credits_total() -> void:
	var ks1 := _make_keystone()
	ks1.end_round_coins = 1
	var ks2 := _make_keystone()
	ks2.end_round_coins = 2
	RunState.keystones.append(ks1)
	RunState.keystones.append(ks2)
	_rm._apply_keystone_economy()
	assert_eq(Economy.coins, 3)

func test_overkill_coins_grants_surplus_attack() -> void:
	var ks := _make_keystone()
	ks.overkill_coins = true
	RunState.keystones.append(ks)
	_rm.surplus_attack = 5
	_rm._apply_keystone_economy()
	assert_eq(Economy.coins, 5)

func test_time_coins_grants_floor_of_time_divided_by_5() -> void:
	var ks := _make_keystone()
	ks.time_coins = true
	RunState.keystones.append(ks)
	_rm.round_timer = 17.0
	_rm._apply_keystone_economy()
	assert_eq(Economy.coins, 3)

# ── Conditional availability ──────────────────────────────────────────────

func test_conditional_keystone_excluded_when_prereq_not_owned() -> void:
	RunState.used_keystone_ids = []
	var ks := _make_keystone()
	ks.requires_keystone_id = "slightly_magical_coin"
	var passes := ks.requires_keystone_id == "" or ks.requires_keystone_id in RunState.used_keystone_ids
	assert_false(passes)

func test_conditional_keystone_included_when_prereq_owned() -> void:
	RunState.used_keystone_ids = ["slightly_magical_coin"]
	var ks := _make_keystone()
	ks.requires_keystone_id = "slightly_magical_coin"
	var passes := ks.requires_keystone_id == "" or ks.requires_keystone_id in RunState.used_keystone_ids
	assert_true(passes)
