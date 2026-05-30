## Context

The current technique system consists of 10 hand-crafted Technique resources evaluated inline in `RunManager`. Each technique exposes a flat `Dictionary` of per-event bonuses (`flat_bonus_by_event`) and a handful of scalar fields; `RunManager` iterates them after each attack event. The schema works but is too narrow: every technique is essentially "add N attack on event X," with a few special cases bolted on. There is no way to express board-state-dependent bonuses, diminishing returns, cumulative round counters, or tags for keystone synergy.

The overhaul replaces all 10 techniques with 53, adds a richer data contract, and introduces a dedicated evaluation class so technique logic doesn't spread further into `RunManager`.

## Goals / Non-Goals

**Goals:**
- 53 new techniques with tags; all 10 old ones removed
- `TechniqueEvaluator` static class centralises all bonus calculation
- `AttackContext` carries full attack snapshot; `TechniqueRoundState` carries per-round counters
- `technique_capacity` on `RunState` enforces slot limits (4 → 8 across stages)
- Board telemetry (hole count, column heights, summit height) available on `TetrisBoard`
- Whirl keystone added
- Shop enforces capacity at purchase time

**Non-Goals:**
- Technique UI redesign (cards, icons, animations)
- Saving/restoring `TechniqueRoundState` mid-run across game restarts (non-critical for now)
- Dynamic technique unlock conditions or rarity tiers

## Decisions

### D1 — TechniqueEvaluator as a static class

**Decision:** All bonus computation lives in a new `TechniqueEvaluator` static class. `RunManager` calls `TechniqueEvaluator.compute_attack_bonus(techniques, ctx, round_state)` and `TechniqueEvaluator.compute_economy_bonus(techniques, ctx, round_state)` after each attack event.

**Why:** Keeps `RunManager` from growing into an unmaintainable god-object. Static functions are trivially unit-testable without a scene tree; the evaluator can be exercised with plain data objects in GUT.

**Alternative considered:** Technique resources with a virtual `evaluate(ctx)` method. Rejected because GDScript doesn't have proper interface enforcement, and the dispatch logic would be duplicated across 53 `.tres` files.

### D2 — AttackContext as a plain Resource

**Decision:** `AttackContext` extends `Resource` with exported fields:
```
lines_cleared: int
combo: int              # current combo count at time of clear
b2b: bool               # whether this clear continues b2b
tspin: String           # "", "mini", "single", "double", "triple"
perfect_clear: bool
garbage_sent: int       # raw garbage before technique bonuses
board_height: int       # summit_height from TetrisBoard
held_this_piece: bool   # whether hold was used this placement
used_soft_drop: bool    # whether soft-drop was used
piece_placement_count: int  # total pieces placed this round
```
`RunManager` constructs one after every attack event.

**Why:** Passing a single context object future-proofs the API. Adding a new field to `AttackContext` doesn't require changing every technique's call signature. Resource subclasses serialize cleanly if we ever want to replay or log attacks.

### D3 — TechniqueRoundState as a per-round object

**Decision:** `TechniqueRoundState` is a plain `RefCounted` with counters reset at round start:
```
clears_this_round: int
attack_events_this_round: int
coins_earned_this_round: int
tspin_count: int
b2b_count: int
perfect_clear_count: int
total_garbage_sent: int
```
`RunManager` creates one at `_start_round()` and passes it alongside `AttackContext` to the evaluator.

**Why:** Several techniques need cross-event state (e.g., "bonus scales with total garbage sent this round"). Embedding this in `AttackContext` would mix snapshot data with cumulative state. A separate object is clearer.

### D4 — effect_type dispatch in TechniqueEvaluator

**Decision:** `Technique` gains a String field `effect_type` (e.g., `"flat_on_event"`, `"per_combo"`, `"board_height_threshold"`, `"economy_per_event"`, `"lifecycle"`). `TechniqueEvaluator` switches on this field. Each effect type has a small set of numeric parameters stored in a `Dictionary params` on the `Technique` resource.

**Why:** Avoids creating a subclass per technique while still being explicit enough to unit-test each effect type in isolation. Adding a new effect type requires only a new branch in the evaluator, not a new script file.

**Alternative considered:** One GDScript per technique. Rejected — 53 scripts is unmaintainable, and most techniques share 3-4 underlying patterns.

### D5 — Lifecycle hooks for special techniques

**Decision:** Eight techniques with side effects beyond attack bonus (Burning Board, Glass Cannon, Flash Step, Counter Strike, and the economy-stream techniques) are handled via explicit hook calls in `RunManager`. The evaluator returns an `EvalResult` dictionary:
```
{ "attack_delta": int, "coins_delta": int, "block_damage": bool, "flags": Array[String] }
```
`RunManager` applies each field. The `"flags"` array signals one-shot triggers (e.g., `"glass_cannon_triggered"`) that `RunManager` handles.

**Why:** Keeps the evaluator pure (input → output, no side effects) while giving `RunManager` clear extension points. The alternative — evaluator mutating game state directly — would make tests impossible and couple the evaluator to the scene tree.

### D6 — Tags as Array[String] on Technique

**Decision:** `Technique` gains `tags: Array[String]` (e.g., `["tspin", "combo", "economy"]`). Tags are informational for now and used by future keystones that scale off tag counts.

**Why:** The user explicitly called out that keystones will scale on tag presence. Storing tags on the resource is the cheapest way to make that data available without adding runtime book-keeping.

### D7 — technique_capacity computed from stage

**Decision:** `RunState` adds `technique_capacity: int = 4`. `RunState.advance_round()` updates it: `technique_capacity = 4 + (stage - 1)` (clamped at 8). Shop checks `RunState.techniques.size() < RunState.technique_capacity` before enabling buy buttons.

**Why:** Computing it from stage keeps the save format minimal; no need to persist the capacity itself. The formula is simple enough that a property would also work, but an explicit field means the shop and UI can read it without recomputing.

### D8 — Whirl keystone implementation

**Decision:** Whirl is a new `Keystone` resource with `effect_type = "whirl"`. After any T-spin clear (mini or full), `RunManager` advances the combo counter by 2 instead of the normal 1 step. This is checked before attack calculation so combo-dependent techniques see the boosted counter.

**Why:** The effect is purely a counter increment — no new event type, no separate attack event. Checking keystone ownership at combo-step time keeps the implementation minimal and avoids special-casing the evaluator.

## Risks / Trade-offs

- [Performance] Evaluating 53 techniques on every attack event via a switch statement is O(n) in technique count. With a max of 8 equipped techniques this is negligible. → No mitigation needed.
- [Data volume] 53 `.tres` files is a large data task. Typos or inconsistent `effect_type` strings will silently produce zero bonuses. → Unit tests for each effect type; evaluator logs a warning on unknown `effect_type`.
- [RunState save compatibility] Adding `technique_capacity` breaks existing save files if `RunSave` serialises the full `RunState` dict. → `RunSave` should use `get(key, default)` on load; confirm this is already the pattern.
- [Board telemetry cost] Computing hole count and column heights on every attack event requires iterating the grid. → Cache telemetry values on `TetrisBoard` and update them only on line-clear events, not on every frame.

## Migration Plan

1. Delete `game/resources/data/techniques/*.tres` (all 10 files)
2. Rewrite `game/resources/technique.gd` with new schema
3. Add `AttackContext`, `TechniqueRoundState`, `TechniqueEvaluator` scripts
4. Add board telemetry to `TetrisBoard`
5. Add `technique_capacity` to `RunState`
6. Rewrite technique evaluation in `RunManager` to use evaluator
7. Add lifecycle hooks in `RunManager`
8. Add 53 new `.tres` files
9. Add Whirl keystone `.tres` and handler
10. Enforce capacity in `shop.gd`
11. Write unit tests; run full test suite

No rollback strategy is needed — this is a local game with no live players. The breaking change is acceptable because the old techniques have no player save data worth preserving.

## Open Questions

- Should `TechniqueRoundState` be persisted to `RunSave`? (Counters reset each round so they only matter mid-round — likely not worth persisting.)
- Exact numeric values for all 53 techniques are not in scope for this design doc; they will be set during data authoring in the tasks phase.
