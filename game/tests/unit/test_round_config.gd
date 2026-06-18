extends GutTest

func test_floor1_small_quota_is_20() -> void:
	assert_eq(RunState.calculate_quota(1, "Small"), 20)

func test_floor1_big_quota_is_32() -> void:
	assert_eq(RunState.calculate_quota(1, "Big"), 32)

func test_floor1_elite_quota_is_44() -> void:
	assert_eq(RunState.calculate_quota(1, "Elite"), 44)

func test_floor1_boss_quota_is_56() -> void:
	assert_eq(RunState.calculate_quota(1, "Boss"), 56)

func test_floor3_small_quota_is_80() -> void:
	assert_eq(RunState.calculate_quota(3, "Small"), 80)

func test_quota_increases_with_floor() -> void:
	var f1 := RunState.calculate_quota(1, "Small")
	var f3 := RunState.calculate_quota(3, "Small")
	assert_gt(f3, f1)

func test_quota_increases_within_floor() -> void:
	var small := RunState.calculate_quota(2, "Small")
	var boss := RunState.calculate_quota(2, "Boss")
	assert_gt(boss, small)
