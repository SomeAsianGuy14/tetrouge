extends GutTest

# ── Income value verification ─────────────────────────────────────────────

func test_slightly_magical_coin_grants_5_coins() -> void:
	var ks := ResourceRegistry.find_by_id(ResourceRegistry.all_keystones, "slightly_magical_coin")
	assert_not_null(ks)
	assert_eq(ks.end_round_coins, 5)

func test_magical_coin_grants_15_coins() -> void:
	var ks := ResourceRegistry.find_by_id(ResourceRegistry.all_keystones, "magical_coin")
	assert_not_null(ks)
	assert_eq(ks.end_round_coins, 15)

func test_combo_payout_awards_20_coins() -> void:
	var t := ResourceRegistry.find_by_id(ResourceRegistry.all_techniques, "combo_payout")
	assert_not_null(t)
	assert_eq(t.params.get("coins", 0), 20)

func test_green_thumb_awards_4_coins_per_trigger() -> void:
	var t := ResourceRegistry.find_by_id(ResourceRegistry.all_techniques, "green_thumb")
	assert_not_null(t)
	assert_eq(t.params.get("coins_per_trigger", 0), 4)

# ── Price verification (spot checks) ─────────────────────────────────────

func test_cheap_technique_costs_40() -> void:
	var t := ResourceRegistry.find_by_id(ResourceRegistry.all_techniques, "brass_knuckles")
	assert_not_null(t)
	assert_eq(t.cost, 40)

func test_mid_technique_costs_48() -> void:
	var t := ResourceRegistry.find_by_id(ResourceRegistry.all_techniques, "combo_payout")
	assert_not_null(t)
	assert_eq(t.cost, 48)

func test_expensive_technique_costs_60() -> void:
	var t := ResourceRegistry.find_by_id(ResourceRegistry.all_techniques, "perfect_spark")
	assert_not_null(t)
	assert_eq(t.cost, 60)

func test_cheap_consumable_costs_30() -> void:
	var c := ResourceRegistry.find_by_id(ResourceRegistry.all_consumables, "power_shard")
	assert_not_null(c)
	assert_eq(c.cost, 30)

func test_mid_consumable_costs_35() -> void:
	var c := ResourceRegistry.find_by_id(ResourceRegistry.all_consumables, "gold_leaf")
	assert_not_null(c)
	assert_eq(c.cost, 35)

func test_expensive_consumable_costs_40() -> void:
	var c := ResourceRegistry.find_by_id(ResourceRegistry.all_consumables, "attack_surge")
	assert_not_null(c)
	assert_eq(c.cost, 40)

# ── All techniques have cost field ────────────────────────────────────────

func test_all_techniques_have_cost_in_range() -> void:
	for t in ResourceRegistry.all_techniques:
		assert_true(t.cost >= 40 and t.cost <= 60,
			"technique %s cost %d should be in 40-60 range" % [t.id, t.cost])

func test_all_consumables_have_cost_in_range() -> void:
	for c in ResourceRegistry.all_consumables:
		assert_true(c.cost >= 30 and c.cost <= 40,
			"consumable %s cost %d should be in 30-40 range" % [c.id, c.cost])

# ── Shop defaults ────────────────────────────────────────────────────────

func test_default_shop_technique_slots_is_5() -> void:
	RunState.reset()
	assert_eq(RunState.shop_technique_slots, 5)

func test_default_consumable_capacity_is_3() -> void:
	RunState.reset()
	assert_eq(RunState.consumable_capacity, 3)
