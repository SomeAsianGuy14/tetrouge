## ADDED Requirements

### Requirement: Ascension selector appears after New Run when game has been beaten
When the player selects "New Run" from the main menu and `ProfileSave.highest_beaten >= 0`, the system SHALL display an ascension selector before starting the run. If `highest_beaten == -1` the selector SHALL be skipped and the run starts at level 0.

#### Scenario: Selector shown after first victory
- **WHEN** the player has beaten the game at least once (`highest_beaten >= 0`)
- **AND** the player presses "New Run"
- **THEN** the ascension selector SHALL appear before the run begins

#### Scenario: Selector skipped before first victory
- **WHEN** the player has never beaten the game (`highest_beaten == -1`)
- **AND** the player presses "New Run"
- **THEN** the run SHALL start immediately at ascension level 0

### Requirement: Ascension selector shows all unlocked levels
The selector SHALL display levels 0 through `ProfileSave.highest_beaten + 1` (inclusive). Each button SHALL display the level number and a summary of cumulative modifiers active at that level. The selector SHALL default to the highest available level.

#### Scenario: Only unlocked levels are selectable
- **WHEN** `highest_beaten` is 2
- **THEN** levels 0, 1, 2, and 3 SHALL be available for selection
- **THEN** levels 4, 5, and 6 SHALL NOT be displayed or selectable

#### Scenario: Default selection is highest available
- **WHEN** the ascension selector opens
- **THEN** the highest available level SHALL be pre-selected

### Requirement: Selecting an ascension level sets it for the run
Confirming a level in the selector SHALL set `AscensionManager.current_level` and then start the run. The level SHALL persist for the entire run and not be changeable mid-run.

#### Scenario: Selected level applied to run
- **WHEN** the player selects level 3 and confirms
- **THEN** `AscensionManager.current_level` SHALL equal 3
- **THEN** the run SHALL start with level 3 modifiers active

### Requirement: Beating the game advances the highest beaten level
When the player completes stage 5 at ascension level N, the system SHALL call `ProfileSave.record_victory(N)`, updating `highest_beaten` to `max(highest_beaten, N)` and making level N+1 available.

#### Scenario: New highest unlocks next level
- **WHEN** the player beats the game at their current highest level N
- **THEN** `highest_beaten` SHALL become N
- **THEN** ascension level N+1 SHALL become available in the selector on the next run

#### Scenario: Beating a lower level does not unlock new content
- **WHEN** the player beats the game at a level below their `highest_beaten`
- **THEN** no new levels SHALL be unlocked

### Requirement: AscensionManager current level resets to 0 between runs
When `AscensionManager` is initialised or `RunState.reset()` is called at the start of a new run, `current_level` SHALL revert to 0 so a crash or early exit does not carry over a stale level.

#### Scenario: Level resets on new run
- **WHEN** a new run starts without going through the selector (e.g. after a crash recovery)
- **THEN** `AscensionManager.current_level` SHALL be 0
