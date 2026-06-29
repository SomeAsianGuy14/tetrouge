## 1. True damage system (TetrisBoard)

- [x] 1.1 Add `CELL_TRUE_DAMAGE = 10` constant and `_true_damage_rows: int = 0` to TetrisBoard
- [x] 1.2 Implement `insert_true_damage_row()`: insert a full row (no gap) at the bottom using `CELL_TRUE_DAMAGE` cell value, increment `_true_damage_rows`
- [x] 1.3 Modify `_find_full_rows()` to skip rows containing any `CELL_TRUE_DAMAGE` cells
- [x] 1.4 Render true damage cells with a distinct dark red/crimson color in `_draw_cell()`

## 2. Burn and poison debuff system (RunManager)

- [x] 2.1 Add debuff state fields: `_burn_debuff_active: bool`, `_burn_debuff_remaining: float`, `_burn_debuff_timer: float`, `_poison_debuff_active: bool`, `_poison_debuff_remaining: float`, `_poison_debuff_timer: float`
- [x] 2.2 Add `apply_burn(duration: float)` and `apply_poison(duration: float)` methods. -1.0 = permanent. Extend duration if already active and new is longer. Do not stack rate.
- [x] 2.3 Implement `_tick_burn_debuff(delta)`: if active, decrement remaining (unless permanent), tick timer. At >= 3.0s, reset timer, append 1 garbage line to `_garbage_packets`
- [x] 2.4 Implement `_tick_poison_debuff(delta)`: if active, decrement remaining (unless permanent), tick timer. At >= 5.0s, reset timer, call `current_board.insert_garbage_rows(1, col)` directly
- [x] 2.5 Call both tick functions from `_process()` alongside existing ticks
- [x] 2.6 Reset all debuff state in `start_round()`

## 3. Debuff status display

- [x] 3.1 Create `DebuffDisplay` Control node class with burn icon (orange rect + "Burn" label) and poison icon (green rect + "Poison" label), each with a countdown label
- [x] 3.2 Position `DebuffDisplay` to the left of the board in RunManager's board setup
- [x] 3.3 Add `update_debuffs(burn_active, burn_remaining, poison_active, poison_remaining)` method. Show/hide icons, display seconds remaining or "∞" for permanent
- [x] 3.4 Call `update_debuffs()` from RunManager each frame with current debuff state

## 4. Elite enemy class

- [x] 4.1 Add `@export var elite_attack: String = ""` to `enemy.gd` and `@export var elite_attack_description: String = ""` for compendium
- [x] 4.2 Rework existing `crimson_drake.tres`, `venomous_archer.tres`, `corrupted_mage.tres`, `possessed_blade.tres` — set their `elite_attack` field and `elite_attack_description`, change tier to match elite designation
- [x] 4.3 Add `TYPE_COMBAT_ELITE_SPECIAL` to `DungeonRoom` constants
- [x] 4.4 In dungeon generator, after spine generation, convert one non-boss combat room to `TYPE_COMBAT_ELITE_SPECIAL` per floor
- [x] 4.5 In `RunManager._draw_enemy()`, when tier is elite special, draw only from enemies with `elite_attack != ""`

## 5. Elite attack handlers

- [x] 5.1 Add `_apply_elite_attack(unblocked: bool)` method to RunManager, called after garbage generation in `_tick_enemy_garbage()`. Pass whether attack was unblocked (lines hit board after shield).
- [x] 5.2 Implement `corrupted_mage` handler: find 4-6 random empty cells on the board, set them to garbage
- [x] 5.3 Implement `possessed_blade` handler: pick a random start row (excluding true damage rows), delete 3 contiguous rows, shift everything above down
- [x] 5.4 Implement `crimson_drake` handler: if unblocked, call `apply_burn(4.0)`
- [x] 5.5 Implement `venomous_archer` handler: if unblocked, call `apply_poison(6.0)`

## 6. Boss reworks

- [x] 6.1 Add `permanent_burn: bool = false`, `permanent_poison: bool = false`, `true_damage_interval: float = 0.0` to `boss_modifier.gd`
- [x] 6.2 Create `boss_tide.tres` enemy + `the_tide.tres` boss modifier with `true_damage_interval = 30.0`. Add to ResourceRegistry
- [x] 6.3 Create `boss_serpent.tres` enemy + `the_serpent.tres` boss modifier with `permanent_poison = true`. Add to ResourceRegistry
- [x] 6.4 Rework `the_furnace.tres` boss modifier: remove `fixed_interval`, set `permanent_burn = true`
- [x] 6.5 In `start_round()`, apply permanent burn/poison from boss modifier flags
- [x] 6.6 Add `_tick_true_damage_interval(delta)` in RunManager: if boss has `true_damage_interval > 0`, tick timer and call `insert_true_damage_row()` when it fires

## 7. Cursed keystones

- [x] 7.1 Add `permanent_poison: bool = false`, `permanent_burn: bool = false`, `true_damage_on_start: int = 0` to `keystone.gd`
- [x] 7.2 Rework `burning_board.tres` keystone → `poisoned_blood.tres`: `all_attack_multiplier = 2.0`, `permanent_poison = true`, remove old burning_board flag. Add legacy alias.
- [x] 7.3 Create `blazing_heart.tres` keystone: `all_attack_multiplier = 2.0`, `permanent_burn = true`
- [x] 7.4 Rework Glass Cannon from technique to keystone: create `glass_cannon.tres` keystone with `all_attack_multiplier = 2.0`, `true_damage_on_start = 10`. Delete technique version. Add legacy alias.
- [x] 7.5 In `start_round()`, apply cursed keystone debuffs: permanent burn, permanent poison, and true damage rows

## 8. Compendium elite attack display

- [x] 8.1 In compendium enemies tab, for discovered elite enemies, show `elite_attack_description` below the flavor text
- [x] 8.2 For undiscovered elites, show "???" without attack description

## 9. Testing

- [x] 9.1 Add test: burn ticks add 1 line to buffer every 3 seconds
- [x] 9.2 Add test: poison ticks add 1 line directly to board every 5 seconds
- [x] 9.3 Add test: true damage rows are not cleared by line clears
- [x] 9.4 Add test: burn/poison do not stack (second apply extends duration, doesn't double rate)
- [x] 9.5 Add test: Glass Cannon applies 10 true damage rows at round start
- [x] 9.6 Add test: possessed_blade deletes 3 rows but skips true damage rows
- [x] 9.7 Add test: unblocked attack applies debuff, fully blocked does not
- [x] 9.8 Add test: at least one elite special room per floor over 20 seeds
- [x] 9.9 Run full test suite and fix any remaining failures
