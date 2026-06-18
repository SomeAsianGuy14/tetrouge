extends Node

func _ready() -> void:
	Settings.apply_saved_display()
	Settings.apply_saved_bindings()

const TOTAL_FLOORS := 4
const STARTING_COINS := 30

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

var shop_technique_slots: int = 5
var consumable_capacity: int = 3
var technique_capacity: int = 4

signal run_started
signal floor_changed(floor_number: int)

func reset() -> void:
	floor = 1
	combat_rooms_cleared_this_floor = 0
	keystones.clear()
	techniques.clear()
	consumables.clear()
	used_boss_modifiers.clear()
	used_boss_enemy_ids.clear()
	used_keystone_ids.clear()
	shop_technique_slots = 5
	consumable_capacity = 3
	technique_capacity = 4
	run_seed = randi()
	rng.seed = run_seed
	current_floor_data = DungeonGenerator.generate(floor, rng)

func is_boss_room(room: DungeonRoom) -> bool:
	return room != null and room.room_type == DungeonRoom.TYPE_BOSS

func advance_floor() -> void:
	floor += 1
	combat_rooms_cleared_this_floor = 0
	technique_capacity = 4 + (floor - 1)
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

func add_technique(technique) -> void:
	techniques.append(technique)

func add_consumable(consumable) -> bool:
	if consumables.size() >= consumable_capacity:
		return false
	consumables.append(consumable)
	return true

func remove_consumable(consumable) -> void:
	consumables.erase(consumable)

func remove_technique(technique) -> void:
	techniques.erase(technique)

func _apply_keystone_effects(_keystone) -> void:
	pass

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
