class_name RunFlow
extends RefCounted

var current_room: DungeonRoom = null
var pending_room_clear: DungeonRoom = null

signal combat_entered(room: DungeonRoom)
signal shop_entered(room: DungeonRoom)
signal encounter_entered(room: DungeonRoom)
signal dungeon_map_requested()
signal round_success_requested(is_boss: bool)
signal keystone_selection_requested()
signal victory_requested()
signal failure_requested()

func enter_room(room: DungeonRoom) -> void:
	current_room = room
	match room.room_type:
		DungeonRoom.TYPE_COMBAT_SMALL, DungeonRoom.TYPE_COMBAT_BIG, \
		DungeonRoom.TYPE_COMBAT_ELITE, DungeonRoom.TYPE_COMBAT_ELITE_SPECIAL, \
		DungeonRoom.TYPE_BOSS:
			combat_entered.emit(room)
		DungeonRoom.TYPE_SHOP:
			shop_entered.emit(room)
		DungeonRoom.TYPE_ENCOUNTER:
			encounter_entered.emit(room)

func resolve_combat(won: bool) -> void:
	if not won:
		failure_requested.emit()
		return

	var is_boss := RunState.is_boss_room(current_room)
	current_room.cleared = true
	if pending_room_clear != null:
		pending_room_clear.cleared = true
		pending_room_clear = null
	if not is_boss:
		RunState.combat_rooms_cleared_this_floor += 1
		RunState.enemies_killed += 1
	round_success_requested.emit(is_boss)

func confirm_boss_cleared() -> void:
	if RunState.floor >= RunState.TOTAL_FLOORS:
		victory_requested.emit()
	else:
		RunState.advance_floor()
		keystone_selection_requested.emit()

func begin_robbers_combat() -> DungeonRoom:
	pending_room_clear = current_room
	var elite_room := DungeonRoom.new()
	elite_room.room_type = DungeonRoom.TYPE_COMBAT_ELITE
	current_room = elite_room
	return elite_room

func resolve_shop(room: DungeonRoom) -> void:
	room.cleared = true
	dungeon_map_requested.emit()

func resolve_encounter(room: DungeonRoom) -> void:
	room.cleared = true
	dungeon_map_requested.emit()
