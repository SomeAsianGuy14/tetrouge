extends GutTest

# ── Shared state ──────────────────────────────────────────────────────────────

var _rm: RunManager
var _saved_keystones: Array
var _saved_techniques: Array
var _saved_coins: int

func before_each() -> void:
	_saved_keystones = RunState.keystones.duplicate()
	_saved_techniques = RunState.techniques.duplicate()
	_saved_coins = Economy.coins
	RunState.keystones = []
	RunState.techniques = []
	Economy.coins = 0
	_rm = RunManager.new()
	_rm.current_config = RoundConfig.new()

func after_each() -> void:
	_rm.free()
	RunState.keystones = _saved_keystones
	RunState.techniques = _saved_techniques
	Economy.coins = _saved_coins

# ── CLEAR_TYPE_DISPLAY coverage ───────────────────────────────────────────────

func test_clear_type_display_contains_all_nine_keys() -> void:
	var expected := ["single", "double", "triple", "quad",
		"tspin_mini", "tspin_single", "tspin_double", "tspin_triple",
		"perfect_clear"]
	for key in expected:
		assert_true(RunManager.CLEAR_TYPE_DISPLAY.has(key),
			"CLEAR_TYPE_DISPLAY missing key: %s" % key)
	assert_eq(RunManager.CLEAR_TYPE_DISPLAY.size(), expected.size(),
		"CLEAR_TYPE_DISPLAY has no extra keys")

func test_plain_clears_are_white() -> void:
	for key in ["single", "double", "triple"]:
		var color: Color = RunManager.CLEAR_TYPE_DISPLAY[key][1]
		assert_eq(color, Color.WHITE, "%s should be white" % key)

func test_tspin_variants_are_all_purple() -> void:
	var tspin_keys := ["tspin_mini", "tspin_single", "tspin_double", "tspin_triple"]
	var reference_color: Color = RunManager.CLEAR_TYPE_DISPLAY[tspin_keys[0]][1]
	for key in tspin_keys:
		var color: Color = RunManager.CLEAR_TYPE_DISPLAY[key][1]
		assert_eq(color, reference_color, "%s should match tspin_mini color" % key)
	assert_ne(reference_color, Color.WHITE, "T-spin color should not be white")

func test_quad_is_cyan_and_perfect_clear_is_gold() -> void:
	var quad_color: Color = RunManager.CLEAR_TYPE_DISPLAY["quad"][1]
	var pc_color: Color = RunManager.CLEAR_TYPE_DISPLAY["perfect_clear"][1]
	assert_eq(quad_color, Color(0.3, 0.9, 1.0), "quad should be cyan")
	assert_eq(pc_color, Color(1.0, 0.85, 0.1), "perfect_clear should be gold")

# ── Double-spawn guard ────────────────────────────────────────────────────────

func test_lines_cleared_handler_skips_when_flag_set() -> void:
	_rm._clear_popup_shown_this_piece = true
	_rm._on_lines_cleared(1, "single")
	assert_false(_rm._clear_popup_shown_this_piece,
		"Flag should be reset after being consumed by _on_lines_cleared")

func test_lines_cleared_handler_does_not_skip_when_flag_clear() -> void:
	_rm._clear_popup_shown_this_piece = false
	# With no hold display the spawn is a no-op, but the flag must stay false
	_rm._on_lines_cleared(1, "single")
	assert_false(_rm._clear_popup_shown_this_piece,
		"Flag remains false when zero-delay path runs normally")

func test_lock_processed_always_resets_flag() -> void:
	_rm._clear_popup_shown_this_piece = true
	_rm._on_lock_processed()
	assert_false(_rm._clear_popup_shown_this_piece,
		"_on_lock_processed must reset the clear popup guard flag")
