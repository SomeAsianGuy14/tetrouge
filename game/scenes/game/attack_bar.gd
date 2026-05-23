class_name AttackBar
extends VBoxContainer

const SEGMENT_COUNT := 20
const BAR_WIDTH := 12
const WARNING_COLOR := Color(0.85, 0.15, 0.1)
const EMPTY_COLOR := Color(0.15, 0.15, 0.15, 0.6)

var _segments: Array[ColorRect] = []

func _ready() -> void:
	custom_minimum_size = Vector2(BAR_WIDTH, TetrisBoard.VISIBLE_ROWS * TetrisBoard.CELL_SIZE)
	for i in range(SEGMENT_COUNT):
		var seg := ColorRect.new()
		seg.color = EMPTY_COLOR
		seg.custom_minimum_size = Vector2(BAR_WIDTH, 0)
		seg.size_flags_vertical = Control.SIZE_EXPAND_FILL
		add_child(seg)
		_segments.append(seg)

func update_pending(count: int) -> void:
	var lit := mini(count, SEGMENT_COUNT)
	for i in range(SEGMENT_COUNT):
		# index 0 = top segment, index SEGMENT_COUNT-1 = bottom segment
		var dist_from_bottom := SEGMENT_COUNT - 1 - i
		_segments[i].color = WARNING_COLOR if dist_from_bottom < lit else EMPTY_COLOR
