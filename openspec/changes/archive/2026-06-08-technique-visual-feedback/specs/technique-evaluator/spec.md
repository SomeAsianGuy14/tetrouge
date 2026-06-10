## MODIFIED Requirements

### Requirement: TechniqueEvaluator computes attack and economy bonuses
`TechniqueEvaluator` SHALL be a static GDScript class with two primary functions:

- `compute_attack_bonus(techniques: Array, ctx: AttackContext, round_state: TechniqueRoundState) -> int`
  Returns the total bonus attack from all equipped techniques for this event.

- `compute_economy_bonus(techniques: Array, ctx: AttackContext, round_state: TechniqueRoundState) -> int`
  Returns the total bonus coins from all equipped techniques for this event.

The evaluator SHALL be pure: it reads data, returns a result, and has no side effects.

The `_apply_keystone_flat_bonuses` check for quad-applicable techniques SHALL use `"quad" in t.tags` (not `"tetris" in t.tags`) to match the renamed tag value.

`evaluate()` SHALL return a dict with keys: `"attack_delta"` (int), `"coins_delta"` (int), `"flags"` (Array), and `"events"` (Array[Dictionary]). Each entry in `"events"` SHALL have the form `{name: String, attack: int, coins: int}` and SHALL only be included when the technique contributed a non-zero attack or coins value. Existing consumers that only read `"attack_delta"`, `"coins_delta"`, and `"flags"` are unaffected.

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

#### Scenario: events array contains entry for each contributing technique
- **WHEN** two techniques each contribute non-zero attack for a clear
- **THEN** `evaluate()["events"]` contains exactly 2 entries, each with the technique's `display_name`, its attack delta, and its coins delta

#### Scenario: events array excludes zero-contribution techniques
- **WHEN** one technique contributes +2 attack and another contributes 0
- **THEN** `evaluate()["events"]` contains exactly 1 entry (for the contributing technique)

#### Scenario: events array is empty when no techniques contribute
- **WHEN** the techniques array is empty or all techniques contribute zero
- **THEN** `evaluate()["events"]` is an empty array
