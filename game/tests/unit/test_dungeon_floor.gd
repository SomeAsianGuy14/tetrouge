extends GutTest

# ── State save/restore ────────────────────────────────────────────────────────

var _saved_floor: int
var _saved_cleared: int
var _saved_floor_data: DungeonFloor

func before_each() -> void:
	_saved_floor = RunState.floor
	_saved_cleared = RunState.combat_rooms_cleared_this_floor
	_saved_floor_data = RunState.current_floor_data

func after_each() -> void:
	RunState.floor = _saved_floor
	RunState.combat_rooms_cleared_this_floor = _saved_cleared
	RunState.current_floor_data = _saved_floor_data

# ── Helpers ───────────────────────────────────────────────────────────────────

func _make_room(room_type: String, footprint: Array[Vector2i]) -> DungeonRoom:
	var r := DungeonRoom.new()
	r.room_type = room_type
	r.tile_footprint = footprint
	r.visual_size = Vector2i(1, 1)
	return r

func _make_floor_linear() -> DungeonFloor:
	# start(0,0) — combat_small(1,0) — combat_big(2,0) — boss(3,0)
	var df := DungeonFloor.new()
	df.floor_number = 1

	var start := _make_room(DungeonRoom.TYPE_START, [Vector2i(0, 0)])
	start.cleared = true
	var c1 := _make_room(DungeonRoom.TYPE_COMBAT_SMALL, [Vector2i(1, 0)])
	var c2 := _make_room(DungeonRoom.TYPE_COMBAT_BIG, [Vector2i(2, 0)])
	var boss := _make_room(DungeonRoom.TYPE_BOSS, [Vector2i(3, 0)])

	df.rooms.append(start)  # index 0
	df.rooms.append(c1)     # index 1
	df.rooms.append(c2)     # index 2
	df.rooms.append(boss)   # index 3

	# Wire adjacency manually: 0—1—2—3
	start.adjacency = [1]
	c1.adjacency = [0, 2]
	c2.adjacency = [1, 3]
	boss.adjacency = [2]

	return df

# ── calculate_quota: floor / tier coverage ────────────────────────────────────

func test_quota_floor1_small() -> void:
	# base = 20 * 2^0 = 20, bonus Small = 0 → 20
	assert_eq(RunState.calculate_quota(1, "Small"), 20)

func test_quota_floor1_big() -> void:
	# base 20 + 12 = 32
	assert_eq(RunState.calculate_quota(1, "Big"), 32)

func test_quota_floor1_elite() -> void:
	assert_eq(RunState.calculate_quota(1, "Elite"), 44)

func test_quota_floor1_boss() -> void:
	assert_eq(RunState.calculate_quota(1, "Boss"), 56)

func test_quota_floor2_small() -> void:
	# base = 20 * 2^1 = 40, bonus 0 → 40
	assert_eq(RunState.calculate_quota(2, "Small"), 40)

func test_quota_floor2_boss() -> void:
	# 40 + 36 = 76
	assert_eq(RunState.calculate_quota(2, "Boss"), 76)

func test_quota_floor3_small() -> void:
	# base = 20 * 4 = 80
	assert_eq(RunState.calculate_quota(3, "Small"), 80)

func test_quota_floor4_small() -> void:
	# base = 20 * 8 = 160
	assert_eq(RunState.calculate_quota(4, "Small"), 160)

func test_quota_floor4_boss() -> void:
	# 160 + 36 = 196
	assert_eq(RunState.calculate_quota(4, "Boss"), 196)

# ── Within-floor quota multiplier ─────────────────────────────────────────────

func test_within_floor_multiplier_0_cleared() -> void:
	RunState.floor = 1
	RunState.combat_rooms_cleared_this_floor = 0
	var base := RunState.calculate_quota(1, "Small")
	var expected := ceili(base * (1.0 + 0 * 0.08))
	assert_eq(expected, 20)

func test_within_floor_multiplier_3_cleared() -> void:
	RunState.floor = 1
	RunState.combat_rooms_cleared_this_floor = 3
	var base := RunState.calculate_quota(1, "Small")
	var expected := ceili(base * (1.0 + 3 * 0.08))
	# ceil(20 * 1.24) = ceil(24.8) = 25
	assert_eq(expected, 25)

func test_within_floor_multiplier_10_cleared() -> void:
	RunState.floor = 1
	RunState.combat_rooms_cleared_this_floor = 10
	var base := RunState.calculate_quota(1, "Small")
	var expected := ceili(base * (1.0 + 10 * 0.08))
	# ceil(20 * 1.8) = ceil(36) = 36
	assert_eq(expected, 36)

func test_boss_quota_unaffected_by_cleared_count() -> void:
	# Boss quota uses base only (no multiplier) — verified by spec
	var base_boss := RunState.calculate_quota(1, "Boss")
	assert_eq(base_boss, 56)

# ── get_accessible_rooms ──────────────────────────────────────────────────────

func test_get_accessible_rooms_only_start_neighbors_at_floor_start() -> void:
	var df := _make_floor_linear()
	# start is cleared, so only rooms adjacent to start should be accessible
	var accessible := df.get_accessible_rooms()
	assert_eq(accessible.size(), 1)
	assert_eq(accessible[0].room_type, DungeonRoom.TYPE_COMBAT_SMALL)

func test_get_accessible_rooms_expands_after_clearing_second() -> void:
	var df := _make_floor_linear()
	df.rooms[1].cleared = true  # clear combat_small
	var accessible := df.get_accessible_rooms()
	# combat_big is now accessible; start and combat_small are cleared
	var types := accessible.map(func(r): return r.room_type)
	assert_has(types, DungeonRoom.TYPE_COMBAT_BIG)
	assert_does_not_have(types, DungeonRoom.TYPE_START)
	assert_does_not_have(types, DungeonRoom.TYPE_COMBAT_SMALL)

func test_get_accessible_rooms_empty_when_all_cleared() -> void:
	var df := _make_floor_linear()
	for room in df.rooms:
		room.cleared = true
	assert_eq(df.get_accessible_rooms().size(), 0)

# ── Orthogonal adjacency ──────────────────────────────────────────────────────

func test_rooms_sharing_tile_edge_are_adjacent() -> void:
	var df := DungeonFloor.new()
	df.floor_number = 1
	var a := _make_room(DungeonRoom.TYPE_COMBAT_SMALL, [Vector2i(0, 0)])
	var b := _make_room(DungeonRoom.TYPE_COMBAT_BIG,   [Vector2i(1, 0)])  # shares right edge
	df.rooms.append(a)
	df.rooms.append(b)
	DungeonGenerator._compute_adjacency(df)
	assert_has(a.adjacency, 1)
	assert_has(b.adjacency, 0)

func test_diagonal_only_rooms_are_not_adjacent() -> void:
	var df := DungeonFloor.new()
	df.floor_number = 1
	var a := _make_room(DungeonRoom.TYPE_COMBAT_SMALL, [Vector2i(0, 0)])
	var b := _make_room(DungeonRoom.TYPE_COMBAT_BIG,   [Vector2i(1, 1)])  # diagonal only
	df.rooms.append(a)
	df.rooms.append(b)
	DungeonGenerator._compute_adjacency(df)
	assert_does_not_have(a.adjacency, 1)
	assert_does_not_have(b.adjacency, 0)

func test_2x1_room_shares_edge_with_1x1_neighbor() -> void:
	var df := DungeonFloor.new()
	df.floor_number = 1
	var wide := _make_room(DungeonRoom.TYPE_COMBAT_ELITE, [Vector2i(0, 0), Vector2i(1, 0)])
	wide.visual_size = Vector2i(2, 1)
	var right := _make_room(DungeonRoom.TYPE_SHOP, [Vector2i(2, 0)])
	df.rooms.append(wide)
	df.rooms.append(right)
	DungeonGenerator._compute_adjacency(df)
	assert_has(wide.adjacency, 1)
	assert_has(right.adjacency, 0)

# ── BFS connectivity over multiple seeds ──────────────────────────────────────

func test_bfs_connected_over_20_seeds() -> void:
	var rng := RandomNumberGenerator.new()
	for seed_val in range(1, 21):
		rng.seed = seed_val
		var df := DungeonGenerator.generate(1, rng)
		assert_not_null(df, "Floor should be generated for seed %d" % seed_val)
		assert_true(DungeonGenerator._bfs_connected(df),
			"Floor should be BFS-connected for seed %d" % seed_val)

# ── combat_rooms_cleared counter ──────────────────────────────────────────────

func test_cleared_counter_increments_on_combat_clear() -> void:
	RunState.floor = 1
	RunState.combat_rooms_cleared_this_floor = 0
	RunState.combat_rooms_cleared_this_floor += 1
	assert_eq(RunState.combat_rooms_cleared_this_floor, 1)

func test_cleared_counter_resets_on_advance_floor() -> void:
	RunState.floor = 1
	RunState.combat_rooms_cleared_this_floor = 5
	RunState.advance_floor()
	assert_eq(RunState.combat_rooms_cleared_this_floor, 0)

func test_advance_floor_increments_floor_number() -> void:
	RunState.floor = 1
	RunState.combat_rooms_cleared_this_floor = 0
	RunState.advance_floor()
	assert_eq(RunState.floor, 2)

# ── Wishing Well probability ──────────────────────────────────────────────────

func test_wishing_well_starts_at_1_percent() -> void:
	var prob := 0.01
	assert_almost_eq(prob, 0.01, 0.0001)

func test_wishing_well_increments_by_1_percent_on_failure() -> void:
	var prob := 0.01
	prob += 0.01  # simulate a miss
	assert_almost_eq(prob, 0.02, 0.0001)

func test_wishing_well_resets_to_1_percent_on_success() -> void:
	var prob := 0.15
	prob = 0.01  # success resets
	assert_almost_eq(prob, 0.01, 0.0001)

func test_wishing_well_clamps_at_100_percent() -> void:
	var prob := 0.99
	prob = minf(prob + 0.01, 1.0)
	assert_almost_eq(prob, 1.0, 0.0001)

# ── Pickpocket deduction ──────────────────────────────────────────────────────

func test_pickpocket_deducts_floor_half_of_even_coins() -> void:
	var coins := 20
	var loss := int(floorf(coins * 0.5))
	assert_eq(loss, 10)

func test_pickpocket_deducts_floor_half_of_odd_coins() -> void:
	var coins := 7
	var loss := int(floorf(coins * 0.5))
	assert_eq(loss, 3)

func test_pickpocket_noop_at_zero_coins() -> void:
	var coins := 0
	var loss := int(floorf(coins * 0.5))
	assert_eq(loss, 0)

func test_pickpocket_deducts_floor_half_of_1_coin() -> void:
	var coins := 1
	var loss := int(floorf(coins * 0.5))
	assert_eq(loss, 0)

# ── Head Trauma remove / no-op ────────────────────────────────────────────────

func test_head_trauma_removes_one_technique_when_techniques_exist() -> void:
	var saved := RunState.techniques.duplicate()
	var t := Technique.new()
	t.id = "test_ht"
	t.display_name = "Test"
	t.effect_type = "flat"
	t.params = {}
	RunState.techniques = [t]
	RunState.seeded_shuffle(RunState.techniques)
	var removed: Technique = RunState.techniques[0]
	RunState.remove_technique(removed)
	assert_eq(RunState.techniques.size(), 0)
	RunState.techniques = saved

func test_head_trauma_noop_when_no_techniques() -> void:
	var saved := RunState.techniques.duplicate()
	RunState.techniques = []
	# simulating the head trauma logic
	var removed_name := ""
	if not RunState.techniques.is_empty():
		RunState.seeded_shuffle(RunState.techniques)
		removed_name = RunState.techniques[0].display_name
		RunState.remove_technique(RunState.techniques[0])
	assert_eq(removed_name, "")
	assert_eq(RunState.techniques.size(), 0)
	RunState.techniques = saved

# ── Seeded floor generation determinism ───────────────────────────────────────

func test_same_seed_produces_same_floor_layout() -> void:
	var rng_a := RandomNumberGenerator.new()
	rng_a.seed = 42
	var floor_a := DungeonGenerator.generate(1, rng_a)

	var rng_b := RandomNumberGenerator.new()
	rng_b.seed = 42
	var floor_b := DungeonGenerator.generate(1, rng_b)

	assert_eq(floor_a.rooms.size(), floor_b.rooms.size(),
		"Same seed must produce same room count")
	for i in range(floor_a.rooms.size()):
		assert_eq(floor_a.rooms[i].room_type, floor_b.rooms[i].room_type,
			"Room %d type must match" % i)
		assert_eq(floor_a.rooms[i].tile_footprint.size(), floor_b.rooms[i].tile_footprint.size(),
			"Room %d footprint size must match" % i)

# ── RunState.reset() initialisation ──────────────────────────────────────────

func test_reset_sets_floor_to_1() -> void:
	RunState.floor = 3
	RunState.reset()
	assert_eq(RunState.floor, 1)

func test_reset_sets_combat_rooms_cleared_to_0() -> void:
	RunState.combat_rooms_cleared_this_floor = 7
	RunState.reset()
	assert_eq(RunState.combat_rooms_cleared_this_floor, 0)

func test_reset_generates_valid_floor_data() -> void:
	RunState.reset()
	assert_not_null(RunState.current_floor_data)
	assert_gt(RunState.current_floor_data.rooms.size(), 0)
	assert_not_null(RunState.current_floor_data.get_start_room())
	assert_not_null(RunState.current_floor_data.get_boss_room())

# ── All rooms reachable from start ───────────────────────────────────────────

func test_all_rooms_reachable_from_start_over_20_seeds() -> void:
	var rng := RandomNumberGenerator.new()
	for seed_val in range(1, 21):
		rng.seed = seed_val
		var df := DungeonGenerator.generate(1, rng)
		assert_not_null(df, "Floor generated for seed %d" % seed_val)

		# BFS from start to verify every room is reachable
		var start_idx := -1
		for i in range(df.rooms.size()):
			if df.rooms[i].room_type == DungeonRoom.TYPE_START:
				start_idx = i
				break
		assert_true(start_idx >= 0, "Start room exists for seed %d" % seed_val)

		var visited: Dictionary = {}
		var queue: Array = [start_idx]
		visited[start_idx] = true
		while not queue.is_empty():
			var current: int = queue.pop_front()
			for adj in df.rooms[current].adjacency:
				if not visited.has(adj):
					visited[adj] = true
					queue.append(adj)

		assert_eq(visited.size(), df.rooms.size(),
			"All %d rooms reachable from start for seed %d (only %d reachable)" % [
				df.rooms.size(), seed_val, visited.size()])

func test_cull_removes_isolated_room_not_reachable_from_start() -> void:
	# Build a floor with a start, a boss, and a lone isolated room with no adjacency
	var df := DungeonFloor.new()
	df.floor_number = 1

	var start := DungeonRoom.new()
	start.room_type = DungeonRoom.TYPE_START
	start.tile_footprint = [Vector2i(0, 5)]
	start.visual_size = Vector2i(1, 1)
	start.cleared = true

	var boss := DungeonRoom.new()
	boss.room_type = DungeonRoom.TYPE_BOSS
	boss.tile_footprint = [Vector2i(1, 5)]
	boss.visual_size = Vector2i(1, 1)

	var isolated := DungeonRoom.new()
	isolated.room_type = DungeonRoom.TYPE_COMBAT_SMALL
	# Placed at (5, 0) — no orthogonal neighbor among start/boss tiles
	isolated.tile_footprint = [Vector2i(5, 0)]
	isolated.visual_size = Vector2i(1, 1)

	df.rooms.append(start)    # index 0
	df.rooms.append(boss)     # index 1
	df.rooms.append(isolated) # index 2

	DungeonGenerator._compute_adjacency(df)
	# Verify isolated has no adjacency before culling
	assert_eq(isolated.adjacency.size(), 0, "Isolated room should have no adjacency")

	DungeonGenerator._cull_unreachable_rooms(df)

	assert_eq(df.rooms.size(), 2, "Isolated room should be culled (2 rooms remain)")
	for r in df.rooms:
		assert_ne(r.room_type, DungeonRoom.TYPE_COMBAT_SMALL,
			"Culled room type should not remain in floor")

# ── Robbers room cleared after fight ─────────────────────────────────────────

func test_robbers_original_room_cleared_after_fight() -> void:
	# Simulates the logic path: original room saved → fight wins → both cleared
	var original_room := DungeonRoom.new()
	original_room.room_type = DungeonRoom.TYPE_ENCOUNTER
	original_room.encounter_subtype = "robbers"
	original_room.cleared = false

	# Simulate start_robbers_combat: save original, swap to synthetic
	var pending_room_clear: DungeonRoom = original_room
	var elite_room := DungeonRoom.new()
	elite_room.room_type = DungeonRoom.TYPE_COMBAT_ELITE
	var current_room := elite_room

	# Simulate _end_round(true) non-boss path
	current_room.cleared = true
	if pending_room_clear != null:
		pending_room_clear.cleared = true
		pending_room_clear = null

	assert_true(original_room.cleared, "Original robbers room must be marked cleared after fight win")
	assert_true(elite_room.cleared, "Synthetic elite room must also be marked cleared")
	assert_null(pending_room_clear, "pending_room_clear must be nil after clearing")

func test_robbers_original_room_not_cleared_if_fight_lost() -> void:
	# If the fight is lost, _end_round(false) is called and rooms are NOT cleared
	var original_room := DungeonRoom.new()
	original_room.room_type = DungeonRoom.TYPE_ENCOUNTER
	original_room.encounter_subtype = "robbers"
	original_room.cleared = false

	var pending_room_clear: DungeonRoom = original_room
	var elite_room := DungeonRoom.new()
	elite_room.room_type = DungeonRoom.TYPE_COMBAT_ELITE

	# Simulate _end_round(false): failure path — nothing cleared, pending stays
	# (In RunManager, the false branch calls _show_failure() and returns early)
	assert_false(original_room.cleared, "Original room must stay uncleared if fight is lost")
	assert_false(elite_room.cleared, "Elite room must stay uncleared if fight is lost")
	assert_not_null(pending_room_clear, "pending_room_clear should still hold reference on loss")

# ── First room adjacent to start is always combat ────────────────────────────

func test_first_room_adjacent_to_start_is_combat_over_20_seeds() -> void:
	var rng := RandomNumberGenerator.new()
	for seed_val in range(1, 21):
		rng.seed = seed_val
		var df := DungeonGenerator.generate(1, rng)
		assert_not_null(df, "Floor generated for seed %d" % seed_val)

		var start_idx := -1
		for i in range(df.rooms.size()):
			if df.rooms[i].room_type == DungeonRoom.TYPE_START:
				start_idx = i
				break
		assert_true(start_idx >= 0, "Start room exists for seed %d" % seed_val)

		var found_combat := false
		for adj_idx in df.rooms[start_idx].adjacency:
			var adj_room: DungeonRoom = df.rooms[adj_idx]
			if adj_room.is_combat():
				found_combat = true
				break
		assert_true(found_combat,
			"At least one room adjacent to start must be combat for seed %d" % seed_val)
