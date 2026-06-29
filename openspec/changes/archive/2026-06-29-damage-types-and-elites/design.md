## Context

Enemy attacks currently generate garbage packets in `_tick_enemy_garbage()` which are flushed to the board. The shield system absorbs lines before they hit. `TetrisBoard` clears full rows and has no concept of unclearable cells. Boss modifiers modify `RoundConfig` and filter attacks. The dungeon generator guarantees rooms per spine but has no elite-specific tile.

## Goals / Non-Goals

**Goals:**
- Implement burn, poison, and true damage as distinct systems
- Create elite enemies with unique board-modifying attacks
- Add debuff status display with duration indicators
- Rework Burning Board → Poisoned Blood, Glass Cannon → cursed keystone
- Add two new bosses (The Tide, The Serpent) and rework The Furnace

**Non-Goals:**
- Stacking multiple burn/poison sources (binary state only)
- True damage removal mechanics (future work)
- Animated debuff effects on the board cells
- Elite enemies on every floor beyond the one guaranteed

## Decisions

### 1. Burn and poison as RunManager state with tick functions

Two new state fields on RunManager:
- `_burn_active: bool`, `_burn_remaining: float` (-1.0 for permanent)
- `_poison_active: bool`, `_poison_remaining: float` (-1.0 for permanent)
- `_burn_tick_timer: float`, `_poison_tick_timer: float`

Tick functions in `_process()`:
- `_tick_burn_debuff(delta)`: if active, decrement remaining (unless permanent), increment tick timer. When tick timer >= 3.0, reset timer and add 1 line to `_garbage_packets` (buffer). Shield can absorb on flush.
- `_tick_poison_debuff(delta)`: if active, decrement remaining (unless permanent), increment tick timer. When tick timer >= 5.0, reset timer and call `current_board.insert_garbage_rows(1, col)` directly (bypasses buffer and shield).

Applying a debuff when already active: if the new duration is longer, extend. If permanent, stay permanent. Never stack rate.

### 2. True damage as unclearable cells in TetrisBoard

Add a `_true_damage_rows: int` field to TetrisBoard tracking permanent rows at the bottom. When true damage is applied:
1. Insert a full row at the bottom (no gap) with a special cell value (e.g. `CELL_TRUE_DAMAGE = 10`)
2. `_find_full_rows()` skips rows that contain any `CELL_TRUE_DAMAGE` cells
3. Increment `_true_damage_rows`
4. These rows render with a distinct color (dark red/crimson)

### 3. Elite enemies use existing Enemy resource with a new `elite_attack` field

`Enemy` gets `@export var elite_attack: String = ""`. Values: `"corrupted_mage"`, `"possessed_blade"`, `"crimson_drake"`, `"venomous_archer"`.

RunManager handles elite attacks in a new `_apply_elite_attack()` called after garbage is generated in `_tick_enemy_garbage()`. Each attack type has its own handler:
- `corrupted_mage`: Randomly fills 4-6 empty cells on the board with garbage
- `possessed_blade`: Picks a random row index, deletes 3 contiguous rows from board (shifts everything down)
- `crimson_drake`: If attack was unblocked (lines hit board), apply burn for 4 seconds
- `venomous_archer`: If attack was unblocked, apply poison for 6 seconds

### 4. Guaranteed elite spawn via dungeon generator

Add `TYPE_COMBAT_ELITE_SPECIAL` to `DungeonRoom`. The generator ensures at least one per floor by converting one non-boss, non-start combat room to this type after spine generation. The elite enemy pool draws from enemies with `elite_attack != ""`.

### 5. Debuff status display

A new `DebuffDisplay` Control node positioned to the left of the board (between the hold display and the board). Shows:
- **Burn icon** (flame emoji or orange rectangle) with remaining seconds as text, or "∞" if permanent
- **Poison icon** (green drop or green rectangle) with remaining seconds, or "∞"
- Only visible when the corresponding debuff is active
- Updated every frame from RunManager's debuff state

### 6. Cursed keystones use existing keystone properties

- **Poisoned Blood**: `all_attack_multiplier = 2.0`, new flag `permanent_poison = true`
- **Blazing Heart**: `all_attack_multiplier = 2.0`, new flag `permanent_burn = true`
- **Glass Cannon**: `all_attack_multiplier = 2.0`, new field `true_damage_on_start: int = 10`

At round start in `start_round()`, check for these flags and apply the debuffs/true damage.

### 7. Boss modifier integration

- **The Tide**: new field `true_damage_interval: float = 30.0` on BossModifier. RunManager ticks a timer and applies 1 true damage when it fires.
- **The Serpent**: new field `permanent_poison: bool = true` on BossModifier. Applied at round start.
- **The Furnace**: reworked to `permanent_burn: bool = true` on BossModifier. Applied at round start.

## Risks / Trade-offs

**True damage permanence** — Once true damage rows exist, they never go away. With The Tide dealing 1 every 30 seconds, a 3-minute fight means 6 permanent rows. Combined with Glass Cannon's 10, the board becomes very constrained. This is intentional — it creates urgency.

**Possessed Blade row deletion** — Deleting 3 random rows could delete true damage rows. Decision: true damage rows cannot be deleted by Possessed Blade (they're permanent by definition). The deletion skips them and picks from clearable rows only.

**Burn vs existing burn system** — The Ignition keystone already has a "burn pool" for damage-over-time delivery to enemies. The new burn debuff is a separate concept (self-harm). Different variable names avoid confusion: `_burn_pool` (Ignition, damages enemy) vs `_burn_debuff_active` (damages player).
