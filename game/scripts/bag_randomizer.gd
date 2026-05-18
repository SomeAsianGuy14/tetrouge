class_name BagRandomizer
extends RefCounted

var _bag: Array = []
var _reset_interval: int = 7  # standard 7-bag; Bag Shift keystone sets this to 5

func _init(reset_interval: int = 7) -> void:
	_reset_interval = reset_interval
	_refill()

func _refill() -> void:
	var pieces := PieceData.ALL_TYPES.duplicate()
	if _reset_interval < 7:
		# Bag Shift: draw from a shorter cycle (still all 7 types but reset sooner)
		pieces.shuffle()
		_bag = pieces.slice(0, _reset_interval)
	else:
		pieces.shuffle()
		_bag = pieces

func next() -> String:
	if _bag.is_empty():
		_refill()
	return _bag.pop_front()

func peek(count: int) -> Array:
	while _bag.size() < count:
		var pieces := PieceData.ALL_TYPES.duplicate()
		pieces.shuffle()
		_bag.append_array(pieces)
	return _bag.slice(0, count)
