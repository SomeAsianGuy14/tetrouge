class_name AttackBar
extends Control

const BAR_WIDTH := 12
const WARNING_COLOR := Color(0.85, 0.15, 0.1)
const FILTH_COLOR := Color(0.95, 0.6, 0.1)
const BG_COLOR := Color(0.08, 0.08, 0.08, 0.8)
const GAP := 2.0

var _packets: Array = []

func _ready() -> void:
	custom_minimum_size = Vector2(BAR_WIDTH, TetrisBoard.VISIBLE_ROWS * TetrisBoard.CELL_SIZE)

func update_packets(packets: Array) -> void:
	_packets = packets
	queue_redraw()

func _draw() -> void:
	var bar_height := float(TetrisBoard.VISIBLE_ROWS * TetrisBoard.CELL_SIZE)
	var pixels_per_line := bar_height / float(TetrisBoard.VISIBLE_ROWS)
	var current_y := bar_height

	draw_rect(Rect2(0.0, 0.0, BAR_WIDTH, bar_height), BG_COLOR)

	for packet in _packets:
		var color := FILTH_COLOR if packet.is_filth else WARNING_COLOR
		for _i in range(packet.lines):
			if current_y <= 0.0:
				break
			var row_h: float = minf(pixels_per_line, current_y)
			var cell_h: float = maxf(0.0, row_h - GAP)
			draw_rect(Rect2(0.0, current_y - cell_h, BAR_WIDTH, cell_h), color)
			current_y -= row_h
