## Context

The existing `Keystone` resource is a thin override bag: it carries scalar fields (`lock_delay_ms_override`, `hold_slots_override`, etc.) applied to `RoundConfig` once at round start. All 8 current keystones use this mechanism. None interact with attack generation, the economy, or in-round state.

The 29 replacement keystones require five new effect categories:
1. Attack modifiers (flat bonuses, multipliers, suppressions) applied inside `_on_attack_generated`
2. In-round stateful mechanics (Dizzy spin counter, Dual Wielding consecutive-quad tracker, Safety Net B2B shield, Final Blow B2B-disabled flag)
3. Enemy interaction (Daze stun)
4. End-of-round economy effects (coin grants, overkill conversion, time-remaining coins)
5. RoundConfig extensions (garbage flush reduction, flexible B2B, instant ARR/soft drop)

## Goals / Non-Goals

**Goals:**
- Replace all 8 existing `.tres` keystones with 29 new ones matching the design document exactly
- Extend `Keystone` resource and `RoundConfig` minimally to support all 29 effects
- Slot keystone effects into the existing `_on_attack_generated` / `_end_round` pipeline; avoid touching TetrisBoard internals where possible
- Support conditional availability (Great Sword, Magical Coin require Slightly Magical Coin)
- All new effects covered by GUT unit tests

**Non-Goals:**
- Visual keystone art or icons (placeholder descriptions only)
- Balancing pass on effect magnitudes (ship with document values)
- New shop integration beyond what already exists for keystone selection

## Decisions

### 1. Keystone data model: flat-field approach

`Keystone` resource gains typed export fields for every effect (see full list in spec). Alternatives considered:
- **Dictionary approach** (`flat_bonus_by_event: Dictionary`) — already used by `Technique`; reusing it here would mix keystone semantics with technique semantics and complicate serialisation in `.tres` files
- **Sub-resource per effect** — too much indirection for what is effectively a small fixed set of flags

Plain exported fields are the cleanest for Godot resources: visible in the editor, trivially serialised, and consistent with the current `Keystone` pattern.

Old fields (`lock_delay_ms_override`, `bag_reset_interval_override`, `deep_sight`, `second_wind`, `disable_hold_lockout`) are removed since no new keystone uses them.

### 2. Attack modifier pipeline

```
raw_attack
  → _apply_techniques()          (existing)
  → _apply_keystone_suppressions()   NEW — zero out suppressed event types first
  → _apply_keystone_flat_bonuses()   NEW — add flat per-clear-type bonuses
  → _apply_keystone_multipliers()    NEW — apply per-clear-type multipliers
  → _drain_attack()              (existing attack-buffer drain)
  → quota_accumulated +=
```

Suppressions run first so multipliers never amplify a zeroed value. Keystone effects run after techniques so player intent (building around techniques) is always honoured before keystones add on top.

### 3. Sharpen / Enchant ("per-technique bonus")

"All techniques related to quads gain 2 damage" = at the time a `tetris` event fires, for each owned `Technique` that has a non-zero entry for `"tetris"` or `"any_clear"` in `flat_bonus_by_event`, add `quad_technique_bonus` (2) to the running total. Same logic for Enchant with t-spin event types.

This stays inside `_apply_keystone_flat_bonuses()` with access to `RunState.techniques`.

### 4. Dual Wielding (consecutive-quad tracker)

`RunManager` adds `_last_attack_was_quad: bool = false`. On each `_on_attack_generated` call:
- If event is `"tetris"` and `_last_attack_was_quad` is true AND player owns Dual Wielding → apply x2 multiplier
- Set `_last_attack_was_quad = (event_type == "tetris")`
- Reset to false at round start

### 5. Dizzy (T-piece rotation counter)

`TetrisBoard` emits a new signal `piece_rotated(piece_type: String)` whenever the active piece is rotated. `RunManager` connects to it and maintains `_t_spin_rotations: int` (reset on `lock_processed`). In `_apply_keystone_flat_bonuses()`, if event is a t-spin type and `_t_spin_rotations > 4`, add 4 bonus and reset counter.

### 6. Risky Business (top-row line clear)

`TetrisBoard` emits `lines_cleared(row_indices: Array[int])` immediately before the corresponding `attack_generated`. `RunManager` stores the indices in `_last_cleared_rows` and checks them in `_apply_keystone_multipliers()`: if any cleared row index ≤ 4 (0-indexed from top of visible board) and Risky Business is owned, apply x2.

### 7. Safety Net / Final Blow / Flexible B2B

These three require TetrisBoard to know about B2B mechanics at a config level:
- **Safety Net**: add `b2b_shield_count: int` to `RoundConfig`. TetrisBoard consumes one shield instead of breaking B2B; when shield reaches 0, B2B breaks normally.
- **Final Blow**: add `b2b_broken(streak: int)` signal to TetrisBoard. `RunManager` handles it: deal `streak × 2` bonus attack to quota, then set `current_config.b2b_disabled = true` (field already exists on RoundConfig).
- **Flexible**: add `flexible_b2b: bool` to `RoundConfig`. TetrisBoard checks this flag; any spin-lock (non-T-spin spins included) is treated as a B2B-maintaining move.

### 8. Daze (enemy stun)

On `tetris` event in `_on_attack_generated`, if Daze is owned, add `daze_stun_seconds` (2.0) to `_enemy_timer` (delays next garbage fire). Simple additive extension of the existing enemy timer.

### 9. Simple Shield (incoming garbage reduction)

Add `garbage_flush_reduction: int` to `RoundConfig` (set by Simple Shield = 2). In `_flush_pending_garbage()`, `flush = max(0, mini(pending_garbage, 8) - current_config.garbage_flush_reduction)`. Reduces effective rows flushed per piece lock.

### 10. Economy keystones

Applied in `_end_round()` after win check, before `Economy.pay_round()`:
- **Slightly Magical Coin / Magical Coin** (`end_round_coins`): `Economy.coins += end_round_coins` for each owned keystone that has a non-zero value
- **Midas Touch** (`overkill_coins`): `surplus_attack` (already tracked) converts to coins: `Economy.coins += surplus_attack`
- **Golden Watch** (`time_coins`): `Economy.coins += int(round_timer / 5.0)` at round end (time remaining at win)

### 11. Run-start starter keystone selection

`start_run()` in `RunManager` SHALL show the keystone selection screen in `starter_only` mode before calling `start_round()`. The selection screen gains a `starter_only: bool` property; when set, `_draw_three_keystones()` filters the pool to keystones with `is_starter = true`. After the player picks, `_on_starter_keystone_chosen()` calls `start_round()`.

No shop is shown between the starter pick and round 1 — the selection is a direct prologue to the first board.

### 13. Conditional availability

Add `requires_keystone_id: String` to `Keystone` (empty = always available). The selection screen's draw pool filters out any keystone whose `requires_keystone_id` is non-empty and not present in `RunState.used_keystone_ids`. Great Sword and Magical Coin both set `requires_keystone_id = "slightly_magical_coin"`.

### 12. Full Potential (instant ARR / soft drop)

Add `instant_arr: bool` and `instant_soft_drop: bool` to `RoundConfig`. Full Potential sets both via `apply_to_config()`. TetrisBoard reads these flags and sets ARR to 0ms and soft-drop delay to 0ms respectively.

### 14. RunState additions

The Dizzy rotation counter and PC-this-round flag (for Beginner's/Veteran's Luck) live in `RunManager` local state (not `RunState`) since they're per-round and cleared on `_end_round`. The B2B-disabled mid-round flag is already handled by `current_config.b2b_disabled`.

## Risks / Trade-offs

- **TetrisBoard signal additions** (`piece_rotated`, `lines_cleared`, `b2b_broken`) — These require modifying a central class. Risk: signal timing edge cases (e.g., `lines_cleared` firing before `attack_generated` is guaranteed). Mitigation: emit both signals within the same `_emit_attack_events()` call, `lines_cleared` first.
- **Dizzy counter drift** — If the T-piece is swapped mid-rotation, the counter should reset. `RunManager` resets `_t_spin_rotations` on `lock_processed` but must also reset on hold (connect to a `piece_held` signal or reset when event type changes from T to non-T).
- **Suppression interaction with B2B** — Keystones that suppress t-spins (Simplicity) will zero attack from `tspin_*` events but the B2B chain is maintained by TetrisBoard independently. Players can still chain T-spins for B2B bonus without the raw T-spin attack. This is intended.
- **Simple Shield vs attack buffer** — The garbage flush reduction applies per piece-lock flush event, not per garbage row accumulated. With 8-row cap + 2 reduction, maximum effective flush is 6 rows. Accepted trade-off.

## Migration Plan

1. Delete all 8 `.tres` files from `game/resources/data/keystones/`
2. Rewrite `keystone.gd` with new fields; remove old fields; update `apply_to_config()` to write new RoundConfig fields
3. Add new fields to `RoundConfig`
4. Add new signals and flags to `TetrisBoard`
5. Add keystone effect methods to `RunManager`
6. Create 29 new `.tres` files
7. Verify keystone selection screen correctly filters conditional keystones
8. Remove dead references (`second_wind_triggered`, `second_wind_used_this_round`) from RunManager and RunState if no longer used

No save-file migration needed: `RunSave` stores keystone IDs; old IDs simply won't match any new `.tres` on load, which is acceptable for in-progress runs (effectively lost — acceptable for a content rework).
