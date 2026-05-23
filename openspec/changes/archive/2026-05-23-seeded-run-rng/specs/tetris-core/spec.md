## MODIFIED Requirements

### Requirement: 7-bag piece randomiser
The game SHALL use a standard 7-bag randomiser: all 7 tetrominoes are shuffled into a bag and drawn in order; a new shuffled bag is prepared when the current bag is exhausted. All bag shuffles SHALL use the run-seeded PRNG from `RunState` rather than GDScript's global `randi()` so piece sequences are deterministic for a given seed.

#### Scenario: All pieces appear within 14 draws
- **WHEN** 14 pieces have been drawn
- **THEN** each of the 7 standard tetrominoes has appeared exactly twice

#### Scenario: Preview queue shows next pieces
- **WHEN** the board is active
- **THEN** the next 5 pieces in the queue are visible to the player (modifiable by Augments)

#### Scenario: Piece sequence is deterministic per seed
- **WHEN** two runs share the same seed
- **THEN** the bag draw order is identical in both runs from the first piece onwards
