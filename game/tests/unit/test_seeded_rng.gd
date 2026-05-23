extends GutTest

var _saved_seed: int
var _saved_state: int

func before_each() -> void:
	_saved_seed = RunState.run_seed
	_saved_state = RunState.rng.state

func after_each() -> void:
	RunState.run_seed = _saved_seed
	RunState.rng.seed = _saved_seed
	RunState.rng.state = _saved_state

# ── seeded_shuffle ────────────────────────────────────────────────────────

func test_seeded_shuffle_same_seed_produces_same_order() -> void:
	RunState.run_seed = 12345
	RunState.rng.seed = 12345
	var arr_a := [1, 2, 3, 4, 5, 6, 7]
	RunState.seeded_shuffle(arr_a)

	RunState.rng.seed = 12345
	var arr_b := [1, 2, 3, 4, 5, 6, 7]
	RunState.seeded_shuffle(arr_b)

	assert_eq(arr_a, arr_b, "Same seed should produce identical shuffle order")

func test_seeded_shuffle_preserves_elements() -> void:
	RunState.run_seed = 99999
	RunState.rng.seed = 99999
	var original := [1, 2, 3, 4, 5, 6, 7]
	var arr := original.duplicate()
	RunState.seeded_shuffle(arr)

	assert_eq(arr.size(), original.size(), "Shuffled array should have same size")
	for v in original:
		assert_true(arr.has(v), "Shuffled array should contain all original elements")

# ── seeded_randf ──────────────────────────────────────────────────────────

func test_seeded_randf_same_seed_produces_same_value() -> void:
	RunState.run_seed = 77777
	RunState.rng.seed = 77777
	var a := RunState.seeded_randf()

	RunState.rng.seed = 77777
	var b := RunState.seeded_randf()

	assert_eq(a, b, "Same seed should produce same randf value")

func test_seeded_randf_returns_value_in_0_1_range() -> void:
	RunState.run_seed = 11111
	RunState.rng.seed = 11111
	for _i in 20:
		var v := RunState.seeded_randf()
		assert_true(v >= 0.0 and v <= 1.0, "seeded_randf should return a value in [0, 1]")

# ── PRNG state save / restore ─────────────────────────────────────────────

func test_rng_state_restore_continues_same_sequence() -> void:
	RunState.run_seed = 55555
	RunState.rng.seed = 55555
	RunState.seeded_randf()
	RunState.seeded_randf()

	var saved_state := RunState.rng.state
	var val_a := RunState.seeded_randf()

	RunState.rng.seed = RunState.run_seed
	RunState.rng.state = saved_state
	var val_b := RunState.seeded_randf()

	assert_eq(val_a, val_b, "Restored PRNG state should produce the same next value")

func test_rng_state_restore_matches_full_sequence() -> void:
	RunState.run_seed = 33333
	RunState.rng.seed = 33333

	var full_seq := []
	for _i in 10:
		full_seq.append(RunState.seeded_randf())

	var saved_state := RunState.rng.state
	for _i in 5:
		RunState.seeded_randf()  # advance past the checkpoint

	RunState.rng.seed = RunState.run_seed
	RunState.rng.state = saved_state
	var continued := []
	for _i in 5:
		continued.append(RunState.seeded_randf())

	assert_eq(continued, full_seq.slice(5, 10),
		"Sequence after restored state should match original continuation")
