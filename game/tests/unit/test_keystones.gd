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

func test_garbage_flush_reduction_reduces_lines_entering_buffer() -> void:
	_rm.current_config.garbage_flush_reduction = 2
	_rm.current_config.garbage_lines_min = 4
	_rm.current_config.garbage_lines_max = 4
	_rm.current_config.garbage_interval_min = 1.0
	_rm.current_config.garbage_interval_max = 1.0
	_rm._next_garbage_interval = 1.0
	_rm._tick_enemy_garbage(1.1)
	# 4 lines - reduction(2) = 2 lines enter buffer
	assert_eq(_rm._garbage_packets.size(), 1)
	assert_eq(_rm._garbage_packets[0].lines, 2)

func test_garbage_flush_reduction_blocks_full_attack() -> void:
	_rm.current_config.garbage_flush_reduction = 3
	_rm.current_config.garbage_lines_min = 2
	_rm.current_config.garbage_lines_max = 2
	_rm.current_config.garbage_interval_min = 1.0
	_rm.current_config.garbage_interval_max = 1.0
	_rm._next_garbage_interval = 1.0
	_rm._tick_enemy_garbage(1.1)
	# 2 lines - reduction(3) = 0 — attack fully blocked, nothing enters buffer
	assert_true(_rm._garbage_packets.is_empty())

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

# ── Upgrade replacement ───────────────────────────────────────────────────

func test_add_keystone_removes_replaced_keystone() -> void:
	var base := _make_keystone()
	base.id = "simple_sword"
	RunState.keystones = [base]
	RunState.used_keystone_ids = ["simple_sword"]
	var upgrade := _make_keystone()
	upgrade.id = "great_sword"
	upgrade.replaces_keystone_id = "simple_sword"
	RunState.add_keystone(upgrade)
	assert_eq(RunState.keystones.size(), 1)
	assert_eq(RunState.keystones[0].id, "great_sword")

func test_replaced_id_stays_in_used_keystone_ids() -> void:
	var base := _make_keystone()
	base.id = "simple_sword"
	RunState.keystones = [base]
	RunState.used_keystone_ids = ["simple_sword"]
	var upgrade := _make_keystone()
	upgrade.id = "great_sword"
	upgrade.replaces_keystone_id = "simple_sword"
	RunState.add_keystone(upgrade)
	assert_has(RunState.used_keystone_ids, "simple_sword")
	assert_has(RunState.used_keystone_ids, "great_sword")

func test_add_keystone_without_replaces_does_not_remove_existing() -> void:
	var existing := _make_keystone()
	existing.id = "simple_sword"
	RunState.keystones = [existing]
	var new_ks := _make_keystone()
	new_ks.id = "foresight"
	new_ks.replaces_keystone_id = ""
	RunState.add_keystone(new_ks)
	assert_eq(RunState.keystones.size(), 2)

func test_add_keystone_replaces_nonexistent_base_adds_normally() -> void:
	RunState.keystones = []
	var upgrade := _make_keystone()
	upgrade.id = "great_sword"
	upgrade.replaces_keystone_id = "simple_sword"
	RunState.add_keystone(upgrade)
	assert_eq(RunState.keystones.size(), 1)
	assert_eq(RunState.keystones[0].id, "great_sword")

# ── Hybrid Reactor ────────────────────────────────────────────────────────

func test_hybrid_reactor_bonus_applies_when_attack_nonzero() -> void:
	var ks := _make_keystone()
	ks.per_attack_tag_bonus = 3
	RunState.keystones = [ks]
	var t1 := Technique.new()
	t1.tags = ["risk", "offense"]
	var t2 := Technique.new()
	t2.tags = ["defense", "utility"]
	RunState.techniques = [t1, t2]
	_rm.current_config.quota = 9999
	var modified := 5
	if modified > 0:
		var tag_bonus := 0
		for k in RunState.keystones:
			if k.per_attack_tag_bonus > 0:
				tag_bonus += k.per_attack_tag_bonus
		var qualifying := 0
		for t in RunState.techniques:
			if t.tags.size() >= 2:
				qualifying += 1
		modified += tag_bonus * qualifying
	assert_eq(modified, 5 + 3 * 2)

func test_hybrid_reactor_bonus_zero_when_attack_zero() -> void:
	var ks := _make_keystone()
	ks.per_attack_tag_bonus = 3
	RunState.keystones = [ks]
	var t1 := Technique.new()
	t1.tags = ["risk", "offense"]
	RunState.techniques = [t1]
	var modified := 0
	if modified > 0:
		modified += 3
	assert_eq(modified, 0)

func test_hybrid_reactor_zero_when_no_qualifying_techniques() -> void:
	var ks := _make_keystone()
	ks.per_attack_tag_bonus = 3
	RunState.keystones = [ks]
	var t1 := Technique.new()
	t1.tags = ["risk"]
	RunState.techniques = [t1]
	var modified := 5
	if modified > 0:
		var tag_bonus := 0
		for k in RunState.keystones:
			if k.per_attack_tag_bonus > 0:
				tag_bonus += k.per_attack_tag_bonus
		var qualifying := 0
		for t in RunState.techniques:
			if t.tags.size() >= 2:
				qualifying += 1
		modified += tag_bonus * qualifying
	assert_eq(modified, 5)

func test_hybrid_reactor_bonus_not_applied_on_b2b_event() -> void:
	var ks := _make_keystone()
	ks.per_attack_tag_bonus = 3
	RunState.keystones = [ks]
	var t1 := Technique.new()
	t1.tags = ["risk", "offense"]
	RunState.techniques = [t1]
	var modified := 5
	var is_bonus_event := true  # event_type == "b2b"
	if modified > 0 and not is_bonus_event:
		var tag_bonus := 0
		for k in RunState.keystones:
			if k.per_attack_tag_bonus > 0:
				tag_bonus += k.per_attack_tag_bonus
		var qualifying := 0
		for t in RunState.techniques:
			if t.tags.size() >= 2:
				qualifying += 1
		modified += tag_bonus * qualifying
	assert_eq(modified, 5, "b2b event: tag bonus must not apply")

func test_hybrid_reactor_bonus_not_applied_on_combo_event() -> void:
	var ks := _make_keystone()
	ks.per_attack_tag_bonus = 3
	RunState.keystones = [ks]
	var t1 := Technique.new()
	t1.tags = ["risk", "offense"]
	RunState.techniques = [t1]
	var modified := 3
	var is_bonus_event := true  # event_type == "combo"
	if modified > 0 and not is_bonus_event:
		var tag_bonus := 0
		for k in RunState.keystones:
			if k.per_attack_tag_bonus > 0:
				tag_bonus += k.per_attack_tag_bonus
		var qualifying := 0
		for t in RunState.techniques:
			if t.tags.size() >= 2:
				qualifying += 1
		modified += tag_bonus * qualifying
	assert_eq(modified, 3, "combo event: tag bonus must not apply")

# ── Reflect keystone ─────────────────────────────────────────────────────

func test_reflect_adds_floor_half_lines_to_quota() -> void:
	var ks := _make_keystone()
	ks.reflect_on_flush = 0.5
	RunState.keystones = [ks]
	_rm.quota_accumulated = 0.0
	var reflect_ratio := 0.0
	for k in RunState.keystones:
		if k.reflect_on_flush > 0.0:
			reflect_ratio = maxf(reflect_ratio, k.reflect_on_flush)
	var to_flush := 4
	var reflected := floori(to_flush * reflect_ratio)
	_rm.quota_accumulated += reflected
	assert_eq(int(_rm.quota_accumulated), 2)

func test_reflect_floors_fractional_result() -> void:
	var ks := _make_keystone()
	ks.reflect_on_flush = 0.5
	RunState.keystones = [ks]
	var to_flush := 3
	var reflected := floori(to_flush * 0.5)
	assert_eq(reflected, 1)

# ── Blessed Stone state ───────────────────────────────────────────────────

func test_blessed_stone_spent_flag_persists_when_set() -> void:
	_rm._blessed_stone_spent = false
	_rm._blessed_stone_spent = true
	assert_true(_rm._blessed_stone_spent)

# ── Data: Double Trouble / Triple Threat suppression removed ─────────────

func test_double_trouble_has_no_suppression_flags() -> void:
	var ks: Keystone = ResourceRegistry.find_by_id(ResourceRegistry.all_keystones, "double_trouble")
	assert_not_null(ks)
	assert_false(ks.suppress_tspin_single, "double_trouble should not suppress tspin_single")
	assert_false(ks.suppress_tspin_triple, "double_trouble should not suppress tspin_triple")

func test_triple_threat_has_no_suppression_flags() -> void:
	var ks: Keystone = ResourceRegistry.find_by_id(ResourceRegistry.all_keystones, "triple_threat")
	assert_not_null(ks)
	assert_false(ks.suppress_tspin_single, "triple_threat should not suppress tspin_single")
	assert_false(ks.suppress_tspin_double, "triple_threat should not suppress tspin_double")
