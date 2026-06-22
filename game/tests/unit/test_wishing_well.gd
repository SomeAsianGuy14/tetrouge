extends GutTest

var _saved_keystones: Array
var _saved_techniques: Array
var _saved_consumables: Array
var _saved_coins: int
var _saved_used_ks_ids: Array
var _saved_technique_capacity: int
var _saved_consumable_capacity: int
var _saved_seed: int
var _saved_rng_state: int

func before_each() -> void:
	_saved_keystones = RunState.keystones.duplicate()
	_saved_techniques = RunState.techniques.duplicate()
	_saved_consumables = RunState.consumables.duplicate()
	_saved_coins = Economy.coins
	_saved_used_ks_ids = RunState.used_keystone_ids.duplicate()
	_saved_technique_capacity = RunState.technique_capacity
	_saved_consumable_capacity = RunState.consumable_capacity
	_saved_seed = RunState.run_seed
	_saved_rng_state = RunState.rng.state
	RunState.keystones.clear()
	RunState.techniques.clear()
	RunState.consumables.clear()
	RunState.used_keystone_ids.clear()
	RunState.technique_capacity = 5
	RunState.consumable_capacity = 3
	Economy.coins = 100
	RunState.rng.seed = 42

func after_each() -> void:
	RunState.keystones = _saved_keystones
	RunState.techniques = _saved_techniques
	RunState.consumables = _saved_consumables
	Economy.coins = _saved_coins
	RunState.used_keystone_ids = _saved_used_ks_ids
	RunState.technique_capacity = _saved_technique_capacity
	RunState.consumable_capacity = _saved_consumable_capacity
	RunState.run_seed = _saved_seed
	RunState.rng.seed = _saved_seed
	RunState.rng.state = _saved_rng_state

# ── Award function ────────────────────────────────────────────────────────

func test_award_returns_non_empty_string() -> void:
	var room := EncounterRoom.new()
	var result := room._wishing_well_award()
	assert_false(result.is_empty(), "should return an item name")
	room.free()

func test_award_adds_item_to_inventory() -> void:
	var room := EncounterRoom.new()
	var before_total := RunState.techniques.size() + RunState.consumables.size() + RunState.keystones.size()
	room._wishing_well_award()
	var after_total := RunState.techniques.size() + RunState.consumables.size() + RunState.keystones.size()
	assert_gt(after_total, before_total, "inventory should grow by 1")
	room.free()

func test_award_returns_empty_when_all_pools_exhausted() -> void:
	RunState.technique_capacity = 0
	RunState.consumable_capacity = 0
	for ks in ResourceRegistry.all_keystones:
		RunState.used_keystone_ids.append(ks.id)
	var room := EncounterRoom.new()
	var result := room._wishing_well_award()
	assert_eq(result, "", "should return empty when all pools exhausted")
	room.free()

func test_award_skips_technique_when_at_capacity() -> void:
	RunState.technique_capacity = 0
	RunState.consumable_capacity = 3
	var room := EncounterRoom.new()
	for i in range(20):
		RunState.rng.seed = i
		var result := room._wishing_well_award()
		if not result.is_empty():
			assert_false(result.ends_with("(Technique)"),
				"should never award technique when at capacity")
		RunState.consumables.clear()
		RunState.keystones.clear()
		RunState.used_keystone_ids.clear()
	room.free()

func test_award_skips_consumable_when_backpack_full() -> void:
	for i in range(3):
		RunState.consumables.append(ResourceRegistry.all_consumables[i])
	var room := EncounterRoom.new()
	for i in range(20):
		RunState.rng.seed = i + 100
		var result := room._wishing_well_award()
		if not result.is_empty():
			assert_false(result.ends_with("(Consumable)"),
				"should never award consumable when backpack full")
		if RunState.techniques.size() > 0:
			RunState.techniques.clear()
		RunState.keystones.clear()
		RunState.used_keystone_ids.clear()
	room.free()
