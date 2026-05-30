## ADDED Requirements

### Requirement: AttackContext captures full attack snapshot
An `AttackContext` resource SHALL be constructed by `RunManager` after every attack-generating event. It SHALL contain:
- `lines_cleared: int`
- `combo: int` — combo count at the time of the clear
- `b2b: bool` — whether this clear continues a B2B chain
- `tspin: String` — `""`, `"mini"`, `"single"`, `"double"`, or `"triple"`
- `perfect_clear: bool`
- `garbage_sent: int` — base garbage before technique bonuses
- `board_height: int` — summit height from `TetrisBoard` telemetry
- `held_this_piece: bool` — whether the player used hold on the piece that caused this clear
- `piece_placement_count: int` — total pieces placed this round (for Escalation)
- `used_soft_drop: bool` — whether the piece was placed with soft drop

#### Scenario: AttackContext populated after T-spin Double
- **WHEN** the player performs a T-spin Double
- **THEN** the constructed `AttackContext` has `lines_cleared=2`, `tspin="double"`, `b2b=true` (if B2B active), and `garbage_sent=4`

### Requirement: TechniqueRoundState tracks per-round counters
A `TechniqueRoundState` object SHALL be created at the start of each round and reset to zero. It SHALL track:
- `clears_this_round: int`
- `attack_events_this_round: int`
- `total_garbage_sent: int`
- `tspin_count: int`
- `b2b_count: int`
- `perfect_clear_count: int`
- `consecutive_attacks_without_receiving: int`

These counters SHALL be updated by `RunManager` after each event.

#### Scenario: Counters start at zero
- **WHEN** a new round begins
- **THEN** all `TechniqueRoundState` counters are 0

#### Scenario: tspin_count increments on T-spin
- **WHEN** an attack event with `tspin != ""` is processed
- **THEN** `TechniqueRoundState.tspin_count` is incremented by 1

### Requirement: TechniqueEvaluator computes attack and economy bonuses
`TechniqueEvaluator` SHALL be a static GDScript class with two primary functions:

- `compute_attack_bonus(techniques: Array, ctx: AttackContext, round_state: TechniqueRoundState) -> int`
  Returns the total bonus attack from all equipped techniques for this event.

- `compute_economy_bonus(techniques: Array, ctx: AttackContext, round_state: TechniqueRoundState) -> int`
  Returns the total bonus coins from all equipped techniques for this event.

The evaluator SHALL be pure: it reads data, returns a result, and has no side effects.

#### Scenario: No techniques → zero bonus
- **WHEN** the techniques array is empty
- **THEN** both compute functions return 0

#### Scenario: Multiple flat-bonus techniques stack additively
- **WHEN** two techniques each grant +1 on T-spin Double and a T-spin Double occurs
- **THEN** `compute_attack_bonus` returns 2

#### Scenario: Unknown effect_type produces a warning and zero bonus
- **WHEN** a technique has an unrecognised `effect_type` value
- **THEN** `compute_attack_bonus` returns 0 for that technique and emits a push_warning

### Requirement: EvalResult carries attack delta, economy delta, and flags
`TechniqueEvaluator` SHALL return an `EvalResult` Dictionary from an optional combined function:
```
{ "attack_delta": int, "coins_delta": int, "flags": Array[String] }
```
`flags` contains string tokens for one-shot side effects (e.g., `"glass_cannon_triggered"`) that `RunManager` handles after receiving the result.

#### Scenario: EvalResult has correct keys
- **WHEN** `TechniqueEvaluator.evaluate(techniques, ctx, round_state)` is called
- **THEN** the returned Dictionary has keys `attack_delta`, `coins_delta`, and `flags`
