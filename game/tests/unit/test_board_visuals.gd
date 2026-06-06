extends GutTest

# ── Crack pattern index ────────────────────────────────────────────────────

func _crack_pattern_index(col: int, screen_row: int) -> int:
	return (col * 7 + screen_row * 13) % 4

func test_crack_pattern_is_deterministic() -> void:
	for col in range(10):
		for row in range(20):
			var first := _crack_pattern_index(col, row)
			var second := _crack_pattern_index(col, row)
			assert_eq(first, second, "Pattern index must be the same on repeated calls for (%d,%d)" % [col, row])

func test_crack_pattern_varies_by_position() -> void:
	var seen := {}
	for col in range(10):
		for row in range(20):
			var idx := _crack_pattern_index(col, row)
			seen[idx] = true
	assert_eq(seen.size(), 4, "All 4 crack patterns should appear across a full 10x20 board")
