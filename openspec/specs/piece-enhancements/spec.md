## ADDED Requirements

### Requirement: Enhancement types and magnitudes
The system SHALL define four enhancement types with fixed per-cell benefit magnitudes: `honed` (+1 attack per cleared enhanced cell), `amplified` (+25% attack per cleared enhanced cell, applied after keystone multipliers, total multiplier clamped at ×3), `gilded` (+1 coin per cleared enhanced cell), and `reinforced` (+1 garbage-shield charge per cleared enhanced cell). Benefit math SHALL be implemented as pure static functions operating on a counts dictionary.

#### Scenario: Honed bonus is linear in cell count
- **WHEN** a clear contains 3 honed cells
- **THEN** the honed bonus function returns 3

#### Scenario: Amplified multiplier is linear and clamped
- **WHEN** a clear contains 2 amplified cells
- **THEN** the amplified multiplier function returns 1.5
- **WHEN** a clear contains 10 amplified cells
- **THEN** the amplified multiplier function returns 3.0 (clamped)

#### Scenario: Zero counts produce neutral benefits
- **WHEN** a clear contains no enhanced cells
- **THEN** honed bonus is 0, amplified multiplier is 1.0, gilded coins is 0, shield charges is 0

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

### Requirement: Hold preserves enhancement
`held_pieces` SHALL be paired with a parallel `held_enhancements` array (same indices, `""` = none). Holding the current piece SHALL move its enhancement (if any) into the matching `held_enhancements` slot alongside its type. Swapping a piece back out of hold SHALL restore its enhancement to the current piece. A piece returned from hold SHALL NOT emit `piece_spawned`, SHALL NOT consume an active grant, and SHALL NOT advance periodic grant cadence.

#### Scenario: Holding an enhanced piece preserves it
- **WHEN** the current piece carries the `gilded` enhancement and the player holds it
- **THEN** `held_enhancements` records `gilded` at the same index as the held piece type

#### Scenario: Swapping back restores the enhancement
- **WHEN** a held piece with the `honed` enhancement is swapped back into play
- **THEN** the current piece's enhancement becomes `honed` and no grant is consumed

#### Scenario: Hold swap does not advance grant cadence
- **WHEN** the player swaps pieces via hold while a periodic technique grant is active
- **THEN** the technique's spawn counter does not advance

### Requirement: Enhanced cell tracking on the board
The board SHALL maintain an enhancement layer (`enh_grid`) parallel to `grid` (`""` = none, else enhancement type id). Locking an enhanced piece SHALL stamp its cells into the layer. Row clears SHALL remove the corresponding layer rows and insert empty rows at top; garbage insertion SHALL shift the layer identically to the grid (garbage rows enter unenhanced); `clear_board()` SHALL reset the layer. The layer SHALL stay row-aligned with `grid` through any sequence of these operations.

#### Scenario: Lock stamps enhanced cells
- **WHEN** a honed-enhanced piece locks
- **THEN** each of its cells is marked `honed` in the enhancement layer at the same coordinates as the grid cells

#### Scenario: Clearing rows shifts the enhancement layer
- **WHEN** a row below an enhanced cell clears
- **THEN** the enhanced cell's layer entry moves down by one row, matching its grid cell

#### Scenario: Garbage insertion shifts the enhancement layer
- **WHEN** 2 garbage rows insert at the bottom while an enhanced cell is on the board
- **THEN** the enhanced cell's layer entry moves up by two rows, matching its grid cell, and the garbage rows have no enhancements

#### Scenario: Board reset clears the layer
- **WHEN** `clear_board()` runs (e.g. Blessed Stone)
- **THEN** the enhancement layer is fully empty

### Requirement: Benefits trigger when enhanced cells clear
When rows clear, the board SHALL capture per-type counts of enhanced cells in the cleared rows at lock time (before rows are removed), available identically with and without the line-clear delay. RunManager SHALL apply benefits exactly once per clear: gilded coins and reinforced charges immediately at clear evaluation; honed added to the attack sum before keystone flat bonuses and multipliers; amplified applied after keystone multipliers. Bonus attack events (`b2b`, `combo`) SHALL NOT re-trigger enhancement benefits. Cleared enhanced cells SHALL be consumed (removed with their rows).

#### Scenario: Honed adds attack before multipliers
- **WHEN** a quad clears 2 honed cells with base attack 4 and a ×2 quad keystone multiplier
- **THEN** the attack is (4 + 2) × 2 = 12

#### Scenario: Amplified applies after multipliers
- **WHEN** a quad clears 2 amplified cells with base attack 4 and a ×2 quad keystone multiplier
- **THEN** the attack is int(4 × 2 × 1.5) = 12

#### Scenario: Gilded pays coins once per clear
- **WHEN** a clear contains 3 gilded cells
- **THEN** the player gains 3 coins exactly once, even if the clear also generates b2b and combo attack events

#### Scenario: Suppressed clears still pay non-attack benefits
- **WHEN** a keystone suppresses the clear type (attack becomes 0) and the cleared rows contain gilded and reinforced cells
- **THEN** no attack is dealt but coins and shield charges are still granted

### Requirement: Garbage shield absorbs incoming lines
RunManager SHALL track a shield-charge pool for the current round, increased by cleared reinforced cells. When an enemy garbage wave is generated, the shield SHALL reduce the incoming line count before packets enter the pending-garbage queue, consuming one charge per line absorbed. Unused charges persist for later waves within the round and reset at round start.

#### Scenario: Shield absorbs a full wave
- **WHEN** the shield has 4 charges and a 3-line wave fires
- **THEN** no packet enters the queue and 1 charge remains

#### Scenario: Shield partially absorbs a wave
- **WHEN** the shield has 1 charge and a 3-line wave fires
- **THEN** a 2-line packet enters the queue and 0 charges remain

#### Scenario: Shield resets between rounds
- **WHEN** a new round starts
- **THEN** the shield pool is 0

### Requirement: Enhancement payout feedback
Enhancement payouts SHALL appear in the per-clear event popup cascade alongside technique and keystone events, one entry per enhancement type that contributed (e.g. "+3 Gilded"), using a distinct color from technique and keystone events.

#### Scenario: Payout popup on clear
- **WHEN** a clear consumes 3 gilded cells and 2 honed cells
- **THEN** the popup schedule contains one gilded entry and one honed entry for that clear

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
