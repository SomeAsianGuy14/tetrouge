## Context

The piece-enhancement system (`game/resources/piece_enhancements.gd`) defines four cell-level enhancements — Honed (+1 atk/cell, pre-multiplier), Amplified (+25% mult/cell, post-multiplier, cap ×3), Gilded (+1 coin/cell), Reinforced (+1 garbage-shield charge/cell) — with pure static benefit functions operating on a `counts: Dictionary`.

Pieces are enhanced at spawn time via `RunManager._advance_enhancement_state(grant, cadence, techniques)` (`game/scenes/game/run_manager.gd:565`), which currently only looks at:
- a single active "grant" dict (`{type, remaining}`, set by consumables)
- technique `piece_enhancer` effects (`effect_type="piece_enhancer", params={enhancement, every_n}`)

`TechniqueEvaluator` evaluates attack/economy deltas per clear from `AttackContext` + `TechniqueRoundState`; `RunManager._on_attack_generated` applies technique deltas, keystone flat bonuses/multipliers, then Honed (pre-multiplier) and Amplified (post-multiplier) from `_pending_enh_counts`.

`Keystone` is a flat-field resource (no `effect_type/params` like `Technique`); each mechanic gets its own typed `@export` field and its own `match` arm in `run_manager.gd`/`technique_evaluator.gd`.

## Goals / Non-Goals

**Goals:**
- Add the 7 techniques, 7+3 keystone changes, and 5 consumable changes from `enhancements.md` using patterns consistent with the existing codebase.
- Extend the enhancement-assignment state machine to support keystone-driven cadences and a `"random"` type, without breaking the existing preview/hold/grant semantics.
- Make Honed/Amplified/Gilded/Reinforced benefit magnitudes adjustable by keystones (Refined/Armored/Polished/Overclocked/Jack of All Trades) while keeping `PieceEnhancements`'s functions pure and unit-testable.
- Cleanly retire Sharpen's old identity, Keen Edge, and `garbage_flush_reduction` without leaving dead code or dangling references.

**Non-Goals:**
- No changes to the enhancement *layer* mechanics (stamping, row-shift, hold-swap) — those are unchanged from the current `piece-enhancements` spec.
- No save-migration tooling for in-progress runs that reference removed ids (`sharpen`, `keen_edge`, `arcane_battery`, `whetstone`, `gilding_kit`, `reinforcing_plate`) — acceptable churn for an in-development build.
- No UI/visual work beyond what's needed for popups (new popup entries reuse existing event-list rendering).

## Decisions

### 1. Random enhancement: resolved per-piece at assignment time
`"random"` is a valid value for both `Technique.params.enhancement`, `Keystone.piece_enhance_type`, and `Consumable.enhance_type`. Inside `_advance_enhancement_state`, whenever an assignment resolves to `"random"`, it's immediately replaced with `PieceEnhancements.ALL_TYPES.pick_random()`. This means:
- Lottery Ticket's 3 granted pieces each roll independently (not one roll applied to all 3).
- Extraordinary Bag's every-7th piece rolls independently each time it fires.
- Preview (`preview_enhancements`) shows a plausible-but-not-guaranteed result for random slots, same as any other RNG-dependent preview in this codebase (acceptable — no precedent for deterministic preview of randf-based effects like `gambler_rng` either).

**Alternative considered**: resolve "random" once at grant-creation time and store the concrete type in the grant dict. Rejected because Extraordinary Bag's cadence-based grants aren't "created" as a dict — resolving lazily keeps both consumable-grant and cadence-grant paths uniform.

### 2. Keystone-level piece enhancers via two new fields
Add to `Keystone`:
```gdscript
@export var piece_enhance_every_n: int = 0
@export var piece_enhance_type: String = ""   # "honed"|"amplified"|"gilded"|"reinforced"|"random"
```
`_advance_enhancement_state` gains a `keystones: Array` parameter and runs the same cadence loop it already runs for technique `piece_enhancer`s, keyed by `ks.id` in the shared `cadence` dict (ids are unique across techniques and keystones, so no collision risk).

Used by:
- Midas Touch: `piece_enhance_every_n=7, piece_enhance_type="gilded"`
- Charging Up: `piece_enhance_every_n=10, piece_enhance_type="amplified"`
- Extraordinary Bag: `piece_enhance_every_n=7, piece_enhance_type="random"`

**Alternative considered**: give `Keystone` an `effect_type/params` dict like `Technique`. Rejected — every other Keystone mechanic is a typed field, and only 3 keystones need this; two scalar fields are simpler and match the existing style (e.g. `per_technique_quad_bonus` was already a single-purpose typed field).

### 3. Queued enhancement grants
`_enhancement_grant: Dictionary` (active grant) gets a sibling `_enhancement_grant_queue: Array[Dictionary]`. Rules:
- If `_enhancement_grant` is empty when a new grant arrives (consumable use, Preparation, Backpedaling), it becomes active immediately.
- If `_enhancement_grant` is active, the new grant is appended to the queue.
- In `_advance_enhancement_state`, when the active grant's `remaining` reaches 0, the next queue entry (if any) is promoted to active.
- `preview_enhancements` duplicates the queue array alongside the grant/cadence dicts, same as today.

Preparation (`effect_type="post_quad_enhance"`) and Backpedaling (`effect_type="post_combo_enhance"`) push `{"type": "honed"|"reinforced", "remaining": 1}` onto this structure when their trigger condition is met during clear evaluation.

**Alternative considered**: drop/overwrite the active grant when a technique grant fires. Rejected per user — queuing preserves the value of an active consumable.

### 4. Benefit-magnitude overrides via additive keystone fields
Add four new optional `@export` fields to `Keystone`, all additive and defaulting to 0:
```gdscript
@export var honed_bonus_per_cell: int = 0       # Refined: 2
@export var reinforced_bonus_per_cell: int = 0  # Armored: 2
@export var gilded_bonus_per_cell: int = 0      # Polished: 1
@export var amplified_bonus_per_cell: float = 0.0  # Overclocked: 0.125 (50% of base 0.25)
@export var double_enhancement_benefits: bool = false  # Jack of All Trades
```
`PieceEnhancements` functions gain an optional per-cell parameter with the current constant as default:
```gdscript
static func honed_bonus(counts, per_cell := HONED_ATTACK_PER_CELL) -> int
static func shield_charges(counts, per_cell := REINFORCED_SHIELD_PER_CELL) -> int
static func gilded_coins(counts, per_cell := GILDED_COINS_PER_CELL) -> int
static func amplified_multiplier(counts, per_cell := AMPLIFIED_PER_CELL) -> float
```
`RunManager` computes the effective `per_cell` once per clear by summing the relevant field across `RunState.keystones`, and computes an `effective_counts` dict (each count ×2 if `double_enhancement_benefits` is true on any owned keystone) before calling these functions. Both `_apply_enhancement_clear_benefits` and the Honed/Amplified application sites in `_on_attack_generated` use the same `effective_counts`/per-cell values so Jack of All Trades and Refined/etc. apply consistently everywhere a benefit is paid.

**Alternative considered**: have `PieceEnhancements` read `RunState.keystones` directly. Rejected — keeps the module a pure/static math utility (matches its current unit-test style), with `RunManager` as the integration point that already owns keystone iteration.

### 5. The Best Defense, Last Stand, Golden Blade, Preparation, Backpedaling as evaluator side-effects
These don't fit `_eval_attack`'s "return an attack delta" model cleanly:
- **The Best Defense** needs the *final* modified attack (after all multipliers) — computed in `_on_attack_generated` after `modified` is finalized (`run_manager.gd:710-723`). Implemented as a new flag (`"best_defense"`) collected by `_collect_flags`; `RunManager` adds `floor(modified * 0.25)` to `_garbage_shield` when the flag is present and the event is a primary clear.
- **Last Stand** is checked once per piece lock (alongside the existing per-lock bookkeeping around `run_manager.gd:520`), not per attack event. New `TechniqueRoundState.last_stand_triggered: bool` (reset each round); when `ctx.board_height >= 16` (80% of 20) and not yet triggered, add 10 to `_garbage_shield` and set the flag.
- **Golden Blade** is evaluated like other `_eval_attack` arms but needs to know cleared-cell composition: `AttackContext` gains `cleared_enh_counts: Dictionary`, populated from `_pending_enh_counts` in `_build_attack_context`. `effect_type="golden_blade"` returns `+2` when `is_clear and ctx.cleared_enh_counts.get("gilded", 0) > 0`.
- **Preparation / Backpedaling** are evaluated in `_eval_attack` (return 0) but are also inspected by `_collect_flags` (or a small dedicated pass) to push onto `_enhancement_grant_queue` per Decision 3, mirroring how `greedy_hands` is a zero-attack flag-only effect today.

### 6. Shield-pool starting values replace `garbage_flush_reduction`
Add `@export var start_shield: int = 0` to `Keystone`. `_reset_enhancement_round_state` (which currently zeroes `_garbage_shield`) instead sets `_garbage_shield = sum(ks.start_shield for ks in RunState.keystones)`.

Simple Shield (`start_shield=5`) and Legionnaire's Shield (`start_shield=10`) replace their `garbage_flush_reduction` values. Since these were the only two consumers of `garbage_flush_reduction`, remove:
- `Keystone.garbage_flush_reduction` and its `apply_to_config` branch
- `RoundConfig.garbage_flush_reduction`
- the consuming check at `run_manager.gd:450`
- `test_garbage_flush_reduction_*` tests in `test_keystones.gd`

### 7. Sharpen's old identity removed cleanly
- Delete `game/resources/data/keystones/sharpen.tres`, remove from `resource_registry.all_keystones`.
- Remove `Keystone.per_technique_quad_bonus` and its evaluation block (`run_manager.gd:910-913`) and associated test (`test_per_technique_quad_bonus_*` in `test_keystones.gd`). `per_technique_tspin_bonus` (Enchant) is untouched — it's evaluated in a separate branch.
- `category = "Quad"` still has `daze`, `dual_wielding`, `great_sword`, `simplicity` — no orphaned category.
- New technique `game/resources/data/techniques/sharpen.tres` (`piece_enhancer`, honed, every_n=6) replaces `keen_edge.tres`, which is deleted and removed from `resource_registry.all_techniques`.

## Risks / Trade-offs

- **[Risk]** `_advance_enhancement_state` is static and now takes more parameters (`keystones`, grant queue) — call sites (`_on_piece_spawned`, `preview_enhancements`) must stay in sync. → Mitigation: both call sites already live in `RunManager` and are covered by `test_enhancement_grid.gd`/`test_piece_enhancements.gd`; add cases for the new params.
- **[Risk]** Doubling `counts` for Jack of All Trades also doubles `amplified_multiplier`'s cell-count input, which could push the ×3 cap differently than "doubling the final multiplier" would. → Mitigation: this is the intended "trigger twice" framing (each amplified cell counts twice toward the multiplier), and the existing cap still applies — document this in the `piece-enhancements` spec delta.
- **[Risk]** Removing `sharpen` (keystone) and `keen_edge` (technique) ids will null-out any in-progress saved run that references them via `ResourceRegistry.find_by_id`. → Mitigation: accepted for in-development build; no players have persistent runs across this change.
- **[Trade-off]** Random-enhancement preview can't guarantee accuracy (RNG resolved at assignment time). → Mitigation: consistent with other RNG-based preview gaps already present (e.g. `gambler_rng`).

## Open Questions

None outstanding — all prior open questions from exploration were resolved before this proposal (naming collision, Sharpen's fate, Midas Touch/Shield redesigns, random-pick scope, Jack of All Trades scope, Best Defense semantics, queueing behavior).
