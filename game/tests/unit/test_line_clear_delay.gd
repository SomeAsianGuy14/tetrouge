extends GutTest

var _board: TetrisBoard
var _cfg: RoundConfig

func before_each() -> void:
	_cfg = RoundConfig.new()
	_board = TetrisBoard.new()
	_board.setup(_cfg)

func after_each() -> void:
	_board.free()

func _fill_row(row: int) -> void:
	for col in range(10):
		_board.grid[row][col] = 1

# Place a piece at the very top of the hidden area so it won't interfere with
# any visible rows when _lock_piece() stamps it.
func _set_safe_piece() -> void:
	_board.current_type = "O"
	_board.current_pivot = Vector2i(0, 0)
	_board.current_rotation = 0

# ── _find_full_rows ───────────────────────────────────────────────────────────

func test_find_full_rows_returns_correct_indices_for_mixed_grid() -> void:
	_fill_row(20)
	_fill_row(21)
	_board.grid[19][5] = 1  # partial row — should not appear
	var result := _board._find_full_rows()
	assert_eq(result.size(), 2, "Only 2 fully-filled rows should be returned")
	assert_has(result, 20, "Row 20 should be in result")
	assert_has(result, 21, "Row 21 should be in result")

func test_find_full_rows_returns_empty_when_no_full_rows() -> void:
	var result := _board._find_full_rows()
	assert_eq(result.size(), 0, "Empty grid should return no full rows")

func test_find_full_rows_partial_row_not_included() -> void:
	_fill_row(21)
	_board.grid[20][5] = 1  # only one cell in row 20
	var result := _board._find_full_rows()
	assert_eq(result.size(), 1, "Only the fully-filled row should be returned")
	assert_has(result, 21)

# ── Signal ordering ───────────────────────────────────────────────────────────

func test_piece_locked_fires_immediately_before_lines_cleared_when_delay_active() -> void:
	_cfg.line_clear_delay = 0.5
	_fill_row(21)
	_set_safe_piece()
	watch_signals(_board)
	_board._lock_piece()
	assert_signal_emitted(_board, "piece_locked", "piece_locked should fire immediately on lock")
	assert_signal_not_emitted(_board, "lines_cleared", "lines_cleared should not fire until delay expires")
	assert_true(_board._in_line_clear_delay, "Board should be in line clear delay state")

func test_lines_cleared_and_lock_processed_do_not_fire_before_delay_expires() -> void:
	_cfg.line_clear_delay = 0.5
	_fill_row(21)
	_set_safe_piece()
	watch_signals(_board)
	_board._lock_piece()
	# Tick just under the delay threshold
	_board.tick(0.3)
	assert_signal_not_emitted(_board, "lines_cleared", "lines_cleared should not fire before delay expires")
	assert_signal_not_emitted(_board, "lock_processed", "lock_processed should not fire before delay expires")
	assert_true(_board._in_line_clear_delay, "Board should still be in delay state")

func test_lines_cleared_and_lock_processed_fire_after_delay_expires() -> void:
	_cfg.line_clear_delay = 0.5
	_fill_row(21)
	_set_safe_piece()
	watch_signals(_board)
	_board._lock_piece()
	# Tick past the delay threshold
	_board.tick(0.6)
	assert_signal_emitted(_board, "lines_cleared", "lines_cleared should fire after delay expires")
	assert_signal_emitted(_board, "lock_processed", "lock_processed should fire after delay expires")
	assert_false(_board._in_line_clear_delay, "Board should no longer be in delay state")

# ── Zero-delay bypass ─────────────────────────────────────────────────────────

func test_zero_delay_clears_rows_synchronously_without_entering_delay_state() -> void:
	_cfg.line_clear_delay = 0.0
	_fill_row(21)
	_set_safe_piece()
	watch_signals(_board)
	_board._lock_piece()
	assert_signal_emitted(_board, "lines_cleared", "lines_cleared should fire synchronously with zero delay")
	assert_signal_emitted(_board, "lock_processed", "lock_processed should fire synchronously with zero delay")
	assert_false(_board._in_line_clear_delay, "Board should not enter delay state when line_clear_delay is 0")

func test_zero_delay_still_emits_line_clear_delay_started_before_processing() -> void:
	# Technique evaluation listens to this signal so it must fire on clears in
	# both paths — otherwise skip_line_clear_delay keystones change technique
	# semantics (post-clear combo/B2B instead of pre-clear)
	_cfg.line_clear_delay = 0.0
	_fill_row(21)
	_set_safe_piece()
	watch_signals(_board)
	_board._lock_piece()
	assert_signal_emitted(_board, "line_clear_delay_started",
		"line_clear_delay_started should fire even with zero delay")

func test_zero_delay_no_clear_does_not_emit_line_clear_delay_started() -> void:
	_cfg.line_clear_delay = 0.0
	_set_safe_piece()
	watch_signals(_board)
	_board._lock_piece()
	assert_signal_not_emitted(_board, "line_clear_delay_started",
		"line_clear_delay_started should not fire when nothing clears")

# ── Summit height ─────────────────────────────────────────────────────────────

func test_summit_height_zero_for_empty_board() -> void:
	_board._update_summit_height()
	assert_eq(_board.summit_height, 0)

func test_summit_height_one_for_bottom_row_only() -> void:
	_board.grid[21][0] = 1
	_board._update_summit_height()
	assert_eq(_board.summit_height, 1, "stack only in bottom row → height 1")

func test_summit_height_twenty_when_stack_reaches_visible_top() -> void:
	_board.grid[2][0] = 1  # row 2 is the first visible row
	_board._update_summit_height()
	assert_eq(_board.summit_height, 20, "stack at top of visible area → height 20")

func test_summit_height_counts_rows_from_bottom() -> void:
	_board.grid[12][3] = 1
	_board._update_summit_height()
	assert_eq(_board.summit_height, 10, "topmost filled row 12 of 22 → 10 rows tall")

func test_summit_height_updates_on_lock_without_clear() -> void:
	_board.grid[18][0] = 1  # partial row, no clear
	_set_safe_piece()
	_board._lock_piece()
	assert_eq(_board.summit_height, 4, "summit must refresh on every lock, not only on clears")

# ── Keystone suppression ──────────────────────────────────────────────────────

func test_skip_line_clear_delay_keystone_sets_config_delay_to_zero() -> void:
	var ks := Keystone.new()
	ks.skip_line_clear_delay = true
	var cfg := RoundConfig.new()
	cfg.line_clear_delay = 0.5
	ks.apply_to_config(cfg)
	assert_eq(cfg.line_clear_delay, 0.0, "apply_to_config should set line_clear_delay to 0.0 when skip_line_clear_delay is true")

# ── Input blocked during delay ────────────────────────────────────────────────

func test_hold_during_delay_is_ignored() -> void:
	_cfg.line_clear_delay = 0.5
	_fill_row(21)
	_set_safe_piece()
	_board._lock_piece()
	assert_true(_board._in_line_clear_delay, "Should be in delay state")
	var held_before := _board.held_pieces.duplicate()
	var queue_size_before := _board.piece_queue.size()
	_board.input_hold()
	assert_eq(_board.held_pieces, held_before, "held_pieces should not change during delay")
	assert_eq(_board.piece_queue.size(), queue_size_before, "piece_queue should not change during delay")

func test_hard_drop_during_delay_is_ignored() -> void:
	_cfg.line_clear_delay = 0.5
	_fill_row(21)
	_set_safe_piece()
	_board._lock_piece()
	assert_true(_board._in_line_clear_delay, "Should be in delay state")
	_board.input_hard_drop()
	assert_true(_board._in_line_clear_delay, "Delay state should still be active after ignored hard drop")

func test_rotate_during_delay_is_ignored() -> void:
	_cfg.line_clear_delay = 0.5
	_fill_row(21)
	_set_safe_piece()
	_board._lock_piece()
	assert_true(_board._in_line_clear_delay, "Should be in delay state")
	var rotation_before := _board.current_rotation
	_board.input_rotate_cw()
	assert_eq(_board.current_rotation, rotation_before, "Rotation should not change during delay")

func test_directional_press_during_delay_queues_das_direction() -> void:
	_cfg.line_clear_delay = 0.5
	_fill_row(21)
	_set_safe_piece()
	_board._lock_piece()
	assert_true(_board._in_line_clear_delay, "Should be in delay state")
	assert_eq(_board.das_direction, 0, "DAS should be idle before press")
	_board.input_move_left_pressed()
	assert_eq(_board.das_direction, -1, "DAS direction should be queued even during delay")
	assert_eq(_board.das_timer, 0.0, "DAS timer should be reset on press")

func test_directional_press_during_delay_does_not_move_piece() -> void:
	_cfg.line_clear_delay = 0.5
	_fill_row(21)
	_set_safe_piece()
	_board._lock_piece()
	var pivot_before := _board.current_pivot
	_board.input_move_left_pressed()
	assert_eq(_board.current_pivot, pivot_before, "Piece position should not change during delay")

func test_keystone_without_flag_does_not_change_delay() -> void:
	var ks := Keystone.new()
	ks.skip_line_clear_delay = false
	var cfg := RoundConfig.new()
	cfg.line_clear_delay = 0.5
	ks.apply_to_config(cfg)
	assert_eq(cfg.line_clear_delay, 0.5, "apply_to_config should not change line_clear_delay when flag is false")
