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

# ── per-cell overrides (Refined / Armored / Polished / Overclocked) ────────

func test_honed_bonus_with_refined_per_cell_override() -> void:
	var per_cell := PieceEnhancements.HONED_ATTACK_PER_CELL + 2
	assert_eq(PieceEnhancements.honed_bonus({PieceEnhancements.HONED: 3}, per_cell), 9)

func test_shield_charges_with_armored_per_cell_override() -> void:
	var per_cell := PieceEnhancements.REINFORCED_SHIELD_PER_CELL + 2
	assert_eq(PieceEnhancements.shield_charges({PieceEnhancements.REINFORCED: 4}, per_cell), 12)

func test_gilded_coins_with_polished_per_cell_override() -> void:
	var per_cell := PieceEnhancements.GILDED_COINS_PER_CELL + 1
	assert_eq(PieceEnhancements.gilded_coins({PieceEnhancements.GILDED: 4}, per_cell), 8)

func test_amplified_multiplier_with_overclocked_per_cell_override() -> void:
	var per_cell := PieceEnhancements.AMPLIFIED_PER_CELL + 0.125
	assert_eq(PieceEnhancements.amplified_multiplier({PieceEnhancements.AMPLIFIED: 2}, per_cell), 1.75)

func test_amplified_multiplier_with_override_still_clamped() -> void:
	var per_cell := PieceEnhancements.AMPLIFIED_PER_CELL + 0.125
	assert_eq(PieceEnhancements.amplified_multiplier({PieceEnhancements.AMPLIFIED: 10}, per_cell), PieceEnhancements.AMPLIFIED_MULTIPLIER_CAP)

# ── double_counts (Jack of All Trades) ─────────────────────────────────────

func test_double_counts_doubles_each_value() -> void:
	var doubled := PieceEnhancements.double_counts({PieceEnhancements.HONED: 2, PieceEnhancements.GILDED: 3})
	assert_eq(doubled.get(PieceEnhancements.HONED, 0), 4)
	assert_eq(doubled.get(PieceEnhancements.GILDED, 0), 6)

func test_double_counts_empty_dict() -> void:
	assert_eq(PieceEnhancements.double_counts({}), {})

# ── resolve_type ─────────────────────────────────────────────────────────

func test_resolve_type_passes_through_non_random() -> void:
	assert_eq(PieceEnhancements.resolve_type(PieceEnhancements.HONED), PieceEnhancements.HONED)

func test_resolve_type_random_resolves_to_known_type() -> void:
	var resolved := PieceEnhancements.resolve_type("random")
	assert_true(resolved in PieceEnhancements.ALL_TYPES)
