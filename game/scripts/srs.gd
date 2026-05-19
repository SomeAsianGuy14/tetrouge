class_name SRS
extends RefCounted

# SRS wall kick tables.
# Key format: "from_stateTO_state" e.g. "0R" means state 0 -> state R.
# Values: Array of Vector2i(col_offset, row_offset), positive row = DOWN.
# Source: Tetris guideline (Tetris Wiki), with Y-axis negated for down-positive grid.

const KICKS_JLSZT: Dictionary = {
	"0R": [Vector2i(0,0), Vector2i(-1,0), Vector2i(-1,-1), Vector2i(0,2), Vector2i(-1,2)],
	"R0": [Vector2i(0,0), Vector2i(1,0), Vector2i(1,1), Vector2i(0,-2), Vector2i(1,-2)],
	"R2": [Vector2i(0,0), Vector2i(1,0), Vector2i(1,1), Vector2i(0,-2), Vector2i(1,-2)],
	"2R": [Vector2i(0,0), Vector2i(-1,0), Vector2i(-1,-1), Vector2i(0,2), Vector2i(-1,2)],
	"2L": [Vector2i(0,0), Vector2i(1,0), Vector2i(1,-1), Vector2i(0,2), Vector2i(1,2)],
	"L2": [Vector2i(0,0), Vector2i(-1,0), Vector2i(-1,1), Vector2i(0,-2), Vector2i(-1,-2)],
	"L0": [Vector2i(0,0), Vector2i(-1,0), Vector2i(-1,1), Vector2i(0,-2), Vector2i(-1,-2)],
	"0L": [Vector2i(0,0), Vector2i(1,0), Vector2i(1,-1), Vector2i(0,2), Vector2i(1,2)],
}

const KICKS_I: Dictionary = {
	"0R": [Vector2i(0,0), Vector2i(-2,0), Vector2i(1,0), Vector2i(-2,1), Vector2i(1,-2)],
	"R0": [Vector2i(0,0), Vector2i(2,0), Vector2i(-1,0), Vector2i(2,-1), Vector2i(-1,2)],
	"R2": [Vector2i(0,0), Vector2i(-1,0), Vector2i(2,0), Vector2i(-1,-2), Vector2i(2,1)],
	"2R": [Vector2i(0,0), Vector2i(1,0), Vector2i(-2,0), Vector2i(1,2), Vector2i(-2,-1)],
	"2L": [Vector2i(0,0), Vector2i(2,0), Vector2i(-1,0), Vector2i(2,-1), Vector2i(-1,2)],
	"L2": [Vector2i(0,0), Vector2i(-2,0), Vector2i(1,0), Vector2i(-2,1), Vector2i(1,-2)],
	"L0": [Vector2i(0,0), Vector2i(1,0), Vector2i(-2,0), Vector2i(1,2), Vector2i(-2,-1)],
	"0L": [Vector2i(0,0), Vector2i(-1,0), Vector2i(2,0), Vector2i(-1,-2), Vector2i(2,1)],
}

# O piece has no kicks
const KICKS_O: Dictionary = {
	"0R": [Vector2i(0,0)], "R0": [Vector2i(0,0)],
	"R2": [Vector2i(0,0)], "2R": [Vector2i(0,0)],
	"2L": [Vector2i(0,0)], "L2": [Vector2i(0,0)],
	"L0": [Vector2i(0,0)], "0L": [Vector2i(0,0)],
}

const STATE_NAMES: Array[String] = ["0", "R", "2", "L"]

static func get_kicks(piece_type: String, from_rot: int, to_rot: int) -> Array[Vector2i]:
	var key: String = STATE_NAMES[from_rot] + STATE_NAMES[to_rot]
	var raw: Array
	match piece_type:
		"I": raw = KICKS_I.get(key, [Vector2i(0, 0)])
		"O": raw = KICKS_O.get(key, [Vector2i(0, 0)])
		_:   raw = KICKS_JLSZT.get(key, [Vector2i(0, 0)])
	var result: Array[Vector2i] = []
	result.assign(raw)
	return result

static func next_rotation_cw(rot: int) -> int:
	return (rot + 1) % 4

static func next_rotation_ccw(rot: int) -> int:
	return (rot + 3) % 4

static func next_rotation_180(rot: int) -> int:
	return (rot + 2) % 4
