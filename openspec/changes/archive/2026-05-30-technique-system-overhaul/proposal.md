## Why

The existing 10 techniques are shallow and largely interchangeable, offering little meaningful build diversity across a run. Replacing them with 53 tag-organized techniques — alongside a new TechniqueEvaluator architecture and capacity-limited slots — gives players a wide enough pool to create distinct, synergistic builds while keeping per-run variety high.

## What Changes

- **BREAKING** Remove all 10 existing technique `.tres` data files and the flat-bonus fields they relied on
- **BREAKING** Replace `Technique` resource schema: add `tags: Array[String]`, `effect_type: String`, and structured effect parameters; remove legacy flat-bonus fields
- Add 52 new technique `.tres` data files covering general, tetris, t-spin, combo, speed, precision, risk, economy, utility, and garbage categories
- Add `TechniqueEvaluator` static class that computes per-attack bonuses from an `AttackContext` and per-round state from a `TechniqueRoundState`
- Add `AttackContext` resource (lines cleared, combo, b2b, t-spin, perfect clear, garbage sent, board height, holes, etc.)
- Add `TechniqueRoundState` resource (per-round counters used by techniques with cumulative effects)
- Add `technique_capacity` to `RunState`: starts at 4, increases by 1 each stage (max 8 at stage 5)
- Add `Whirl` keystone (spins generate attack regardless of line clear)
- Add board telemetry to `TetrisBoard`: hole count, column heights, summit height (needed by board-state techniques)
- Wire lifecycle hooks in `RunManager` for special techniques (e.g., Burning Board on-clear, Glass Cannon on-receive, Flash Step on-tspin, Counter Strike, economy hooks)
- Enforce `technique_capacity` in shop purchase flow

## Capabilities

### New Capabilities

- `technique-pool`: the 53 technique definitions — data schema and `.tres` files
- `technique-capacity`: slot limit starting at 4, scaling +1 per stage
- `technique-evaluator`: `TechniqueEvaluator` static class + `AttackContext` + `TechniqueRoundState`
- `board-telemetry`: `TetrisBoard` exposes hole count, column heights, and summit height
- `whirl-keystone`: new keystone that grants attack on any spin (no line clear required)

### Modified Capabilities

- `techniques`: requirements change entirely — pool replaced, schema changes, evaluation logic moves to TechniqueEvaluator
- `shop-system`: must enforce `technique_capacity` limit at purchase time

## Impact

- `game/resources/technique.gd` — schema rewrite
- `game/resources/data/techniques/*.tres` — all 10 deleted, 53 new files added
- `game/scenes/tetris/tetris_board.gd` — add telemetry properties
- `game/scenes/game/run_manager.gd` — integrate TechniqueEvaluator, add lifecycle hooks, enforce capacity
- `game/autoloads/run_state.gd` — add `technique_capacity`
- New files: `TechniqueEvaluator`, `AttackContext`, `TechniqueRoundState`
- `game/scenes/screens/shop.gd` — capacity enforcement
- `game/tests/unit/` — new test files for evaluator, capacity, board telemetry
