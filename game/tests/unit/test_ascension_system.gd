extends GutTest

# ── State save/restore ────────────────────────────────────────────────────────

var _saved_highest_beaten: int
var _saved_unlocked_ids: Array
var _saved_runs_completed: int
var _saved_total_damage: int
var _saved_quad_damage: int
var _saved_tspin_damage: int
var _saved_highest_combo: int
var _saved_highest_b2b: int
var _saved_ascension_level: int

func before_each() -> void:
	_saved_highest_beaten = ProfileSave.highest_beaten
	_saved_unlocked_ids = ProfileSave.unlocked_ids.duplicate()
	_saved_runs_completed = ProfileSave.runs_completed
	_saved_total_damage = ProfileSave.total_damage
	_saved_quad_damage = ProfileSave.total_quad_damage
	_saved_tspin_damage = ProfileSave.total_tspin_damage
	_saved_highest_combo = ProfileSave.highest_combo_chain
	_saved_highest_b2b = ProfileSave.highest_b2b
	_saved_ascension_level = AscensionManager.current_level

func after_each() -> void:
	ProfileSave.highest_beaten = _saved_highest_beaten
	ProfileSave.unlocked_ids = _saved_unlocked_ids
	ProfileSave.runs_completed = _saved_runs_completed
	ProfileSave.total_damage = _saved_total_damage
	ProfileSave.total_quad_damage = _saved_quad_damage
	ProfileSave.total_tspin_damage = _saved_tspin_damage
	ProfileSave.highest_combo_chain = _saved_highest_combo
	ProfileSave.highest_b2b = _saved_highest_b2b
	AscensionManager.current_level = _saved_ascension_level

# ── ProfileSave.record_victory ────────────────────────────────────────────────

func test_record_victory_sets_highest_beaten_from_negative_one() -> void:
	ProfileSave.highest_beaten = -1
	ProfileSave.record_victory(0)
	assert_eq(ProfileSave.highest_beaten, 0)

func test_record_victory_does_not_downgrade() -> void:
	ProfileSave.highest_beaten = 3
	ProfileSave.record_victory(1)
	assert_eq(ProfileSave.highest_beaten, 3)

func test_record_victory_upgrades_when_higher() -> void:
	ProfileSave.highest_beaten = 2
	ProfileSave.record_victory(4)
	assert_eq(ProfileSave.highest_beaten, 4)

# ── ProfileSave.accumulate_stats ─────────────────────────────────────────────

func test_accumulate_stats_adds_additive_fields() -> void:
	ProfileSave.runs_completed = 0
	ProfileSave.total_damage = 100
	ProfileSave.total_quad_damage = 20
	var rs := RunStats.new()
	rs.total_damage = 50
	rs.quad_damage = 10
	rs.tspin_damage = 5
	ProfileSave.accumulate_stats(rs)
	assert_eq(ProfileSave.runs_completed, 1)
	assert_eq(ProfileSave.total_damage, 150)
	assert_eq(ProfileSave.total_quad_damage, 30)

func test_accumulate_stats_updates_lifetime_max_when_higher() -> void:
	ProfileSave.highest_combo_chain = 5
	var rs := RunStats.new()
	rs.highest_combo_chain = 8
	ProfileSave.accumulate_stats(rs)
	assert_eq(ProfileSave.highest_combo_chain, 8)

func test_accumulate_stats_does_not_lower_lifetime_max() -> void:
	ProfileSave.highest_b2b = 10
	var rs := RunStats.new()
	rs.highest_b2b = 3
	ProfileSave.accumulate_stats(rs)
	assert_eq(ProfileSave.highest_b2b, 10)

# ── AscensionManager.get_modifiers ───────────────────────────────────────────

func test_get_modifiers_level_0_is_empty() -> void:
	var mods := AscensionManager.get_modifiers(0)
	assert_false(mods.get("faster_attacks", false))
	assert_eq(mods.get("extra_lines", 0), 0)
	assert_eq(mods.get("consumable_capacity_delta", 0), 0)
	assert_false(mods.get("skip_starter_keystone", false))
	assert_eq(mods.get("technique_capacity_delta", 0), 0)

func test_get_modifiers_level_3_has_correct_keys() -> void:
	var mods := AscensionManager.get_modifiers(3)
	assert_true(mods.get("faster_attacks", false))
	assert_eq(mods.get("extra_lines", 0), 1)
	assert_eq(mods.get("consumable_capacity_delta", 0), -1)
	assert_false(mods.get("skip_starter_keystone", false))
	assert_eq(mods.get("technique_capacity_delta", 0), 0)

func test_get_modifiers_level_6_has_all_keys() -> void:
	var mods := AscensionManager.get_modifiers(6)
	assert_true(mods.get("faster_attacks", false))
	assert_eq(mods.get("extra_lines", 0), 1)
	assert_eq(mods.get("consumable_capacity_delta", 0), -1)
	assert_true(mods.get("skip_starter_keystone", false))
	assert_eq(mods.get("technique_capacity_delta", 0), -1)

# ── ResourceRegistry.get_available_keystones ──────────────────────────────────

func test_get_available_keystones_excludes_locked_items() -> void:
	ProfileSave.unlocked_ids = []
	# Verify no all_keystones items have unlock_condition_id set (they shouldn't yet)
	var available := ResourceRegistry.get_available_keystones()
	assert_eq(available.size(), ResourceRegistry.all_keystones.size(),
		"all keystones should be available when none are locked")

func test_get_available_keystones_filters_when_condition_not_met() -> void:
	ProfileSave.unlocked_ids = []
	# Temporarily mark a real keystone as requiring an unlock
	var ks: Keystone = ResourceRegistry.all_keystones[0]
	var original_id := ks.unlock_condition_id
	ks.unlock_condition_id = "test_condition_xyz"
	var available := ResourceRegistry.get_available_keystones()
	ks.unlock_condition_id = original_id
	assert_eq(available.size(), ResourceRegistry.all_keystones.size() - 1)

# ── UnlockChecker ────────────────────────────────────────────────────────────

func test_unlock_checker_noop_with_no_conditions() -> void:
	ProfileSave.unlocked_ids = []
	var rs := RunStats.new()
	UnlockChecker.check_all(rs, ProfileSave)
	assert_eq(ProfileSave.unlocked_ids.size(), 0)

# ── Ascension level 4 quota calculation ──────────────────────────────────────

func test_level_4_quota_multiplier_ceili() -> void:
	assert_eq(ceili(50 * 1.2), 60)
	assert_eq(ceili(51 * 1.2), 62)
