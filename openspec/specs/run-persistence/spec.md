## ADDED Requirements

### Requirement: Run state is saved after each completed round
The game SHALL write a save file (`user://save.cfg`) each time the player exits the shop after completing a round. The save SHALL include the run PRNG state (seed and counter position) in addition to all existing run fields, so that continuing a saved run produces deterministic future outcomes. A save is NOT created during the first round of a run until that round is completed and the shop is visited. This ensures Continue is only available when meaningful progress has been made.

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

### Requirement: Save is deleted when a run ends or a new run begins
The save file SHALL be deleted on run victory, run failure, and when the player starts a New Run from the main menu. After deletion, no continue option SHALL be available.

#### Scenario: Save deleted on victory
- **WHEN** the player completes the final stage and sees the victory screen
- **THEN** `user://save.cfg` no longer exists

#### Scenario: Save deleted on failure
- **WHEN** a round ends in failure (timer expired or board blocked out)
- **THEN** `user://save.cfg` no longer exists

#### Scenario: Save deleted on New Run
- **WHEN** the player clicks New Run on the main menu
- **THEN** any existing `user://save.cfg` is deleted before the new run begins

### Requirement: Main menu shows a Continue button when a save exists
The main menu SHALL display a **Continue** button when `user://save.cfg` is present. The button SHALL be hidden when no save exists. Clicking Continue SHALL restore the full run state and resume from the saved round.

#### Scenario: Continue button visible with save
- **WHEN** the main menu loads and `user://save.cfg` exists
- **THEN** the Continue button is visible

#### Scenario: Continue button hidden without save
- **WHEN** the main menu loads and no save file exists
- **THEN** the Continue button is not visible

#### Scenario: Continuing a run resumes the correct round
- **WHEN** the player clicks Continue
- **THEN** RunState and Economy are restored from the save, and the game begins the saved round without resetting any state
