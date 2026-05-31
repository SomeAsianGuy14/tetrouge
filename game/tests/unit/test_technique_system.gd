extends GutTest

var _TechniqueEvaluator = preload("res://scenes/game/technique_evaluator.gd")

# ── State save/restore ────────────────────────────────────────────────────────

var _saved_stage: int
var _saved_round_index: int
var _saved_techniques: Array
var _saved_technique_capacity: int

func before_each() -> void:
	_saved_stage = RunState.stage
	_saved_round_index = RunState.round_index
	_saved_techniques = RunState.techniques.duplicate()
	_saved_technique_capacity = RunState.technique_capacity
	RunState.techniques = []

func after_each() -> void:
	RunState.stage = _saved_stage
	RunState.round_index = _saved_round_index
	RunState.techniques = _saved_techniques
	RunState.technique_capacity = _saved_technique_capacity

# ── Helpers ───────────────────────────────────────────────────────────────────

func _make_flat_technique(on: String, bonus: int) -> Technique:
	var t := Technique.new()
	t.id = "test_flat_" + on
	t.effect_type = "flat"
	t.params = {"on": on, "bonus": bonus}
	return t

func _make_economy_technique(trigger: String, coins: int) -> Technique:
	var t := Technique.new()
	t.id = "test_economy_" + trigger
	t.effect_type = "economy"
	t.params = {"trigger": trigger, "coins": coins}
	return t

func _make_ctx(lines: int = 0, tspin: String = "", b2b: bool = false, combo: int = -1, perfect: bool = false) -> AttackContext:
	var ctx := AttackContext.new()
	ctx.lines_cleared = lines
	ctx.tspin = tspin
	ctx.b2b = b2b
	ctx.combo = combo
	ctx.perfect_clear = perfect
	return ctx

# ── TechniqueRoundState: initial state ───────────────────────────────────────

func test_round_state_counters_start_at_zero() -> void:
	var rs := TechniqueRoundState.new()
	assert_eq(rs.clears_this_round, 0)
	assert_eq(rs.attack_events_this_round, 0)
	assert_eq(rs.total_garbage_sent, 0)
	assert_eq(rs.tspin_count, 0)
	assert_eq(rs.b2b_count, 0)
	assert_eq(rs.perfect_clear_count, 0)
	assert_eq(rs.pieces_placed, 0)
	assert_eq(rs.tetris_count, 0)
	assert_eq(rs.no_rotate_streak, 0)
	assert_eq(rs.good_planning_consecutive_no_hold, 0)
	assert_eq(rs.patience_cooldown_pieces, 0)

func test_round_state_bool_flags_start_false() -> void:
	var rs := TechniqueRoundState.new()
	assert_false(rs.last_clear_was_tetris)
	assert_false(rs.follow_up_pending)
	assert_false(rs.tetris_echo_pending)
	assert_false(rs.escalation_pending)
	assert_false(rs.after_receive_pending)
	assert_false(rs.patience_pending)
	assert_false(rs.constant_pressure_pending)
	assert_false(rs.flow_step_pending)
	assert_false(rs.good_planning_pending)
	assert_false(rs.switch_up_armed)
	assert_false(rs.opening_blow_used)
	assert_false(rs.combo_payout_used)

func test_round_state_counters_can_be_incremented() -> void:
	var rs := TechniqueRoundState.new()
	rs.clears_this_round += 1
	rs.tetris_count += 1
	rs.pieces_placed += 5
	assert_eq(rs.clears_this_round, 1)
	assert_eq(rs.tetris_count, 1)
	assert_eq(rs.pieces_placed, 5)

# ── TechniqueEvaluator.compute_attack_bonus ───────────────────────────────────

func test_no_techniques_returns_zero() -> void:
	var ctx := _make_ctx(1)
	var rs := TechniqueRoundState.new()
	assert_eq(_TechniqueEvaluator.compute_attack_bonus([], ctx, rs), 0)

func test_single_flat_all_clear_technique() -> void:
	var t := _make_flat_technique("all_clear", 2)
	var ctx := _make_ctx(1)
	var rs := TechniqueRoundState.new()
	assert_eq(_TechniqueEvaluator.compute_attack_bonus([t], ctx, rs), 2)

func test_flat_all_clear_does_not_fire_on_no_clear() -> void:
	var t := _make_flat_technique("all_clear", 2)
	var ctx := _make_ctx(0)
	var rs := TechniqueRoundState.new()
	assert_eq(_TechniqueEvaluator.compute_attack_bonus([t], ctx, rs), 0)

func test_two_flat_techniques_stack_additively() -> void:
	var t1 := _make_flat_technique("all_clear", 2)
	var t2 := _make_flat_technique("all_clear", 3)
	var ctx := _make_ctx(1)
	var rs := TechniqueRoundState.new()
	assert_eq(_TechniqueEvaluator.compute_attack_bonus([t1, t2], ctx, rs), 5)

func test_flat_quad_fires_only_on_quad() -> void:
	var t := _make_flat_technique("quad", 2)
	var ctx_quad := _make_ctx(4)
	var ctx_single := _make_ctx(1)
	var rs := TechniqueRoundState.new()
	assert_eq(_TechniqueEvaluator.compute_attack_bonus([t], ctx_quad, rs), 2)
	assert_eq(_TechniqueEvaluator.compute_attack_bonus([t], ctx_single, rs), 0)

func test_flat_tspin_fires_on_any_tspin() -> void:
	var t := _make_flat_technique("tspin", 2)
	var ctx_double := _make_ctx(2, "double")
	var ctx_mini := _make_ctx(1, "mini")
	var ctx_no_spin := _make_ctx(1)
	var rs := TechniqueRoundState.new()
	assert_eq(_TechniqueEvaluator.compute_attack_bonus([t], ctx_double, rs), 2)
	assert_eq(_TechniqueEvaluator.compute_attack_bonus([t], ctx_mini, rs), 2)
	assert_eq(_TechniqueEvaluator.compute_attack_bonus([t], ctx_no_spin, rs), 0)

func test_flat_tspin_double_fires_only_on_double() -> void:
	var t := _make_flat_technique("tspin_double", 3)
	var ctx_double := _make_ctx(2, "double")
	var ctx_single := _make_ctx(1, "single")
	var rs := TechniqueRoundState.new()
	assert_eq(_TechniqueEvaluator.compute_attack_bonus([t], ctx_double, rs), 3)
	assert_eq(_TechniqueEvaluator.compute_attack_bonus([t], ctx_single, rs), 0)

func test_flat_require_b2b_only_fires_with_b2b() -> void:
	var t := Technique.new()
	t.effect_type = "flat"
	t.params = {"on": "quad", "require_b2b": true, "bonus": 2}
	var ctx_b2b := _make_ctx(4, "", true)
	var ctx_no_b2b := _make_ctx(4, "", false)
	var rs := TechniqueRoundState.new()
	assert_eq(_TechniqueEvaluator.compute_attack_bonus([t], ctx_b2b, rs), 2)
	assert_eq(_TechniqueEvaluator.compute_attack_bonus([t], ctx_no_b2b, rs), 0)

func test_flat_board_above_pct_blocks_when_board_too_low() -> void:
	var t := Technique.new()
	t.effect_type = "flat"
	t.params = {"on": "all_clear", "board_above_pct": 0.7, "bonus": 3}
	var ctx_high := _make_ctx(1)
	ctx_high.board_height = 15  # 15/20 = 75% > 70%
	var ctx_low := _make_ctx(1)
	ctx_low.board_height = 10  # 10/20 = 50% < 70%
	var rs := TechniqueRoundState.new()
	assert_eq(_TechniqueEvaluator.compute_attack_bonus([t], ctx_high, rs), 3)
	assert_eq(_TechniqueEvaluator.compute_attack_bonus([t], ctx_low, rs), 0)

func test_flat_board_below_pct_blocks_when_board_too_high() -> void:
	var t := Technique.new()
	t.effect_type = "flat"
	t.params = {"on": "all_clear", "board_below_pct": 0.4, "bonus": 1}
	var ctx_low := _make_ctx(1)
	ctx_low.board_height = 6  # 6/20 = 30% < 40%
	var ctx_high := _make_ctx(1)
	ctx_high.board_height = 10  # 10/20 = 50% >= 40%
	var rs := TechniqueRoundState.new()
	assert_eq(_TechniqueEvaluator.compute_attack_bonus([t], ctx_low, rs), 1)
	assert_eq(_TechniqueEvaluator.compute_attack_bonus([t], ctx_high, rs), 0)

func test_empty_effect_type_returns_zero() -> void:
	var t := Technique.new()
	t.id = "blank"
	t.effect_type = ""
	t.params = {}
	var ctx := _make_ctx(1)
	var rs := TechniqueRoundState.new()
	assert_eq(_TechniqueEvaluator.compute_attack_bonus([t], ctx, rs), 0)

func test_first_clear_fires_only_once_per_round() -> void:
	var t := Technique.new()
	t.effect_type = "first_clear"
	t.params = {"bonus": 3}
	var ctx := _make_ctx(1)
	var rs := TechniqueRoundState.new()
	assert_eq(_TechniqueEvaluator.compute_attack_bonus([t], ctx, rs), 3)
	rs.opening_blow_used = true
	assert_eq(_TechniqueEvaluator.compute_attack_bonus([t], ctx, rs), 0)

func test_discipline_hold_fires_without_hold() -> void:
	var t := Technique.new()
	t.effect_type = "discipline_hold"
	t.params = {"bonus": 2}
	var ctx_no_hold := _make_ctx(1)
	ctx_no_hold.held_this_piece = false
	var ctx_held := _make_ctx(1)
	ctx_held.held_this_piece = true
	var rs := TechniqueRoundState.new()
	assert_eq(_TechniqueEvaluator.compute_attack_bonus([t], ctx_no_hold, rs), 2)
	assert_eq(_TechniqueEvaluator.compute_attack_bonus([t], ctx_held, rs), 0)

func test_enemy_hp_below_fires_only_at_low_hp() -> void:
	var t := Technique.new()
	t.effect_type = "enemy_hp_below"
	t.params = {"threshold": 0.25, "bonus": 1}
	var ctx_low := _make_ctx(1)
	ctx_low.enemy_hp_pct = 0.2
	var ctx_high := _make_ctx(1)
	ctx_high.enemy_hp_pct = 0.5
	var rs := TechniqueRoundState.new()
	assert_eq(_TechniqueEvaluator.compute_attack_bonus([t], ctx_low, rs), 1)
	assert_eq(_TechniqueEvaluator.compute_attack_bonus([t], ctx_high, rs), 0)

func test_side_strike_fires_on_quad_at_far_left_col() -> void:
	var t := Technique.new()
	t.effect_type = "side_strike"
	t.params = {"bonus": 1}
	var ctx := _make_ctx(4)
	ctx.locked_col = 0
	var rs := TechniqueRoundState.new()
	assert_eq(_TechniqueEvaluator.compute_attack_bonus([t], ctx, rs), 1)

func test_side_strike_fires_on_quad_at_far_right_col() -> void:
	var t := Technique.new()
	t.effect_type = "side_strike"
	t.params = {"bonus": 1}
	var ctx := _make_ctx(4)
	ctx.locked_col = 6
	var rs := TechniqueRoundState.new()
	assert_eq(_TechniqueEvaluator.compute_attack_bonus([t], ctx, rs), 1)

func test_side_strike_does_not_fire_on_quad_at_centre_col() -> void:
	var t := Technique.new()
	t.effect_type = "side_strike"
	t.params = {"bonus": 1}
	var ctx := _make_ctx(4)
	ctx.locked_col = 3
	var rs := TechniqueRoundState.new()
	assert_eq(_TechniqueEvaluator.compute_attack_bonus([t], ctx, rs), 0)

func test_side_strike_does_not_fire_on_non_quad_even_at_edge() -> void:
	var t := Technique.new()
	t.effect_type = "side_strike"
	t.params = {"bonus": 1}
	var ctx := _make_ctx(2)
	ctx.locked_col = 0
	var rs := TechniqueRoundState.new()
	assert_eq(_TechniqueEvaluator.compute_attack_bonus([t], ctx, rs), 0)

func test_rotation_training_fires_at_two_or_more_rotations() -> void:
	var t := Technique.new()
	t.effect_type = "rotation_training"
	t.params = {"min_rotations": 2, "bonus": 1}
	var ctx_2rot := _make_ctx(1)
	ctx_2rot.rotations_this_placement = 2
	var ctx_1rot := _make_ctx(1)
	ctx_1rot.rotations_this_placement = 1
	var rs := TechniqueRoundState.new()
	assert_eq(_TechniqueEvaluator.compute_attack_bonus([t], ctx_2rot, rs), 1)
	assert_eq(_TechniqueEvaluator.compute_attack_bonus([t], ctx_1rot, rs), 0)

# ── TechniqueEvaluator.compute_economy_bonus ──────────────────────────────────

func test_economy_quad_trigger_credits_on_quad() -> void:
	var t := _make_economy_technique("quad", 2)
	var ctx := _make_ctx(4)
	var rs := TechniqueRoundState.new()
	assert_eq(_TechniqueEvaluator.compute_economy_bonus([t], ctx, rs), 2)

func test_economy_quad_trigger_no_coins_on_non_quad() -> void:
	var t := _make_economy_technique("quad", 2)
	var ctx := _make_ctx(2)
	var rs := TechniqueRoundState.new()
	assert_eq(_TechniqueEvaluator.compute_economy_bonus([t], ctx, rs), 0)

func test_economy_tspin_trigger_credits_on_tspin() -> void:
	var t := _make_economy_technique("tspin", 3)
	var ctx := _make_ctx(2, "double")
	var rs := TechniqueRoundState.new()
	assert_eq(_TechniqueEvaluator.compute_economy_bonus([t], ctx, rs), 3)

func test_economy_b2b_trigger_credits_on_b2b() -> void:
	var t := _make_economy_technique("b2b", 1)
	var ctx := _make_ctx(4, "", true)
	var rs := TechniqueRoundState.new()
	assert_eq(_TechniqueEvaluator.compute_economy_bonus([t], ctx, rs), 1)

func test_economy_combo_payout_credits_once_at_threshold() -> void:
	var t := Technique.new()
	t.effect_type = "economy"
	t.params = {"trigger": "combo_payout", "combo_threshold": 4, "coins": 5}
	var ctx := _make_ctx(1, "", false, 4)  # combo = 4 (>= threshold)
	var rs := TechniqueRoundState.new()
	assert_eq(_TechniqueEvaluator.compute_economy_bonus([t], ctx, rs), 5)

func test_economy_combo_payout_zero_after_used() -> void:
	var t := Technique.new()
	t.effect_type = "economy"
	t.params = {"trigger": "combo_payout", "combo_threshold": 4, "coins": 5}
	var ctx := _make_ctx(1, "", false, 4)
	var rs := TechniqueRoundState.new()
	rs.combo_payout_used = true
	assert_eq(_TechniqueEvaluator.compute_economy_bonus([t], ctx, rs), 0)

func test_non_economy_technique_returns_zero_from_economy_func() -> void:
	var t := _make_flat_technique("all_clear", 3)
	var ctx := _make_ctx(1)
	var rs := TechniqueRoundState.new()
	assert_eq(_TechniqueEvaluator.compute_economy_bonus([t], ctx, rs), 0)

# ── TechniqueEvaluator.evaluate ───────────────────────────────────────────────

func test_evaluate_result_has_correct_keys() -> void:
	var ctx := _make_ctx(0)
	var rs := TechniqueRoundState.new()
	var result: Dictionary = _TechniqueEvaluator.evaluate([], ctx, rs)
	assert_true(result.has("attack_delta"))
	assert_true(result.has("coins_delta"))
	assert_true(result.has("flags"))

func test_evaluate_returns_combined_attack_and_coins() -> void:
	var t_atk := _make_flat_technique("all_clear", 2)
	var t_eco := _make_economy_technique("quad", 3)
	var ctx := _make_ctx(4)
	var rs := TechniqueRoundState.new()
	var result: Dictionary = _TechniqueEvaluator.evaluate([t_atk, t_eco], ctx, rs)
	assert_eq(result.attack_delta, 2)
	assert_eq(result.coins_delta, 3)

func test_evaluate_flags_includes_glass_cannon_on_clear() -> void:
	var t := Technique.new()
	t.effect_type = "glass_cannon"
	t.params = {"attack_bonus": 4}
	var ctx := _make_ctx(1)
	var rs := TechniqueRoundState.new()
	var result: Dictionary = _TechniqueEvaluator.evaluate([t], ctx, rs)
	assert_has(result.flags, "glass_cannon")

func test_evaluate_glass_cannon_no_flag_on_no_clear() -> void:
	var t := Technique.new()
	t.effect_type = "glass_cannon"
	t.params = {"attack_bonus": 4}
	var ctx := _make_ctx(0)
	var rs := TechniqueRoundState.new()
	var result: Dictionary = _TechniqueEvaluator.evaluate([t], ctx, rs)
	assert_does_not_have(result.flags, "glass_cannon")

func test_evaluate_flags_includes_flash_step_on_multiline() -> void:
	var t := Technique.new()
	t.effect_type = "flash_step"
	t.params = {"min_lines": 2}
	var ctx_double := _make_ctx(2)
	var ctx_single := _make_ctx(1)
	var rs := TechniqueRoundState.new()
	var result_double: Dictionary = _TechniqueEvaluator.evaluate([t], ctx_double, rs)
	var result_single: Dictionary = _TechniqueEvaluator.evaluate([t], ctx_single, rs)
	assert_has(result_double.flags, "flash_step_arr")
	assert_does_not_have(result_single.flags, "flash_step_arr")

func test_evaluate_flags_empty_with_no_lifecycle_techniques() -> void:
	var t := _make_flat_technique("all_clear", 1)
	var ctx := _make_ctx(1)
	var rs := TechniqueRoundState.new()
	var result: Dictionary = _TechniqueEvaluator.evaluate([t], ctx, rs)
	assert_eq(result.flags.size(), 0)

# ── RunState.technique_capacity ───────────────────────────────────────────────

func test_technique_capacity_is_4_at_run_start() -> void:
	RunState.reset()
	assert_eq(RunState.technique_capacity, 4)

func test_technique_capacity_unchanged_mid_stage() -> void:
	RunState.reset()
	RunState.advance_round()  # stage 1, round 1
	assert_eq(RunState.technique_capacity, 4)
	RunState.advance_round()  # stage 1, round 2
	assert_eq(RunState.technique_capacity, 4)
	RunState.advance_round()  # stage 1, round 3
	assert_eq(RunState.technique_capacity, 4)

func test_technique_capacity_increases_to_5_at_stage_2() -> void:
	RunState.reset()
	RunState.advance_round()
	RunState.advance_round()
	RunState.advance_round()
	RunState.advance_round()  # completes stage 1, enters stage 2
	assert_eq(RunState.stage, 2)
	assert_eq(RunState.technique_capacity, 5)

func test_technique_capacity_increases_to_6_at_stage_3() -> void:
	RunState.reset()
	for _i in range(8):  # 4 rounds stage 1 + 4 rounds stage 2
		RunState.advance_round()
	assert_eq(RunState.stage, 3)
	assert_eq(RunState.technique_capacity, 6)

func test_technique_capacity_reset_on_run_reset() -> void:
	RunState.reset()
	for _i in range(4):
		RunState.advance_round()
	assert_eq(RunState.technique_capacity, 5)
	RunState.reset()
	assert_eq(RunState.technique_capacity, 4)

# ── Burning Board ─────────────────────────────────────────────────────────────

func test_burning_board_adds_attack_bonus_on_clear() -> void:
	var t := Technique.new()
	t.effect_type = "burning_board"
	t.params = {"attack_bonus": 3}
	var ctx := _make_ctx(1)
	var rs := TechniqueRoundState.new()
	var result: Dictionary = _TechniqueEvaluator.evaluate([t], ctx, rs)
	assert_eq(result.attack_delta, 3)

func test_burning_board_no_bonus_on_no_clear() -> void:
	var t := Technique.new()
	t.effect_type = "burning_board"
	t.params = {"attack_bonus": 3}
	var ctx := _make_ctx(0)
	var rs := TechniqueRoundState.new()
	var result: Dictionary = _TechniqueEvaluator.evaluate([t], ctx, rs)
	assert_eq(result.attack_delta, 0)

func test_burning_board_flag_emitted_on_clear() -> void:
	var t := Technique.new()
	t.effect_type = "burning_board"
	t.params = {"attack_bonus": 3}
	var ctx := _make_ctx(1)
	var rs := TechniqueRoundState.new()
	var result: Dictionary = _TechniqueEvaluator.evaluate([t], ctx, rs)
	assert_has(result.flags, "burning_board")

func test_burning_board_no_flag_on_no_clear() -> void:
	var t := Technique.new()
	t.effect_type = "burning_board"
	t.params = {"attack_bonus": 3}
	var ctx := _make_ctx(0)
	var rs := TechniqueRoundState.new()
	var result: Dictionary = _TechniqueEvaluator.evaluate([t], ctx, rs)
	assert_does_not_have(result.flags, "burning_board")
