class_name ShieldBar
extends Control

const BAR_WIDTH := 12
const SHIELD_COLOR := Color(0.78, 0.80, 0.84)
const BG_COLOR := Color(0.08, 0.08, 0.08, 0.8)
const GAP := 2.0

var _charges: int = 0

func _ready() -> void:
	custom_minimum_size = Vector2(BAR_WIDTH, TetrisBoard.VISIBLE_ROWS * TetrisBoard.CELL_SIZE)

func update_charges(charges: int) -> void:
	_charges = charges
	queue_redraw()

func _draw() -> void:
	var bar_height := float(TetrisBoard.VISIBLE_ROWS * TetrisBoard.CELL_SIZE)
	var pixels_per_line := bar_height / float(TetrisBoard.VISIBLE_ROWS)

	draw_rect(Rect2(0.0, 0.0, BAR_WIDTH, bar_height), BG_COLOR)

	var visible_charges := mini(_charges, TetrisBoard.VISIBLE_ROWS)
	for i in range(visible_charges):
		var block_h := pixels_per_line - GAP
		var y := bar_height - (i + 1) * pixels_per_line
		draw_rect(Rect2(0.0, y, BAR_WIDTH, block_h), SHIELD_COLOR)

	if _charges > TetrisBoard.VISIBLE_ROWS:
		var overflow_text := "+%d" % (_charges - TetrisBoard.VISIBLE_ROWS)
		draw_string(ThemeDB.fallback_font, Vector2(0.0, 12.0), overflow_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, SHIELD_COLOR)
