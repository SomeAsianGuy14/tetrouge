## MODIFIED Requirements

### Requirement: Spawn-time enhancement assignment
The board SHALL emit a `piece_spawned` signal when a new piece spawns. RunManager SHALL assign at most one enhancement per spawned piece from its active grants and set it on the board's current piece. An active timed grant SHALL take precedence over periodic grants (techniques and keystones); when multiple periodic grants fire on the same spawn, the first one wins, checking techniques (in list order) before keystones (in list order). Periodic cadence counters SHALL advance on every spawn regardless of which grant wins.

The active timed grant SHALL be backed by a queue of pending grants. When the active grant's remaining count reaches 0, the next entry in the queue (if any) SHALL become the active grant on the following spawn.

#### Scenario: Timed grant wins over periodic grant
- **WHEN** a timed grant (gilded, 5 pieces remaining) is active and a periodic grant (honed, every 4th piece) fires on the same spawn
- **THEN** the piece is enhanced with gilded
- **AND** the periodic counter still advances

#### Scenario: Periodic grant fires every Nth spawn
- **WHEN** a technique grants an enhancement every 4th piece and 8 pieces spawn with no timed grant active
- **THEN** exactly the 4th and 8th pieces are enhanced

#### Scenario: Timed grant decrements and expires
- **WHEN** a timed grant has 2 pieces remaining and 3 pieces spawn
- **THEN** the first 2 pieces are enhanced and the 3rd is not

#### Scenario: Keystone periodic grant fires every Nth spawn
- **WHEN** a keystone grants an enhancement every 7th piece and 7 pieces spawn with no timed grant active and no competing technique grant
- **THEN** the 7th piece is enhanced with the keystone's enhancement type

#### Scenario: Queued grant activates after the active grant drains
- **WHEN** a timed grant (gilded, 1 piece remaining) is active and a second grant (honed, 1 piece) is already queued
- **THEN** the next spawn is enhanced gilded and consumes the active grant
- **AND** the spawn after that is enhanced honed, now drawn from the promoted queued grant

## ADDED Requirements

### Requirement: Random enhancement type resolves independently per piece
`"random"` SHALL be a valid enhancement type for technique `piece_enhancer` params, keystone piece-enhancer fields, and consumable `enhance_type`. Whenever an assignment resolves to `"random"`, RunManager SHALL immediately replace it with one of `honed`, `amplified`, `gilded`, `reinforced` chosen independently at that spawn (not fixed once for the whole grant or cadence).

#### Scenario: Each piece in a multi-piece random grant rolls independently
- **WHEN** a consumable grants `enhance_type = "random"` for the next 3 pieces
- **THEN** each of the 3 spawned pieces independently resolves to one of `honed`, `amplified`, `gilded`, `reinforced`, and they are not required to match each other

#### Scenario: A periodic random grant rolls a fresh type each time it fires
- **WHEN** a keystone grants `piece_enhance_type = "random"` every 7th piece and it fires twice over the course of a round
- **THEN** each of the two enhanced pieces independently resolves to one of the four enhancement types

### Requirement: Benefit magnitude modifiers from keystones
`PieceEnhancements.honed_bonus`, `shield_charges`, `gilded_coins`, and `amplified_multiplier` SHALL accept an optional per-cell magnitude parameter (defaulting to the existing constants). RunManager SHALL compute the effective per-cell magnitude for a clear by adding, for each owned keystone, that keystone's corresponding bonus field (`honed_bonus_per_cell`, `reinforced_bonus_per_cell`, `gilded_bonus_per_cell`, `amplified_bonus_per_cell`) to the base constant. Additionally, if any owned keystone has `double_enhancement_benefits = true`, RunManager SHALL double every entry in the cleared-cell counts dictionary before computing any of these benefits.

#### Scenario: Refined adds 2 attack per honed cell
- **WHEN** a clear contains 2 honed cells and the player owns a keystone with `honed_bonus_per_cell = 2`
- **THEN** the honed attack bonus is `2 * (1 + 2) = 6`

#### Scenario: Armored adds 2 shield per reinforced cell
- **WHEN** a clear contains 1 reinforced cell and the player owns a keystone with `reinforced_bonus_per_cell = 2`
- **THEN** the shield charge gain is `1 * (1 + 2) = 3`

#### Scenario: Polished adds 1 coin per gilded cell
- **WHEN** a clear contains 3 gilded cells and the player owns a keystone with `gilded_bonus_per_cell = 1`
- **THEN** the coin gain is `3 * (1 + 1) = 6`

#### Scenario: Overclocked increases the amplified per-cell rate by 50%
- **WHEN** a clear contains 2 amplified cells and the player owns a keystone with `amplified_bonus_per_cell = 0.125`
- **THEN** the amplified multiplier is `1.0 + 2 * (0.25 + 0.125) = 1.75`

#### Scenario: Jack of All Trades doubles all enhancement benefits on a clear
- **WHEN** a clear contains 2 honed cells and 1 gilded cell, and the player owns a keystone with `double_enhancement_benefits = true`
- **THEN** the honed attack bonus and gilded coin gain are computed from counts of 4 honed and 2 gilded (each doubled), before any other per-cell modifiers are applied

#### Scenario: Jack of All Trades does not affect spawn-time assignment
- **WHEN** the player owns a keystone with `double_enhancement_benefits = true` and a technique grants an enhancement every 4th piece
- **THEN** the spawn cadence and assignment are unaffected; only clear-time benefit counts are doubled

### Requirement: Additional garbage-shield sources
The garbage-shield charge pool (`_garbage_shield`) SHALL gain charges from three additional sources beyond Reinforced cell clears:
1. At round start, RunManager SHALL add `start_shield` summed across all owned keystones to the pool (replacing the previous reset-to-zero behavior when any keystone grants `start_shield`).
2. The first time in a round that a piece locks with board height at or above 80% (`board_height >= 16` of 20), if the player owns a technique with `effect_type = "height_shield"`, RunManager SHALL add that technique's configured shield amount to the pool exactly once for the round.
3. On a clear, if the player owns a technique with `effect_type = "attack_to_shield"`, RunManager SHALL add `floor(final_attack * pct)` to the pool, where `final_attack` is the fully-modified attack value for that clear and `pct` is the technique's configured fraction. This is in addition to the full attack damage being dealt.

#### Scenario: Round start seeds the shield pool from start_shield
- **WHEN** the player owns a keystone with `start_shield = 5` and a new round begins
- **THEN** `_garbage_shield` is 5 at the start of the round (before any clears)

#### Scenario: Last Stand grants shield once per round at high board height
- **WHEN** the player owns a technique with `effect_type = "height_shield", params = {"threshold_pct": 0.8, "shield": 10}` and a piece locks with board height at 17 (85%)
- **THEN** `_garbage_shield` increases by 10
- **AND** if a later piece in the same round locks at or above 80% height again, the pool does not increase further from this technique

#### Scenario: The Best Defense converts a fraction of attack to shield without reducing damage
- **WHEN** the player owns a technique with `effect_type = "attack_to_shield", params = {"pct": 0.25}` and a clear deals 12 final attack
- **THEN** the enemy takes 12 damage
- **AND** `_garbage_shield` increases by `floor(12 * 0.25) = 3`

### Requirement: AttackContext exposes cleared enhancement counts
`AttackContext` SHALL include a `cleared_enh_counts: Dictionary` field, populated by RunManager from the pending enhancement counts of the cells consumed by the current clear, before `TechniqueEvaluator.evaluate` is called.

#### Scenario: cleared_enh_counts reflects the clear's enhanced cells
- **WHEN** a clear consumes 2 gilded cells and 1 honed cell
- **THEN** `ctx.cleared_enh_counts` is `{"gilded": 2, "honed": 1}`

#### Scenario: cleared_enh_counts is empty for a clear with no enhanced cells
- **WHEN** a clear consumes no enhanced cells
- **THEN** `ctx.cleared_enh_counts` is an empty dictionary
