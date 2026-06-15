## Why

The piece-enhancement system (Honed/Amplified/Gilded/Reinforced) and the garbage-shield pool currently have only a few techniques/keystones/consumables that interact with them. `enhancements.md` lays out a batch of new techniques, keystones, and consumables that build around these systems more deeply, while also retiring a couple of underused or redundant items (Sharpen's old per-technique quad bonus, Keen Edge, and the garbage-flush-reduction shields).

## What Changes

### Techniques
- **NEW** Sharpen: `piece_enhancer`, every 6th piece spawns Honed. **BREAKING**: replaces `keen_edge` (every 5th piece Honed), which is removed.
- **NEW** Barricade: `piece_enhancer`, every 6th piece spawns Reinforced.
- **NEW** The Best Defense: on a clear, 25% of the final attack value is also granted as garbage-shield charges (on top of full damage).
- **NEW** Last Stand: first time per round the board height exceeds 80%, grant +10 garbage-shield charges.
- **NEW** Preparation: after a Quad clear, the next piece spawns Honed (queued enhancement grant).
- **NEW** Backpedaling: after combo count exceeds 5, the next piece spawns Reinforced (queued enhancement grant).
- **NEW** Golden Blade: if a clear contains a Gilded cell, deal +2 additional damage.

### Keystones
- **NEW** Extraordinary Bag: every 7 pieces, one piece spawns with a randomly-chosen enhancement.
- **NEW** Charging Up: every 10th piece spawns Amplified.
- **NEW** Jack of All Trades: doubles all enhancement benefits at clear time (Honed/Amplified/Gilded/Reinforced counts), does not affect spawn cadence.
- **NEW** Refined: Honed cells grant +2 additional attack (3 total per cell).
- **NEW** Armored: Reinforced cells grant +2 additional shield (3 total per cell).
- **NEW** Polished: Gilded cells grant +1 additional coin (2 total per cell).
- **NEW** Overclocked: Amplified cells grant a +50% larger multiplier contribution (0.375 instead of 0.25 per cell).
- **REDESIGN** Midas Touch: was "earn coins equal to overkill damage at round end" → now every 7th piece spawns Gilded.
- **REDESIGN** Simple Shield: was `garbage_flush_reduction = 1` → now starts each round with 5 garbage-shield charges.
- **REDESIGN** Legionnaire's Shield: was `garbage_flush_reduction = 3` → now starts each round with 10 garbage-shield charges.
- **BREAKING**: Remove the `sharpen` keystone (per-technique Quad bonus) entirely. The now-unused `per_technique_quad_bonus` and `garbage_flush_reduction` fields (and their evaluation code) are removed from `Keystone`/`RoundConfig`.

### Consumables
- **NEW** Lottery Ticket: next 3 pieces each independently spawn with a randomly-chosen enhancement.
- **RENAME** Whetstone → Sharpening Stone (no mechanic change: next 4 pieces Honed).
- **RENAME** Gilding Kit → Gold Leaf (no mechanic change: next 4 pieces Gilded).
- **RENAME** Reinforcing Plate → Steel Plates (no mechanic change: next 4 pieces Reinforced).
- **RENAME + REBALANCE** Arcane Battery → Charged Battery (next 4 → next 2 pieces Amplified).

### System/architecture
- Add `"random"` as a resolvable enhancement type: resolved independently per piece at assignment time (not at grant-creation time).
- Add `piece_enhance_every_n: int` and `piece_enhance_type: String` fields to `Keystone`; `_advance_enhancement_state` is extended to also evaluate keystone-level piece enhancers alongside technique `piece_enhancer`s.
- Add a queued-grant mechanism (`_enhancement_grant_queue`) so single-piece technique grants (Preparation, Backpedaling) wait for an active consumable grant to fully drain before applying.
- `PieceEnhancements` benefit functions (`honed_bonus`, `shield_charges`, `gilded_coins`, `amplified_multiplier`) accept per-cell/multiplier overrides so Refined/Armored/Polished/Overclocked can adjust magnitudes, and a counts-doubling path for Jack of All Trades.
- `AttackContext` gains `cleared_enh_counts: Dictionary` so techniques (Golden Blade) can react to which enhancement types were in the cleared cells.
- New one-shot round-state flag for Last Stand; round start now sums `start_shield` across owned keystones into the garbage-shield pool.

## Capabilities

### New Capabilities
(none — all changes extend existing capabilities)

### Modified Capabilities
- `piece-enhancements`: random enhancement resolution, keystone-level piece enhancers, queued grants, benefit-magnitude overrides (Refined/Armored/Polished/Overclocked/Jack of All Trades), `cleared_enh_counts` on AttackContext, Last Stand shield grant, `start_shield` round-start pool.
- `keystones`: new keystones (Extraordinary Bag, Charging Up, Jack of All Trades, Refined, Armored, Polished, Overclocked), redesigns (Midas Touch, Simple Shield, Legionnaire's Shield), removal of Sharpen and `per_technique_quad_bonus`/`garbage_flush_reduction`.
- `techniques`: new techniques (Sharpen, Barricade, The Best Defense, Last Stand, Preparation, Backpedaling, Golden Blade), removal of Keen Edge.
- `consumables`: new Lottery Ticket (random enhancement type).
- `economy`: removal of Midas Touch's overkill-to-coins conversion (replaced by its piece-enhancer redesign in `keystones`).

## Impact

- `game/resources/piece_enhancements.gd` — benefit function signatures, random type resolution
- `game/resources/keystone.gd` — new fields, removed fields
- `game/resources/round_config.gd` — removed `garbage_flush_reduction`
- `game/resources/attack_context.gd` — new `cleared_enh_counts` field
- `game/resources/technique_round_state.gd` — new Last Stand flag
- `game/scenes/game/run_manager.gd` — enhancement assignment/grant queue, shield pool reset, attack pipeline (Best Defense, Last Stand, Golden Blade context), removed `garbage_flush_reduction` handling and `per_technique_quad_bonus` evaluation
- `game/scenes/game/technique_evaluator.gd` — new effect types for Golden Blade, The Best Defense, Last Stand, Preparation, Backpedaling
- `game/resources/data/keystones/*.tres` — 7 new, 3 redesigned, 1 removed (`sharpen.tres`)
- `game/resources/data/techniques/*.tres` — 7 new (including replacement `sharpen.tres`), 1 removed (`keen_edge.tres`)
- `game/resources/data/consumables/*.tres` — 1 new, 4 renamed/rebalanced
- `game/autoloads/resource_registry.gd` — registry list updates
- `game/tests/unit/test_*.gd` — new/updated unit tests across all affected areas
