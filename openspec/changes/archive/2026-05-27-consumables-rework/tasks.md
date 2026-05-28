## 1. Rename "tetris" Event Type to "quad"

- [x] 1.1 In `game/resources/technique.gd`, rename constant `EVENT_TETRIS` to `EVENT_QUAD` and change its value from `"tetris"` to `"quad"`
- [x] 1.2 In `game/scenes/tetris/tetris_board.gd`, update `_get_clear_type()` to return `"quad"` instead of `"tetris"` for 4-line clears, and update the base attack table key from `"tetris"` to `"quad"`
- [x] 1.3 In `game/scenes/tetris/tetris_board.gd`, update the B2B qualifying check: replace `"tetris"` with `"quad"` in the qualifying clear types array
- [x] 1.4 In `game/scenes/game/run_manager.gd`, replace all `"tetris"` string literals with `"quad"` (match branches, comparisons, `flat_bonus_by_event.get("tetris", ...)` calls)
- [x] 1.5 In `game/resources/data/boss_modifiers/the_purge.tres`, replace `"tetris"` with `"quad"` in the `quota_whitelist` array
- [x] 1.6 In `game/resources/data/techniques/efficiency.tres`, replace the key `"tetris"` with `"quad"` in `flat_bonus_by_event`
- [x] 1.7 In `game/resources/data/keystones/` `.tres` files (`daze.tres`, `dual_wielding.tres`, `great_sword.tres`, `sharpen.tres`, `simplicity.tres`), change `category = "Tetris"` to `category = "Quad"`
- [x] 1.8 In `game/tests/unit/test_attack_system.gd`, replace all `"tetris"` string literals with `"quad"`
- [x] 1.9 In `game/tests/unit/test_keystones.gd`, replace all `"tetris"` string literals with `"quad"`

## 2. Rework Consumable Resource

- [x] 2.1 In `game/resources/consumable.gd`, remove export fields: `clears_board`, `guarantees_next_t`, `adds_coins`; retain `adds_time` and `attack_surge_clears` (repurposed: fixed 3-clear surge count)
- [x] 2.2 In `game/resources/consumable.gd`, add attack bonus export fields: `bonus_all_clears: int`, `bonus_quad: int`, `bonus_tspin: int`, `bonus_b2b: int`, `bonus_combo: int`, `bonus_pc: int`
- [x] 2.3 In `game/resources/consumable.gd`, add `func apply_to_config(cfg: RoundConfig) -> void` that writes the bonus fields to the corresponding `cfg.consumable_*` fields, and sets `cfg.consumable_surge_clears_remaining = attack_surge_clears` if `attack_surge_clears > 0`
- [x] 2.4 Remove old consumable .tres files: `game/resources/data/consumables/clean_slate.tres`, `coin_purse.tres`, `piece_lock.tres`
- [x] 2.5 Update `game/resources/data/consumables/time_shard.tres` to clear any removed fields; keep `adds_time = 8.0`
- [x] 2.6 Update `game/resources/data/consumables/attack_surge.tres`: set `attack_surge_clears = 3`, clear any removed fields
- [x] 2.7 Create new .tres files in `game/resources/data/consumables/`: `power_fragment.tres` (+3 all), `power_shard.tres` (+2 all), `quad_stone.tres` (+5 quad), `spin_amplifier.tres` (+5 tspin), `b2b_booster.tres` (+4 b2b), `combo_coil.tres` (+3 combo), `perfected_spike.tres` (+8 pc)

## 3. Add Consumable Bonus Fields to RoundConfig

- [x] 3.1 In `game/resources/round_config.gd`, add: `var consumable_all_bonus: int = 0`, `var consumable_quad_bonus: int = 0`, `var consumable_tspin_bonus: int = 0`, `var consumable_b2b_bonus: int = 0`, `var consumable_combo_bonus: int = 0`, `var consumable_pc_bonus: int = 0`, `var consumable_surge_clears_remaining: int = 0`

## 4. RunManager — Consumable Application

- [x] 4.1 In `game/scenes/game/run_manager.gd`, replace `apply_consumable(consumable)` with a new version: if `consumable.adds_time > 0`, apply time effect (existing logic); otherwise call `consumable.apply_to_config(current_config)`; then call `RunState.remove_consumable(consumable)`
- [x] 4.2 In `game/scenes/game/run_manager.gd`, add `func _apply_consumable_flat_bonuses(attack: int, event_type: String) -> int` that reads from `current_config.consumable_*` fields and adds bonuses per event type (all, quad, tspin variants, b2b, combo, pc)
- [x] 4.3 In `game/scenes/game/run_manager.gd`, add `func _apply_consumable_surge(attack: int) -> int` that checks `current_config.consumable_surge_clears_remaining > 0`; if so, doubles `attack` and decrements the counter by 1
- [x] 4.4 In `game/scenes/game/run_manager.gd`, insert calls to `_apply_consumable_flat_bonuses` then `_apply_consumable_surge` in `_on_attack_generated` after `_apply_keystone_flat_bonuses` and before `_apply_keystone_multipliers`
- [x] 4.5 In `game/scenes/game/run_manager.gd`, remove the old effect branches from `apply_consumable` (`clears_board`, `guarantees_next_t`, `adds_coins`; `attack_surge_clears` is now handled via `apply_to_config`)

## 5. Remove Unused TetrisBoard Methods

- [x] 5.1 In `game/scenes/tetris/tetris_board.gd`, remove `apply_clean_slate()`, `activate_attack_surge(n)`, and any `_guarantee_next_t` logic if present (surge is now managed via `RoundConfig.consumable_surge_clears_remaining` in RunManager)

## 6. RunState — Backpack Capacity

- [x] 6.1 In `game/autoloads/run_state.gd`, change `consumable_capacity: int = 2` to `consumable_capacity: int = 3`
- [x] 6.2 In `game/autoloads/run_state.gd`, update `reset()` to reset `consumable_capacity = 3`

## 7. Shop — Add Second Consumable Slot

- [x] 7.1 In `game/scenes/shop/shop.tscn`, duplicate the `ConsumableSlot` node under `BottomRow`, naming it `ConsumableSlot2`
- [x] 7.2 In `game/scenes/shop/shop.gd`, add `@onready var consumable_slot_2: Control = $Panel/VBox/BottomRow/ConsumableSlot2`
- [x] 7.3 In `game/scenes/shop/shop.gd`, update shop population to call `_populate_slot(consumable_slot_2, [already_picked_consumable])` after populating the first consumable slot, passing the first draw as an exclusion to avoid duplicates

## 8. HUD — Backpack Display

- [x] 8.1 In `game/scenes/game/run_manager.tscn`, add a `HBoxContainer` named `BackpackContainer` as a child of `HUD` with 3 `Button` children (`BackpackSlot0`, `BackpackSlot1`, `BackpackSlot2`) positioned below the keystone icon area
- [x] 8.2 In `game/scenes/game/hud.gd`, add `@onready` refs for the 3 backpack slot buttons and a `func _refresh_backpack_slots()` that updates each button's text to the item's display name (or empty/dim if no item)
- [x] 8.3 In `game/scenes/game/hud.gd`, connect each backpack slot button's `pressed` signal to a handler that calls `RunManager.apply_consumable(RunState.consumables[slot_index])` when activation timing is valid
- [x] 8.4 In `game/scenes/game/hud.gd`, implement timing guards: enable backpack slot buttons only when (a) the round has not yet started for attack-buff items, or (b) the round is active for Time Shard items; disable otherwise
- [x] 8.5 In `game/scenes/game/run_manager.gd`, call `hud._refresh_backpack_slots()` after any consumable is added or removed (after shop purchase, after activation)

## 9. Testing

- [x] 9.1 In `game/tests/unit/test_consumables.gd` (create file), add a test that verifies `apply_to_config` writes `bonus_quad` to `cfg.consumable_quad_bonus`
- [x] 9.2 Add a test that verifies `apply_to_config` with `bonus_all_clears` writes to `cfg.consumable_all_bonus`
- [x] 9.3 Add a test that verifies `_apply_consumable_flat_bonuses` adds `consumable_all_bonus` to every clear type
- [x] 9.4 Add a test that verifies `_apply_consumable_flat_bonuses` adds `consumable_quad_bonus` only to `"quad"` event type
- [x] 9.5 Add a test that verifies `_apply_consumable_flat_bonuses` adds `consumable_tspin_bonus` to all tspin variants (`tspin_single`, `tspin_double`, `tspin_triple`, `tspin_mini`)
- [x] 9.6 Add a test that verifies `_apply_consumable_flat_bonuses` returns attack unchanged when all consumable config fields are 0
- [x] 9.7 Add a test verifying `_apply_consumable_surge` doubles attack when `consumable_surge_clears_remaining > 0` and decrements the counter
- [x] 9.8 Add a test verifying `_apply_consumable_surge` does not double attack on the 4th call (counter reaches 0 after 3)
- [x] 9.9 Add a test verifying `RunState.add_consumable` returns false when backpack is at capacity (3 items)
