## MODIFIED Requirements

### Requirement: Run state is saved after each completed round
The game SHALL write a save file (`user://save.cfg`) each time the player exits the shop after completing a round. The save SHALL include the run PRNG state (seed and counter position) in addition to all existing run fields, so that continuing a saved run produces deterministic future outcomes. A save is NOT created during the first round of a run until that round is completed and the shop is visited.

#### Scenario: Save written after first round
- **WHEN** the player completes a round and closes the shop for the first time
- **THEN** `user://save.cfg` is created with the current stage, round index, coin balance, all owned item IDs, and the current PRNG seed and state

#### Scenario: Save updated on each subsequent round
- **WHEN** the player closes the shop after any subsequent round
- **THEN** `user://save.cfg` is overwritten with the updated run state including the current PRNG counter position

#### Scenario: No save while in first round
- **WHEN** the player quits to the main menu during the first round (before completing it)
- **THEN** no save file is created and the Continue button is not shown

#### Scenario: PRNG state restored on continue
- **WHEN** the player continues a saved run
- **THEN** the PRNG is restored to the exact seed and counter position saved, so future draws match what they would have been in an uninterrupted session
