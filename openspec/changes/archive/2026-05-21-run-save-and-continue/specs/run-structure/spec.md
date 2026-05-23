## ADDED Requirements

### Requirement: Run lifecycle includes save and delete events
A run SHALL be persisted to disk after each completed round (when the shop is closed), and deleted from disk when the run concludes (victory or failure) or is abandoned via New Run. These events are part of the run lifecycle and SHALL not alter any in-memory game state.

#### Scenario: Run saved after first shop visit
- **WHEN** the player exits the shop for the first time in a run
- **THEN** the run state is saved to disk before the next round begins

#### Scenario: Run deleted on natural conclusion
- **WHEN** the run ends in victory or failure
- **THEN** the save file is removed so the main menu no longer offers a Continue option
