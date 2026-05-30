extends Node

func _ready() -> void:
	Settings.apply_saved_bindings()

const TOTAL_STAGES := 5
const ROUNDS_PER_STAGE := 4
const ROUND_NAMES := ["Small Round", "Big Round", "Elite Round", "Boss Round"]
const STARTING_COINS := 8

var stage: int = 1
var round_index: int = 0  # 0-3 within each stage

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var run_seed: int = 0

var keystones: Array = []       # Array[Keystone]
var techniques: Array = []      # Array[Technique]
var consumables: Array = []     # Array[Consumable]
var vouchers: Array = []        # Array[Voucher]

var used_boss_modifiers: Array = []   # ids already seen this run
var used_boss_enemy_ids: Array = []   # boss enemy ids already seen this run
var used_keystone_ids: Array = []     # ids already owned this run

var shop_technique_slots: int = 3
var consumable_capacity: int = 3
var technique_capacity: int = 4

signal run_started
signal round_changed(stage: int, round_index: int)

func reset() -> void:
	stage = 1
	round_index = 0
	keystones.clear()
	techniques.clear()
	consumables.clear()
	vouchers.clear()
	used_boss_modifiers.clear()
	used_boss_enemy_ids.clear()
	used_keystone_ids.clear()
	shop_technique_slots = 3
	consumable_capacity = 3
	technique_capacity = 4
	run_seed = randi()
	rng.seed = run_seed

func is_boss_round() -> bool:
	return round_index == 3

func advance_round() -> void:
	round_index += 1
	if round_index >= ROUNDS_PER_STAGE:
		round_index = 0
		stage += 1
	technique_capacity = 4 + (stage - 1)
	emit_signal("round_changed", stage, round_index)

func is_run_complete() -> bool:
	return stage > TOTAL_STAGES

func get_round_name() -> String:
	return ROUND_NAMES[round_index]

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

func has_voucher(id: String) -> bool:
	for v in vouchers:
		if v.id == id:
			return true
	return false

func add_keystone(keystone) -> void:
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

func add_voucher(voucher) -> void:
	vouchers.append(voucher)
	_apply_voucher_effects(voucher)

func _apply_keystone_effects(_keystone) -> void:
	pass  # Keystones modify RoundConfig at round start; no immediate run-state effect

func _apply_voucher_effects(voucher) -> void:
	match voucher.id:
		"interest_cap_up":
			Economy.interest_cap = 8
		"expanded_shop":
			shop_technique_slots = 4
		"consumable_expert":
			consumable_capacity = 3
		"bonus_round":
			Economy.speed_bonus_multiplier = 2.0

func calculate_quota(current_stage: int, current_round: int) -> int:
	return 20 + (current_stage - 1) * 15 + current_round * 8

func calculate_time_limit(_current_stage: int, boss_modifier_id: String) -> float:
	if boss_modifier_id == "the_enforcer":
		return 90.0
	return 120.0

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
