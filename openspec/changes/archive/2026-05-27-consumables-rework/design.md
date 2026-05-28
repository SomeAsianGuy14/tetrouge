## Context

Consumables are currently single-use items that execute an immediate effect (clear board, add coins, inject a specific piece, etc.) at purchase or round start. The inventory holds up to 2 items, the shop offers 1 consumable slot, and the HUD has no visible backpack — the player must navigate to an inventory screen. This model disconnects consumables from the round-by-round combat loop and produces low-impact items.

The rework reimagines consumables as one-round attack buffs: items sit in a visible 3-slot backpack on the HUD, the player activates one before a round begins, and its bonuses apply to that round's `RoundConfig` exactly as keystones do. Time Shard is retained as the only mid-round usable. Clean Slate, Coin Purse, and Piece Lock are removed.

Throughout the codebase, the 4-line clear event is referred to internally as `"tetris"`. This change renames it to `"quad"` everywhere: event type strings, technique constants, .tres files, and UI text.

## Goals / Non-Goals

**Goals:**
- All consumable items (except Time Shard) apply flat attack bonuses to one round's `RoundConfig` via `apply_to_config(cfg)`.
- Player activates an item from the HUD backpack before the round starts (in the pre-round state, before first piece spawns).
- Time Shard (adds 8 seconds) remains usable during a round.
- Backpack shows 3 persistent slots on the HUD, visible throughout every round.
- Shop offers 2 consumable slots per visit.
- `"tetris"` event type renamed to `"quad"` throughout (GDScript, .tres, UI text).
- Remove Clean Slate, Coin Purse, Piece Lock .tres files and their effect fields from `consumable.gd`.

**Non-Goals:**
- Per-round limit on number of items activated (player can use as many as they hold, though 3 slots makes this naturally bounded).
- Stackable consumable slots beyond 3.
- New visual consumable icons (placeholder text labels are fine).
- Changes to the economy or shop pricing model.
- Changes to keystone or technique mechanics.

## Decisions

**`apply_to_config(cfg)` on Consumable, parallel to Keystone**

Chosen: `Consumable.apply_to_config(cfg: RoundConfig)` writes bonus fields onto `RoundConfig` before the round starts. RunManager calls this for the activated item after building the config from keystones. This mirrors how keystones work and keeps RunManager's `_apply_consumable_flat_bonuses(attack, event_type)` simple: read from `current_config`.

Alternative: Store the active consumable on RunState and query it during the attack pipeline. Rejected — makes it harder to clear the effect at round end and adds another global query site.

**Consumable bonus fields on RoundConfig**

New fields added to `round_config.gd`:
```
var consumable_all_bonus: int = 0    # applies to every clear type
var consumable_quad_bonus: int = 0
var consumable_tspin_bonus: int = 0  # any t-spin variant
var consumable_b2b_bonus: int = 0    # added per b2b streak event
var consumable_combo_bonus: int = 0  # added per combo count
var consumable_pc_bonus: int = 0     # perfect clear only
```
These default to 0, so non-consumable rounds are unaffected. They are naturally scoped to one round because `RoundConfig` is rebuilt each round.

**Consumable resource fields**

Existing effect flags (`clears_board`, `guarantees_next_t`, `adds_coins`, `attack_surge_clears`) are removed. Retained: `adds_time` (Time Shard). Added:
```
@export var bonus_all_clears: int = 0
@export var bonus_quad: int = 0
@export var bonus_tspin: int = 0
@export var bonus_b2b: int = 0
@export var bonus_combo: int = 0
@export var bonus_pc: int = 0
```
`apply_to_config(cfg)` writes these to the corresponding `RoundConfig` fields. `adds_time` is not applied via `apply_to_config` — RunManager reads it when the player presses the HUD button during a round (identical to current Time Shard logic).

**Pre-round activation: HUD button, not a full screen**

Chosen: Each backpack slot on the HUD is a button. In the pre-round idle state (before first piece spawns), clicking a slot activates the item: calls `apply_to_config(current_config)`, removes the item from `RunState.consumables`, and refreshes the HUD slots. The round is started by the existing "Start" interaction or begins automatically — no new screen is added.

Alternative: Dedicated pre-round consumable selection screen (like keystone selection). Rejected — adds screen transition complexity for a lightweight action. The HUD backpack visible at all times is sufficient UX.

**`"tetris"` → `"quad"` event type rename**

The internal event type string `"tetris"` is renamed to `"quad"` everywhere:
- `technique.gd`: `EVENT_TETRIS` constant → `EVENT_QUAD`; value `"tetris"` → `"quad"`
- `tetris_board.gd`: `_get_clear_type()` return value and base attack table
- `run_manager.gd`: all `match` branches and string comparisons
- `.tres` data files: `boss_modifiers/the_purge.tres` quota whitelist, `techniques/efficiency.tres` event key, keystone category strings `"Tetris"` → `"Quad"`
- Unit tests: all `"tetris"` string literals in test files

The scene class names `TetrisBoard` and `TetrisCore` remain unchanged — these are engine class references, not player-facing terms.

**New item pool (.tres files)**

| Name | Effect | Activation |
|------|--------|-----------|
| Power Fragment | +3 to all clears | Pre-round |
| Power Shard | +2 to all clears | Pre-round |
| Quad Stone | +5 to quads | Pre-round |
| Spin Amplifier | +5 to any T-spin | Pre-round |
| B2B Booster | +4 to B2B attacks | Pre-round |
| Combo Coil | +3 to combo bonus | Pre-round |
| Perfected Spike | +8 to perfect clears | Pre-round |
| Attack Surge | First 3 clears deal double attack | Pre-round |
| Time Shard | +8 seconds to timer | During round |

Attack Surge is retained but reworked: instead of a dynamic per-purchase N count, it always grants double attack for the first 3 clears of the round. Mechanically this uses a `consumable_surge_clears_remaining: int` field on `RoundConfig`. After each attack fires, if the counter is > 0 the attack value is doubled and the counter is decremented. `TetrisBoard.activate_attack_surge()` is removed — the counter on `RoundConfig` replaces it.

**Shop consumable slots: 1 → 2**

`shop.gd` and the shop scene are updated to instantiate 2 consumable item slots instead of 1. No structural changes to the slot container are needed; the existing slot template is reused.

## Risks / Trade-offs

- [`apply_to_config` called before board is running — timing must be correct] → RunManager must call consumable activation after `_build_round_config()` and before `start_round()`. The HUD button should only be enabled during the pre-round window.
- [Player forgets to use items] → No forced usage. Items stay in backpack, can be used before any future round. Slight UX friction, but keeps agency with the player.
- [Renaming `"tetris"` to `"quad"` breaks save data with technique flat_bonus_by_event keys] → Technique flat_bonus_by_event keys in .tres files are renamed. Existing saves that reference the old event key will simply not grant bonuses for that technique until the save is invalidated or a migration is added. At this stage of development, save migration is out of scope — treat as known breakage in existing runs.
- [3 items in shop instead of 2 may flood the player early] → The shop only shows 2 at a time, so the player still faces binary choices. Pool diversity distributes item types. No change needed.

## Open Questions

- Should Time Shard's HUD button be visually distinct from attack-buff slots (e.g., different color) to signal it can be used mid-round?  → Probably yes; can be addressed when implementing the backpack UI.
