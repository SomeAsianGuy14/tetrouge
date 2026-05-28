extends GutTest

# ── Shared state ──────────────────────────────────────────────────────────

var _rm: RunManager
var _saved_consumables: Array
var _saved_capacity: int

func before_each() -> void:
	_saved_consumables = RunState.consumables.duplicate()
	_saved_capacity = RunState.consumable_capacity
	RunState.consumables = []
	RunState.consumable_capacity = 3
	_rm = RunManager.new()
	_rm.current_config = RoundConfig.new()

func after_each() -> void:
	_rm.free()
	RunState.consumables = _saved_consumables
	RunState.consumable_capacity = _saved_capacity

func _make_consumable() -> Consumable:
	return Consumable.new()

# ── apply_to_config ───────────────────────────────────────────────────────

func test_apply_to_config_writes_bonus_quad() -> void:
	var c := _make_consumable()
	c.bonus_quad = 5
	var cfg := RoundConfig.new()
	c.apply_to_config(cfg)
	assert_eq(cfg.consumable_quad_bonus, 5, "bonus_quad should be written to consumable_quad_bonus")

func test_apply_to_config_writes_bonus_all_clears() -> void:
	var c := _make_consumable()
	c.bonus_all_clears = 3
	var cfg := RoundConfig.new()
	c.apply_to_config(cfg)
	assert_eq(cfg.consumable_all_bonus, 3, "bonus_all_clears should be written to consumable_all_bonus")

func test_apply_to_config_writes_surge_clears() -> void:
	var c := _make_consumable()
	c.attack_surge_clears = 3
	var cfg := RoundConfig.new()
	c.apply_to_config(cfg)
	assert_eq(cfg.consumable_surge_clears_remaining, 3, "attack_surge_clears should be written to consumable_surge_clears_remaining")

# ── _apply_consumable_flat_bonuses ─────────────────────────────────────────

func test_flat_bonus_all_added_to_every_clear_type() -> void:
	_rm.current_config.consumable_all_bonus = 2
	for event_type in ["single", "double", "triple", "quad", "tspin_single", "tspin_double", "tspin_triple", "tspin_mini"]:
		assert_eq(_rm._apply_consumable_flat_bonuses(4, event_type), 6,
			"consumable_all_bonus should add 2 to %s" % event_type)

func test_flat_bonus_quad_only_added_to_quad() -> void:
	_rm.current_config.consumable_quad_bonus = 5
	assert_eq(_rm._apply_consumable_flat_bonuses(4, "quad"), 9, "quad bonus applies to quad")
	assert_eq(_rm._apply_consumable_flat_bonuses(4, "triple"), 4, "quad bonus does not apply to triple")
	assert_eq(_rm._apply_consumable_flat_bonuses(4, "tspin_double"), 4, "quad bonus does not apply to tspin_double")

func test_flat_bonus_tspin_added_to_all_tspin_variants() -> void:
	_rm.current_config.consumable_tspin_bonus = 5
	for event_type in ["tspin_single", "tspin_double", "tspin_triple", "tspin_mini"]:
		assert_eq(_rm._apply_consumable_flat_bonuses(4, event_type), 9,
			"tspin bonus should add 5 to %s" % event_type)
	assert_eq(_rm._apply_consumable_flat_bonuses(4, "quad"), 4, "tspin bonus does not apply to quad")

func test_flat_bonus_returns_unchanged_when_all_zero() -> void:
	assert_eq(_rm._apply_consumable_flat_bonuses(4, "quad"), 4, "no bonus when config fields are 0")
	assert_eq(_rm._apply_consumable_flat_bonuses(4, "tspin_double"), 4, "no bonus when config fields are 0")

# ── _apply_consumable_surge ───────────────────────────────────────────────

func test_surge_doubles_attack_and_decrements_counter() -> void:
	_rm.current_config.consumable_surge_clears_remaining = 3
	var result := _rm._apply_consumable_surge(4, "quad")
	assert_eq(result, 8, "surge should double attack")
	assert_eq(_rm.current_config.consumable_surge_clears_remaining, 2, "counter should decrement to 2")

func test_surge_does_not_fire_on_4th_clear() -> void:
	_rm.current_config.consumable_surge_clears_remaining = 3
	_rm._apply_consumable_surge(4, "single")  # 1st clear → counter = 2
	_rm._apply_consumable_surge(4, "single")  # 2nd clear → counter = 1
	_rm._apply_consumable_surge(4, "single")  # 3rd clear → counter = 0
	var result := _rm._apply_consumable_surge(4, "single")  # 4th → no surge
	assert_eq(result, 4, "surge should not apply on 4th clear")
	assert_eq(_rm.current_config.consumable_surge_clears_remaining, 0, "counter should stay at 0")

# ── RunState backpack capacity ─────────────────────────────────────────────

func test_add_consumable_returns_false_when_at_capacity() -> void:
	RunState.consumable_capacity = 3
	for _i in 3:
		RunState.consumables.append(_make_consumable())
	var extra := _make_consumable()
	assert_false(RunState.add_consumable(extra), "add_consumable should return false when backpack is full")
	assert_eq(RunState.consumables.size(), 3, "backpack should still have 3 items")
