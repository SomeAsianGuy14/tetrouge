## 1. Resource schema changes

- [x] 1.1 `game/resources/keystone.gd`: add `piece_enhance_every_n: int = 0`, `piece_enhance_type: String = ""` (keystone-level piece enhancers: Midas Touch, Charging Up, Extraordinary Bag)
- [x] 1.2 `game/resources/keystone.gd`: add `start_shield: int = 0`, `honed_bonus_per_cell: int = 0`, `reinforced_bonus_per_cell: int = 0`, `gilded_bonus_per_cell: int = 0`, `amplified_bonus_per_cell: float = 0.0`, `double_enhancement_benefits: bool = false`
- [x] 1.3 Remove `garbage_flush_reduction` from `Keystone` (and its `apply_to_config` branch) and from `RoundConfig`
- [x] 1.4 Remove `per_technique_quad_bonus` from `Keystone`
- [x] 1.5 Remove `overkill_coins` from `Keystone`
- [x] 1.6 `game/resources/attack_context.gd`: add `cleared_enh_counts: Dictionary = {}`
- [x] 1.7 `game/resources/technique_round_state.gd`: add `last_stand_triggered: bool = false`

## 2. PieceEnhancements pure-function updates

- [x] 2.1 `game/resources/piece_enhancements.gd`: add optional per-cell parameters (defaulting to existing constants) to `honed_bonus`, `shield_charges`, `gilded_coins`, `amplified_multiplier`
- [x] 2.2 `game/resources/piece_enhancements.gd`: add a helper to resolve `"random"` to one of `ALL_TYPES` via `pick_random()`
- [x] 2.3 Add a helper to double a counts dictionary (for Jack of All Trades)

## 3. RunManager — enhancement assignment & grant queue

- [x] 3.1 Extend `_advance_enhancement_state(grant, cadence, techniques)` to `_advance_enhancement_state(grant, cadence, techniques, keystones, grant_queue)`, evaluating keystone `piece_enhance_every_n`/`piece_enhance_type` with the same cadence logic as technique `piece_enhancer`s (techniques checked before keystones on ties)
- [x] 3.2 Resolve any `"random"` assignment (technique, keystone, or grant) independently per piece using the helper from 2.2
- [x] 3.3 Add `_enhancement_grant_queue: Array` to `RunManager`; when the active `_enhancement_grant` is empty, a new grant becomes active immediately, otherwise it's appended to the queue; when the active grant's `remaining` reaches 0, promote the next queued entry
- [x] 3.4 Update `preview_enhancements` to duplicate `_enhancement_grant_queue` alongside the grant/cadence dicts
- [x] 3.5 Update `_on_piece_spawned` and `_reset_enhancement_round_state` for the new state (`_enhancement_grant_queue` reset each round)

## 4. RunManager — garbage-shield pool sources

- [x] 4.1 `_reset_enhancement_round_state`: set `_garbage_shield = sum(ks.start_shield for ks in RunState.keystones)` instead of always 0
- [x] 4.2 Last Stand: on each piece lock, if a technique has `effect_type = "height_shield"` and `ctx.board_height >= 20 * params.threshold_pct` and `not _technique_round_state.last_stand_triggered`, add `params.shield` to `_garbage_shield` and set the flag
- [x] 4.3 The Best Defense: after `modified` attack is finalized for a primary clear, if a technique has `effect_type = "attack_to_shield"`, add `floor(modified * params.pct)` to `_garbage_shield`
- [x] 4.4 Remove the `garbage_flush_reduction` consumption at `run_manager.gd:450` (garbage line reduction now comes only from shield-charge absorption)
- [x] 4.5 Remove the Midas Touch overkill-to-coins conversion at round end

## 5. RunManager — benefit magnitude application

- [x] 5.1 Compute effective per-cell values for honed/reinforced/gilded/amplified by summing each keystone's `*_bonus_per_cell` field onto the `PieceEnhancements` constants
- [x] 5.2 Compute `effective_counts` (doubled via 2.3 if any owned keystone has `double_enhancement_benefits = true`) and use it for all four benefit calls in `_apply_enhancement_clear_benefits` and the honed/amplified application in `_on_attack_generated`
- [x] 5.3 Remove the `per_technique_quad_bonus` evaluation block in `compute_keystone_flat_bonus` (`run_manager.gd:910-913`)

## 6. RunManager / TechniqueEvaluator — AttackContext & new effect types

- [x] 6.1 Populate `ctx.cleared_enh_counts` from `_pending_enh_counts` in `_build_attack_context`
- [x] 6.2 `TechniqueEvaluator._eval_attack`: add `"golden_blade"` arm — `params.bonus` if `ctx.cleared_enh_counts.get("gilded", 0) > 0` on a clear, else 0
- [x] 6.3 `TechniqueEvaluator`: add `"attack_to_shield"`, `"height_shield"`, `"post_quad_enhance"`, `"post_combo_enhance"` to the no-op effect-type list (return 0, no warning)
- [x] 6.4 Implement `post_quad_enhance` (Quad clear → queue 1-piece grant of `params.enhancement`) and `post_combo_enhance` (`ctx.combo > params.combo_threshold` → queue 1-piece grant of `params.enhancement`) as RunManager-side flag handling feeding the grant queue from 3.3

## 7. New/removed technique data files

- [x] 7.1 Replace `game/resources/data/techniques/keen_edge.tres` with `sharpen.tres`: `effect_type="piece_enhancer", params={enhancement:"honed", every_n:6}`
- [x] 7.2 Add `barricade.tres`: `effect_type="piece_enhancer", params={enhancement:"reinforced", every_n:6}`
- [x] 7.3 Add `the_best_defense.tres`: `effect_type="attack_to_shield", params={pct:0.25}`
- [x] 7.4 Add `last_stand.tres`: `effect_type="height_shield", params={threshold_pct:0.8, shield:10}`
- [x] 7.5 Add `preparation.tres`: `effect_type="post_quad_enhance", params={enhancement:"honed"}`
- [x] 7.6 Add `backpedaling.tres`: `effect_type="post_combo_enhance", params={enhancement:"reinforced", combo_threshold:5}`
- [x] 7.7 Add `golden_blade.tres`: `effect_type="golden_blade", params={bonus:2}`

## 8. New/redesigned/removed keystone data files

- [x] 8.1 Add `extraordinary_bag.tres`: `category="Enhancement", piece_enhance_every_n=7, piece_enhance_type="random"`
- [x] 8.2 Add `charging_up.tres`: `category="Enhancement", piece_enhance_every_n=10, piece_enhance_type="amplified"`
- [x] 8.3 Add `jack_of_all_trades.tres`: `category="Enhancement", double_enhancement_benefits=true`
- [x] 8.4 Add `refined.tres`: `category="Enhancement", honed_bonus_per_cell=2`
- [x] 8.5 Add `armored.tres`: `category="Enhancement", reinforced_bonus_per_cell=2`
- [x] 8.6 Add `polished.tres`: `category="Enhancement", gilded_bonus_per_cell=1`
- [x] 8.7 Add `overclocked.tres`: `category="Enhancement", amplified_bonus_per_cell=0.125`
- [x] 8.8 Redesign `midas_touch.tres`: remove `overkill_coins`, set `piece_enhance_every_n=7, piece_enhance_type="gilded"`
- [x] 8.9 Redesign `simple_shield.tres`: remove `garbage_flush_reduction`, set `start_shield=5`
- [x] 8.10 Redesign `legionnaires_shield.tres`: remove `garbage_flush_reduction`, set `start_shield=10`
- [x] 8.11 Delete `sharpen.tres` (keystone)

## 9. Consumable data files

- [x] 9.1 Add `lottery_ticket.tres`: `enhance_type="random", enhance_pieces=3`
- [x] 9.2 Rename `whetstone.tres` → `sharpening_stone.tres` (`id`/`display_name` only; effect unchanged)
- [x] 9.3 Rename `gilding_kit.tres` → `gold_leaf.tres` (`id`/`display_name` only; effect unchanged)
- [x] 9.4 Rename `reinforcing_plate.tres` → `steel_plates.tres` (`id`/`display_name` only; effect unchanged)
- [x] 9.5 Rename `arcane_battery.tres` → `charged_battery.tres`, change `enhance_pieces` from 4 to 2, update description

## 10. Registry updates

- [x] 10.1 `game/autoloads/resource_registry.gd`: update `all_techniques` (remove `keen_edge`, rename `sharpen` entry path, add `barricade`, `the_best_defense`, `last_stand`, `preparation`, `backpedaling`, `golden_blade`)
- [x] 10.2 `game/autoloads/resource_registry.gd`: update `all_keystones` (remove `sharpen`, add `extraordinary_bag`, `charging_up`, `jack_of_all_trades`, `refined`, `armored`, `polished`, `overclocked`)
- [x] 10.3 `game/autoloads/resource_registry.gd`: update `all_consumables` (rename `arcane_battery`→`charged_battery`, `whetstone`→`sharpening_stone`, `gilding_kit`→`gold_leaf`, `reinforcing_plate`→`steel_plates`, add `lottery_ticket`)

## 11. Testing

- [x] 11.1 `test_piece_enhancements.gd`: per-cell override params on `honed_bonus`/`shield_charges`/`gilded_coins`/`amplified_multiplier` (Refined/Armored/Polished/Overclocked magnitudes)
- [x] 11.2 `test_piece_enhancements.gd`: counts-doubling helper for Jack of All Trades
- [x] 11.3 `test_piece_enhancements.gd`: `"random"` resolves to one of `ALL_TYPES`
- [x] 11.4 `test_enhancement_grid.gd` / `test_enhancement_benefits.gd`: keystone-level piece-enhancer cadence (Midas Touch every 7th gilded, Charging Up every 10th amplified, Extraordinary Bag every 7th random)
- [x] 11.5 `test_enhancement_grid.gd`: technique-vs-keystone tie-break (techniques win), grant-queue promotion after active grant drains
- [x] 11.6 `test_enhancement_grid.gd`: independent random resolution across multiple pieces in one grant
- [x] 11.7 `test_keystones.gd`: `start_shield` seeds `_garbage_shield` at round start (Simple Shield=5, Legionnaire's Shield=10); remove obsolete `garbage_flush_reduction` tests
- [x] 11.8 `test_keystones.gd`: remove obsolete `per_technique_quad_bonus` tests; remove/replace Midas Touch overkill-coins test in economy tests
- [x] 11.9 `test_technique_evaluator.gd` (or equivalent): Golden Blade (+2 with gilded cell, +0 without)
- [x] 11.10 `test_technique_evaluator.gd`: Preparation queues honed grant after Quad, not after other clears
- [x] 11.11 `test_technique_evaluator.gd`: Backpedaling queues reinforced grant when `combo > 5`, not otherwise
- [x] 11.12 New test: Last Stand grants +10 shield once per round at `board_height >= 16`, not again later in the same round
- [x] 11.13 New test: The Best Defense adds `floor(modified * 0.25)` shield on a clear without reducing dealt damage
