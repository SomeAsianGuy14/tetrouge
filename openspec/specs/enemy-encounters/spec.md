## ADDED Requirements

### Requirement: Every round is assigned an enemy from a seeded tier pool
At round build time, the game SHALL assign one enemy to the round by drawing from a tier-specific pool using the run PRNG. The tier is determined by round index: Small (0), Big (1), Elite (2), Boss (3). Common tier pools may produce the same enemy in multiple rounds across a run; boss tier enemies SHALL NOT repeat within a run.

#### Scenario: Common enemy drawn from correct tier pool
- **WHEN** a Small, Big, or Elite round begins
- **THEN** the assigned enemy is drawn from the corresponding tier pool using the run PRNG

#### Scenario: Boss enemy is unique per run
- **WHEN** a Boss round begins
- **THEN** the assigned enemy is drawn from the boss pool excluding any bosses already used in the current run; if all have been used the full pool is eligible again

#### Scenario: Enemy assignment is deterministic per seed
- **WHEN** a run is continued from a save
- **THEN** the same enemy appears in each round as would have appeared in an uninterrupted session

### Requirement: Enemy data model
Each enemy SHALL be defined by a resource with the following fields: unique id, display name, placeholder color, optional sprite texture (null = show colored rectangle), tier, base garbage interval in seconds, and an optional board-rule ability (BossModifier reference, null for common enemies).

#### Scenario: Common enemy has no board-rule ability
- **WHEN** a common (non-boss) enemy is assigned to a round
- **THEN** no board-rule modification is applied to RoundConfig beyond the garbage interval

#### Scenario: Boss enemy ability is applied to RoundConfig
- **WHEN** a boss enemy with a non-null ability is assigned
- **THEN** the ability's effects are applied to RoundConfig before the round starts

### Requirement: Garbage attacks occur every round
Every round SHALL have periodic garbage attacks driven by the assigned enemy's tier and the current stage. Each attack fires after a randomised interval drawn from a tier-specific range, and delivers a randomised number of garbage rows drawn from a tier-specific lines range. Both ranges scale with stage. The next interval and line count are re-rolled independently after every attack.

Tier base ranges (before stage scaling):

| Tier   | Interval range | Lines range |
|--------|---------------|-------------|
| Normal (Small / Big / Elite) | 15 – 25s | 1 – 3 |
| Boss   | 10 – 16s      | 2 – 4       |

Stage scaling:
- **Interval**: both min and max are multiplied by `max(0.5, 1.0 - (stage - 1) × 0.1)`, making attacks progressively faster with a floor at 50% of the base rate.
- **Lines**: both min and max receive an additive bonus of `floor((stage - 1) / 2)`, adding +1 at stages 3–4 and +2 at stage 5.

All garbage rows from a single attack SHALL share the same hole column, chosen randomly at attack fire time.

Garbage rows are added to the attack buffer (`pending_garbage`) rather than inserted directly. The buffer is flushed to the board when the player locks a piece (see attack-buffer spec).

#### Scenario: Attack fires within the randomised interval window
- **WHEN** the enemy attack timer reaches the current target interval
- **THEN** the attack fires, `pending_garbage` is increased by the rolled line count, and a new target interval is drawn from the tier range

#### Scenario: Multi-row attack delivers aligned garbage
- **WHEN** an attack delivers more than one garbage row
- **THEN** all rows share the same hole column so the player can clear them with a single well-placed piece

#### Scenario: Interval re-rolled independently after each attack
- **WHEN** an attack fires
- **THEN** the next target interval is a new independent random draw from the tier range (not the same value as the previous attack)

#### Scenario: Line count scales up at higher stages
- **WHEN** the same enemy tier appears in Stage 1 and Stage 5
- **THEN** the Stage 5 minimum and maximum line counts are each 2 higher than the Stage 1 values

#### Scenario: Interval scales faster at higher stages
- **WHEN** the same enemy tier appears in Stage 1 and Stage 5
- **THEN** the Stage 5 effective interval range is 60% of the Stage 1 range

#### Scenario: Buffered garbage delivers on piece lock
- **WHEN** garbage rows have been added to the buffer and the player locks a piece
- **THEN** they are inserted into the board during the lock flush (assuming no player counter-attack cancelled them)

### Requirement: Enemy roster for launch
The following enemies SHALL be available at launch:

**Small tier** (base garbage interval 20s):
- Slimeling (green), Cave Bat (dark purple), Rock Crawler (brown)

**Big tier** (base garbage interval 17s):
- Iron Shambler (steel blue), Rust Golem (orange-brown), Hex Wraith (teal)

**Elite tier** (base garbage interval 15s):
- Void Knight (deep purple), The Warden (dark red), Crimson Drake (crimson)

**Boss tier** (base garbage interval 12s, each with a board-rule ability):
- The Enforcer (ability: time reduced to 45s)
- The Narrow (ability: board width reduced to 8)
- The Purge (ability: only triples/tetrises/t-spins count)
- The Surgeon (ability: only t-spins count)
- The Silencer (ability: B2B disabled)
- The Blinder (ability: preview reduced to 1)
- The Void (ability: hold disabled)

#### Scenario: All tier pools are non-empty
- **WHEN** a run begins
- **THEN** each of the four tier pools contains at least one enemy available for draw

## ADDED Requirements

### Requirement: Daze keystone stuns the enemy on quad clears
When the player owns the Daze keystone and a `"tetris"` attack event is processed, `RunManager` SHALL extend the enemy garbage timer by `daze_stun_seconds` (2.0 seconds). This delays the next garbage row from entering the attack buffer.

#### Scenario: Quad clear extends enemy timer by 2 seconds
- **WHEN** Daze is owned and the player sends a quad
- **THEN** the enemy garbage timer's remaining time is increased by 2 seconds

#### Scenario: Daze does not fire on non-quad clears
- **WHEN** Daze is owned and the player sends a T-spin double
- **THEN** the enemy garbage timer is not extended

#### Scenario: Multiple consecutive quads stack the stun
- **WHEN** Daze is owned and the player sends two quads in succession before the timer fires
- **THEN** the enemy timer is extended by 4 seconds total (2 seconds per quad)
