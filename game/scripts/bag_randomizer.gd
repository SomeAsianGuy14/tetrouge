class_name BagRandomizer
extends RefCounted

var _bag: Array = []
var _reset_interval: int = 7  # standard 7-bag; Bag Shift keystone sets this to 5
var _rng: RandomNumberGenerator = null

func _init(reset_interval: int = 7, rng: RandomNumberGenerator = null) -> void:
	_reset_interval = reset_interval
	_rng = rng
	_refill()

func _seeded_shuffle(arr: Array) -> void:
	if _rng:
		var i := arr.size() - 1
		while i > 0:
			var j := _rng.randi_range(0, i)
			var tmp = arr[i]
			arr[i] = arr[j]
			arr[j] = tmp
			i -= 1
	else:
		arr.shuffle()

func _refill() -> void:
	var pieces := PieceData.ALL_TYPES.duplicate()
	if _reset_interval < 7:
		# Bag Shift: draw from a shorter cycle (still all 7 types but reset sooner)
		_seeded_shuffle(pieces)
		_bag = pieces.slice(0, _reset_interval)
	else:
		_seeded_shuffle(pieces)
		_bag = pieces

func next() -> String:
	if _bag.is_empty():
		_refill()
	return _bag.pop_front()

func peek(count: int) -> Array:
	while _bag.size() < count:
		var pieces := PieceData.ALL_TYPES.duplicate()
		_seeded_shuffle(pieces)
		_bag.append_array(pieces)
	return _bag.slice(0, count)
