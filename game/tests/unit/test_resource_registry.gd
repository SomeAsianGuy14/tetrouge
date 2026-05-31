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
