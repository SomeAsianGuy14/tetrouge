## ADDED Requirements

### Requirement: Side Strike effect type
The evaluator SHALL support a `"side_strike"` effect type. It SHALL return `params.bonus` (default 1) when `ctx.lines_cleared == 4` and `ctx.locked_col == 0` or `ctx.locked_col >= board_width - 4` (where `board_width = 10`, so rightmost threshold is col 6). It SHALL return 0 otherwise.

#### Scenario: Side Strike fires on left-edge Quad
- **WHEN** the player clears 4 lines with `locked_col = 0`
- **THEN** `compute_attack_bonus` returns the technique's bonus value

#### Scenario: Side Strike fires on right-edge Quad
- **WHEN** the player clears 4 lines with `locked_col = 6`
- **THEN** `compute_attack_bonus` returns the technique's bonus value

#### Scenario: Side Strike does not fire on centre Quad
- **WHEN** the player clears 4 lines with `locked_col = 3`
- **THEN** `compute_attack_bonus` returns 0 for the Side Strike technique

#### Scenario: Side Strike does not fire on non-Quad clear
- **WHEN** `lines_cleared = 2` and `locked_col = 0`
- **THEN** `compute_attack_bonus` returns 0 for the Side Strike technique

## MODIFIED Requirements

### Requirement: TechniqueEvaluator computes attack and economy bonuses
`TechniqueEvaluator` SHALL be a static GDScript class with two primary functions:

- `compute_attack_bonus(techniques: Array, ctx: AttackContext, round_state: TechniqueRoundState) -> int`
  Returns the total bonus attack from all equipped techniques for this event.

- `compute_economy_bonus(techniques: Array, ctx: AttackContext, round_state: TechniqueRoundState) -> int`
  Returns the total bonus coins from all equipped techniques for this event.

The evaluator SHALL be pure: it reads data, returns a result, and has no side effects.

The `_apply_keystone_flat_bonuses` check for quad-applicable techniques SHALL use `"quad" in t.tags` (not `"tetris" in t.tags`) to match the renamed tag value.

#### Scenario: No techniques → zero bonus
- **WHEN** the techniques array is empty
- **THEN** both compute functions return 0

#### Scenario: Multiple flat-bonus techniques stack additively
- **WHEN** two techniques each grant +1 on T-spin Double and a T-spin Double occurs
- **THEN** `compute_attack_bonus` returns 2

#### Scenario: Unknown effect_type produces a warning and zero bonus
- **WHEN** a technique has an unrecognised `effect_type` value
- **THEN** `compute_attack_bonus` returns 0 for that technique and emits a push_warning

#### Scenario: Quad-tagged technique counts for per_technique_quad_bonus
- **WHEN** a keystone with `per_technique_quad_bonus = 2` is active and the player owns 2 techniques with tag `"quad"`
- **THEN** the flat bonus from that keystone is 4 (2 per technique × 2 techniques)
