class_name TetrisBoard
extends Node2D

# ── Constants ──────────────────────────────────────────────────────────────
const TOTAL_ROWS := 22
const VISIBLE_ROWS := 20
const COLS := 10
const CELL_SIZE := 36
const HIDDEN_ROWS := 2  # rows 0-1 are above the visible area

# Gravity: cells per second at level 1 (standard guideline level 1 speed)
const GRAVITY_SPEED := 1.0

const BEVEL_SIZE := 2
const BEVEL_TOP_LIGHTEN    := 0.40
const BEVEL_LEFT_LIGHTEN   := 0.25
const BEVEL_RIGHT_DARKEN   := 0.40
const BEVEL_BOTTOM_DARKEN  := 0.55

const PIECE_COLORS: Dictionary = {
	1: Color(0.0, 0.9, 0.9),   # I — cyan
	2: Color(0.9, 0.9, 0.0),   # O — yellow
	3: Color(0.6, 0.0, 0.9),   # T — purple
	4: Color(0.0, 0.9, 0.0),   # S — green
	5: Color(0.9, 0.0, 0.0),   # Z — red
	6: Color(0.0, 0.0, 0.9),   # J — blue
	7: Color(0.9, 0.5, 0.0),   # L — orange
	8: Color(0.5, 0.5, 0.5),   # ghost
	9: Color(0.35, 0.35, 0.35), # garbage
	10: Color(0.5, 0.05, 0.05), # true damage (dark crimson)
}
const CELL_TRUE_DAMAGE := 10

# Each pattern is an array of [x0,y0, x1,y1] segments in normalised (0–1) coords
# within the inner cell rect. Selected by (col*7 + screen_row*13) % 4.
const CRACK_PATTERNS: Array = [
	# 0: diagonal + branch
	[[0.25, 0.10, 0.55, 0.90], [0.55, 0.50, 0.82, 0.35]],
	# 1: Z-crack
	[[0.15, 0.20, 0.65, 0.35], [0.65, 0.35, 0.35, 0.70], [0.35, 0.70, 0.85, 0.82]],
	# 2: Y-fork
	[[0.50, 0.10, 0.50, 0.55], [0.50, 0.55, 0.20, 0.90], [0.50, 0.55, 0.80, 0.90]],
	# 3: corner crack + branch
	[[0.10, 0.10, 0.45, 0.52], [0.45, 0.52, 0.72, 0.40], [0.45, 0.52, 0.55, 0.87]],
]

# ── Configuration (set by RunManager before round starts) ─────────────────
var config: RoundConfig
var _rng: RandomNumberGenerator = null

# ── Grid ──────────────────────────────────────────────────────────────────
var grid: Array = []  # grid[row][col] = int (0=empty, 1-7=piece, 9=garbage)
var enh_grid: Array = []  # enh_grid[row][col] = String ("" = none, else enhancement type id)

# ── Current piece ─────────────────────────────────────────────────────────
var current_type: String = ""
var current_enhancement: String = ""
var current_pivot: Vector2i = Vector2i.ZERO
var current_rotation: int = 0
var last_move_was_rotation: bool = false

# ── Ghost ─────────────────────────────────────────────────────────────────
var ghost_pivot: Vector2i = Vector2i.ZERO

# ── Hold ──────────────────────────────────────────────────────────────────
var held_pieces: Array = []  # up to hold_slots strings
var held_enhancements: Array = []  # parallel to held_pieces, "" = none
var hold_used: bool = false

# ── Queue ─────────────────────────────────────────────────────────────────
var bag: BagRandomizer
var piece_queue: Array = []  # strings, maintained at preview_count+1 size
var next_piece_forced_t: bool = false

# ── Timing ────────────────────────────────────────────────────────────────
var gravity_accumulator: float = 0.0
var das_timer: float = 0.0
var arr_timer: float = 0.0
var lock_timer: float = 0.0
var lock_resets: int = 0
var das_direction: int = 0  # -1 or 1 while held; 0 = not held

# Configurable timing (read from config/settings)
var das_delay: float = 0.167
var arr_rate: float = 0.033
var sdf_multiplier: int = 10
var lock_delay: float = 0.5
var lock_max_resets: int = 15

# ── State ─────────────────────────────────────────────────────────────────
var is_active: bool = false
var is_on_ground: bool = false
var soft_dropping: bool = false

# ── Line clear delay ──────────────────────────────────────────────────────
var _in_line_clear_delay: bool = false
var _line_clear_timer: float = 0.0
var _pending_clear_rows: Array[int] = []
var _pending_piece_type: String = ""
var _pending_pivot: Vector2i = Vector2i.ZERO
var _pending_rotation: int = 0
var _pending_was_rotation: bool = false

# ── Telemetry ─────────────────────────────────────────────────────────────
var summit_height: int = 0  # rows from top to highest filled cell (0=empty, 20=full)
var true_damage_rows: int = 0

# ── Attack tracking ───────────────────────────────────────────────────────
var combo: int = -1
var is_b2b: bool = false
var b2b_count: int = 0

# ── Enhancement tracking ───────────────────────────────────────────────────
var pending_enhancement_counts: Dictionary = {}

# ── Signals ───────────────────────────────────────────────────────────────
signal piece_locked
signal line_clear_delay_started(clear_type: String)
signal lock_processed
signal lines_cleared(count: int, clear_type: String)
signal rows_cleared(row_indices: Array[int])
signal attack_generated(raw_attack: int, event_type: String)
signal b2b_broken(streak: int)
signal piece_rotated(piece_type: String)
signal piece_spawned(piece_type: String)
signal game_over
signal board_updated

# ── Initialisation ────────────────────────────────────────────────────────

func setup(round_config: RoundConfig) -> void:
	config = round_config
	_rng = config.rng
	lock_delay = config.lock_delay_ms / 1000.0
	lock_max_resets = config.lock_max_resets
	if config.instant_arr:
		arr_rate = 0.0
	_init_grid()
	bag = BagRandomizer.new(config.bag_reset_interval, config.rng)
	piece_queue.clear()
	held_pieces.clear()
	held_enhancements.clear()
	hold_used = false
	combo = -1
	is_b2b = false
	b2b_count = 0
	_fill_queue()
	spawn_next_piece()
	is_active = true

func clear_board() -> void:
	_init_grid()
	held_pieces.clear()
	held_enhancements.clear()
	hold_used = false
	combo = -1
	is_b2b = false
	b2b_count = 0
	piece_queue.clear()
	_fill_queue()
	spawn_next_piece()
	queue_redraw()

func _init_grid() -> void:
	grid = []
	enh_grid = []
	for _r in range(TOTAL_ROWS):
		var row := []
		row.resize(COLS)
		row.fill(0)
		grid.append(row)
		var enh_row := []
		enh_row.resize(COLS)
		enh_row.fill("")
		enh_grid.append(enh_row)

func _fill_queue() -> void:
	while piece_queue.size() < config.preview_count + 1:
		if config.random_pieces:
			piece_queue.append(PieceData.ALL_TYPES[config.rng.randi_range(0, 6)])
		else:
			piece_queue.append(bag.next())

# ── Per-frame update ──────────────────────────────────────────────────────

func tick(delta: float) -> void:
	if not is_active:
		return
	if _in_line_clear_delay:
		_line_clear_timer += delta
		queue_redraw()
		if _line_clear_timer >= config.line_clear_delay:
			_in_line_clear_delay = false
			_execute_pending_clears()
			if not _spawn_next():
				is_active = false
				emit_signal("game_over")
		return
	_handle_das(delta)
	_handle_gravity(delta)
	if is_on_ground:
		_handle_lock(delta)

func _handle_das(delta: float) -> void:
	if das_direction == 0:
		return
	das_timer += delta
	if das_timer >= das_delay:
		if arr_rate <= 0.0:
			# ARR = 0: instant — move all the way to the wall in one frame
			while _cells_valid(current_type, current_rotation, current_pivot + Vector2i(das_direction, 0)):
				_move_horizontal(das_direction)
			arr_timer = 0.0
		else:
			arr_timer += delta
			while arr_timer >= arr_rate:
				arr_timer -= arr_rate
				_move_horizontal(das_direction)

func _handle_gravity(delta: float) -> void:
	var soft_mult := 1000.0 if config.instant_soft_drop else float(sdf_multiplier)
	var speed := GRAVITY_SPEED * (soft_mult if soft_dropping else 1.0)
	gravity_accumulator += speed * delta
	while gravity_accumulator >= 1.0:
		gravity_accumulator -= 1.0
		if not _try_move(current_pivot + Vector2i(0, 1)):
			if not is_on_ground:
				is_on_ground = true
				lock_timer = 0.0
				lock_resets = 0
		else:
			is_on_ground = false

func _handle_lock(delta: float) -> void:
	lock_timer += delta
	if lock_timer >= lock_delay or lock_resets >= lock_max_resets:
		_lock_piece()

# ── Input handlers (called by TetrisBoard's parent scene) ─────────────────

func input_move_left_pressed() -> void:
	das_direction = -1
	das_timer = 0.0
	arr_timer = 0.0
	if _in_line_clear_delay:
		return
	_move_horizontal(-1)

func input_move_right_pressed() -> void:
	das_direction = 1
	das_timer = 0.0
	arr_timer = 0.0
	if _in_line_clear_delay:
		return
	_move_horizontal(1)

func input_move_released() -> void:
	das_direction = 0
	das_timer = 0.0
	arr_timer = 0.0

func input_soft_drop(pressed: bool) -> void:
	if _in_line_clear_delay:
		soft_dropping = false
		return
	if pressed and not soft_dropping:
		gravity_accumulator = 0.0  # reset only on initial press for immediate response
	soft_dropping = pressed

func input_hard_drop() -> void:
	if _in_line_clear_delay:
		return
	current_pivot = ghost_pivot
	gravity_accumulator = 0.0
	is_on_ground = true
	lock_timer = lock_delay  # lock immediately
	_lock_piece()

func input_rotate_cw() -> void:
	if _in_line_clear_delay:
		return
	_try_rotate(SRS.next_rotation_cw(current_rotation))

func input_rotate_ccw() -> void:
	if _in_line_clear_delay:
		return
	_try_rotate(SRS.next_rotation_ccw(current_rotation))

func input_rotate_180() -> void:
	if _in_line_clear_delay:
		return
	_try_rotate(SRS.next_rotation_180(current_rotation))

func input_hold() -> void:
	if _in_line_clear_delay:
		return
	if config.hold_disabled:
		return
	if hold_used and config.hold_lockout_enabled and config.hold_slots <= 1:
		return
	var held_type := current_type
	var held_enhancement := current_enhancement
	if held_pieces.size() < config.hold_slots:
		held_pieces.append(held_type)
		held_enhancements.append(held_enhancement)
		current_type = piece_queue.pop_front()
		current_enhancement = ""
		_fill_queue()
	else:
		current_type = held_pieces.pop_front()
		current_enhancement = held_enhancements.pop_front()
		held_pieces.push_back(held_type)
		held_enhancements.push_back(held_enhancement)
	current_rotation = 0
	current_pivot = Vector2i(PieceData.SPAWN_COL, PieceData.SPAWN_ROW)
	hold_used = true
	gravity_accumulator = 0.0
	is_on_ground = false
	lock_timer = 0.0
	last_move_was_rotation = false
	_update_ghost()
	emit_signal("board_updated")

# ── Movement helpers ──────────────────────────────────────────────────────

func _move_horizontal(dir: int) -> void:
	var new_pivot := current_pivot + Vector2i(dir, 0)
	if _try_move(new_pivot):
		last_move_was_rotation = false
		if is_on_ground:
			if _cells_valid(current_type, current_rotation, current_pivot + Vector2i(0, 1)):
				is_on_ground = false
				lock_timer = 0.0
			else:
				_reset_lock()

func _try_move(new_pivot: Vector2i) -> bool:
	if _cells_valid(current_type, current_rotation, new_pivot):
		current_pivot = new_pivot
		_update_ghost()
		emit_signal("board_updated")
		return true
	return false

func _try_rotate(new_rot: int) -> void:
	var kicks: Array[Vector2i] = SRS.get_kicks(current_type, current_rotation, new_rot)
	for kick: Vector2i in kicks:
		var test_pivot: Vector2i = current_pivot + kick
		if _cells_valid(current_type, new_rot, test_pivot):
			current_pivot = test_pivot
			current_rotation = new_rot
			last_move_was_rotation = true
			if is_on_ground:
				_reset_lock()
			_update_ghost()
			emit_signal("piece_rotated", current_type)
			emit_signal("board_updated")
			return

func _reset_lock() -> void:
	if lock_resets < lock_max_resets:
		lock_resets += 1
		lock_timer = 0.0

# ── Ghost piece ───────────────────────────────────────────────────────────

func _update_ghost() -> void:
	ghost_pivot = current_pivot
	while _cells_valid(current_type, current_rotation, ghost_pivot + Vector2i(0, 1)):
		ghost_pivot += Vector2i(0, 1)

func get_ghost_distance() -> int:
	return ghost_pivot.y - current_pivot.y

# ── Cell validation ───────────────────────────────────────────────────────

func _cells_valid(piece_type: String, rotation: int, pivot: Vector2i) -> bool:
	var effective_cols := config.board_width
	for offset: Vector2i in PieceData.get_cells(piece_type, rotation):
		var cell: Vector2i = pivot + offset
		if cell.x < 0 or cell.x >= effective_cols:
			return false
		if cell.y >= TOTAL_ROWS:
			return false
		if cell.y >= 0 and grid[cell.y][cell.x] != 0:
			return false
	return true

# ── Piece locking ─────────────────────────────────────────────────────────

func _lock_piece() -> void:
	if not is_active:
		return
	var cells: Array[Vector2i] = PieceData.get_world_cells(current_type, current_rotation, current_pivot)
	var color_id := PieceData.get_color_id(current_type)
	for cell: Vector2i in cells:
		if cell.y >= 0 and cell.y < TOTAL_ROWS:
			grid[cell.y][cell.x] = color_id
			enh_grid[cell.y][cell.x] = current_enhancement
	current_enhancement = ""
	var was_rotation := last_move_was_rotation
	var locked_type := current_type
	var locked_pivot := current_pivot
	var locked_rotation := current_rotation
	emit_signal("piece_locked")
	hold_used = false
	_update_summit_height()
	var full_rows := _find_full_rows()
	pending_enhancement_counts = PieceEnhancements.count_in_rows(enh_grid, full_rows)
	if full_rows.size() > 0:
		# Always announce the clear before processing it, so listeners evaluate
		# against pre-clear state (combo/B2B/height) regardless of delay config
		_pending_clear_rows = full_rows
		var _pre_tspin := _detect_tspin(locked_type, locked_pivot, locked_rotation, was_rotation)
		var _pre_pc := _would_be_perfect_clear()
		var _pre_type := _get_clear_type(full_rows.size(), _pre_tspin, _pre_pc)
		if config.line_clear_delay > 0.0:
			_pending_piece_type = locked_type
			_pending_pivot = locked_pivot
			_pending_rotation = locked_rotation
			_pending_was_rotation = was_rotation
			_in_line_clear_delay = true
			_line_clear_timer = 0.0
			queue_redraw()
			emit_signal("line_clear_delay_started", _pre_type)
			return
		emit_signal("line_clear_delay_started", _pre_type)
		_process_clears(locked_type, locked_pivot, locked_rotation, was_rotation)
	else:
		_process_clears(locked_type, locked_pivot, locked_rotation, was_rotation)
	emit_signal("lock_processed")
	if not _spawn_next():
		is_active = false
		emit_signal("game_over")

func _spawn_next() -> bool:
	if next_piece_forced_t:
		current_type = "T"
		next_piece_forced_t = false
	else:
		current_type = piece_queue.pop_front()
		_fill_queue()
	current_rotation = 0
	current_pivot = Vector2i(PieceData.SPAWN_COL, PieceData.SPAWN_ROW)
	is_on_ground = false
	gravity_accumulator = 0.0
	lock_timer = 0.0
	lock_resets = 0
	last_move_was_rotation = false
	_update_ghost()
	emit_signal("board_updated")
	emit_signal("piece_spawned", current_type)
	# Block-out check
	return _cells_valid(current_type, current_rotation, current_pivot)

func spawn_next_piece() -> void:
	_spawn_next()

# ── Line clear processing ─────────────────────────────────────────────────

func _find_full_rows() -> Array[int]:
	var full: Array[int] = []
	for r in range(TOTAL_ROWS - 1, -1, -1):
		if _is_row_full(r):
			full.append(r)
	return full

func _execute_pending_clears() -> void:
	_process_clears(_pending_piece_type, _pending_pivot, _pending_rotation, _pending_was_rotation)
	emit_signal("lock_processed")

func _process_clears(piece_type: String, pivot: Vector2i, rotation: int, was_rotation: bool) -> void:
	var is_tspin := _detect_tspin(piece_type, pivot, rotation, was_rotation)
	var cleared_rows := _find_and_clear_rows()
	var clear_count := cleared_rows.size()
	if clear_count == 0:
		combo = -1
		return

	combo += 1
	var is_pc := _detect_perfect_clear()
	var clear_type := _get_clear_type(clear_count, is_tspin, is_pc)
	var is_qualifying := clear_type in ["quad", "tspin_single", "tspin_double", "tspin_triple", "tspin_mini", "perfect_clear"]

	_update_summit_height()
	emit_signal("lines_cleared", clear_count, clear_type)
	emit_signal("rows_cleared", cleared_rows)
	_emit_attack_events(clear_type, is_qualifying, is_pc, was_rotation)
	emit_signal("board_updated")

func _emit_attack_events(clear_type: String, is_qualifying: bool, is_pc: bool, was_rotation: bool) -> void:
	if is_pc:
		emit_signal("attack_generated", 10, clear_type)
		return

	var base_attack: int = BASE_ATTACK.get(clear_type, 0)
	var b2b_bonus := 0
	var combo_bonus := 0

	if not config.b2b_disabled:
		var effective_qualifying := is_qualifying or (config.flexible_b2b and was_rotation)
		if effective_qualifying:
			if is_b2b:
				b2b_bonus = 1
				b2b_count += 1
			else:
				b2b_count = 1
			is_b2b = true
		else:
			if not (config.b2b_persists_on_doubles and clear_type == "double"):
				if is_b2b:
					if config.b2b_shield_count > 0:
						config.b2b_shield_count -= 1
					else:
						var broken_streak := b2b_count
						is_b2b = false
						b2b_count = 0
						emit_signal("b2b_broken", broken_streak)
	else:
		is_b2b = false
		b2b_count = 0

	if combo >= 0 and combo < COMBO_TABLE.size():
		combo_bonus = COMBO_TABLE[combo]
	elif combo >= COMBO_TABLE.size():
		combo_bonus = COMBO_TABLE[COMBO_TABLE.size() - 1]

	emit_signal("attack_generated", base_attack, clear_type)
	if b2b_bonus > 0:
		emit_signal("attack_generated", b2b_bonus, "b2b")
	if combo_bonus > 0:
		emit_signal("attack_generated", combo_bonus, "combo")

func _find_and_clear_rows() -> Array[int]:
	var cleared: Array[int] = []
	for r in range(TOTAL_ROWS - 1, -1, -1):
		if _is_row_full(r):
			cleared.append(r)
	if cleared.is_empty():
		return cleared
	for r in cleared:
		grid.remove_at(r)
		enh_grid.remove_at(r)
	for _i in cleared.size():
		var empty_row := []
		empty_row.resize(COLS)
		empty_row.fill(0)
		grid.insert(0, empty_row)
		var empty_enh_row := []
		empty_enh_row.resize(COLS)
		empty_enh_row.fill("")
		enh_grid.insert(0, empty_enh_row)
	return cleared

func _is_row_full(row: int) -> bool:
	for col in range(config.board_width):
		if grid[row][col] == 0:
			return false
		if grid[row][col] == CELL_TRUE_DAMAGE:
			return false
	return true

# ── T-spin detection (3-corner rule) ─────────────────────────────────────

func _detect_tspin(piece_type: String, pivot: Vector2i, rotation: int, was_rotation: bool) -> bool:
	if piece_type != "T" or not was_rotation:
		return false
	# The 4 diagonal corners of the T pivot
	var corners: Array[Vector2i] = [
		Vector2i(-1, -1), Vector2i(1, -1),
		Vector2i(-1, 1), Vector2i(1, 1),
	]
	var filled := 0
	for c: Vector2i in corners:
		var cell: Vector2i = pivot + c
		if cell.x < 0 or cell.x >= config.board_width or cell.y >= TOTAL_ROWS or cell.y < 0:
			filled += 1
		elif grid[cell.y][cell.x] != 0:
			filled += 1
	return filled >= 3

# ── Perfect clear detection ───────────────────────────────────────────────

func _detect_perfect_clear() -> bool:
	for r in range(TOTAL_ROWS):
		for c in range(config.board_width):
			if grid[r][c] != 0:
				return false
	return true

func _would_be_perfect_clear() -> bool:
	for r in range(TOTAL_ROWS):
		if r in _pending_clear_rows:
			continue
		for c in range(config.board_width):
			if grid[r][c] != 0:
				return false
	return true

# ── Clear type classification ─────────────────────────────────────────────

func _get_clear_type(count: int, is_tspin: bool, is_pc: bool) -> String:
	if is_pc:
		return "perfect_clear"
	if is_tspin:
		match count:
			1: return "tspin_single"
			2: return "tspin_double"
			3: return "tspin_triple"
	match count:
		1: return "single"
		2: return "double"
		3: return "triple"
		4: return "quad"
	return "single"

# ── Attack calculation ────────────────────────────────────────────────────

const BASE_ATTACK: Dictionary = {
	"single": 0, "double": 1, "triple": 2, "quad": 4,
	"tspin_mini": 1, "tspin_single": 2, "tspin_double": 4, "tspin_triple": 6,
	"perfect_clear": 10,
}

const COMBO_TABLE := [0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 4]

func _calculate_attack(count: int, clear_type: String, is_qualifying: bool, is_pc: bool) -> int:
	if is_pc:
		return 10

	var base: int = BASE_ATTACK.get(clear_type, 0)

	var b2b_bonus := 0
	if not config.b2b_disabled:
		if is_qualifying:
			if is_b2b:
				b2b_bonus = 1
				b2b_count += 1
			else:
				b2b_count = 1
			is_b2b = true
		else:
			# Persistence technique: doubles don't break B2B chain
			if not (config.b2b_persists_on_doubles and clear_type == "double"):
				is_b2b = false
				b2b_count = 0
	else:
		is_b2b = false
		b2b_count = 0

	var combo_bonus := 0
	if combo >= 0 and combo < COMBO_TABLE.size():
		combo_bonus = COMBO_TABLE[combo]
	elif combo >= COMBO_TABLE.size():
		combo_bonus = COMBO_TABLE[COMBO_TABLE.size() - 1]

	return base + b2b_bonus + combo_bonus

# ── Garbage insertion (The Tide boss modifier) ────────────────────────────

func insert_garbage_row() -> void:
	var col := (_rng.randi() if _rng else randi()) % config.board_width
	insert_garbage_rows(1, col)

func insert_garbage_rows(count: int, col: int) -> void:
	for _i in count:
		grid.remove_at(0)
		enh_grid.remove_at(0)
		var garbage := []
		garbage.resize(COLS)
		garbage.fill(PieceData.COLOR_GARBAGE)
		garbage[col] = 0
		grid.append(garbage)
		var empty_enh_row := []
		empty_enh_row.resize(COLS)
		empty_enh_row.fill("")
		enh_grid.append(empty_enh_row)
	_update_ghost()
	_update_summit_height()
	emit_signal("board_updated")

func insert_true_damage_row() -> void:
	grid.remove_at(0)
	enh_grid.remove_at(0)
	var td_row := []
	td_row.resize(COLS)
	td_row.fill(CELL_TRUE_DAMAGE)
	grid.append(td_row)
	var empty_enh_row := []
	empty_enh_row.resize(COLS)
	empty_enh_row.fill("")
	enh_grid.append(empty_enh_row)
	true_damage_rows += 1
	_update_ghost()
	_update_summit_height()
	emit_signal("board_updated")

# ── Board telemetry ───────────────────────────────────────────────────────

func _update_summit_height() -> void:
	summit_height = 0
	for r in range(HIDDEN_ROWS, TOTAL_ROWS):
		for c in range(COLS):
			if grid[r][c] != 0:
				summit_height = TOTAL_ROWS - r
				return

# ── Board query helpers ───────────────────────────────────────────────────

func get_current_cells() -> Array:
	return PieceData.get_world_cells(current_type, current_rotation, current_pivot)

func get_ghost_cells() -> Array:
	return PieceData.get_world_cells(current_type, current_rotation, ghost_pivot)

func get_visible_row(screen_row: int) -> Array:
	# screen_row 0 = topmost visible row
	return grid[HIDDEN_ROWS + screen_row]

func get_preview_types() -> Array:
	return piece_queue.slice(0, config.preview_count)

# ── Rendering ─────────────────────────────────────────────────────────────

func _draw() -> void:
	# Board background
	draw_rect(Rect2(0, 0, config.board_width * CELL_SIZE, VISIBLE_ROWS * CELL_SIZE), Color(0.08, 0.07, 0.10))

	# Grid cells (visible rows only)
	for screen_row in range(VISIBLE_ROWS):
		var grid_row: int = HIDDEN_ROWS + screen_row
		for col in range(config.board_width):
			var cell_val: int = grid[grid_row][col]
			if cell_val != 0:
				if cell_val == 9:
					_draw_garbage_cell(col, screen_row)
				else:
					var enh: String = enh_grid[grid_row][col]
					if enh != "":
						_draw_enhanced_cell(col, screen_row, PIECE_COLORS.get(cell_val, Color.WHITE), enh)
					else:
						_draw_cell(col, screen_row, PIECE_COLORS.get(cell_val, Color.WHITE))

	# Line clear flash overlay
	if _in_line_clear_delay and config.line_clear_delay > 0.0:
		var flash_t := absf(sin(_line_clear_timer * PI / config.line_clear_delay * 3.0))
		for grid_row: int in _pending_clear_rows:
			var screen_row := grid_row - HIDDEN_ROWS
			if screen_row < 0 or screen_row >= VISIBLE_ROWS:
				continue
			for col in range(config.board_width):
				var cell_val: int = grid[grid_row][col]
				if cell_val != 0:
					var base_color := _enhancement_fill_color(enh_grid[grid_row][col], PIECE_COLORS.get(cell_val, Color.WHITE))
					_draw_cell(col, screen_row, base_color.lerp(Color.WHITE, flash_t))

	# Ghost piece
	var ghost_cells: Array[Vector2i] = get_ghost_cells()
	var ghost_piece_color: Color = PIECE_COLORS.get(PieceData.get_color_id(current_type), Color.WHITE)
	for cell: Vector2i in ghost_cells:
		var screen_row := cell.y - HIDDEN_ROWS
		if screen_row >= 0 and screen_row < VISIBLE_ROWS:
			_draw_ghost_cell(cell.x, screen_row, ghost_piece_color, soft_dropping, current_enhancement)
			if config.deep_sight_enabled:
				var dist := get_ghost_distance()
				draw_string(ThemeDB.fallback_font, Vector2(cell.x * CELL_SIZE + 2, screen_row * CELL_SIZE + 22), str(dist), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)

	# Current piece
	var current_cells: Array[Vector2i] = get_current_cells()
	for cell: Vector2i in current_cells:
		var screen_row := cell.y - HIDDEN_ROWS
		if screen_row >= 0 and screen_row < VISIBLE_ROWS:
			var current_color: Color = PIECE_COLORS.get(PieceData.get_color_id(current_type), Color.WHITE)
			if current_enhancement != "":
				_draw_enhanced_cell(cell.x, screen_row, current_color, current_enhancement)
			else:
				_draw_cell(cell.x, screen_row, current_color)

	# Grid lines
	var grid_color := Color(0.2, 0.2, 0.2)
	for c in range(config.board_width + 1):
		draw_line(Vector2(c * CELL_SIZE, 0), Vector2(c * CELL_SIZE, VISIBLE_ROWS * CELL_SIZE), grid_color)
	for r in range(VISIBLE_ROWS + 1):
		draw_line(Vector2(0, r * CELL_SIZE), Vector2(config.board_width * CELL_SIZE, r * CELL_SIZE), grid_color)

func _draw_cell(col: int, screen_row: int, color: Color) -> void:
	var x := col * CELL_SIZE + 1
	var y := screen_row * CELL_SIZE + 1
	var s := CELL_SIZE - 2
	# Base fill
	draw_rect(Rect2(x, y, s, s), color)
	# Bevel — top highlight
	draw_rect(Rect2(x, y, s, BEVEL_SIZE), color.lightened(BEVEL_TOP_LIGHTEN))
	# Bevel — left highlight
	draw_rect(Rect2(x, y + BEVEL_SIZE, BEVEL_SIZE, s - BEVEL_SIZE), color.lightened(BEVEL_LEFT_LIGHTEN))
	# Bevel — bottom shadow
	draw_rect(Rect2(x, y + s - BEVEL_SIZE, s, BEVEL_SIZE), color.darkened(BEVEL_BOTTOM_DARKEN))
	# Bevel — right shadow
	draw_rect(Rect2(x + s - BEVEL_SIZE, y, BEVEL_SIZE, s - BEVEL_SIZE), color.darkened(BEVEL_RIGHT_DARKEN))

func _draw_garbage_cell(col: int, screen_row: int) -> void:
	_draw_cell(col, screen_row, PIECE_COLORS[9])
	var x := float(col * CELL_SIZE + 1)
	var y := float(screen_row * CELL_SIZE + 1)
	var s := float(CELL_SIZE - 2)
	var crack_color := Color(0.0, 0.0, 0.0, 0.70)
	var pattern_idx: int = (col * 7 + screen_row * 13) % CRACK_PATTERNS.size()
	for seg in CRACK_PATTERNS[pattern_idx]:
		draw_line(
			Vector2(x + seg[0] * s, y + seg[1] * s),
			Vector2(x + seg[2] * s, y + seg[3] * s),
			crack_color, 1.0
		)

func _draw_ghost_cell(col: int, screen_row: int, piece_color: Color, is_soft_drop: bool, enh_type: String = "") -> void:
	var x := col * CELL_SIZE + 1
	var y := screen_row * CELL_SIZE + 1
	var s := CELL_SIZE - 2
	# Void fill
	draw_rect(Rect2(x, y, s, s), Color(0.05, 0.04, 0.08))
	# Rune outline
	var outline_color: Color
	match enh_type:
		PieceEnhancements.HONED:
			outline_color = PieceEnhancements.HONED_COLOR
		PieceEnhancements.GILDED:
			outline_color = PieceEnhancements.GILDED_COLOR
		PieceEnhancements.REINFORCED:
			outline_color = PieceEnhancements.REINFORCED_BORDER_COLOR
		_:
			if is_soft_drop:
				outline_color = Color(1.0, 1.0, 1.0, 0.85)
			else:
				outline_color = Color(piece_color.r, piece_color.g, piece_color.b, 0.75)
	draw_rect(Rect2(x, y, s, BEVEL_SIZE), outline_color)
	draw_rect(Rect2(x, y + s - BEVEL_SIZE, s, BEVEL_SIZE), outline_color)
	draw_rect(Rect2(x, y, BEVEL_SIZE, s), outline_color)
	draw_rect(Rect2(x + s - BEVEL_SIZE, y, BEVEL_SIZE, s), outline_color)
	if enh_type == PieceEnhancements.AMPLIFIED:
		_draw_amplified_triangle(col, screen_row)

# ── Enhancement cell styling ──────────────────────────────────────────────

func _enhancement_fill_color(enh_type: String, fallback_color: Color) -> Color:
	match enh_type:
		PieceEnhancements.HONED:
			return PieceEnhancements.HONED_COLOR
		PieceEnhancements.GILDED:
			return PieceEnhancements.GILDED_COLOR
		PieceEnhancements.REINFORCED:
			return PieceEnhancements.REINFORCED_FILL_COLOR
		_:
			return fallback_color

func _draw_metallic_cell(col: int, screen_row: int, color: Color) -> void:
	var x := col * CELL_SIZE + 1
	var y := screen_row * CELL_SIZE + 1
	var s := CELL_SIZE - 2

	var dark := color.darkened(0.20)
	var mid := color
	var bright := color.lightened(0.30)

	# Bottom half — darker base
	draw_rect(Rect2(x, y, s, s), dark)
	# Top half — mid tone
	draw_rect(Rect2(x, y, s, s * 0.55), mid)
	# Specular highlight band in upper quarter
	draw_rect(Rect2(x + 3, y + 3, s - 6, s * 0.22), bright)

	# Metallic bevels — sharper contrast than normal cells
	draw_rect(Rect2(x, y, s, BEVEL_SIZE), color.lightened(0.55))
	draw_rect(Rect2(x, y + BEVEL_SIZE, BEVEL_SIZE, s - BEVEL_SIZE), color.lightened(0.35))
	draw_rect(Rect2(x, y + s - BEVEL_SIZE, s, BEVEL_SIZE), color.darkened(0.65))
	draw_rect(Rect2(x + s - BEVEL_SIZE, y, BEVEL_SIZE, s - BEVEL_SIZE), color.darkened(0.50))

func _draw_enhanced_cell(col: int, screen_row: int, base_color: Color, enh_type: String) -> void:
	match enh_type:
		PieceEnhancements.HONED:
			_draw_metallic_cell(col, screen_row, PieceEnhancements.HONED_COLOR)
		PieceEnhancements.GILDED:
			_draw_metallic_cell(col, screen_row, PieceEnhancements.GILDED_COLOR)
		PieceEnhancements.REINFORCED:
			_draw_cell(col, screen_row, PieceEnhancements.REINFORCED_FILL_COLOR)
			_draw_cell_border(col, screen_row, PieceEnhancements.REINFORCED_BORDER_COLOR)
		PieceEnhancements.AMPLIFIED:
			_draw_cell(col, screen_row, base_color)
			_draw_amplified_triangle(col, screen_row)
		_:
			_draw_cell(col, screen_row, base_color)

func _draw_cell_border(col: int, screen_row: int, color: Color) -> void:
	var x := col * CELL_SIZE + 1
	var y := screen_row * CELL_SIZE + 1
	var s := CELL_SIZE - 2
	var w := BEVEL_SIZE
	draw_rect(Rect2(x, y, s, w), color)
	draw_rect(Rect2(x, y + s - w, s, w), color)
	draw_rect(Rect2(x, y, w, s), color)
	draw_rect(Rect2(x + s - w, y, w, s), color)

func _draw_amplified_triangle(col: int, screen_row: int) -> void:
	var x := float(col * CELL_SIZE + 1)
	var y := float(screen_row * CELL_SIZE + 1)
	var s := float(CELL_SIZE - 2)
	var cx := x + s * 0.5
	var cy := y + s * 0.5
	var r := s * 0.22
	var points := PackedVector2Array([
		Vector2(cx, cy - r),
		Vector2(cx - r * 0.87, cy + r * 0.5),
		Vector2(cx + r * 0.87, cy + r * 0.5),
	])
	draw_colored_polygon(points, PieceEnhancements.AMPLIFIED_TRIANGLE_COLOR)
