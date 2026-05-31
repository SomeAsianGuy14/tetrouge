class_name RunSave
extends RefCounted

const SAVE_PATH := "user://save.cfg"

static func exists() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

static func delete() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))

static func save() -> void:
	var cfg := ConfigFile.new()

	cfg.set_value("run", "stage", RunState.stage)
	cfg.set_value("run", "round_index", RunState.round_index)
	cfg.set_value("run", "shop_technique_slots", RunState.shop_technique_slots)
	cfg.set_value("run", "consumable_capacity", RunState.consumable_capacity)

	cfg.set_value("economy", "coins", Economy.coins)
	cfg.set_value("economy", "interest_cap", Economy.interest_cap)
	cfg.set_value("economy", "speed_bonus_multiplier", Economy.speed_bonus_multiplier)

	cfg.set_value("inventory", "keystone_ids", _ids_from(RunState.keystones))
	cfg.set_value("inventory", "technique_ids", _ids_from(RunState.techniques))
	cfg.set_value("inventory", "consumable_ids", _ids_from(RunState.consumables))
	cfg.set_value("inventory", "voucher_ids", _ids_from(RunState.vouchers))
	cfg.set_value("inventory", "used_boss_modifier_ids", RunState.used_boss_modifiers)
	cfg.set_value("inventory", "used_boss_enemy_ids", RunState.used_boss_enemy_ids)
	cfg.set_value("inventory", "used_keystone_ids", RunState.used_keystone_ids)

	cfg.set_value("rng", "seed", RunState.run_seed)
	cfg.set_value("rng", "state", RunState.rng.state)

	cfg.save(SAVE_PATH)

static func load_into_state() -> bool:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return false

	RunState.stage = cfg.get_value("run", "stage", 1)
	RunState.round_index = cfg.get_value("run", "round_index", 0)
	RunState.shop_technique_slots = cfg.get_value("run", "shop_technique_slots", 3)
	RunState.consumable_capacity = cfg.get_value("run", "consumable_capacity", 2)

	Economy.coins = cfg.get_value("economy", "coins", 0)
	Economy.interest_cap = cfg.get_value("economy", "interest_cap", 5)
	Economy.speed_bonus_multiplier = cfg.get_value("economy", "speed_bonus_multiplier", 1.0)

	RunState.keystones = _load_by_ids(ResourceRegistry.all_keystones,
			cfg.get_value("inventory", "keystone_ids", []))
	RunState.techniques = _load_by_ids(ResourceRegistry.all_techniques,
			cfg.get_value("inventory", "technique_ids", []))
	RunState.consumables = _load_by_ids(ResourceRegistry.all_consumables,
			cfg.get_value("inventory", "consumable_ids", []))
	RunState.vouchers = _load_by_ids(ResourceRegistry.all_vouchers,
			cfg.get_value("inventory", "voucher_ids", []))
	RunState.used_boss_modifiers = cfg.get_value("inventory", "used_boss_modifier_ids", [])
	RunState.used_boss_enemy_ids = cfg.get_value("inventory", "used_boss_enemy_ids", [])
	RunState.used_keystone_ids = cfg.get_value("inventory", "used_keystone_ids", [])

	RunState.run_seed = cfg.get_value("rng", "seed", randi())
	RunState.rng.seed = RunState.run_seed
	RunState.rng.state = cfg.get_value("rng", "state", 0)

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
