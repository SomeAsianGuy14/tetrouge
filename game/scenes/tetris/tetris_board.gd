class_name TetrisBoard
extends Node2D

# ── Constants ──────────────────────────────────────────────────────────────
const TOTAL_ROWS := 22
const VISIBLE_ROWS := 20
const COLS := 10
const CELL_SIZE := 32
const HIDDEN_ROWS := 2  # rows 0-1 are above the visible area

# Gravity: cells per second at level 1 (standard guideline level 1 speed)
const GRAVITY_SPEED := 1.0

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
}

# ── Configuration (set by RunManager before round starts) ─────────────────
var config: RoundConfig

# ── Grid ──────────────────────────────────────────────────────────────────
var grid: Array = []  # grid[row][col] = int (0=empty, 1-7=piece, 9=garbage)

# ── Current piece ─────────────────────────────────────────────────────────
var current_type: String = ""
var current_pivot: Vector2i = Vector2i.ZERO
var current_rotation: int = 0
var last_move_was_rotation: bool = false

# ── Ghost ─────────────────────────────────────────────────────────────────
var ghost_pivot: Vector2i = Vector2i.ZERO

# ── Hold ──────────────────────────────────────────────────────────────────
var held_pieces: Array = []  # up to hold_slots strings
var hold_used: bool = false

# ── Queue ─────────────────────────────────────────────────────────────────
var bag: BagRandomizer
var piece_queue: Array = []  # strings, maintained at preview_count+1 size
var next_piece_forced_t: bool = false  # Piece Lock consumable

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
var lock_delay: float = 0.5
var lock_max_resets: int = 15

# ── State ─────────────────────────────────────────────────────────────────
var is_active: bool = false
var is_on_ground: bool = false
var soft_dropping: bool = false

# ── Attack tracking ───────────────────────────────────────────────────────
var combo: int = -1
var is_b2b: bool = false
var attack_surge_remaining: int = 0  # Attack Surge consumable

# ── Signals ───────────────────────────────────────────────────────────────
signal piece_locked
signal lines_cleared(count: int, clear_type: String)
signal attack_generated(raw_attack: int, event_type: String)
signal game_over
signal board_updated

# ── Initialisation ────────────────────────────────────────────────────────

func setup(round_config: RoundConfig) -> void:
	config = round_config
	lock_delay = config.lock_delay_ms / 1000.0
	lock_max_resets = config.lock_max_resets
	_init_grid()
	bag = BagRandomizer.new(config.bag_reset_interval)
	piece_queue.clear()
	held_pieces.clear()
	hold_used = false
	combo = -1
	is_b2b = false
	attack_surge_remaining = 0
	_fill_queue()
	spawn_next_piece()
	is_active = true

func _init_grid() -> void:
	grid = []
	for _r in range(TOTAL_ROWS):
		var row := []
		row.resize(COLS)
		row.fill(0)
		grid.append(row)

func _fill_queue() -> void:
	while piece_queue.size() < config.preview_count + 1:
		piece_queue.append(bag.next())

# ── Per-frame update ──────────────────────────────────────────────────────

func tick(delta: float) -> void:
	if not is_active:
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
		arr_timer += delta
		while arr_timer >= arr_rate:
			arr_timer -= arr_rate
			_move_horizontal(das_direction)

func _handle_gravity(delta: float) -> void:
	var speed := GRAVITY_SPEED * (20.0 if soft_dropping else 1.0)
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
	_move_horizontal(-1)

func input_move_right_pressed() -> void:
	das_direction = 1
	das_timer = 0.0
	arr_timer = 0.0
	_move_horizontal(1)

func input_move_released() -> void:
	das_direction = 0
	das_timer = 0.0
	arr_timer = 0.0

func input_soft_drop(pressed: bool) -> void:
	soft_dropping = pressed
	if pressed:
		gravity_accumulator = 0.0

func input_hard_drop() -> void:
	current_pivot = ghost_pivot
	gravity_accumulator = 0.0
	is_on_ground = true
	lock_timer = lock_delay  # lock immediately
	_lock_piece()

func input_rotate_cw() -> void:
	_try_rotate(SRS.next_rotation_cw(current_rotation))

func input_rotate_ccw() -> void:
	_try_rotate(SRS.next_rotation_ccw(current_rotation))

func input_rotate_180() -> void:
	_try_rotate(SRS.next_rotation_180(current_rotation))

func input_hold() -> void:
	if config.hold_disabled:
		return
	if hold_used and config.hold_lockout_enabled:
		return
	var swap_type := current_type
	if held_pieces.size() > 0:
		current_type = held_pieces[0]
		held_pieces[0] = swap_type
	else:
		held_pieces.append(swap_type)
		current_type = piece_queue.pop_front()
		_fill_queue()
	if config.hold_slots > 1 and held_pieces.size() < config.hold_slots:
		pass  # second slot stays empty until filled
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
			_reset_lock()

func _try_move(new_pivot: Vector2i) -> bool:
	if _cells_valid(current_type, current_rotation, new_pivot):
		current_pivot = new_pivot
		_update_ghost()
		emit_signal("board_updated")
		return true
	return false

func _try_rotate(new_rot: int) -> void:
	var kicks := SRS.get_kicks(current_type, current_rotation, new_rot)
	for kick in kicks:
		var test_pivot := current_pivot + kick
		if _cells_valid(current_type, new_rot, test_pivot):
			current_pivot = test_pivot
			current_rotation = new_rot
			last_move_was_rotation = true
			if is_on_ground:
				_reset_lock()
			_update_ghost()
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
	for offset in PieceData.get_cells(piece_type, rotation):
		var cell := pivot + offset
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
	var cells := PieceData.get_world_cells(current_type, current_rotation, current_pivot)
	var color_id := PieceData.get_color_id(current_type)
	for cell in cells:
		if cell.y >= 0 and cell.y < TOTAL_ROWS:
			grid[cell.y][cell.x] = color_id
	var was_rotation := last_move_was_rotation
	var locked_type := current_type
	var locked_pivot := current_pivot
	var locked_rotation := current_rotation
	emit_signal("piece_locked")
	hold_used = false
	_process_clears(locked_type, locked_pivot, locked_rotation, was_rotation)
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
	# Block-out check
	return _cells_valid(current_type, current_rotation, current_pivot)

func spawn_next_piece() -> void:
	_spawn_next()

# ── Line clear processing ─────────────────────────────────────────────────

func _process_clears(piece_type: String, pivot: Vector2i, rotation: int, was_rotation: bool) -> void:
	var cleared_rows := _find_and_clear_rows()
	var clear_count := cleared_rows.size()
	if clear_count == 0:
		combo = -1
		return

	combo += 1
	var is_tspin := _detect_tspin(piece_type, pivot, rotation, was_rotation)
	var is_pc := _detect_perfect_clear()
	var clear_type := _get_clear_type(clear_count, is_tspin, is_pc)
	var is_qualifying := clear_type in ["tetris", "tspin_single", "tspin_double", "tspin_triple", "tspin_mini", "perfect_clear"]

	var raw_attack := _calculate_attack(clear_count, clear_type, is_qualifying, is_pc)
	emit_signal("lines_cleared", clear_count, clear_type)
	emit_signal("attack_generated", raw_attack, clear_type)
	emit_signal("board_updated")

func _find_and_clear_rows() -> Array:
	var cleared := []
	for r in range(TOTAL_ROWS - 1, -1, -1):
		if _is_row_full(r):
			cleared.append(r)
	if cleared.is_empty():
		return cleared
	for r in cleared:
		grid.remove_at(r)
	for _i in cleared.size():
		var empty_row := []
		empty_row.resize(COLS)
		empty_row.fill(0)
		grid.insert(0, empty_row)
	return cleared

func _is_row_full(row: int) -> bool:
	for col in range(config.board_width):
		if grid[row][col] == 0:
			return false
	return true

# ── T-spin detection (3-corner rule) ─────────────────────────────────────

func _detect_tspin(piece_type: String, pivot: Vector2i, rotation: int, was_rotation: bool) -> bool:
	if piece_type != "T" or not was_rotation:
		return false
	# The 4 diagonal corners of the T pivot
	var corners := [
		Vector2i(-1, -1), Vector2i(1, -1),
		Vector2i(-1, 1), Vector2i(1, 1),
	]
	var filled := 0
	for c in corners:
		var cell := pivot + c
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
		4: return "tetris"
	return "single"

# ── Attack calculation ────────────────────────────────────────────────────

const BASE_ATTACK: Dictionary = {
	"single": 0, "double": 1, "triple": 2, "tetris": 4,
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
			is_b2b = true
		else:
			# Persistence technique: doubles don't break B2B chain
			if not (config.b2b_persists_on_doubles and clear_type == "double"):
				is_b2b = false
	else:
		is_b2b = false

	var combo_bonus := 0
	if combo >= 0 and combo < COMBO_TABLE.size():
		combo_bonus = COMBO_TABLE[combo]
	elif combo >= COMBO_TABLE.size():
		combo_bonus = COMBO_TABLE[COMBO_TABLE.size() - 1]

	var total := base + b2b_bonus + combo_bonus
	if attack_surge_remaining > 0:
		total *= 2
		attack_surge_remaining -= 1
	return total

# ── Garbage insertion (The Tide boss modifier) ────────────────────────────

func insert_garbage_row() -> void:
	grid.remove_at(0)
	var garbage := []
	garbage.resize(COLS)
	garbage.fill(PieceData.COLOR_GARBAGE)
	var gap := randi() % config.board_width
	garbage[gap] = 0
	grid.append(garbage)
	_update_ghost()
	emit_signal("board_updated")

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

# ── Consumable effects (called by RunManager) ─────────────────────────────

func apply_clean_slate() -> void:
	for r in range(TOTAL_ROWS):
		for c in range(COLS):
			if grid[r][c] != 0:
				grid[r][c] = 0
	emit_signal("board_updated")

func activate_attack_surge(clears: int) -> void:
	attack_surge_remaining = clears

# ── Rendering ─────────────────────────────────────────────────────────────

func _draw() -> void:
	# Board background
	draw_rect(Rect2(0, 0, config.board_width * CELL_SIZE, VISIBLE_ROWS * CELL_SIZE), Color(0.1, 0.1, 0.1))

	# Grid cells (visible rows only)
	for screen_row in range(VISIBLE_ROWS):
		var grid_row := HIDDEN_ROWS + screen_row
		for col in range(config.board_width):
			var cell_val := grid[grid_row][col]
			if cell_val != 0:
				var color: Color = PIECE_COLORS.get(cell_val, Color.WHITE)
				_draw_cell(col, screen_row, color)

	# Ghost piece
	var ghost_cells := get_ghost_cells()
	for cell in ghost_cells:
		var screen_row := cell.y - HIDDEN_ROWS
		if screen_row >= 0 and screen_row < VISIBLE_ROWS:
			_draw_cell(cell.x, screen_row, PIECE_COLORS[PieceData.COLOR_GHOST])
			if config.deep_sight_enabled:
				var dist := get_ghost_distance()
				draw_string(ThemeDB.fallback_font, Vector2(cell.x * CELL_SIZE + 2, screen_row * CELL_SIZE + 22), str(dist), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)

	# Current piece
	var current_cells := get_current_cells()
	for cell in current_cells:
		var screen_row := cell.y - HIDDEN_ROWS
		if screen_row >= 0 and screen_row < VISIBLE_ROWS:
			_draw_cell(cell.x, screen_row, PIECE_COLORS.get(PieceData.get_color_id(current_type), Color.WHITE))

	# Grid lines
	var grid_color := Color(0.2, 0.2, 0.2)
	for c in range(config.board_width + 1):
		draw_line(Vector2(c * CELL_SIZE, 0), Vector2(c * CELL_SIZE, VISIBLE_ROWS * CELL_SIZE), grid_color)
	for r in range(VISIBLE_ROWS + 1):
		draw_line(Vector2(0, r * CELL_SIZE), Vector2(config.board_width * CELL_SIZE, r * CELL_SIZE), grid_color)

func _draw_cell(col: int, screen_row: int, color: Color) -> void:
	var rect := Rect2(col * CELL_SIZE + 1, screen_row * CELL_SIZE + 1, CELL_SIZE - 2, CELL_SIZE - 2)
	draw_rect(rect, color)
