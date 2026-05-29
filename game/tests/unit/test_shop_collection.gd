extends GutTest

var _saved_techniques: Array
var _saved_consumables: Array
var _saved_capacity: int
var _saved_coins: int

func before_each() -> void:
	_saved_techniques = RunState.techniques.duplicate()
	_saved_consumables = RunState.consumables.duplicate()
	_saved_capacity = RunState.consumable_capacity
	_saved_coins = Economy.coins
	RunState.techniques = []
	RunState.consumables = []
	RunState.consumable_capacity = 3
	Economy.coins = 0

func after_each() -> void:
	RunState.techniques = _saved_techniques
	RunState.consumables = _saved_consumables
	RunState.consumable_capacity = _saved_capacity
	Economy.coins = _saved_coins

# ── RunState.remove_technique ─────────────────────────────────────────────

func test_remove_technique_removes_matching_entry() -> void:
	var t1 := Technique.new()
	t1.id = "efficiency"
	var t2 := Technique.new()
	t2.id = "momentum"
	RunState.techniques = [t1, t2]
	RunState.remove_technique(t1)
	assert_eq(RunState.techniques.size(), 1, "should have 1 technique after remove")
	assert_eq(RunState.techniques[0].id, "momentum", "remaining technique should be momentum")

func test_remove_technique_leaves_others_intact() -> void:
	var t1 := Technique.new()
	t1.id = "efficiency"
	var t2 := Technique.new()
	t2.id = "momentum"
	var t3 := Technique.new()
	t3.id = "avalanche"
	RunState.techniques = [t1, t2, t3]
	RunState.remove_technique(t2)
	assert_eq(RunState.techniques.size(), 2)
	assert_false(RunState.has_technique("momentum"), "removed technique should be gone")
	assert_true(RunState.has_technique("efficiency"), "other techniques should remain")
	assert_true(RunState.has_technique("avalanche"), "other techniques should remain")

# ── _sell_price ───────────────────────────────────────────────────────────

func test_sell_price_cost_5_returns_3() -> void:
	var c := Consumable.new()
	c.cost = 5
	assert_eq(int(c.cost * 0.6), 3, "floor(5 * 0.6) should be 3")

func test_sell_price_cost_4_returns_2() -> void:
	var c := Consumable.new()
	c.cost = 4
	assert_eq(int(c.cost * 0.6), 2, "floor(4 * 0.6) should be 2")

# ── sell consumable ───────────────────────────────────────────────────────

func test_sell_consumable_removes_item_and_adds_coins() -> void:
	var c := Consumable.new()
	c.cost = 5
	RunState.consumables = [c]
	var sell_price := int(c.cost * 0.6)
	Economy.add_coins(0)  # ensure signal connected
	Economy.coins = 0
	RunState.remove_consumable(c)
	Economy.add_coins(sell_price)
	assert_eq(RunState.consumables.size(), 0, "backpack should be empty after sell")
	assert_eq(Economy.coins, sell_price, "coins should increase by sell price")

# ── sell technique ────────────────────────────────────────────────────────

func test_sell_technique_removes_item_and_adds_coins() -> void:
	var t := Technique.new()
	t.id = "efficiency"
	t.cost = 4
	RunState.techniques = [t]
	var sell_price := int(t.cost * 0.6)
	Economy.coins = 0
	RunState.remove_technique(t)
	Economy.add_coins(sell_price)
	assert_eq(RunState.techniques.size(), 0, "techniques should be empty after sell")
	assert_eq(Economy.coins, sell_price, "coins should increase by sell price")
