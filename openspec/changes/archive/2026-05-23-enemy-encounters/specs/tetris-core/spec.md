## MODIFIED Requirements

### Requirement: Garbage row insertion is triggered by the enemy attack timer
Garbage row insertion SHALL be driven by `RoundConfig.effective_garbage_interval` for every round type, not exclusively by a boss modifier. The timer is managed by `RunManager` and resets after each insertion. This replaces the previous boss-modifier-only garbage mechanism.

#### Scenario: Garbage fires in non-boss rounds
- **WHEN** a Small, Big, or Elite round is active and the effective garbage interval elapses
- **THEN** one garbage row is inserted at the bottom of the board

#### Scenario: Garbage fires in boss rounds
- **WHEN** a Boss round is active and the effective garbage interval elapses
- **THEN** one garbage row is inserted, the same as in any other round

#### Scenario: Garbage row has one random gap
- **WHEN** a garbage row is inserted
- **THEN** exactly one cell in the row is empty; all other cells are filled with garbage color; the gap position is determined by the run PRNG
