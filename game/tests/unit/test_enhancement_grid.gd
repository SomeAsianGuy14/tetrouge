extends GutTest

var _board: TetrisBoard
var _cfg: RoundConfig

func before_each() -> void:
	_cfg = RoundConfig.new()
	_board = TetrisBoard.new()
	_board.setup(_cfg)

func after_each() -> void:
	_board.free()

# ── Places the current piece so its bottom cells complete the bottom row,
#    pre-filling the remaining bottom-row columns (the first `gilded_count`
#    of which are marked Gilded), and returns the pivot to lock at. ────────
func _setup_full_bottom_row(gilded_count: int) -> Vector2i:
	var cells: Array[Vector2i] = PieceData.get_cells(_board.current_type, _board.current_rotation)
	var min_x: int = cells[0].x
	var max_y: int = cells[0].y
	for c: Vector2i in cells:
		min_x = mini(min_x, c.x)
		max_y = maxi(max_y, c.y)
	var pivot := Vector2i(-min_x, TetrisBoard.TOTAL_ROWS - 1 - max_y)
	var world_cells: Array[Vector2i] = PieceData.get_world_cells(_board.current_type, _board.current_rotation, pivot)
	var bottom_cols := []
	for wc: Vector2i in world_cells:
		if wc.y == TetrisBoard.TOTAL_ROWS - 1:
			bottom_cols.append(wc.x)
	var fill_cols := []
	for col in range(TetrisBoard.COLS):
		if not bottom_cols.has(col):
			fill_cols.append(col)
	for col in fill_cols:
		_board.grid[TetrisBoard.TOTAL_ROWS - 1][col] = 1
	for i in gilded_count:
		_board.enh_grid[TetrisBoard.TOTAL_ROWS - 1][fill_cols[i]] = PieceEnhancements.GILDED
	return pivot

# ── 13.5: enh_grid stays aligned with grid through row clears ────────────

func test_find_and_clear_rows_single_row_keeps_enh_grid_aligned() -> void:
	for col in range(TetrisBoard.COLS):
		_board.grid[TetrisBoard.TOTAL_ROWS - 1][col] = 1
	_board.enh_grid[TetrisBoard.TOTAL_ROWS - 1][0] = PieceEnhancements.HONED
	_board.enh_grid[TetrisBoard.TOTAL_ROWS - 2][3] = PieceEnhancements.GILDED

	var cleared := _board._find_and_clear_rows()

	assert_eq(cleared, [TetrisBoard.TOTAL_ROWS - 1])
	assert_eq(_board.grid.size(), TetrisBoard.TOTAL_ROWS)
	assert_eq(_board.enh_grid.size(), TetrisBoard.TOTAL_ROWS)
	# Surviving row shifted down by one
	assert_eq(_board.enh_grid[TetrisBoard.TOTAL_ROWS - 1][3], PieceEnhancements.GILDED)
	# New empty row inserted at the top
	for col in range(TetrisBoard.COLS):
		assert_eq(_board.enh_grid[0][col], "")

func test_find_and_clear_rows_multi_row_keeps_enh_grid_aligned() -> void:
	for row in [TetrisBoard.TOTAL_ROWS - 1, TetrisBoard.TOTAL_ROWS - 2]:
		for col in range(TetrisBoard.COLS):
			_board.grid[row][col] = 1
		_board.enh_grid[row][0] = PieceEnhancements.HONED
	_board.enh_grid[TetrisBoard.TOTAL_ROWS - 3][5] = PieceEnhancements.AMPLIFIED

	var cleared := _board._find_and_clear_rows()

	assert_eq(cleared.size(), 2)
	assert_eq(_board.grid.size(), TetrisBoard.TOTAL_ROWS)
	assert_eq(_board.enh_grid.size(), TetrisBoard.TOTAL_ROWS)
	# Surviving row shifted down by two
	assert_eq(_board.enh_grid[TetrisBoard.TOTAL_ROWS - 1][5], PieceEnhancements.AMPLIFIED)
	for col in range(TetrisBoard.COLS):
		assert_eq(_board.enh_grid[0][col], "")
		assert_eq(_board.enh_grid[1][col], "")

# ── 13.6: enh_grid stays aligned through insert_garbage_rows ─────────────

func test_insert_garbage_rows_keeps_enh_grid_aligned_and_unenhanced() -> void:
	_board.enh_grid[1][0] = PieceEnhancements.HONED
	_board.enh_grid[TetrisBoard.TOTAL_ROWS - 1][2] = PieceEnhancements.GILDED

	_board.insert_garbage_rows(1, 4)

	assert_eq(_board.grid.size(), TetrisBoard.TOTAL_ROWS)
	assert_eq(_board.enh_grid.size(), TetrisBoard.TOTAL_ROWS)
	# Surviving row shifted up by one
	assert_eq(_board.enh_grid[0][0], PieceEnhancements.HONED)
	# New garbage row at the bottom is unenhanced
	for col in range(TetrisBoard.COLS):
		assert_eq(_board.enh_grid[TetrisBoard.TOTAL_ROWS - 1][col], "")

# ── 13.7: clear_board resets enh_grid ─────────────────────────────────────

func test_clear_board_resets_enh_grid_to_fully_empty() -> void:
	_board.enh_grid[5][2] = PieceEnhancements.AMPLIFIED
	_board.clear_board()
	for row: Array in _board.enh_grid:
		for cell in row:
			assert_eq(cell, "")

# ── 13.8: lock-time stamping ──────────────────────────────────────────────

func test_lock_piece_stamps_enh_grid_matching_current_enhancement() -> void:
	_board.current_enhancement = PieceEnhancements.HONED
	var locked_type := _board.current_type
	var locked_rotation := _board.current_rotation
	var locked_pivot := _board.ghost_pivot

	_board.input_hard_drop()

	var cells: Array[Vector2i] = PieceData.get_world_cells(locked_type, locked_rotation, locked_pivot)
	for cell: Vector2i in cells:
		assert_eq(_board.grid[cell.y][cell.x], PieceData.get_color_id(locked_type))
		assert_eq(_board.enh_grid[cell.y][cell.x], PieceEnhancements.HONED)
	assert_eq(_board.current_enhancement, "")

# ── 13.9: pending_enhancement_counts at lock time ─────────────────────────

func test_pending_enhancement_counts_without_delay() -> void:
	_cfg.line_clear_delay = 0.0
	var pivot := _setup_full_bottom_row(2)
	_board.current_pivot = pivot
	_board._lock_piece()
	assert_eq(_board.pending_enhancement_counts.get(PieceEnhancements.GILDED, 0), 2)

func test_pending_enhancement_counts_with_delay() -> void:
	_cfg.line_clear_delay = 0.5
	var pivot := _setup_full_bottom_row(2)
	_board.current_pivot = pivot
	_board._lock_piece()
	assert_eq(_board.pending_enhancement_counts.get(PieceEnhancements.GILDED, 0), 2)

# ── 13.10: holding an enhanced piece ──────────────────────────────────────

func test_input_hold_moves_enhancement_to_held_enhancements() -> void:
	_cfg.hold_slots = 2
	_board.current_enhancement = PieceEnhancements.AMPLIFIED
	_board.input_hold()
	assert_eq(_board.held_enhancements.size(), 1)
	assert_eq(_board.held_enhancements[0], PieceEnhancements.AMPLIFIED)
	assert_eq(_board.current_enhancement, "")
