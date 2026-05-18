class_name PieceData
extends RefCounted

# Piece color IDs (match rendering colors in TetrisBoard)
const COLOR_I := 1
const COLOR_O := 2
const COLOR_T := 3
const COLOR_S := 4
const COLOR_Z := 5
const COLOR_J := 6
const COLOR_L := 7
const COLOR_GHOST := 8
const COLOR_GARBAGE := 9

const ALL_TYPES := ["I", "O", "T", "S", "Z", "J", "L"]

# Piece cell offsets per rotation state.
# Coordinates: Vector2i(col_offset, row_offset), positive row = DOWN.
# Pivot is at the rotation center for each piece type.
# Based on standard SRS guideline (Tetris wiki).
const ROTATIONS: Dictionary = {
	"I": [
		[Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)],   # 0
		[Vector2i(1, -1), Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2)],   # R
		[Vector2i(-1, 1), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)],   # 2
		[Vector2i(0, -1), Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, 2)],   # L
	],
	"O": [
		[Vector2i(0, -1), Vector2i(1, -1), Vector2i(0, 0), Vector2i(1, 0)],  # all same
		[Vector2i(0, -1), Vector2i(1, -1), Vector2i(0, 0), Vector2i(1, 0)],
		[Vector2i(0, -1), Vector2i(1, -1), Vector2i(0, 0), Vector2i(1, 0)],
		[Vector2i(0, -1), Vector2i(1, -1), Vector2i(0, 0), Vector2i(1, 0)],
	],
	"T": [
		[Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, -1)],  # 0
		[Vector2i(0, -1), Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1)],   # R
		[Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1)],   # 2
		[Vector2i(-1, 0), Vector2i(0, -1), Vector2i(0, 0), Vector2i(0, 1)],  # L
	],
	"S": [
		[Vector2i(-1, 0), Vector2i(0, 0), Vector2i(0, -1), Vector2i(1, -1)], # 0
		[Vector2i(0, -1), Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1)],   # R
		[Vector2i(-1, 1), Vector2i(0, 1), Vector2i(0, 0), Vector2i(1, 0)],   # 2
		[Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(0, 0), Vector2i(0, 1)], # L
	],
	"Z": [
		[Vector2i(-1, -1), Vector2i(0, -1), Vector2i(0, 0), Vector2i(1, 0)], # 0
		[Vector2i(1, -1), Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1)],   # R
		[Vector2i(-1, 0), Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1)],   # 2
		[Vector2i(0, -1), Vector2i(-1, 0), Vector2i(0, 0), Vector2i(-1, 1)], # L
	],
	"J": [
		[Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(-1, -1)], # 0
		[Vector2i(0, -1), Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, -1)],  # R
		[Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1)],   # 2
		[Vector2i(0, -1), Vector2i(0, 0), Vector2i(0, 1), Vector2i(-1, 1)],  # L
	],
	"L": [
		[Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, -1)],  # 0
		[Vector2i(0, -1), Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1)],   # R
		[Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(-1, 1)],  # 2
		[Vector2i(0, -1), Vector2i(0, 0), Vector2i(0, 1), Vector2i(-1, -1)], # L
	],
}

const COLOR_IDS: Dictionary = {
	"I": COLOR_I, "O": COLOR_O, "T": COLOR_T,
	"S": COLOR_S, "Z": COLOR_Z, "J": COLOR_J, "L": COLOR_L,
}

# Spawn pivot column (center of 10-wide board)
const SPAWN_COL := 4
# Spawn row in 22-row grid (row 0 = top hidden, row 2 = first visible)
const SPAWN_ROW := 1

static func get_cells(piece_type: String, rotation: int) -> Array:
	return ROTATIONS[piece_type][rotation]

static func get_color_id(piece_type: String) -> int:
	return COLOR_IDS[piece_type]

static func get_world_cells(piece_type: String, rotation: int, pivot: Vector2i) -> Array:
	var cells := []
	for offset in get_cells(piece_type, rotation):
		cells.append(pivot + offset)
	return cells
