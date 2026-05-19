extends GutTest

var board: TetrisBoard
var cfg: RoundConfig

func before_each() -> void:
	cfg = RoundConfig.new()
	board = TetrisBoard.new()
	board.config = cfg
	board._init_grid()

func after_each() -> void:
	board.free()

# Helper: fill a specific grid cell (using grid row/col, not screen row)
func _fill_cell(row: int, col: int) -> void:
	board.grid[row][col] = 1

# Helper: place a T-piece at a pivot and set up 3 filled corners
# Pivot at (5, 10) (visible area), rotation state 0 (flat horizontal)
func _setup_tspin_position() -> void:
	var pivot := Vector2i(5, 10)
	board.current_type = "T"
	board.current_pivot = pivot
	board.current_rotation = 1  # State R: T pointing right
	board.last_move_was_rotation = true
	# Fill 3 diagonal corners of the pivot to satisfy 3-corner rule
	# Corners: (-1,-1), (1,-1), (-1,1), (1,1) relative to pivot
	_fill_cell(pivot.y - 1, pivot.x - 1)  # top-left
	_fill_cell(pivot.y - 1, pivot.x + 1)  # top-right
	_fill_cell(pivot.y + 1, pivot.x - 1)  # bottom-left
	# 3 of 4 corners filled → T-spin

# ── T-spin detection ──────────────────────────────────────────────────────

func test_3_corners_and_rotation_is_tspin() -> void:
	_setup_tspin_position()
	var result := board._detect_tspin(
		board.current_type,
		board.current_pivot,
		board.current_rotation,
		true  # was_rotation
	)
	assert_true(result, "3 occupied corners + rotation should be a T-spin")

func test_2_corners_is_not_tspin() -> void:
	var pivot := Vector2i(5, 10)
	board.current_type = "T"
	board.current_pivot = pivot
	# Only fill 2 corners
	_fill_cell(pivot.y - 1, pivot.x - 1)
	_fill_cell(pivot.y - 1, pivot.x + 1)
	var result := board._detect_tspin("T", pivot, 0, true)
	assert_false(result, "Only 2 corners occupied should not be a T-spin")

func test_no_rotation_is_not_tspin() -> void:
	_setup_tspin_position()
	var result := board._detect_tspin(
		board.current_type,
		board.current_pivot,
		board.current_rotation,
		false  # was_rotation = false
	)
	assert_false(result, "No preceding rotation should not be a T-spin")

func test_non_t_piece_is_not_tspin() -> void:
	_setup_tspin_position()
	var result := board._detect_tspin("I", board.current_pivot, 0, true)
	assert_false(result, "Non-T piece cannot be a T-spin")

func test_wall_counts_as_corner() -> void:
	# Pivot near left wall: corner at col -1 is out of bounds → counts as filled
	var pivot := Vector2i(0, 10)
	board.current_type = "T"
	board.current_pivot = pivot
	# Only fill 2 grid corners; the wall provides the 3rd
	_fill_cell(pivot.y - 1, pivot.x + 1)  # top-right
	_fill_cell(pivot.y + 1, pivot.x + 1)  # bottom-right
	# col -1 is a wall → counts, giving 3 total
	var result := board._detect_tspin("T", pivot, 0, true)
	assert_true(result, "Out-of-bounds corner (wall) counts toward T-spin detection")
