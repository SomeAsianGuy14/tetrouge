extends GutTest

# Tests call RunState.calculate_quota() which is a pure function with no side effects.
# RunState is an autoload so it is always available.

func test_ante1_small_blind_quota_is_20() -> void:
	assert_eq(RunState.calculate_quota(1, 0), 20)

func test_ante1_big_blind_quota_is_28() -> void:
	assert_eq(RunState.calculate_quota(1, 1), 28)

func test_ante1_elite_blind_quota_is_36() -> void:
	assert_eq(RunState.calculate_quota(1, 2), 36)

func test_ante1_boss_blind_quota_is_44() -> void:
	assert_eq(RunState.calculate_quota(1, 3), 44)

func test_ante3_small_blind_quota_is_50() -> void:
	assert_eq(RunState.calculate_quota(3, 0), 50)

func test_ante5_boss_blind_quota_is_104() -> void:
	assert_eq(RunState.calculate_quota(5, 3), 104)

func test_quota_increases_with_ante() -> void:
	var a1 := RunState.calculate_quota(1, 0)
	var a3 := RunState.calculate_quota(3, 0)
	var a5 := RunState.calculate_quota(5, 0)
	assert_gt(a3, a1)
	assert_gt(a5, a3)

func test_quota_increases_within_ante() -> void:
	var small := RunState.calculate_quota(2, 0)
	var boss := RunState.calculate_quota(2, 3)
	assert_gt(boss, small)
