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
Every round SHALL have periodic garbage row insertions driven by the assigned enemy's garbage interval scaled by stage. The effective interval SHALL be computed as `base_interval × max(0.5, 1.0 - (stage - 1) × 0.1)`, making attacks progressively faster at higher stages with a floor at 50% of the base rate.

On each timer expiry, one row SHALL be **added to the attack buffer** (`pending_garbage += 1`) rather than inserted directly into the board. The buffer is flushed to the board when the player locks a piece (see attack-buffer spec).

#### Scenario: Garbage fires at the effective interval
- **WHEN** the elapsed time since the last garbage event reaches the effective interval
- **THEN** `pending_garbage` is incremented by 1 and the timer resets (no immediate board insertion)

#### Scenario: Garbage scales faster at higher stages
- **WHEN** the same enemy appears in Stage 1 and Stage 5
- **THEN** the Stage 5 effective interval is 60% of the Stage 1 interval

#### Scenario: Buffered garbage delivers on piece lock
- **WHEN** a garbage row has been added to the buffer and the player locks a piece
- **THEN** it is inserted into the board during the lock flush (assuming no player counter-attack cancelled it)

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
