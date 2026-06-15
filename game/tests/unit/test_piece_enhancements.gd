extends GutTest

# ── honed_bonus ──────────────────────────────────────────────────────────

func test_honed_bonus_zero_cells() -> void:
	assert_eq(PieceEnhancements.honed_bonus({}), 0)

func test_honed_bonus_three_cells() -> void:
	assert_eq(PieceEnhancements.honed_bonus({PieceEnhancements.HONED: 3}), 3)

# ── amplified_multiplier ─────────────────────────────────────────────────

func test_amplified_multiplier_zero_cells() -> void:
	assert_eq(PieceEnhancements.amplified_multiplier({}), 1.0)

func test_amplified_multiplier_two_cells() -> void:
	assert_eq(PieceEnhancements.amplified_multiplier({PieceEnhancements.AMPLIFIED: 2}), 1.5)

func test_amplified_multiplier_ten_cells_clamped() -> void:
	assert_eq(PieceEnhancements.amplified_multiplier({PieceEnhancements.AMPLIFIED: 10}), 3.0)

# ── gilded_coins / shield_charges ────────────────────────────────────────

func test_gilded_coins_linear_and_empty() -> void:
	assert_eq(PieceEnhancements.gilded_coins({}), 0)
	assert_eq(PieceEnhancements.gilded_coins({PieceEnhancements.GILDED: 4}), 4)

func test_shield_charges_linear_and_empty() -> void:
	assert_eq(PieceEnhancements.shield_charges({}), 0)
	assert_eq(PieceEnhancements.shield_charges({PieceEnhancements.REINFORCED: 5}), 5)

# ── count_in_rows ────────────────────────────────────────────────────────

func test_count_in_rows_tallies_only_given_rows() -> void:
	var enh_grid := []
	for r in range(4):
		var row := []
		row.resize(3)
		row.fill("")
		enh_grid.append(row)
	enh_grid[0][0] = PieceEnhancements.HONED
	enh_grid[0][1] = PieceEnhancements.HONED
	enh_grid[1][0] = PieceEnhancements.GILDED
	enh_grid[2][2] = PieceEnhancements.AMPLIFIED

	var counts := PieceEnhancements.count_in_rows(enh_grid, [0, 1])
	assert_eq(counts.get(PieceEnhancements.HONED, 0), 2)
	assert_eq(counts.get(PieceEnhancements.GILDED, 0), 1)
	assert_eq(counts.get(PieceEnhancements.AMPLIFIED, 0), 0)

func test_count_in_rows_ignores_excluded_rows() -> void:
	var enh_grid := []
	for r in range(2):
		var row := []
		row.resize(3)
		row.fill("")
		enh_grid.append(row)
	enh_grid[1][0] = PieceEnhancements.REINFORCED

	var counts := PieceEnhancements.count_in_rows(enh_grid, [0])
	assert_eq(counts.get(PieceEnhancements.REINFORCED, 0), 0)
