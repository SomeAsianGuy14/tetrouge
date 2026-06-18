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

func _make_room(room_type: String) -> DungeonRoom:
	var r := DungeonRoom.new()
	r.room_type = room_type
	r.tile_footprint = [Vector2i(0, 0)]
	r.visual_size = Vector2i(1, 1)
	return r

# ── 3.2 Instantiation ────────────────────────────────────────────────────────

func test_instantiates_without_scene_tree() -> void:
	var flow := RunFlow.new()
	assert_not_null(flow)
	assert_null(flow.current_room)
	assert_null(flow.pending_room_clear)

# ── 3.3–3.5 enter_room routing ───────────────────────────────────────────────

func test_enter_room_combat_small_emits_combat_entered() -> void:
	var flow := RunFlow.new()
	var room := _make_room(DungeonRoom.TYPE_COMBAT_SMALL)
	watch_signals(flow)
	flow.enter_room(room)
	assert_signal_emitted(flow, "combat_entered")
	assert_eq(flow.current_room, room)

func test_enter_room_combat_big_emits_combat_entered() -> void:
	var flow := RunFlow.new()
	var room := _make_room(DungeonRoom.TYPE_COMBAT_BIG)
	watch_signals(flow)
	flow.enter_room(room)
	assert_signal_emitted(flow, "combat_entered")

func test_enter_room_combat_elite_emits_combat_entered() -> void:
	var flow := RunFlow.new()
	var room := _make_room(DungeonRoom.TYPE_COMBAT_ELITE)
	watch_signals(flow)
	flow.enter_room(room)
	assert_signal_emitted(flow, "combat_entered")

func test_enter_room_boss_emits_combat_entered() -> void:
	var flow := RunFlow.new()
	var room := _make_room(DungeonRoom.TYPE_BOSS)
	watch_signals(flow)
	flow.enter_room(room)
	assert_signal_emitted(flow, "combat_entered")

func test_enter_room_shop_emits_shop_entered() -> void:
	var flow := RunFlow.new()
	var room := _make_room(DungeonRoom.TYPE_SHOP)
	watch_signals(flow)
	flow.enter_room(room)
	assert_signal_emitted(flow, "shop_entered")

func test_enter_room_encounter_emits_encounter_entered() -> void:
	var flow := RunFlow.new()
	var room := _make_room(DungeonRoom.TYPE_ENCOUNTER)
	watch_signals(flow)
	flow.enter_room(room)
	assert_signal_emitted(flow, "encounter_entered")

# ── 3.6–3.8 resolve_combat(true) non-boss ────────────────────────────────────

func test_resolve_combat_win_non_boss_sets_cleared() -> void:
	var flow := RunFlow.new()
	flow.current_room = _make_room(DungeonRoom.TYPE_COMBAT_SMALL)
	flow.resolve_combat(true)
	assert_true(flow.current_room.cleared)

func test_resolve_combat_win_non_boss_increments_cleared_count() -> void:
	RunState.combat_rooms_cleared_this_floor = 0
	var flow := RunFlow.new()
	flow.current_room = _make_room(DungeonRoom.TYPE_COMBAT_SMALL)
	flow.resolve_combat(true)
	assert_eq(RunState.combat_rooms_cleared_this_floor, 1)

func test_resolve_combat_win_non_boss_emits_round_success_not_boss() -> void:
	var flow := RunFlow.new()
	flow.current_room = _make_room(DungeonRoom.TYPE_COMBAT_SMALL)
	watch_signals(flow)
	flow.resolve_combat(true)
	assert_signal_emitted_with_parameters(flow, "round_success_requested", [false])

# ── 3.9–3.10 resolve_combat(false) ───────────────────────────────────────────

func test_resolve_combat_loss_does_not_clear_room() -> void:
	var flow := RunFlow.new()
	flow.current_room = _make_room(DungeonRoom.TYPE_COMBAT_SMALL)
	watch_signals(flow)
	flow.resolve_combat(false)
	assert_false(flow.current_room.cleared)
	assert_signal_emitted(flow, "failure_requested")

func test_resolve_combat_loss_does_not_change_cleared_count() -> void:
	RunState.combat_rooms_cleared_this_floor = 3
	var flow := RunFlow.new()
	flow.current_room = _make_room(DungeonRoom.TYPE_COMBAT_SMALL)
	flow.resolve_combat(false)
	assert_eq(RunState.combat_rooms_cleared_this_floor, 3)

# ── 3.11 resolve_combat(true) boss ───────────────────────────────────────────

func test_resolve_combat_win_boss_sets_cleared_and_emits_boss() -> void:
	var flow := RunFlow.new()
	flow.current_room = _make_room(DungeonRoom.TYPE_BOSS)
	watch_signals(flow)
	flow.resolve_combat(true)
	assert_true(flow.current_room.cleared)
	assert_signal_emitted_with_parameters(flow, "round_success_requested", [true])

# ── 3.12–3.13 confirm_boss_cleared ───────────────────────────────────────────

func test_confirm_boss_cleared_advances_floor_when_not_final() -> void:
	RunState.floor = 1
	var flow := RunFlow.new()
	watch_signals(flow)
	flow.confirm_boss_cleared()
	assert_eq(RunState.floor, 2)
	assert_signal_emitted(flow, "keystone_selection_requested")

func test_confirm_boss_cleared_emits_victory_on_final_floor() -> void:
	RunState.floor = RunState.TOTAL_FLOORS
	var prev_floor := RunState.floor
	var flow := RunFlow.new()
	watch_signals(flow)
	flow.confirm_boss_cleared()
	assert_signal_emitted(flow, "victory_requested")
	assert_signal_not_emitted(flow, "keystone_selection_requested")
	assert_eq(RunState.floor, prev_floor, "floor should not advance past final")

# ── 3.14–3.16 begin_robbers_combat + resolve ─────────────────────────────────

func test_begin_robbers_saves_pending_and_replaces_current() -> void:
	var flow := RunFlow.new()
	var original := _make_room(DungeonRoom.TYPE_ENCOUNTER)
	original.encounter_subtype = "robbers"
	flow.current_room = original
	var synthetic := flow.begin_robbers_combat()
	assert_eq(flow.pending_room_clear, original)
	assert_eq(flow.current_room, synthetic)
	assert_ne(flow.current_room, original)
	assert_eq(synthetic.room_type, DungeonRoom.TYPE_COMBAT_ELITE)

func test_robbers_win_clears_original_encounter_room() -> void:
	RunState.combat_rooms_cleared_this_floor = 0
	var flow := RunFlow.new()
	var original := _make_room(DungeonRoom.TYPE_ENCOUNTER)
	original.encounter_subtype = "robbers"
	flow.current_room = original
	flow.begin_robbers_combat()
	flow.resolve_combat(true)
	assert_true(original.cleared)

func test_robbers_win_clears_pending_to_null() -> void:
	RunState.combat_rooms_cleared_this_floor = 0
	var flow := RunFlow.new()
	var original := _make_room(DungeonRoom.TYPE_ENCOUNTER)
	flow.current_room = original
	flow.begin_robbers_combat()
	flow.resolve_combat(true)
	assert_null(flow.pending_room_clear)

# ── 3.17–3.18 resolve_shop / resolve_encounter ──────────────────────────────

func test_resolve_shop_sets_cleared_and_emits_map() -> void:
	var flow := RunFlow.new()
	var room := _make_room(DungeonRoom.TYPE_SHOP)
	watch_signals(flow)
	flow.resolve_shop(room)
	assert_true(room.cleared)
	assert_signal_emitted(flow, "dungeon_map_requested")

func test_resolve_encounter_sets_cleared_and_emits_map() -> void:
	var flow := RunFlow.new()
	var room := _make_room(DungeonRoom.TYPE_ENCOUNTER)
	watch_signals(flow)
	flow.resolve_encounter(room)
	assert_true(room.cleared)
	assert_signal_emitted(flow, "dungeon_map_requested")
