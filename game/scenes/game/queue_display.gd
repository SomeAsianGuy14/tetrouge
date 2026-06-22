class_name QueueDisplay
extends Node2D

const SLOT_GAP := 6
const PADDING := 8
const BG_COLOR := Color(0.08, 0.08, 0.1)

var board: TetrisBoard = null
var run_manager: RunManager = null

func setup(b: TetrisBoard, rm: RunManager = null) -> void:
	board = b
	run_manager = rm
	board.connect("board_updated", queue_redraw)
	queue_redraw()

func _draw() -> void:
	if board == null or board.config == null:
		return

	var preview_count: int = board.config.preview_count
	var types: Array = board.get_preview_types()
	var enh_types: Array[String] = run_manager.preview_enhancements(preview_count) if run_manager else []

	# Scale mini cell so up to 7 pieces fit within the board height (640px)
	var mini_cell: int = mini(24, int(600.0 / float(maxi(preview_count, 1) * 4)))
	var slot_h: float = 4 * mini_cell
	var panel_w: float = 4 * mini_cell + PADDING * 2
	var panel_h: float = preview_count * slot_h + (preview_count - 1) * SLOT_GAP + PADDING * 2

	draw_rect(Rect2(0, 0, panel_w, panel_h), BG_COLOR)

	for i in mini(preview_count, types.size()):
		var origin := Vector2(PADDING, PADDING + i * (slot_h + SLOT_GAP))
		var piece_type: String = types[i]
		var color: Color = TetrisBoard.PIECE_COLORS.get(PieceData.get_color_id(piece_type), Color.WHITE)
		var enh_type: String = enh_types[i] if i < enh_types.size() else ""
		_draw_mini_piece(piece_type, origin, color, mini_cell, enh_type)

func _draw_mini_piece(piece_type: String, origin: Vector2, color: Color, mini_cell: int, enh_type: String = "") -> void:
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
		var px := origin + Vector2((c.x + off_x) * mini_cell, (c.y + off_y) * mini_cell)
		_draw_mini_cell(px, color, mini_cell, enh_type)

func _draw_mini_metallic(rect: Rect2, color: Color) -> void:
	var dark := color.darkened(0.20)
	var mid := color
	var bright := color.lightened(0.30)
	draw_rect(rect, dark)
	draw_rect(Rect2(rect.position, Vector2(rect.size.x, rect.size.y * 0.55)), mid)
	var hl := Rect2(rect.position + Vector2(2, 2), Vector2(rect.size.x - 4, rect.size.y * 0.22))
	draw_rect(hl, bright)

func _draw_mini_cell(px: Vector2, base_color: Color, mini_cell: int, enh_type: String) -> void:
	var rect := Rect2(px + Vector2(1, 1), Vector2(mini_cell - 2, mini_cell - 2))
	match enh_type:
		PieceEnhancements.HONED:
			_draw_mini_metallic(rect, PieceEnhancements.HONED_COLOR)
		PieceEnhancements.GILDED:
			_draw_mini_metallic(rect, PieceEnhancements.GILDED_COLOR)
		PieceEnhancements.REINFORCED:
			draw_rect(rect, PieceEnhancements.REINFORCED_FILL_COLOR)
			_draw_mini_cell_border(rect, PieceEnhancements.REINFORCED_BORDER_COLOR)
		PieceEnhancements.AMPLIFIED:
			draw_rect(rect, base_color)
			_draw_mini_amplified_triangle(rect)
		_:
			draw_rect(rect, base_color)

func _draw_mini_cell_border(rect: Rect2, color: Color) -> void:
	const W := 2.0
	draw_rect(Rect2(rect.position, Vector2(rect.size.x, W)), color)
	draw_rect(Rect2(rect.position + Vector2(0, rect.size.y - W), Vector2(rect.size.x, W)), color)
	draw_rect(Rect2(rect.position, Vector2(W, rect.size.y)), color)
	draw_rect(Rect2(rect.position + Vector2(rect.size.x - W, 0), Vector2(W, rect.size.y)), color)

func _draw_mini_amplified_triangle(rect: Rect2) -> void:
	var cx := rect.position.x + rect.size.x * 0.5
	var cy := rect.position.y + rect.size.y * 0.5
	var r := rect.size.x * 0.22
	var points := PackedVector2Array([
		Vector2(cx, cy - r),
		Vector2(cx - r * 0.87, cy + r * 0.5),
		Vector2(cx + r * 0.87, cy + r * 0.5),
	])
	draw_colored_polygon(points, PieceEnhancements.AMPLIFIED_TRIANGLE_COLOR)
