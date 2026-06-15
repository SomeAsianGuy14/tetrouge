extends GutTest

# ── ResourceRegistry ──────────────────────────────────────────────────────────

func test_all_keystones_non_empty() -> void:
	assert_true(ResourceRegistry.all_keystones.size() > 0, "keystones should be populated")

func test_all_techniques_non_empty() -> void:
	assert_true(ResourceRegistry.all_techniques.size() > 0, "techniques should be populated")

func test_all_consumables_non_empty() -> void:
	assert_true(ResourceRegistry.all_consumables.size() > 0, "consumables should be populated")

func test_all_vouchers_non_empty() -> void:
	assert_true(ResourceRegistry.all_vouchers.size() > 0, "vouchers should be populated")

func test_all_enemies_non_empty() -> void:
	assert_true(ResourceRegistry.all_enemies.size() > 0, "enemies should be populated")

func test_all_resources_have_ids() -> void:
	var all := ResourceRegistry.all_keystones + ResourceRegistry.all_techniques \
		+ ResourceRegistry.all_consumables + ResourceRegistry.all_vouchers
	for res in all:
		assert_true("id" in res and res.id != "", "resource missing id: %s" % str(res))

func test_find_by_id_returns_correct_resource() -> void:
	var ks := ResourceRegistry.find_by_id(ResourceRegistry.all_keystones, "simple_sword")
	assert_not_null(ks, "simple_sword keystone should be found")
	assert_eq(ks.id, "simple_sword")

func test_find_by_id_returns_null_for_missing() -> void:
	var result := ResourceRegistry.find_by_id(ResourceRegistry.all_keystones, "does_not_exist")
	assert_null(result, "unknown id should return null")

# ── Legacy id aliases (renamed resources) ─────────────────────────────────

func test_find_by_id_resolves_legacy_technique_id() -> void:
	var t := ResourceRegistry.find_by_id(ResourceRegistry.all_techniques, "keen_edge")
	assert_not_null(t, "legacy id keen_edge should resolve to the renamed technique")
	assert_eq(t.id, "sharpen")

func test_find_by_id_resolves_legacy_consumable_ids() -> void:
	var aliases := {
		"whetstone": "sharpening_stone",
		"gilding_kit": "gold_leaf",
		"reinforcing_plate": "steel_plates",
		"arcane_battery": "charged_battery",
	}
	for old_id in aliases:
		var c := ResourceRegistry.find_by_id(ResourceRegistry.all_consumables, old_id)
		assert_not_null(c, "legacy id %s should resolve to a consumable" % old_id)
		assert_eq(c.id, aliases[old_id])

func test_load_by_ids_recovers_inventory_with_legacy_ids() -> void:
	var loaded := RunSave._load_by_ids(ResourceRegistry.all_consumables, ["gilding_kit", "sharpening_stone"])
	assert_eq(loaded.size(), 2, "both legacy and current ids should resolve")
	assert_eq(loaded[0].id, "gold_leaf")
	assert_eq(loaded[1].id, "sharpening_stone")

func test_no_duplicate_keystone_ids() -> void:
	var seen := {}
	for ks in ResourceRegistry.all_keystones:
		assert_false(ks.id in seen, "duplicate keystone id: %s" % ks.id)
		seen[ks.id] = true

func test_no_duplicate_technique_ids() -> void:
	var seen := {}
	for t in ResourceRegistry.all_techniques:
		assert_false(t.id in seen, "duplicate technique id: %s" % t.id)
		seen[t.id] = true

# ── Starter keystone loading ──────────────────────────────────────────────

func test_starter_keystones_have_is_starter_true() -> void:
	var starter_ids := ["simple_sword", "simple_flail", "simple_shield", "simple_wand", "slightly_magical_coin"]
	for id in starter_ids:
		var ks := ResourceRegistry.find_by_id(ResourceRegistry.all_keystones, id)
		assert_not_null(ks, "%s keystone should exist" % id)
		assert_true(ks.is_starter, "%s should have is_starter = true" % id)

func test_non_starter_keystones_have_is_starter_false() -> void:
	for ks in ResourceRegistry.all_keystones:
		if ks.id not in ["simple_sword", "simple_flail", "simple_shield", "simple_wand", "slightly_magical_coin"]:
			assert_false(ks.is_starter, "%s should have is_starter = false" % ks.id)

func test_get_available_keystones_includes_starters() -> void:
	var available := ResourceRegistry.get_available_keystones()
	var starters := available.filter(func(ks): return ks.is_starter)
	assert_true(starters.size() >= 4, "at least 4 starter keystones should be available, got %d" % starters.size())

func test_all_keystones_have_is_starter_property() -> void:
	for ks in ResourceRegistry.all_keystones:
		assert_true("is_starter" in ks, "keystone %s missing is_starter property (script not applied?)" % ks.id)
