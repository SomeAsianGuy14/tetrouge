extends GutTest

var _rm: RunManager
var _board: TetrisBoard
var _cfg: RoundConfig
var _saved_techniques: Array

func before_each() -> void:
	_saved_techniques = RunState.techniques.duplicate()
	RunState.techniques = []
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
	_board.free()
	_rm.free()

func _make_enhancer_technique(enhancement: String, every_n: int) -> Technique:
	var t := Technique.new()
	t.id = "test_enhancer_%s" % enhancement
	t.effect_type = "piece_enhancer"
	t.params = {"enhancement": enhancement, "every_n": every_n}
	return t

# ── 13.11: hold swap does not consume grant / advance cadence ────────────

func test_hold_swap_restores_enhancement_without_consuming_grant_or_cadence() -> void:
	_cfg.hold_slots = 1
	_rm._enhancement_grant = {"type": PieceEnhancements.GILDED, "remaining": 2}
	_rm._enhancement_cadence = {"keen_edge": 1}

	_board.current_enhancement = PieceEnhancements.HONED
	_board.input_hold()
	_board.input_hold()

	assert_eq(_board.current_enhancement, PieceEnhancements.HONED)
	assert_eq(_rm._enhancement_grant, {"type": PieceEnhancements.GILDED, "remaining": 2})
	assert_eq(_rm._enhancement_cadence, {"keen_edge": 1})

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

func test_apply_consumable_replaces_different_type_grant() -> void:
	_board.current_enhancement = PieceEnhancements.HONED
	_rm._enhancement_grant = {"type": PieceEnhancements.HONED, "remaining": 2}
	var c := Consumable.new()
	c.enhance_type = PieceEnhancements.GILDED
	c.enhance_pieces = 4
	_rm.apply_consumable(c)
	assert_eq(_rm._enhancement_grant, {"type": PieceEnhancements.GILDED, "remaining": 4})

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
