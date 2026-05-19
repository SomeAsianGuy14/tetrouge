class_name HoldDisplay
extends Node2D

const MINI_CELL := 24
const SLOT_GAP := 6
const PADDING := 8
const BG_COLOR := Color(0.08, 0.08, 0.1)
const BG_DISABLED_COLOR := Color(0.08, 0.08, 0.1, 0.3)

var board: TetrisBoard = null

func setup(b: TetrisBoard) -> void:
	board = b
	board.connect("board_updated", queue_redraw)
	queue_redraw()

func _draw() -> void:
	if board == null or board.config == null:
		return

	var slots: int = board.config.hold_slots
	var panel_w: float = 4 * MINI_CELL + PADDING * 2
	var slot_h: float = 4 * MINI_CELL
	var panel_h: float = slots * slot_h + (slots - 1) * SLOT_GAP + PADDING * 2

	var bg := BG_DISABLED_COLOR if board.config.hold_disabled else BG_COLOR
	draw_rect(Rect2(0, 0, panel_w, panel_h), bg)

	if board.config.hold_disabled:
		return

	for i in slots:
		var origin := Vector2(PADDING, PADDING + i * (slot_h + SLOT_GAP))
		if i < board.held_pieces.size():
			var piece_type: String = board.held_pieces[i]
			var color: Color = TetrisBoard.PIECE_COLORS.get(PieceData.get_color_id(piece_type), Color.WHITE)
			_draw_mini_piece(piece_type, origin, color)

func _draw_mini_piece(piece_type: String, origin: Vector2, color: Color) -> void:
	var cells: Array[Vector2i] = PieceData.get_cells(piece_type, 0)
	var min_x: int = cells[0].x
	var max_x: int = cells[0].x
	var min_y: int = cells[0].y
	var max_y: int = cells[0].y
	for c: Vector2i in cells:
		min_x = mini(min_x, c.x)
		max_x = maxi(max_x, c.x)
		min_y = mini(min_y, c.y)
		max_y = maxi(max_y, c.y)
	var span_x: float = max_x - min_x + 1
	var span_y: float = max_y - min_y + 1
	var off_x: float = (4.0 - span_x) / 2.0 - min_x
	var off_y: float = (4.0 - span_y) / 2.0 - min_y
	for c: Vector2i in cells:
		var px := origin + Vector2((c.x + off_x) * MINI_CELL, (c.y + off_y) * MINI_CELL)
		draw_rect(Rect2(px + Vector2(1, 1), Vector2(MINI_CELL - 2, MINI_CELL - 2)), color)
