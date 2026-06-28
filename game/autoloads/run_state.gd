extends Node

func _ready() -> void:
	Settings.apply_saved_display()
	Settings.apply_saved_bindings()

const TOTAL_FLOORS := 4
const STARTING_COINS := 30

const MASTERY_TRACKS := ["single", "double", "triple", "quad", "tspin_single", "tspin_double", "tspin_triple"]

const MASTERY_BASE_XP := {
	"single": 10, "double": 10, "triple": 5, "quad": 5,
	"tspin_single": 10, "tspin_double": 10, "tspin_triple": 5,
}

const MASTERY_XP_INCREMENT := {
	"single": 2, "double": 2, "triple": 1, "quad": 1,
	"tspin_single": 2, "tspin_double": 2, "tspin_triple": 1,
}

const TIER_BONUS := {
	"Small": 0,
	"Big":   12,
	"Elite": 24,
	"Boss":  36,
}

var floor: int = 1
var current_floor_data: DungeonFloor = null
var combat_rooms_cleared_this_floor: int = 0

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var run_seed: int = 0

var keystones: Array = []       # Array[Keystone]
var techniques: Array = []      # Array[Technique]
var consumables: Array = []     # Array[Consumable]
var used_boss_modifiers: Array = []
var used_boss_enemy_ids: Array = []
var used_keystone_ids: Array = []

var mastery: Dictionary = {}
var technique_state: Dictionary = {}
var mastery_xp_multiplier: int = 1

var shop_technique_slots: int = 5
var consumable_capacity: int = 3
var technique_capacity: int = 5

var pickpocket_stolen_gold: int = 0
var pickpocket_revenge_room_idx: int = -1
var enemies_killed: int = 0

signal run_started
signal floor_changed(floor_number: int)
signal build_changed

func reset() -> void:
	floor = 1
	combat_rooms_cleared_this_floor = 0
	keystones.clear()
	techniques.clear()
	consumables.clear()
	used_boss_modifiers.clear()
	used_boss_enemy_ids.clear()
	used_keystone_ids.clear()
	_reset_mastery()
	technique_state.clear()
	mastery_xp_multiplier = 1
	shop_technique_slots = 5
	consumable_capacity = 3
	technique_capacity = 5
	pickpocket_stolen_gold = 0
	pickpocket_revenge_room_idx = -1
	enemies_killed = 0
	run_seed = randi()
	rng.seed = run_seed
	current_floor_data = DungeonGenerator.generate(floor, rng)

func is_boss_room(room: DungeonRoom) -> bool:
	return room != null and room.room_type == DungeonRoom.TYPE_BOSS

func advance_floor() -> void:
	floor += 1
	combat_rooms_cleared_this_floor = 0
	if floor <= TOTAL_FLOORS:
		current_floor_data = DungeonGenerator.generate(floor, rng)
	emit_signal("floor_changed", floor)

func is_run_complete() -> bool:
	return floor > TOTAL_FLOORS

func calculate_quota(current_floor: int, room_tier: String) -> int:
	var stage_base := roundi(20.0 * pow(2.0, current_floor - 1))
	var tier_bonus: int = TIER_BONUS.get(room_tier, 0)
	return stage_base + tier_bonus

func calculate_time_limit(_current_floor: int) -> float:
	return 180.0

func has_technique(id: String) -> bool:
	for t in techniques:
		if t.id == id:
			return true
	return false

func has_keystone(id: String) -> bool:
	for k in keystones:
		if k.id == id:
			return true
	return false

func add_keystone(keystone) -> void:
	if keystone.replaces_keystone_id != "":
		for i in range(keystones.size() - 1, -1, -1):
			if keystones[i].id == keystone.replaces_keystone_id:
				keystones.remove_at(i)
				break
	keystones.append(keystone)
	used_keystone_ids.append(keystone.id)
	_apply_keystone_effects(keystone)
	build_changed.emit()

func add_technique(technique) -> void:
	techniques.append(technique)
	build_changed.emit()

func add_consumable(consumable) -> bool:
	if consumables.size() >= consumable_capacity:
		return false
	consumables.append(consumable)
	build_changed.emit()
	return true

func remove_consumable(consumable) -> void:
	consumables.erase(consumable)
	build_changed.emit()

func remove_technique(technique) -> void:
	techniques.erase(technique)
	build_changed.emit()

func _apply_keystone_effects(keystone) -> void:
	if keystone.technique_capacity_bonus > 0:
		technique_capacity += keystone.technique_capacity_bonus

func _reset_mastery() -> void:
	mastery.clear()
	for track in MASTERY_TRACKS:
		mastery[track] = {"xp": 0, "level": 0}

func get_mastery_threshold(track: String) -> int:
	var base: int = MASTERY_BASE_XP.get(track, 10)
	var inc: int = MASTERY_XP_INCREMENT.get(track, 1)
	var level: int = mastery.get(track, {"level": 0}).level
	return base + inc * level

func grant_mastery_xp(track: String) -> int:
	if track not in mastery:
		return 0
	mastery[track].xp += mastery_xp_multiplier
	var threshold := get_mastery_threshold(track)
	if mastery[track].xp >= threshold:
		mastery[track].xp -= threshold
		mastery[track].level += 1
		return mastery[track].level
	return 0

func get_mastery_level(track: String) -> int:
	if track not in mastery:
		return 0
	return mastery[track].level

func get_highest_mastery_for(category: String) -> int:
	var best := 0
	match category:
		"all_clear":
			for t in MASTERY_TRACKS:
				best = maxi(best, get_mastery_level(t))
		"tspin":
			for t in ["tspin_single", "tspin_double", "tspin_triple"]:
				best = maxi(best, get_mastery_level(t))
		"multiline":
			for t in ["double", "triple", "quad"]:
				best = maxi(best, get_mastery_level(t))
	return best

func seeded_shuffle(arr: Array) -> void:
	var i := arr.size() - 1
	while i > 0:
		var j := rng.randi_range(0, i)
		var tmp = arr[i]
		arr[i] = arr[j]
		arr[j] = tmp
		i -= 1

func seeded_randf() -> float:
	return rng.randf()
