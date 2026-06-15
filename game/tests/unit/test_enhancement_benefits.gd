extends GutTest

var _saved_keystones: Array
var _saved_techniques: Array
var _saved_coins: int
var _managers: Array = []
var _boards: Array = []

func before_each() -> void:
	_saved_keystones = RunState.keystones.duplicate()
	_saved_techniques = RunState.techniques.duplicate()
	_saved_coins = Economy.coins
	RunState.keystones = []
	RunState.techniques = []
	Economy.coins = 0
	_managers = []
	_boards = []

func after_each() -> void:
	RunState.keystones = _saved_keystones
	RunState.techniques = _saved_techniques
	Economy.coins = _saved_coins
	for m in _managers:
		m.free()
	for b in _boards:
		b.free()

func _make_manager(interval: float = 5.0) -> RunManager:
	var rm := RunManager.new()
	var cfg := RoundConfig.new()
	cfg.garbage_interval_min = interval
	cfg.garbage_interval_max = interval
	cfg.quota = 999
	rm.current_config = cfg
	rm._next_garbage_interval = interval
	_managers.append(rm)
	return rm

func _make_board() -> TetrisBoard:
	var board := TetrisBoard.new()
	board.setup(RoundConfig.new())
	_boards.append(board)
	return board

# ── 13.16: shield absorption ──────────────────────────────────────────────

func test_shield_absorbs_wave_fully_no_packet() -> void:
	var rm := _make_manager(5.0)
	rm.current_config.garbage_lines_min = 2
	rm.current_config.garbage_lines_max = 2
	rm._garbage_shield = 5

	rm._tick_enemy_garbage(5.1)

	assert_true(rm._garbage_packets.is_empty(), "fully absorbed wave creates no packet")
	assert_eq(rm._garbage_shield, 3)

func test_shield_absorbs_wave_partially_then_hits_zero() -> void:
	var rm := _make_manager(5.0)
	rm.current_config.garbage_lines_min = 3
	rm.current_config.garbage_lines_max = 3
	rm._garbage_shield = 1

	rm._tick_enemy_garbage(5.1)

	assert_eq(rm._garbage_packets.size(), 1)
	assert_eq(rm._garbage_packets[0].lines, 2, "smaller packet after partial absorption")
	assert_eq(rm._garbage_shield, 0)

# ── 13.17: shield resets at round start ───────────────────────────────────

func test_shield_resets_to_zero_at_round_start() -> void:
	var rm := _make_manager()
	rm._garbage_shield = 7
	rm._reset_enhancement_round_state()
	assert_eq(rm._garbage_shield, 0)

# ── 13.18 / 13.19: enhancement pipeline ordering ──────────────────────────

func test_honed_bonus_applied_before_keystone_multiplier() -> void:
	var ks := Keystone.new()
	ks.quad_multiplier = 2.0
	RunState.keystones = [ks]

	var rm := _make_manager()
	rm._last_attack_was_quad = false
	rm._pending_enh_counts = {PieceEnhancements.HONED: 2}

	rm._on_attack_generated(4, "quad")

	# (4 base + 2 honed) * 2 keystone = 12
	assert_eq(rm.quota_accumulated, 12)

func test_amplified_multiplier_applied_after_keystone_multiplier() -> void:
	var ks := Keystone.new()
	ks.quad_multiplier = 2.0
	RunState.keystones = [ks]

	var rm := _make_manager()
	rm._last_attack_was_quad = false
	rm._pending_enh_counts = {PieceEnhancements.AMPLIFIED: 2}

	rm._on_attack_generated(4, "quad")

	# (4 base * 2 keystone) * 1.5 amplified = int(8 * 1.5) = 12
	assert_eq(rm.quota_accumulated, 12)

# ── 13.20: gilded coins paid once per clear ───────────────────────────────

func test_gilded_coins_paid_once_despite_b2b_and_combo_events() -> void:
	var rm := _make_manager()
	var board := _make_board()
	rm.current_board = board
	board.pending_enhancement_counts = {PieceEnhancements.GILDED: 3}

	rm._on_line_clear_delay_started("quad")
	assert_eq(Economy.coins, 3)

	rm._on_attack_generated(4, "quad")
	rm._on_attack_generated(1, "b2b")
	rm._on_attack_generated(2, "combo")

	assert_eq(Economy.coins, 3, "gilded coins paid exactly once for the clear")

# ── 13.21: suppressed clear still pays gilded/reinforced ──────────────────

func test_suppressed_clear_still_pays_gilded_and_reinforced() -> void:
	var ks := Keystone.new()
	ks.suppress_non_singles = true
	RunState.keystones = [ks]

	var rm := _make_manager()
	var board := _make_board()
	rm.current_board = board
	board.pending_enhancement_counts = {
		PieceEnhancements.GILDED: 2,
		PieceEnhancements.REINFORCED: 3,
	}

	rm._on_line_clear_delay_started("quad")

	assert_eq(Economy.coins, 2, "gilded coins paid despite suppression")
	assert_eq(rm._garbage_shield, 3, "reinforced charges granted despite suppression")

	rm._on_attack_generated(4, "quad")
	assert_eq(rm.quota_accumulated, 0, "attack itself remains suppressed")

# ── 11.12: Last Stand ──────────────────────────────────────────────────────

func test_last_stand_grants_shield_at_height_threshold() -> void:
	var t := Technique.new()
	t.effect_type = "height_shield"
	t.params = {"threshold_pct": 0.8, "shield": 10}
	RunState.techniques = [t]

	var rm := _make_manager()
	var board := _make_board()
	rm.current_board = board
	rm._technique_round_state = TechniqueRoundState.new()
	rm._garbage_shield = 0
	board.summit_height = 16  # 16/20 = 0.8, meets threshold

	rm._on_piece_locked()

	assert_eq(rm._garbage_shield, 10)
	assert_true(rm._technique_round_state.last_stand_triggered)

func test_last_stand_does_not_fire_below_threshold() -> void:
	var t := Technique.new()
	t.effect_type = "height_shield"
	t.params = {"threshold_pct": 0.8, "shield": 10}
	RunState.techniques = [t]

	var rm := _make_manager()
	var board := _make_board()
	rm.current_board = board
	rm._technique_round_state = TechniqueRoundState.new()
	rm._garbage_shield = 0
	board.summit_height = 15  # 15/20 = 0.75, below threshold

	rm._on_piece_locked()

	assert_eq(rm._garbage_shield, 0)
	assert_false(rm._technique_round_state.last_stand_triggered)

func test_last_stand_does_not_fire_twice_in_same_round() -> void:
	var t := Technique.new()
	t.effect_type = "height_shield"
	t.params = {"threshold_pct": 0.8, "shield": 10}
	RunState.techniques = [t]

	var rm := _make_manager()
	var board := _make_board()
	rm.current_board = board
	rm._technique_round_state = TechniqueRoundState.new()
	rm._garbage_shield = 0
	board.summit_height = 16

	rm._on_piece_locked()
	assert_eq(rm._garbage_shield, 10)

	board.summit_height = 18  # board grows further within the same round
	rm._on_piece_locked()
	assert_eq(rm._garbage_shield, 10, "Last Stand only grants once per round")

# ── 11.13: The Best Defense ─────────────────────────────────────────────────

func test_best_defense_adds_shield_without_reducing_attack() -> void:
	var t := Technique.new()
	t.effect_type = "attack_to_shield"
	t.params = {"pct": 0.25}
	RunState.techniques = [t]

	var rm := _make_manager()
	rm._garbage_shield = 0

	rm._on_attack_generated(4, "quad")

	assert_eq(rm.quota_accumulated, 4, "dealt damage is unaffected")
	assert_eq(rm._garbage_shield, 1, "floor(4 * 0.25) = 1 shield gained")

func test_best_defense_no_shield_on_bonus_event() -> void:
	var t := Technique.new()
	t.effect_type = "attack_to_shield"
	t.params = {"pct": 0.25}
	RunState.techniques = [t]

	var rm := _make_manager()
	rm._garbage_shield = 0

	rm._on_attack_generated(4, "b2b")

	assert_eq(rm._garbage_shield, 0, "b2b/combo bonus events do not grant Best Defense shield")

# ── Round income breakdown tracking ───────────────────────────────────────

func test_round_enhancement_coins_tracks_gilded_clear_payouts() -> void:
	var rm := _make_manager()
	var board := _make_board()
	rm.current_board = board
	board.pending_enhancement_counts = {PieceEnhancements.GILDED: 3}

	rm._on_line_clear_delay_started("quad")

	assert_eq(rm._round_enhancement_coins, 3)

func test_round_technique_coins_tracks_economy_technique_payouts() -> void:
	var t := Technique.new()
	t.effect_type = "economy"
	t.params = {"trigger": "quad", "coins": 3}
	RunState.techniques = [t]

	var rm := _make_manager()
	rm._technique_round_state = TechniqueRoundState.new()

	rm._on_attack_generated(4, "quad")

	assert_eq(rm._round_technique_coins, 3)
	assert_eq(Economy.coins, 3)
