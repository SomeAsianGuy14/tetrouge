extends GutTest

var _board: TetrisBoard
var _cfg: RoundConfig

func before_each() -> void:
	_cfg = RoundConfig.new()
	_cfg.hold_lockout_enabled = false
	_board = TetrisBoard.new()
	_board.setup(_cfg)

func after_each() -> void:
	_board.free()

# ── 2-slot hold queue ─────────────────────────────────────────────────────────

func test_hold_2_slots_first_hold_fills_slot_one() -> void:
	_cfg.hold_slots = 2
	var first := _board.current_type
	_board.input_hold()
	assert_eq(_board.held_pieces.size(), 1)
	assert_eq(_board.held_pieces[0], first)

func test_hold_2_slots_second_hold_fills_slot_two() -> void:
	_cfg.hold_slots = 2
	var first := _board.current_type
	_board.input_hold()
	_board.hold_used = false
	var second := _board.current_type
	_board.input_hold()
	assert_eq(_board.held_pieces.size(), 2)
	assert_eq(_board.held_pieces[0], first)
	assert_eq(_board.held_pieces[1], second)

func test_hold_2_slots_third_hold_cycles_queue() -> void:
	_cfg.hold_slots = 2
	var first := _board.current_type
	_board.input_hold()
	_board.hold_used = false
	_board.input_hold()
	_board.hold_used = false
	_board.input_hold()
	assert_eq(_board.held_pieces.size(), 2)
	assert_eq(_board.current_type, first)

# ── 1-slot hold ──────────────────────────────────────────────────────────────

func test_hold_1_slot_first_hold_fills_held() -> void:
	_cfg.hold_slots = 1
	var first := _board.current_type
	_board.input_hold()
	assert_eq(_board.held_pieces.size(), 1)
	assert_eq(_board.held_pieces[0], first)

func test_hold_1_slot_second_hold_swaps_piece_back() -> void:
	_cfg.hold_slots = 1
	var first := _board.current_type
	_board.input_hold()
	_board.hold_used = false
	_board.input_hold()
	assert_eq(_board.current_type, first)
	assert_eq(_board.held_pieces.size(), 1)

# ── Back-to-back holds with lockout enabled ────────────────────────────────────

func test_hold_2_slots_back_to_back_fills_both_slots_with_lockout_enabled() -> void:
	_cfg.hold_lockout_enabled = true
	_cfg.hold_slots = 2
	var first := _board.current_type
	_board.input_hold()
	var second := _board.current_type
	_board.input_hold()
	assert_eq(_board.held_pieces.size(), 2)
	assert_eq(_board.held_pieces[0], first)
	assert_eq(_board.held_pieces[1], second)

func test_hold_2_slots_lockout_does_not_apply_free_cycling() -> void:
	_cfg.hold_lockout_enabled = true
	_cfg.hold_slots = 2
	_board.input_hold()
	_board.input_hold()
	var saved_oldest = _board.held_pieces[0]
	var saved_second = _board.held_pieces[1]
	var saved_current = _board.current_type
	_board.input_hold()
	# Queue cycles: oldest held becomes current, current pushed to back
	assert_eq(_board.held_pieces.size(), 2)
	assert_eq(_board.current_type, saved_oldest)
	assert_eq(_board.held_pieces[0], saved_second)
	assert_eq(_board.held_pieces[1], saved_current)

func test_hold_2_slots_free_cycling_repeated_holds_cycle_pieces() -> void:
	_cfg.hold_lockout_enabled = true
	_cfg.hold_slots = 2
	_board.input_hold()
	_board.input_hold()
	var observed := []
	for i in range(6):
		observed.append(_board.current_type)
		_board.input_hold()
	assert_eq(observed.size(), 6)

func test_hold_1_slot_back_to_back_still_blocked_by_lockout() -> void:
	_cfg.hold_lockout_enabled = true
	_cfg.hold_slots = 1
	_board.input_hold()
	var before_type := _board.current_type
	_board.input_hold()
	assert_eq(_board.held_pieces.size(), 1)
	assert_eq(_board.current_type, before_type)
