## ADDED Requirements

### Requirement: Run failure screen properly starts a fresh run when the player chooses to play again
The failure screen SHALL provide a "New Run" action that fully resets run state and economy and begins a new run, equivalent to selecting New Run from the main menu.

#### Scenario: New Run resets state and starts play
- **WHEN** the player clicks "New Run" on the failure screen
- **THEN** the save file is deleted, run state is fully reset, economy is reset, and a new run begins from Round 1 of Ante 1

#### Scenario: New Run button label communicates permadeath semantics
- **WHEN** the failure screen is displayed
- **THEN** the restart action is labelled "New Run", not "Try Again", to make clear the previous run is over and a fresh run is starting
