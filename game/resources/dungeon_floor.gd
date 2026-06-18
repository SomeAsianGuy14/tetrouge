class_name DungeonFloor
extends RefCounted

var rooms: Array = []  # Array[DungeonRoom]
var floor_number: int = 1

func get_start_room() -> DungeonRoom:
	for room in rooms:
		if room.room_type == DungeonRoom.TYPE_START:
			return room
	return null

func get_boss_room() -> DungeonRoom:
	for room in rooms:
		if room.room_type == DungeonRoom.TYPE_BOSS:
			return room
	return null

func get_accessible_rooms() -> Array:
	var result := []
	for room in rooms:
		if not room.cleared and _is_accessible(room):
			result.append(room)
	return result

func get_cleared_rooms() -> Array:
	var result := []
	for room in rooms:
		if room.cleared:
			result.append(room)
	return result

func _is_accessible(room: DungeonRoom) -> bool:
	if room.room_type == DungeonRoom.TYPE_START:
		return true
	var room_idx := rooms.find(room)
	for adj_idx in room.adjacency:
		if rooms[adj_idx].cleared:
			return true
	return false

func get_room_index(room: DungeonRoom) -> int:
	return rooms.find(room)
