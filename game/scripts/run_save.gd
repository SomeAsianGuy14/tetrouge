class_name RunSave
extends RefCounted

const SAVE_PATH := "user://save.cfg"
const SAVE_VERSION := 2

static func exists() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

static func delete() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))

static func save() -> void:
	var cfg := ConfigFile.new()

	cfg.set_value("run", "save_version", SAVE_VERSION)
	cfg.set_value("run", "floor", RunState.floor)
	cfg.set_value("run", "combat_rooms_cleared", RunState.combat_rooms_cleared_this_floor)
	cfg.set_value("run", "shop_technique_slots", RunState.shop_technique_slots)
	cfg.set_value("run", "consumable_capacity", RunState.consumable_capacity)

	cfg.set_value("economy", "coins", Economy.coins)

	cfg.set_value("inventory", "keystone_ids", _ids_from(RunState.keystones))
	cfg.set_value("inventory", "technique_ids", _ids_from(RunState.techniques))
	cfg.set_value("inventory", "consumable_ids", _ids_from(RunState.consumables))
	cfg.set_value("inventory", "used_boss_modifier_ids", RunState.used_boss_modifiers)
	cfg.set_value("inventory", "used_boss_enemy_ids", RunState.used_boss_enemy_ids)
	cfg.set_value("inventory", "used_keystone_ids", RunState.used_keystone_ids)

	cfg.set_value("rng", "seed", RunState.run_seed)
	cfg.set_value("rng", "state", RunState.rng.state)

	var rooms_data: Array = []
	if RunState.current_floor_data != null:
		for room in RunState.current_floor_data.rooms:
			var fp_arr: Array = []
			for tile in room.tile_footprint:
				fp_arr.append([tile.x, tile.y])
			rooms_data.append({
				"type": room.room_type,
				"encounter_subtype": room.encounter_subtype,
				"footprint": fp_arr,
				"visual_size": [room.visual_size.x, room.visual_size.y],
				"cleared": room.cleared,
				"adjacency": room.adjacency.duplicate(),
			})
	cfg.set_value("run", "floor_rooms", rooms_data)

	cfg.save(SAVE_PATH)

static func load_into_state() -> bool:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return false

	var version: int = cfg.get_value("run", "save_version", 1)
	if version < SAVE_VERSION:
		return false  # incompatible old save format

	RunState.floor = cfg.get_value("run", "floor", 1)
	RunState.combat_rooms_cleared_this_floor = cfg.get_value("run", "combat_rooms_cleared", 0)
	RunState.shop_technique_slots = cfg.get_value("run", "shop_technique_slots", 5)
	RunState.consumable_capacity = cfg.get_value("run", "consumable_capacity", 3)

	Economy.coins = cfg.get_value("economy", "coins", 0)

	RunState.keystones = _load_by_ids(ResourceRegistry.all_keystones,
			cfg.get_value("inventory", "keystone_ids", []))
	RunState.techniques = _load_by_ids(ResourceRegistry.all_techniques,
			cfg.get_value("inventory", "technique_ids", []))
	RunState.consumables = _load_by_ids(ResourceRegistry.all_consumables,
			cfg.get_value("inventory", "consumable_ids", []))
	RunState.used_boss_modifiers = cfg.get_value("inventory", "used_boss_modifier_ids", [])
	RunState.used_boss_enemy_ids = cfg.get_value("inventory", "used_boss_enemy_ids", [])
	RunState.used_keystone_ids = cfg.get_value("inventory", "used_keystone_ids", [])

	RunState.run_seed = cfg.get_value("rng", "seed", randi())
	RunState.rng.seed = RunState.run_seed
	RunState.rng.state = cfg.get_value("rng", "state", 0)

	var rooms_data: Array = cfg.get_value("run", "floor_rooms", [])
	if not rooms_data.is_empty():
		var df := DungeonFloor.new()
		df.floor_number = RunState.floor
		for rd in rooms_data:
			var room := DungeonRoom.new()
			room.room_type = rd.get("type", "")
			room.encounter_subtype = rd.get("encounter_subtype", "")
			var fp: Array[Vector2i] = []
			for pair in rd.get("footprint", []):
				fp.append(Vector2i(pair[0], pair[1]))
			room.tile_footprint = fp
			var vs: Array = rd.get("visual_size", [1, 1])
			room.visual_size = Vector2i(vs[0], vs[1])
			room.cleared = rd.get("cleared", false)
			room.adjacency = rd.get("adjacency", [])
			df.rooms.append(room)
		RunState.current_floor_data = df
	else:
		RunState.current_floor_data = DungeonGenerator.generate(RunState.floor, RunState.rng)

	return true

static func _ids_from(resources: Array) -> Array:
	var ids := []
	for res in resources:
		ids.append(res.id)
	return ids

static func _load_by_ids(collection: Array, ids: Array) -> Array:
	if ids.is_empty():
		return []
	var result := []
	for id in ids:
		var res := ResourceRegistry.find_by_id(collection, id)
		if res != null:
			result.append(res)
	return result
