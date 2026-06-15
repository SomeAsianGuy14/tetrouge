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
The board SHALL emit a `piece_spawned` signal when a new piece spawns. RunManager SHALL assign at most one enhancement per spawned piece from its active grants and set it on the board's current piece. An active timed grant (consumable) SHALL take precedence over periodic grants (techniques); when multiple periodic grants fire on the same spawn, the first technique in the player's technique list wins. Periodic cadence counters SHALL advance on every spawn regardless of which grant wins.

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
