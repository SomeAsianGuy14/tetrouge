class_name AttackBar
extends Control

const BAR_WIDTH := 12
const WARNING_COLOR := Color(0.85, 0.15, 0.1)
const FILTH_COLOR := Color(0.95, 0.6, 0.1)
const BG_COLOR := Color(0.08, 0.08, 0.08, 0.8)
const MARKER_COLOR := Color(1.0, 1.0, 1.0, 0.5)
const SEP_COLOR := Color(0.0, 0.0, 0.0, 1.0)
const GAP := 2.0
const COL_SEP := 3.0

var _packets: Array = []
var flush_capacity: int = 8

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

	var prev_col := -1
	for packet in _packets:
		var pkt_col: int = packet.get("col", -1)
		var color := FILTH_COLOR if packet.get("is_filth", false) else WARNING_COLOR

		# Black separator when the hole column changes between packets
		if prev_col != -1 and pkt_col != -1 and pkt_col != prev_col:
			var sep := minf(COL_SEP, current_y)
			draw_rect(Rect2(0.0, current_y - sep, BAR_WIDTH, sep), SEP_COLOR)
			current_y -= sep

		# Draw the packet as one solid block
		var block_h := minf(packet.lines * pixels_per_line - GAP, current_y)
		if block_h > 0.0:
			draw_rect(Rect2(0.0, current_y - block_h, BAR_WIDTH, block_h), color)
		current_y -= maxf(0.0, packet.lines * pixels_per_line)

		prev_col = pkt_col

	# Flush threshold marker
	var marker_y := bar_height - flush_capacity * pixels_per_line
	draw_rect(Rect2(0.0, marker_y - 1.0, BAR_WIDTH, 2.0), MARKER_COLOR)
