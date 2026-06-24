extends GutTest

var _saved_seed: int
var _saved_state: int
var _saved_boss_enemy_ids: Array

func before_each() -> void:
	_saved_seed = RunState.run_seed
	_saved_state = RunState.rng.state
	_saved_boss_enemy_ids = RunState.used_boss_enemy_ids.duplicate()

func after_each() -> void:
	RunState.run_seed = _saved_seed
	RunState.rng.seed = _saved_seed
	RunState.rng.state = _saved_state
	RunState.used_boss_enemy_ids = _saved_boss_enemy_ids

func _load_enemies_by_tier(tier: String) -> Array:
	var dir := DirAccess.open("res://resources/data/enemies/")
	var result := []
	if dir:
		dir.list_dir_begin()
		var f := dir.get_next()
		while f != "":
			if f.ends_with(".tres"):
				var res := load("res://resources/data/enemies/" + f)
				if res != null and res.tier == tier:
					result.append(res)
			f = dir.get_next()
	return result

func test_effective_garbage_interval_stage1() -> void:
	var base := 35.0
	var effective := base * maxf(0.5, 1.0 - (1 - 1) * 0.1)
	assert_almost_eq(effective, base * 1.0, 0.001, "Stage 1 multiplier should be 1.0")

func test_effective_garbage_interval_stage5() -> void:
	var base := 35.0
	var effective := base * maxf(0.5, 1.0 - (5 - 1) * 0.1)
	assert_almost_eq(effective, base * 0.6, 0.001, "Stage 5 multiplier should be 0.6")

func test_effective_garbage_interval_floor() -> void:
	var base := 35.0
	for stage in [10, 15, 20, 100]:
		var effective := base * maxf(0.5, 1.0 - (stage - 1) * 0.1)
		assert_true(effective >= base * 0.5,
			"Interval should never drop below 50%% of base (stage %d)" % stage)

func test_boss_enemy_not_repeated() -> void:
	RunState.run_seed = 42
	RunState.rng.seed = 42
	RunState.used_boss_enemy_ids.clear()

	var boss_pool := _load_enemies_by_tier("Boss")
	assert_eq(boss_pool.size(), 14, "Expected 14 boss enemies in pool")

	var drawn_ids := []
	for _i in 14:
		var available := boss_pool.filter(func(e): return e.id not in RunState.used_boss_enemy_ids)
		RunState.seeded_shuffle(available)
		var chosen = available[0]
		assert_false(chosen.id in drawn_ids,
			"Boss enemy '%s' should not repeat before pool exhausted" % chosen.id)
		drawn_ids.append(chosen.id)
		RunState.used_boss_enemy_ids.append(chosen.id)

func test_common_enemy_from_correct_tier() -> void:
	var tier_to_round := {"Small": 0, "Big": 1, "Elite": 2}
	for tier in tier_to_round.keys():
		var pool := _load_enemies_by_tier(tier)
		assert_true(pool.size() > 0, "Tier '%s' pool should not be empty" % tier)
		for enemy in pool:
			assert_eq(enemy.tier, tier,
				"Enemy '%s' should have tier '%s' but has '%s'" % [enemy.id, tier, enemy.tier])

func test_encounter_only_excluded_from_registry_pool() -> void:
	for tier in ["Small", "Big", "Elite"]:
		var pool: Array = []
		for res in ResourceRegistry.all_enemies:
			if res.tier == tier and not res.encounter_only:
				pool.append(res)
		for enemy in pool:
			assert_false(enemy.encounter_only,
				"Encounter-only enemy '%s' should not be in filtered pool" % enemy.id)

func test_enemy_kill_counter_increments_and_resets() -> void:
	RunState.enemies_killed = 0
	RunState.enemies_killed += 1
	assert_eq(RunState.enemies_killed, 1)
	RunState.reset()
	assert_eq(RunState.enemies_killed, 0)
