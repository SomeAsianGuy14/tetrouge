extends GutTest

# ── Rarity field ─────────────────────────────────────────────────────────

func test_all_techniques_have_rarity() -> void:
	for t in ResourceRegistry.all_techniques:
		assert_true(t.rarity in ["common", "rare", "epic"],
			"technique %s has invalid rarity '%s'" % [t.id, t.rarity])

func test_common_count_is_31() -> void:
	var count := 0
	for t in ResourceRegistry.all_techniques:
		if t.rarity == "common":
			count += 1
	assert_eq(count, 31)

func test_rare_count_is_14() -> void:
	var count := 0
	for t in ResourceRegistry.all_techniques:
		if t.rarity == "rare":
			count += 1
	assert_eq(count, 14)

func test_epic_count_is_12() -> void:
	var count := 0
	for t in ResourceRegistry.all_techniques:
		if t.rarity == "epic":
			count += 1
	assert_eq(count, 12)

# ── Base cost ────────────────────────────────────────────────────────────

func test_get_base_cost_common() -> void:
	var t := Technique.new()
	t.rarity = "common"
	assert_eq(t.get_base_cost(), 40)

func test_get_base_cost_rare() -> void:
	var t := Technique.new()
	t.rarity = "rare"
	assert_eq(t.get_base_cost(), 52)

func test_get_base_cost_epic() -> void:
	var t := Technique.new()
	t.rarity = "epic"
	assert_eq(t.get_base_cost(), 64)

func test_common_techniques_cost_40() -> void:
	for t in ResourceRegistry.all_techniques:
		if t.rarity == "common":
			assert_eq(t.cost, 40, "common technique %s should cost 40" % t.id)

func test_rare_techniques_cost_52() -> void:
	for t in ResourceRegistry.all_techniques:
		if t.rarity == "rare":
			assert_eq(t.cost, 52, "rare technique %s should cost 52" % t.id)

func test_epic_techniques_cost_64() -> void:
	for t in ResourceRegistry.all_techniques:
		if t.rarity == "epic":
			assert_eq(t.cost, 64, "epic technique %s should cost 64" % t.id)

# ── Weighted draw ────────────────────────────────────────────────────────

func test_weighted_draw_favors_common() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 42
	var pool := ResourceRegistry.all_techniques.duplicate()
	var counts := {"common": 0, "rare": 0, "epic": 0}
	for i in range(200):
		rng.seed = i
		var t: Technique = ResourceRegistry.weighted_technique_draw(pool, rng)
		counts[t.rarity] += 1
	assert_gt(counts["common"], counts["rare"],
		"common (%d) should appear more than rare (%d)" % [counts["common"], counts["rare"]])
	assert_gt(counts["rare"], counts["epic"],
		"rare (%d) should appear more than epic (%d)" % [counts["rare"], counts["epic"]])

func test_weighted_draw_n_returns_unique() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 99
	var pool := ResourceRegistry.all_techniques.duplicate()
	var drawn := ResourceRegistry.weighted_technique_draw_n(pool, 5, rng)
	assert_eq(drawn.size(), 5)
	var ids := {}
	for t in drawn:
		assert_false(t.id in ids, "duplicate id: %s" % t.id)
		ids[t.id] = true
