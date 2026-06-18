extends GutTest

var _saved_floor: int

func before_each() -> void:
	_saved_floor = RunState.floor

func after_each() -> void:
	RunState.floor = _saved_floor

# ── Helpers ───────────────────────────────────────────────────────────────

func _stage_scalar(stage: int) -> float:
	return maxf(0.5, 1.0 - (stage - 1) * 0.1)

func _lines_bonus(stage: int) -> int:
	return (stage - 1) / 2

# ── Interval scaling ──────────────────────────────────────────────────────

func test_stage5_interval_is_60_percent_of_stage1_small() -> void:
	var s1_min := RunManager.SMALL_INTERVAL_MIN * _stage_scalar(1)
	var s1_max := RunManager.SMALL_INTERVAL_MAX * _stage_scalar(1)
	var s5_min := RunManager.SMALL_INTERVAL_MIN * _stage_scalar(5)
	var s5_max := RunManager.SMALL_INTERVAL_MAX * _stage_scalar(5)
	assert_almost_eq(s5_min / s1_min, 0.6, 0.001, "stage 5 min is 60% of stage 1 min")
	assert_almost_eq(s5_max / s1_max, 0.6, 0.001, "stage 5 max is 60% of stage 1 max")

func test_stage5_interval_is_60_percent_of_stage1_boss() -> void:
	var s1_min := RunManager.BOSS_INTERVAL_MIN * _stage_scalar(1)
	var s1_max := RunManager.BOSS_INTERVAL_MAX * _stage_scalar(1)
	var s5_min := RunManager.BOSS_INTERVAL_MIN * _stage_scalar(5)
	var s5_max := RunManager.BOSS_INTERVAL_MAX * _stage_scalar(5)
	assert_almost_eq(s5_min / s1_min, 0.6, 0.001, "boss stage 5 min is 60% of stage 1 min")
	assert_almost_eq(s5_max / s1_max, 0.6, 0.001, "boss stage 5 max is 60% of stage 1 max")

# ── Lines bonus ───────────────────────────────────────────────────────────

func test_lines_bonus_zero_at_stage1_and_2() -> void:
	assert_eq(_lines_bonus(1), 0, "stage 1 bonus is 0")
	assert_eq(_lines_bonus(2), 0, "stage 2 bonus is 0")

func test_lines_bonus_plus1_at_stage3_and_4() -> void:
	assert_eq(_lines_bonus(3), 1, "stage 3 bonus is +1")
	assert_eq(_lines_bonus(4), 1, "stage 4 bonus is +1")

func test_lines_bonus_plus2_at_stage5() -> void:
	assert_eq(_lines_bonus(5), 2, "stage 5 bonus is +2")

func test_lines_min_max_each_increase_by_bonus() -> void:
	var s1_min := RunManager.SMALL_LINES_MIN + _lines_bonus(1)
	var s1_max := RunManager.SMALL_LINES_MAX + _lines_bonus(1)
	var s3_min := RunManager.SMALL_LINES_MIN + _lines_bonus(3)
	var s3_max := RunManager.SMALL_LINES_MAX + _lines_bonus(3)
	var s5_min := RunManager.SMALL_LINES_MIN + _lines_bonus(5)
	var s5_max := RunManager.SMALL_LINES_MAX + _lines_bonus(5)
	assert_eq(s3_min - s1_min, 1, "stage 3 lines_min is 1 higher than stage 1")
	assert_eq(s3_max - s1_max, 1, "stage 3 lines_max is 1 higher than stage 1")
	assert_eq(s5_min - s1_min, 2, "stage 5 lines_min is 2 higher than stage 1")
	assert_eq(s5_max - s1_max, 2, "stage 5 lines_max is 2 higher than stage 1")

# ── Boss vs Normal tier ───────────────────────────────────────────────────

func test_tiers_get_progressively_faster_intervals() -> void:
	assert_lt(RunManager.BIG_INTERVAL_MIN, RunManager.SMALL_INTERVAL_MIN,
		"big min < small min")
	assert_lt(RunManager.BIG_INTERVAL_MAX, RunManager.SMALL_INTERVAL_MAX,
		"big max < small max")
	assert_lt(RunManager.ELITE_INTERVAL_MIN, RunManager.BIG_INTERVAL_MIN,
		"elite min < big min")
	assert_lt(RunManager.ELITE_INTERVAL_MAX, RunManager.BIG_INTERVAL_MAX,
		"elite max < big max")
	assert_lt(RunManager.BOSS_INTERVAL_MIN, RunManager.ELITE_INTERVAL_MIN,
		"boss min < elite min")
	assert_lt(RunManager.BOSS_INTERVAL_MAX, RunManager.ELITE_INTERVAL_MAX,
		"boss max < elite max")

func test_boss_interval_range_narrower_than_small() -> void:
	var small_width := RunManager.SMALL_INTERVAL_MAX - RunManager.SMALL_INTERVAL_MIN
	var boss_width := RunManager.BOSS_INTERVAL_MAX - RunManager.BOSS_INTERVAL_MIN
	assert_lt(boss_width, small_width, "boss interval range is narrower than small")
