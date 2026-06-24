extends GutTest

var _saved_mastery: Dictionary

func before_each() -> void:
	_saved_mastery = RunState.mastery.duplicate(true)
	RunState._reset_mastery()

func after_each() -> void:
	RunState.mastery = _saved_mastery

# ── XP granting ──────────────────────────────────────────────────────────

func test_grant_xp_increments_by_1() -> void:
	RunState.grant_mastery_xp("quad")
	assert_eq(RunState.mastery["quad"].xp, 1)
	assert_eq(RunState.mastery["quad"].level, 0)

func test_quad_levels_up_at_5_then_6_then_7() -> void:
	for i in range(5):
		RunState.grant_mastery_xp("quad")
	assert_eq(RunState.mastery["quad"].level, 1, "level 1 at 5 XP")
	assert_eq(RunState.mastery["quad"].xp, 0)

	for i in range(6):
		RunState.grant_mastery_xp("quad")
	assert_eq(RunState.mastery["quad"].level, 2, "level 2 at 5+6=11 XP")
	assert_eq(RunState.mastery["quad"].xp, 0)

	for i in range(7):
		RunState.grant_mastery_xp("quad")
	assert_eq(RunState.mastery["quad"].level, 3, "level 3 at 5+6+7=18 XP")

func test_singles_levels_up_at_10_then_12() -> void:
	for i in range(10):
		RunState.grant_mastery_xp("single")
	assert_eq(RunState.mastery["single"].level, 1)
	assert_eq(RunState.mastery["single"].xp, 0)

	for i in range(12):
		RunState.grant_mastery_xp("single")
	assert_eq(RunState.mastery["single"].level, 2)
	assert_eq(RunState.mastery["single"].xp, 0)

func test_grant_xp_returns_new_level_on_levelup() -> void:
	for i in range(4):
		assert_eq(RunState.grant_mastery_xp("quad"), 0)
	assert_eq(RunState.grant_mastery_xp("quad"), 1)

func test_grant_xp_returns_0_for_untracked() -> void:
	assert_eq(RunState.grant_mastery_xp("perfect_clear"), 0)

# ── Level queries ────────────────────────────────────────────────────────

func test_get_mastery_level_returns_0_for_untracked() -> void:
	assert_eq(RunState.get_mastery_level("b2b"), 0)
	assert_eq(RunState.get_mastery_level("combo"), 0)
	assert_eq(RunState.get_mastery_level("perfect_clear"), 0)

func test_get_highest_mastery_for_all_clear() -> void:
	RunState.mastery["single"].level = 2
	RunState.mastery["quad"].level = 8
	RunState.mastery["tspin_double"].level = 5
	assert_eq(RunState.get_highest_mastery_for("all_clear"), 8)

func test_get_highest_mastery_for_tspin() -> void:
	RunState.mastery["tspin_single"].level = 1
	RunState.mastery["tspin_double"].level = 6
	RunState.mastery["tspin_triple"].level = 3
	RunState.mastery["quad"].level = 20
	assert_eq(RunState.get_highest_mastery_for("tspin"), 6)

func test_get_highest_mastery_for_multiline() -> void:
	RunState.mastery["single"].level = 10
	RunState.mastery["double"].level = 3
	RunState.mastery["triple"].level = 7
	RunState.mastery["quad"].level = 5
	assert_eq(RunState.get_highest_mastery_for("multiline"), 7)

# ── Technique amplification ──────────────────────────────────────────────

func test_mastery_amplifies_specific_technique() -> void:
	RunState.mastery["quad"].level = 6
	var ctx := AttackContext.new()
	ctx.lines_cleared = 4
	var bonus := TechniqueEvaluator._eval_flat(
		{"on": "quad", "bonus": 2}, ctx, 0.5)
	assert_eq(bonus, 2 + 6, "bonus 2 + mastery 6 = 8")

func test_mastery_amplifies_broad_technique_with_highest() -> void:
	RunState.mastery["single"].level = 2
	RunState.mastery["quad"].level = 8
	var ctx := AttackContext.new()
	ctx.lines_cleared = 1
	var bonus := TechniqueEvaluator._eval_flat(
		{"on": "all_clear", "bonus": 1}, ctx, 0.5)
	assert_eq(bonus, 1 + 8, "bonus 1 + mastery 8 = 9")

func test_require_b2b_technique_not_amplified() -> void:
	RunState.mastery["quad"].level = 10
	var ctx := AttackContext.new()
	ctx.lines_cleared = 4
	ctx.b2b = true
	var bonus := TechniqueEvaluator._eval_flat(
		{"on": "quad", "bonus": 2, "require_b2b": true}, ctx, 0.5)
	assert_eq(bonus, 2, "require_b2b skips mastery amplification")

func test_perfect_clear_technique_not_amplified() -> void:
	RunState.mastery["quad"].level = 10
	var ctx := AttackContext.new()
	ctx.perfect_clear = true
	var bonus := TechniqueEvaluator._eval_flat(
		{"on": "perfect_clear", "bonus": 6}, ctx, 0.5)
	assert_eq(bonus, 6, "perfect_clear skips mastery amplification")

# ── Reset ────────────────────────────────────────────────────────────────

func test_mastery_resets_on_run_reset() -> void:
	RunState.mastery["quad"].level = 5
	RunState.mastery["quad"].xp = 3
	RunState.reset()
	assert_eq(RunState.mastery["quad"].level, 0)
	assert_eq(RunState.mastery["quad"].xp, 0)

# ── Threshold escalation ────────────────────────────────────────────────

func test_threshold_escalates_for_quads() -> void:
	assert_eq(RunState.get_mastery_threshold("quad"), 5)
	RunState.mastery["quad"].level = 1
	assert_eq(RunState.get_mastery_threshold("quad"), 6)
	RunState.mastery["quad"].level = 5
	assert_eq(RunState.get_mastery_threshold("quad"), 10)

func test_threshold_escalates_for_singles() -> void:
	assert_eq(RunState.get_mastery_threshold("single"), 10)
	RunState.mastery["single"].level = 1
	assert_eq(RunState.get_mastery_threshold("single"), 12)
	RunState.mastery["single"].level = 3
	assert_eq(RunState.get_mastery_threshold("single"), 16)
