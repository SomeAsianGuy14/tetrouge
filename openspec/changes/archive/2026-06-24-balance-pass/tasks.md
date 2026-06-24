## 1. Technique renames (data-only)

- [x] 1.1 Update `coupon.tres`: `display_name` → "Haggling", update `description`
- [x] 1.2 Update `bounty_list.tres`: `display_name` → "Bounty Connections", update `description`
- [x] 1.3 Update `hone.tres`: `display_name` → "Slash", update `description`
- [x] 1.4 Update `smooth_haggling.tres`: `display_name` → "Upcharging", update `description`
- [x] 1.5 Update `greedy_hands.tres`: `display_name` → "Sticky Fingers", `description` updated, coin gain → 15 in params

## 2. Technique damage/value changes (data-only)

- [x] 2.1 `clean_strike.tres`: bonus 1 → 2
- [x] 2.2 `dualcasting.tres`: bonus 3 → 2
- [x] 2.3 `low_pressure.tres`: bonus 1 → 2
- [x] 2.4 `opening_blow.tres`: bonus 3 → 5
- [x] 2.5 `patience.tres`: bonus 1 → 2
- [x] 2.6 `tetris_echo.tres` (Quad Echo): bonus 1 → 3
- [x] 2.7 `side_strike.tres`: bonus 1 → 3
- [x] 2.8 `flatline.tres`: bonus 2 → 5
- [x] 2.9 `flow_step.tres`: bonus 2 → 5
- [x] 2.10 `golden_blade.tres`: bonus 2 → 4
- [x] 2.11 `recycling.tres`: bonus 3 → 4
- [x] 2.12 `redzone.tres`: bonus 3 → 4
- [x] 2.13 `adrenaline_rush.tres`: bonus 5 → 8
- [x] 2.14 `glass_cannon.tres`: bonus 4 → 8
- [x] 2.15 `reckless_assault.tres`: bonus 4 → 6
- [x] 2.16 `finisher.tres`: bonus 1 → 4

## 3. Technique rarity moves

- [x] 3.1 `sharpen.tres`: rarity "common" → "rare", cost 40 → 52
- [x] 3.2 `barricade.tres`: rarity "common" → "rare", cost 40 → 52
- [x] 3.3 `finisher.tres`: rarity "common" → "rare", cost 40 → 52
- [x] 3.4 `perfect_spark.tres`: rarity "epic" → "rare", cost 64 → 52
- [x] 3.5 `compact_setup.tres`: rarity "epic" → "rare", cost 64 → 52, threshold reduced to 30% in params and description updated

## 4. Technique removals

- [x] 4.1 Delete `chain_starter.tres`, add "chain_starter" → null to `LEGACY_ID_ALIASES`
- [x] 4.2 Delete `mini_spark.tres`, add "mini_spark" → null to `LEGACY_ID_ALIASES`
- [x] 4.3 Delete `chain_battery.tres`, add "chain_battery" → null to `LEGACY_ID_ALIASES`
- [x] 4.4 Delete `four_disciplines.tres`, add "four_disciplines" → null to `LEGACY_ID_ALIASES`

## 5. Technique reworks (code + data)

- [x] 5.1 Rework Backpedaling: change effect_type to `shield_per_clear_while_combo`, params `{"combo_threshold": 3, "shield_per_clear": 1}`, update description. Implement `shield_per_clear_while_combo` in TechniqueEvaluator — returns shield charges instead of attack delta when combo > threshold
- [x] 5.2 Rework Escalation: change params to `{"every_n_attacks": 5, "bonus": 5}`, update description. Modify the escalation evaluator to count attack events (non-bonus clears) instead of pieces placed
- [x] 5.3 Rework Switch-Up: change effect_type to `different_clear_bonus`, params `{"bonus": 2}`, update description. Implement in TechniqueEvaluator — track last clear type in round state, grant bonus when current differs
- [x] 5.4 Rework Green Thumb: change params to `{"rows_threshold": 6, "coins": 20}`, update description. Modify the green_thumb evaluator to accumulate garbage rows cleared and pay out at threshold
- [x] 5.5 Rework Combo Spike: change params `every_n` from 5 to 3, update description
- [x] 5.6 Rework Delayed Cannon → One-Two Punch: change id to `one_two_punch`, display_name to "One-Two Punch", effect_type to `same_clear_bonus`, params `{"bonus": 6}`, update description. Add "delayed_cannon" → "one_two_punch" to legacy aliases. Implement `same_clear_bonus` in TechniqueEvaluator
- [x] 5.7 Rework Gambler's Blade: change params to `{"win_chance": 0.5, "win_bonus": 8, "loss_chance": 0.5, "loss_penalty": 4}`, update description

## 6. Keystone changes (data-only)

- [x] 6.1 `simple_sword.tres`: quad_bonus 2 → 3, update description
- [x] 6.2 `simple_wand.tres`: tspin_any_bonus 2 → 3, update description
- [x] 6.3 `simple_flail.tres`: display_name → "Simple Bow", update description
- [x] 6.4 `mace_and_chain.tres`: display_name → "Recurve Bow", update description
- [x] 6.5 `simple_shield.tres`: start_shield 5 → 10, update description
- [x] 6.6 `legionnaires_shield.tres`: start_shield 10 → 20, update description
- [x] 6.7 `charging_up.tres`: display_name → "Supercharge", update description
- [x] 6.8 `blessed_stone.tres`: remove time bonus from description (time bonus was already removed in previous change — verify)
- [x] 6.9 `simplicity.tres`: quad_multiplier 2.0 → 3.0, update description
- [x] 6.10 `dizzy.tres`: dizzy bonus 4 → 8 (update the dizzy bonus constant/param in RunManager or keystone)
- [x] 6.11 `holy_cheese.tres`: single_multiplier 2.0 → 3.0, update description

## 7. Golden Watch rework

- [x] 7.1 In `_apply_keystone_economy()`, change `int(round_timer / 5.0) * 3` to `int(round_timer)` for time_coins keystones
- [x] 7.2 Update `golden_watch.tres` description to "Gain a 3-minute timer. At round end, earn 1 coin for every second remaining on the timer."

## 8. Keystone removals

- [x] 8.1 Delete `hybrid_reactor.tres`, add "hybrid_reactor" → null to `LEGACY_ID_ALIASES`. Remove Hybrid Reactor tag bonus logic from RunManager._on_attack_generated()
- [x] 8.2 Delete `whirl.tres`, add "whirl" → null to `LEGACY_ID_ALIASES`. Remove whirl combo-step logic from RunManager/TetrisBoard if present
- [x] 8.3 Delete `flexible.tres`, add "flexible" → null to `LEGACY_ID_ALIASES`

## 9. Burning Board: technique → keystone

- [x] 9.1 Add `all_attack_multiplier: float = 0.0` and `burning_board: bool = false` properties to `keystone.gd`
- [x] 9.2 Create `game/resources/data/keystones/burning_board.tres` with `all_attack_multiplier = 1.5`, `burning_board = true`, appropriate display_name/description/category
- [x] 9.3 Delete `game/resources/data/techniques/burning_board.tres`, add "burning_board" legacy alias mapping to the keystone ID
- [x] 9.4 Apply `all_attack_multiplier` in `RunManager._apply_keystone_multipliers()` — multiply unconditionally when > 0
- [x] 9.5 Update RunManager burning board timer logic to check for keystone flag instead of technique presence

## 10. Enchant: keystone → technique

- [x] 10.1 Create `game/resources/data/techniques/enchant.tres` with effect_type `per_tspin_technique`, params `{"bonus_per_technique": 3}`, rarity "rare", cost 52, tags ["tspin"]
- [x] 10.2 Delete `game/resources/data/keystones/enchant.tres`, add keystone "enchant" legacy alias
- [x] 10.3 Implement `per_tspin_technique` effect type in TechniqueEvaluator — count techniques with "tspin" tag, multiply by bonus_per_technique, apply on tspin events
- [x] 10.4 Remove `per_technique_tspin_bonus` handling from RunManager keystone flat bonus logic

## 11. Testing

- [x] 11.1 Update `test_technique_rarity.gd` counts: recalculate common/rare/epic counts after removals, moves, and additions (Enchant added as rare)
- [x] 11.2 Update `test_resource_registry.gd` to include new legacy aliases for removed items — verify `find_by_id` returns null for removed IDs
- [x] 11.3 Add test: Escalation fires on 5th attack with +5 bonus, not on 4th
- [x] 11.4 Add test: Switch-Up (different_clear_bonus) grants +2 when clear type differs from previous
- [x] 11.5 Add test: One-Two Punch (same_clear_bonus) grants +6 when clear type matches previous
- [x] 11.6 Add test: Backpedaling grants 1 shield per clear when combo > 3, no shield at combo ≤ 3
- [x] 11.7 Add test: Green Thumb awards 20 coins after 6 garbage lines cleared
- [x] 11.8 Add test: Enchant technique adds +3 per tspin-tagged technique on tspin events
- [x] 11.9 Add test: Burning Board keystone applies 1.5× multiplier to all attacks
- [x] 11.10 Add test: Golden Watch awards 1 coin per second remaining (not per 5 seconds)
- [x] 11.11 Update existing tests that assert old damage values (Simple Sword +2 → +3, Simplicity 2× → 3×, Dizzy +4 → +8, etc.)
- [x] 11.12 Remove or update tests for removed items (Hybrid Reactor tag bonus, Whirl combo steps)
- [x] 11.13 Run full test suite and fix any remaining failures
