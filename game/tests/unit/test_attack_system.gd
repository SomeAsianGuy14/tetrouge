extends GutTest

var board: TetrisBoard
var cfg: RoundConfig

func before_each() -> void:
	cfg = RoundConfig.new()
	board = TetrisBoard.new()
	board.config = cfg
	board.combo = -1
	board.is_b2b = false

func after_each() -> void:
	board.free()

# ── Base attack values ────────────────────────────────────────────────────

func test_single_sends_0() -> void:
	var result := board._calculate_attack(1, "single", false, false)
	assert_eq(result, 0)

func test_double_sends_1() -> void:
	var result := board._calculate_attack(2, "double", false, false)
	assert_eq(result, 1)

func test_triple_sends_2() -> void:
	var result := board._calculate_attack(3, "triple", false, false)
	assert_eq(result, 2)

func test_tetris_sends_4() -> void:
	var result := board._calculate_attack(4, "quad", true, false)
	assert_eq(result, 4)

func test_tspin_single_sends_2() -> void:
	var result := board._calculate_attack(1, "tspin_single", true, false)
	assert_eq(result, 2)

func test_tspin_double_sends_4() -> void:
	var result := board._calculate_attack(2, "tspin_double", true, false)
	assert_eq(result, 4)

func test_tspin_triple_sends_6() -> void:
	var result := board._calculate_attack(3, "tspin_triple", true, false)
	assert_eq(result, 6)

# ── B2B bonus ─────────────────────────────────────────────────────────────

func test_b2b_bonus_adds_1_to_second_tetris() -> void:
	# First qualifying clear sets the flag
	board._calculate_attack(4, "quad", true, false)
	assert_true(board.is_b2b, "B2B flag should be set after first qualifying clear")
	# Second qualifying clear should get +1 bonus
	var result := board._calculate_attack(4, "quad", true, false)
	assert_eq(result, 5)

func test_b2b_resets_after_non_qualifying_clear() -> void:
	board._calculate_attack(4, "quad", true, false)  # set B2B
	board._calculate_attack(1, "single", false, false)  # break B2B
	assert_false(board.is_b2b, "B2B flag should be cleared after single")
	var result := board._calculate_attack(4, "quad", true, false)
	assert_eq(result, 4, "No B2B bonus after chain reset")

func test_b2b_disabled_never_gives_bonus() -> void:
	cfg.b2b_disabled = true
	board._calculate_attack(4, "quad", true, false)
	var result := board._calculate_attack(4, "quad", true, false)
	assert_eq(result, 4, "B2B disabled should give no bonus")

# ── Perfect clear ─────────────────────────────────────────────────────────

func test_perfect_clear_returns_10() -> void:
	var result := board._calculate_attack(1, "single", false, true)
	assert_eq(result, 10)

func test_perfect_clear_overrides_tspin_value() -> void:
	var result := board._calculate_attack(2, "tspin_double", true, true)
	assert_eq(result, 10)

# ── Combo table ───────────────────────────────────────────────────────────

func test_combo_step_0_adds_0() -> void:
	board.combo = 0
	var result := board._calculate_attack(1, "single", false, false)
	assert_eq(result, 0, "Combo step 0 adds 0 bonus")

func test_combo_step_2_adds_1() -> void:
	board.combo = 2
	var result := board._calculate_attack(1, "single", false, false)
	assert_eq(result, 1)

func test_combo_step_4_adds_2() -> void:
	board.combo = 4
	var result := board._calculate_attack(1, "single", false, false)
	assert_eq(result, 2)

