extends GutTest

var _rm: RunManager
var _board: TetrisBoard
var _cfg: RoundConfig
var _saved_techniques: Array
var _saved_keystones: Array

func before_each() -> void:
	_saved_techniques = RunState.techniques.duplicate()
	_saved_keystones = RunState.keystones.duplicate()
	RunState.techniques = []
	RunState.keystones = []
	_cfg = RoundConfig.new()
	_cfg.hold_lockout_enabled = false
	_board = TetrisBoard.new()
	_board.setup(_cfg)
	_rm = RunManager.new()
	_rm.current_config = _cfg
	_rm.current_board = _board
	_board.piece_spawned.connect(_rm._on_piece_spawned)

func after_each() -> void:
	RunState.techniques = _saved_techniques
	RunState.keystones = _saved_keystones
	_board.free()
	_rm.free()

func _make_enhancer_technique(enhancement: String, every_n: int) -> Technique:
	var t := Technique.new()
	t.id = "test_enhancer_%s" % enhancement
	t.effect_type = "piece_enhancer"
	t.params = {"enhancement": enhancement, "every_n": every_n}
	return t

func _make_enhancer_keystone(enhancement: String, every_n: int) -> Keystone:
	var ks := Keystone.new()
	ks.id = "test_keystone_enhancer_%s" % enhancement
	ks.piece_enhance_every_n = every_n
	ks.piece_enhance_type = enhancement
	return ks

# ── 13.11: hold swap does not consume grant / advance cadence ────────────

func test_hold_swap_restores_enhancement_without_consuming_grant_or_cadence() -> void:
	_cfg.hold_slots = 1
	_rm._enhancement_grant = {"type": PieceEnhancements.GILDED, "remaining": 2}
	_rm._enhancement_cadence = {"sharpen": 1}

	_board.current_enhancement = PieceEnhancements.HONED
	_board.input_hold()
	_board.input_hold()

	assert_eq(_board.current_enhancement, PieceEnhancements.HONED)
	assert_eq(_rm._enhancement_grant, {"type": PieceEnhancements.GILDED, "remaining": 2})
	assert_eq(_rm._enhancement_cadence, {"sharpen": 1})

# ── 13.12: grant precedence ───────────────────────────────────────────────

func test_grant_precedence_consumable_wins_and_cadence_still_advances() -> void:
	var tech := _make_enhancer_technique(PieceEnhancements.HONED, 2)
	RunState.techniques = [tech]
	_rm._enhancement_cadence = {tech.id: 0}
	_rm._enhancement_grant = {"type": PieceEnhancements.GILDED, "remaining": 1}

	_rm._on_piece_spawned(_board.current_type)

	assert_eq(_board.current_enhancement, PieceEnhancements.GILDED)
	assert_eq(_rm._enhancement_grant, {})
	assert_eq(_rm._enhancement_cadence[tech.id], 1)

# ── 13.13: periodic technique grant fires every Nth spawn ─────────────────

func test_periodic_technique_grant_fires_every_nth_spawn() -> void:
	var tech := _make_enhancer_technique(PieceEnhancements.AMPLIFIED, 3)
	RunState.techniques = [tech]
	_rm._enhancement_cadence = {tech.id: 0}

	_rm._on_piece_spawned(_board.current_type)
	assert_eq(_board.current_enhancement, "")
	_rm._on_piece_spawned(_board.current_type)
	assert_eq(_board.current_enhancement, "")
	_rm._on_piece_spawned(_board.current_type)
	assert_eq(_board.current_enhancement, PieceEnhancements.AMPLIFIED)
	assert_eq(_rm._enhancement_cadence[tech.id], 0)

# ── 13.14: consumable grant lasts exactly N pieces then expires ───────────

func test_consumable_grant_enhances_next_n_pieces_then_expires() -> void:
	_rm._enhancement_grant = {"type": PieceEnhancements.REINFORCED, "remaining": 2}

	_rm._on_piece_spawned(_board.current_type)
	assert_eq(_board.current_enhancement, PieceEnhancements.REINFORCED)
	assert_eq(_rm._enhancement_grant.get("remaining", 0), 1)

	_rm._on_piece_spawned(_board.current_type)
	assert_eq(_board.current_enhancement, PieceEnhancements.REINFORCED)
	assert_eq(_rm._enhancement_grant, {})

	_rm._on_piece_spawned(_board.current_type)
	assert_eq(_board.current_enhancement, "")

# ── 13.15: apply_consumable extend vs replace ─────────────────────────────

func test_apply_consumable_extends_same_type_grant() -> void:
	_board.current_enhancement = PieceEnhancements.HONED
	_rm._enhancement_grant = {"type": PieceEnhancements.HONED, "remaining": 2}
	var c := Consumable.new()
	c.enhance_type = PieceEnhancements.HONED
	c.enhance_pieces = 4
	_rm.apply_consumable(c)
	assert_eq(_rm._enhancement_grant, {"type": PieceEnhancements.HONED, "remaining": 6})

func test_apply_consumable_queues_different_type_grant_when_active() -> void:
	_board.current_enhancement = PieceEnhancements.HONED
	_rm._enhancement_grant = {"type": PieceEnhancements.HONED, "remaining": 2}
	var c := Consumable.new()
	c.enhance_type = PieceEnhancements.GILDED
	c.enhance_pieces = 4
	_rm.apply_consumable(c)
	assert_eq(_rm._enhancement_grant, {"type": PieceEnhancements.HONED, "remaining": 2}, "active grant unaffected")
	assert_eq(_rm._enhancement_grant_queue, [{"type": PieceEnhancements.GILDED, "remaining": 4}], "different-type grant queued instead of replacing")

# ── apply_consumable: immediate effect on the piece currently in play ────

func test_apply_consumable_immediately_enhances_unenhanced_current_piece() -> void:
	_board.current_enhancement = ""
	_rm._enhancement_grant = {}
	var c := Consumable.new()
	c.enhance_type = PieceEnhancements.AMPLIFIED
	c.enhance_pieces = 3
	_rm.apply_consumable(c)

	assert_eq(_board.current_enhancement, PieceEnhancements.AMPLIFIED, "current piece is enhanced immediately")
	assert_eq(_rm._enhancement_grant, {"type": PieceEnhancements.AMPLIFIED, "remaining": 2}, "current piece counts toward the grant")

func test_apply_consumable_immediate_grant_expires_when_only_one_piece() -> void:
	_board.current_enhancement = ""
	_rm._enhancement_grant = {}
	var c := Consumable.new()
	c.enhance_type = PieceEnhancements.GILDED
	c.enhance_pieces = 1
	_rm.apply_consumable(c)

	assert_eq(_board.current_enhancement, PieceEnhancements.GILDED)
	assert_eq(_rm._enhancement_grant, {}, "grant fully consumed by the current piece")

func test_apply_consumable_does_not_override_already_enhanced_current_piece() -> void:
	_board.current_enhancement = PieceEnhancements.HONED
	_rm._enhancement_grant = {}
	var c := Consumable.new()
	c.enhance_type = PieceEnhancements.GILDED
	c.enhance_pieces = 4
	_rm.apply_consumable(c)

	assert_eq(_board.current_enhancement, PieceEnhancements.HONED, "already-enhanced current piece keeps its enhancement")
	assert_eq(_rm._enhancement_grant, {"type": PieceEnhancements.GILDED, "remaining": 4}, "full grant reserved for future pieces")

# ── preview_enhancements: queue preview simulation ────────────────────────

func test_preview_enhancements_matches_periodic_cadence_without_mutating_state() -> void:
	var tech := _make_enhancer_technique(PieceEnhancements.AMPLIFIED, 3)
	RunState.techniques = [tech]
	_rm._enhancement_cadence = {tech.id: 0}

	var preview := _rm.preview_enhancements(5)

	assert_eq(preview, ["", "", PieceEnhancements.AMPLIFIED, "", ""])
	assert_eq(_rm._enhancement_cadence[tech.id], 0, "preview does not mutate live cadence state")

func test_preview_enhancements_matches_actual_spawn_sequence() -> void:
	var tech := _make_enhancer_technique(PieceEnhancements.HONED, 2)
	RunState.techniques = [tech]
	_rm._enhancement_cadence = {tech.id: 0}

	var preview := _rm.preview_enhancements(4)

	var actual: Array[String] = []
	for _i in 4:
		_rm._on_piece_spawned(_board.current_type)
		actual.append(_board.current_enhancement)

	assert_eq(preview, actual)

func test_preview_enhancements_reflects_active_grant_without_consuming_it() -> void:
	_rm._enhancement_grant = {"type": PieceEnhancements.REINFORCED, "remaining": 2}

	var preview := _rm.preview_enhancements(3)

	assert_eq(preview, [PieceEnhancements.REINFORCED, PieceEnhancements.REINFORCED, ""])
	assert_eq(_rm._enhancement_grant, {"type": PieceEnhancements.REINFORCED, "remaining": 2}, "preview does not consume the live grant")

# ── keystone-level piece-enhancer cadence (Midas Touch / Charging Up / Extraordinary Bag) ──

func test_midas_touch_grants_gilded_every_7th_piece() -> void:
	var ks := _make_enhancer_keystone(PieceEnhancements.GILDED, 7)
	RunState.keystones = [ks]
	_rm._enhancement_cadence = {ks.id: 0}

	for i in 6:
		_rm._on_piece_spawned(_board.current_type)
		assert_eq(_board.current_enhancement, "", "piece %d should not be enhanced" % (i + 1))

	_rm._on_piece_spawned(_board.current_type)
	assert_eq(_board.current_enhancement, PieceEnhancements.GILDED, "7th piece is Gilded")
	assert_eq(_rm._enhancement_cadence[ks.id], 0)

func test_charging_up_grants_amplified_every_10th_piece() -> void:
	var ks := _make_enhancer_keystone(PieceEnhancements.AMPLIFIED, 10)
	RunState.keystones = [ks]
	_rm._enhancement_cadence = {ks.id: 0}

	for i in 9:
		_rm._on_piece_spawned(_board.current_type)
		assert_eq(_board.current_enhancement, "", "piece %d should not be enhanced" % (i + 1))

	_rm._on_piece_spawned(_board.current_type)
	assert_eq(_board.current_enhancement, PieceEnhancements.AMPLIFIED, "10th piece is Amplified")

func test_extraordinary_bag_grants_random_enhancement_every_7th_piece() -> void:
	var ks := _make_enhancer_keystone("random", 7)
	RunState.keystones = [ks]
	_rm._enhancement_cadence = {ks.id: 0}

	for i in 6:
		_rm._on_piece_spawned(_board.current_type)
	_rm._on_piece_spawned(_board.current_type)

	assert_true(_board.current_enhancement in PieceEnhancements.ALL_TYPES, "7th piece resolves random to a real enhancement type")

# ── technique-vs-keystone tie-break & grant-queue promotion ──────────────

func test_technique_piece_enhancer_wins_tie_with_keystone() -> void:
	var tech := _make_enhancer_technique(PieceEnhancements.HONED, 2)
	var ks := _make_enhancer_keystone(PieceEnhancements.GILDED, 2)
	RunState.techniques = [tech]
	RunState.keystones = [ks]
	_rm._enhancement_cadence = {tech.id: 0, ks.id: 0}

	_rm._on_piece_spawned(_board.current_type)
	assert_eq(_board.current_enhancement, "")
	_rm._on_piece_spawned(_board.current_type)
	assert_eq(_board.current_enhancement, PieceEnhancements.HONED, "technique grant takes precedence over keystone on a tie")

func test_grant_queue_promotes_next_entry_when_active_grant_drains() -> void:
	_rm._enhancement_grant = {"type": PieceEnhancements.HONED, "remaining": 1}
	_rm._enhancement_grant_queue = [{"type": PieceEnhancements.GILDED, "remaining": 2}]

	_rm._on_piece_spawned(_board.current_type)
	assert_eq(_board.current_enhancement, PieceEnhancements.HONED, "active grant still in effect")
	assert_eq(_rm._enhancement_grant, {"type": PieceEnhancements.GILDED, "remaining": 2}, "queued grant promoted to active")
	assert_eq(_rm._enhancement_grant_queue, [], "queue drained")

	_rm._on_piece_spawned(_board.current_type)
	assert_eq(_board.current_enhancement, PieceEnhancements.GILDED, "promoted grant now applies")
	assert_eq(_rm._enhancement_grant, {"type": PieceEnhancements.GILDED, "remaining": 1})

# ── independent random resolution across multiple pieces ─────────────────

func test_random_grant_resolves_independently_per_piece() -> void:
	_rm._enhancement_grant = {"type": "random", "remaining": 20}

	var seen: Dictionary = {}
	for _i in 20:
		_rm._on_piece_spawned(_board.current_type)
		assert_true(_board.current_enhancement in PieceEnhancements.ALL_TYPES)
		seen[_board.current_enhancement] = true

	assert_true(seen.size() > 1, "20 independent rolls should not all resolve to the same type")
