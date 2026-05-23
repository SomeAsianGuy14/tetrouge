## ADDED Requirements

### Requirement: Boss modifier selection is deterministic per seed
The boss modifier drawn for each Boss Blind round SHALL be selected using the run-seeded PRNG. Reloading the game before a Boss Blind SHALL produce the same modifier as would have appeared without the reload.

#### Scenario: Same modifier appears after reload
- **WHEN** a run is saved before a Boss Blind, the game is closed and reopened, and the player continues
- **THEN** the same boss modifier is applied as would have been selected in an uninterrupted session

### Requirement: Augment pool draw is deterministic per seed
The three Augments offered at the end of each Boss Blind SHALL be selected using the run-seeded PRNG. Reloading the game before the augment selection screen SHALL produce the same three offerings.

#### Scenario: Same augments offered after reload
- **WHEN** a run is saved before an augment offering, the game is closed and reopened, and the player continues
- **THEN** the same three Augments are presented as would have appeared without the reload
