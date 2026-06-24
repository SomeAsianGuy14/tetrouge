extends Node

# DirAccess.open("res://...") does not work in web exports because Godot packs
# everything into a virtual PCK. preload() is resolved at compile time and
# works on all platforms, so all runtime resource scanning goes through here.

const all_keystones: Array = [
	preload("res://resources/data/keystones/armored.tres"),
	preload("res://resources/data/keystones/beginners_luck.tres"),
	preload("res://resources/data/keystones/charging_up.tres"),
	preload("res://resources/data/keystones/consistency.tres"),
	preload("res://resources/data/keystones/daze.tres"),
	preload("res://resources/data/keystones/dizzy.tres"),
	preload("res://resources/data/keystones/double_trouble.tres"),
	preload("res://resources/data/keystones/dual_wielding.tres"),
	preload("res://resources/data/keystones/extraordinary_bag.tres"),
	preload("res://resources/data/keystones/final_blow.tres"),
	preload("res://resources/data/keystones/flurry.tres"),
	preload("res://resources/data/keystones/foresight.tres"),
	preload("res://resources/data/keystones/full_potential.tres"),
	preload("res://resources/data/keystones/golden_watch.tres"),
	preload("res://resources/data/keystones/great_sword.tres"),
	preload("res://resources/data/keystones/holy_cheese.tres"),
	preload("res://resources/data/keystones/jack_of_all_trades.tres"),
	preload("res://resources/data/keystones/magical_coin.tres"),
	preload("res://resources/data/keystones/midas_touch.tres"),
	preload("res://resources/data/keystones/overclocked.tres"),
	preload("res://resources/data/keystones/polished.tres"),
	preload("res://resources/data/keystones/refined.tres"),
	preload("res://resources/data/keystones/risky_business.tres"),
	preload("res://resources/data/keystones/safety_net.tres"),
	preload("res://resources/data/keystones/simple_flail.tres"),
	preload("res://resources/data/keystones/simple_shield.tres"),
	preload("res://resources/data/keystones/simple_sword.tres"),
	preload("res://resources/data/keystones/simple_wand.tres"),
	preload("res://resources/data/keystones/simplicity.tres"),
	preload("res://resources/data/keystones/slightly_magical_bag.tres"),
	preload("res://resources/data/keystones/slightly_magical_coin.tres"),
	preload("res://resources/data/keystones/triple_threat.tres"),
	preload("res://resources/data/keystones/veterans_luck.tres"),
	preload("res://resources/data/keystones/mace_and_chain.tres"),
	preload("res://resources/data/keystones/legionnaires_shield.tres"),
	preload("res://resources/data/keystones/crystal_staff.tres"),
	preload("res://resources/data/keystones/blessed_stone.tres"),
	preload("res://resources/data/keystones/burning_board.tres"),
	preload("res://resources/data/keystones/reflect.tres"),
	preload("res://resources/data/keystones/the_best_defense.tres"),
]

const all_techniques: Array = [
	preload("res://resources/data/techniques/adrenaline_rush.tres"),
	preload("res://resources/data/techniques/aggressive_positioning.tres"),
	preload("res://resources/data/techniques/attack_battery.tres"),
	preload("res://resources/data/techniques/back_to_back_pressure.tres"),
	preload("res://resources/data/techniques/back_to_back_spin.tres"),
	preload("res://resources/data/techniques/backpedaling.tres"),
	preload("res://resources/data/techniques/barricade.tres"),
	preload("res://resources/data/techniques/bounty_list.tres"),
	preload("res://resources/data/techniques/brass_knuckles.tres"),
	preload("res://resources/data/techniques/clean_strike.tres"),
	preload("res://resources/data/techniques/combo_payout.tres"),
	preload("res://resources/data/techniques/combo_spark.tres"),
	preload("res://resources/data/techniques/combo_spike.tres"),
	preload("res://resources/data/techniques/compact_setup.tres"),
	preload("res://resources/data/techniques/constant_pressure.tres"),
	preload("res://resources/data/techniques/controlled_drop.tres"),
	preload("res://resources/data/techniques/counter_strike.tres"),
	preload("res://resources/data/techniques/coupon.tres"),
	preload("res://resources/data/techniques/delayed_cannon.tres"),
	preload("res://resources/data/techniques/discipline.tres"),
	preload("res://resources/data/techniques/dualcasting.tres"),
	preload("res://resources/data/techniques/escalation.tres"),
	preload("res://resources/data/techniques/finisher.tres"),
	preload("res://resources/data/techniques/flash_step.tres"),
	preload("res://resources/data/techniques/flatline.tres"),
	preload("res://resources/data/techniques/flow_step.tres"),
	preload("res://resources/data/techniques/flurry.tres"),
	preload("res://resources/data/techniques/follow_up.tres"),
	preload("res://resources/data/techniques/gamblers_blade.tres"),
	preload("res://resources/data/techniques/glass_cannon.tres"),
	preload("res://resources/data/techniques/golden_blade.tres"),
	preload("res://resources/data/techniques/good_planning.tres"),
	preload("res://resources/data/techniques/greedy_hands.tres"),
	preload("res://resources/data/techniques/green_thumb.tres"),
	preload("res://resources/data/techniques/last_stand.tres"),
	preload("res://resources/data/techniques/low_pressure.tres"),
	preload("res://resources/data/techniques/enchant.tres"),
	preload("res://resources/data/techniques/opening_blow.tres"),
	preload("res://resources/data/techniques/patience.tres"),
	preload("res://resources/data/techniques/perfect_spark.tres"),
	preload("res://resources/data/techniques/preparation.tres"),
	preload("res://resources/data/techniques/reckless_assault.tres"),
	preload("res://resources/data/techniques/recycling.tres"),
	preload("res://resources/data/techniques/redzone.tres"),
	preload("res://resources/data/techniques/rotation_training.tres"),
	preload("res://resources/data/techniques/hone.tres"),
	preload("res://resources/data/techniques/sharpen.tres"),
	preload("res://resources/data/techniques/side_strike.tres"),
	preload("res://resources/data/techniques/smooth_haggling.tres"),
	preload("res://resources/data/techniques/specialist_discount.tres"),
	preload("res://resources/data/techniques/spinning_strike.tres"),
	preload("res://resources/data/techniques/switch_up.tres"),
	preload("res://resources/data/techniques/tetris_echo.tres"),
]

const all_consumables: Array = [
	preload("res://resources/data/consumables/attack_surge.tres"),
	preload("res://resources/data/consumables/b2b_booster.tres"),
	preload("res://resources/data/consumables/charged_battery.tres"),
	preload("res://resources/data/consumables/combo_coil.tres"),
	preload("res://resources/data/consumables/gold_leaf.tres"),
	preload("res://resources/data/consumables/lottery_ticket.tres"),
	preload("res://resources/data/consumables/perfected_spike.tres"),
	preload("res://resources/data/consumables/power_fragment.tres"),
	preload("res://resources/data/consumables/power_shard.tres"),
	preload("res://resources/data/consumables/quad_stone.tres"),
	preload("res://resources/data/consumables/sharpening_stone.tres"),
	preload("res://resources/data/consumables/spin_amplifier.tres"),
	preload("res://resources/data/consumables/steel_plates.tres"),
]

const all_enemies: Array = [
	preload("res://resources/data/enemies/boss_ancient.tres"),
	preload("res://resources/data/enemies/boss_enforcer.tres"),
	preload("res://resources/data/enemies/boss_fateless.tres"),
	preload("res://resources/data/enemies/boss_filth.tres"),
	preload("res://resources/data/enemies/boss_purge.tres"),
	preload("res://resources/data/enemies/boss_reflection.tres"),
	preload("res://resources/data/enemies/boss_silencer.tres"),
	preload("res://resources/data/enemies/boss_thin.tres"),
	preload("res://resources/data/enemies/boss_void.tres"),
	preload("res://resources/data/enemies/cave_bat.tres"),
	preload("res://resources/data/enemies/crimson_drake.tres"),
	preload("res://resources/data/enemies/hex_wraith.tres"),
	preload("res://resources/data/enemies/iron_shambler.tres"),
	preload("res://resources/data/enemies/rock_crawler.tres"),
	preload("res://resources/data/enemies/rust_golem.tres"),
	preload("res://resources/data/enemies/slimeling.tres"),
	preload("res://resources/data/enemies/the_warden.tres"),
	preload("res://resources/data/enemies/void_knight.tres"),
	preload("res://resources/data/enemies/corrupted_mage.tres"),
	preload("res://resources/data/enemies/venomous_archer.tres"),
	preload("res://resources/data/enemies/possessed_blade.tres"),
	preload("res://resources/data/enemies/insane_adventurer.tres"),
	preload("res://resources/data/enemies/giant_frog.tres"),
	preload("res://resources/data/enemies/unstable_construct.tres"),
	preload("res://resources/data/enemies/pickpocket_enemy.tres"),
	preload("res://resources/data/enemies/robbers_enemy.tres"),
	preload("res://resources/data/enemies/mimic_enemy.tres"),
	preload("res://resources/data/enemies/boss_ram.tres"),
	preload("res://resources/data/enemies/boss_jester.tres"),
	preload("res://resources/data/enemies/boss_berserker.tres"),
	preload("res://resources/data/enemies/boss_forgotten.tres"),
	preload("res://resources/data/enemies/boss_furnace.tres"),
	preload("res://resources/data/enemies/boss_mutant.tres"),
	preload("res://resources/data/enemies/boss_titan.tres"),
	preload("res://resources/data/enemies/boss_klepto.tres"),
	preload("res://resources/data/enemies/boss_origin.tres"),
]

# Maps ids of renamed/replaced resources to their current id, so that save
# files written before a rename still resolve to the new resource.
const LEGACY_ID_ALIASES: Dictionary = {
	"keen_edge": "sharpen",
	"whetstone": "sharpening_stone",
	"gilding_kit": "gold_leaf",
	"reinforcing_plate": "steel_plates",
	"arcane_battery": "charged_battery",
	"chain_starter": "",
	"mini_spark": "",
	"chain_battery": "",
	"four_disciplines": "",
	"delayed_cannon": "one_two_punch",
	"hybrid_reactor": "",
	"whirl": "",
	"flexible": "",
	"enchant_keystone": "enchant",
}

static func find_by_id(collection: Array, id: String) -> Resource:
	var resolved_id: String = LEGACY_ID_ALIASES.get(id, id)
	for res in collection:
		if res.id == resolved_id:
			return res
	return null

static func get_available_keystones() -> Array:
	return all_keystones.filter(func(ks):
		return ks.unlock_condition_id == "" or ks.unlock_condition_id in ProfileSave.unlocked_ids)

static func get_available_techniques() -> Array:
	return all_techniques.filter(func(t):
		return t.unlock_condition_id == "" or t.unlock_condition_id in ProfileSave.unlocked_ids)

static func weighted_technique_draw(pool: Array, rng: RandomNumberGenerator) -> Technique:
	if pool.is_empty():
		return null
	var total_weight := 0
	for t in pool:
		total_weight += Technique.RARITY_WEIGHT.get(t.rarity, 1)
	var roll := rng.randi_range(0, total_weight - 1)
	var cumulative := 0
	for t in pool:
		cumulative += Technique.RARITY_WEIGHT.get(t.rarity, 1)
		if roll < cumulative:
			return t
	return pool[pool.size() - 1]

static func weighted_technique_draw_n(pool: Array, n: int, rng: RandomNumberGenerator) -> Array:
	var remaining := pool.duplicate()
	var result: Array = []
	for i in range(n):
		if remaining.is_empty():
			break
		var pick: Technique = weighted_technique_draw(remaining, rng)
		if pick != null:
			result.append(pick)
			remaining.erase(pick)
	return result
