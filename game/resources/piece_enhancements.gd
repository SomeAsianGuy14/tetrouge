class_name PieceEnhancements

# ── Type ids ─────────────────────────────────────────────────────────────
const HONED := "honed"
const AMPLIFIED := "amplified"
const GILDED := "gilded"
const REINFORCED := "reinforced"

const ALL_TYPES: Array = [HONED, AMPLIFIED, GILDED, REINFORCED]

# ── Per-cell magnitudes ──────────────────────────────────────────────────
const HONED_ATTACK_PER_CELL := 1
const AMPLIFIED_PER_CELL := 0.25
const AMPLIFIED_MULTIPLIER_CAP := 3.0
const GILDED_COINS_PER_CELL := 1
const REINFORCED_SHIELD_PER_CELL := 1

# ── Per-type style colors ───────────────────────────────────────────────
const HONED_COLOR := Color(0.78, 0.80, 0.84)      # silver fill
const GILDED_COLOR := Color(0.95, 0.80, 0.15)     # golden fill
const REINFORCED_FILL_COLOR := Color(0.40, 0.28, 0.16)   # brown fill
const REINFORCED_BORDER_COLOR := Color(0.78, 0.80, 0.84) # silver border
const AMPLIFIED_TRIANGLE_COLOR := Color(1.0, 0.95, 0.2)  # yellow triangle

# ── Counting ─────────────────────────────────────────────────────────────

static func count_in_rows(enh_grid: Array, rows: Array) -> Dictionary:
	var counts := {}
	for row_idx in rows:
		var row: Array = enh_grid[row_idx]
		for cell in row:
			if cell == "":
				continue
			counts[cell] = counts.get(cell, 0) + 1
	return counts

# ── Benefit math ─────────────────────────────────────────────────────────

static func honed_bonus(counts: Dictionary, per_cell: int = HONED_ATTACK_PER_CELL) -> int:
	return counts.get(HONED, 0) * per_cell

static func amplified_multiplier(counts: Dictionary, per_cell: float = AMPLIFIED_PER_CELL) -> float:
	var cells: int = counts.get(AMPLIFIED, 0)
	return minf(1.0 + cells * per_cell, AMPLIFIED_MULTIPLIER_CAP)

static func gilded_coins(counts: Dictionary, per_cell: int = GILDED_COINS_PER_CELL) -> int:
	return counts.get(GILDED, 0) * per_cell

static func shield_charges(counts: Dictionary, per_cell: int = REINFORCED_SHIELD_PER_CELL) -> int:
	return counts.get(REINFORCED, 0) * per_cell

# ── Random resolution ───────────────────────────────────────────────────

static func resolve_type(enhancement_type: String) -> String:
	if enhancement_type == "random":
		return ALL_TYPES.pick_random()
	return enhancement_type

# ── Benefit doubling ────────────────────────────────────────────────────

static func double_counts(counts: Dictionary) -> Dictionary:
	var doubled := {}
	for key in counts:
		doubled[key] = counts[key] * 2
	return doubled
