## ADDED Requirements

### Requirement: Stats screen is accessible from the main menu
The main menu SHALL include a "Stats" button that opens the stats screen. The stats screen opens as an overlay (added as a child of the main menu scene) and is dismissed by a "Close" button that removes it, returning focus to the main menu beneath.

#### Scenario: Stats button opens the screen
- **WHEN** the player presses the "Stats" button on the main menu
- **THEN** the stats screen SHALL appear over the main menu

#### Scenario: Close button dismisses the screen
- **WHEN** the player presses "Close" on the stats screen
- **THEN** the stats screen SHALL be removed and the main menu SHALL be visible and interactive

#### Scenario: Stats button hidden when no data exists
- **WHEN** no runs have been played (runs_completed == 0 and highest_beaten == -1)
- **THEN** the Stats button SHALL still be visible (stats screen shows zeroes; this is not a first-run-only feature)

### Requirement: Stats screen displays career, personal best, and lifetime sections
The stats screen SHALL display three sections of data read from ProfileSave:

**Career**: Runs Played (`runs_completed`), Victories (`victories`), Best Ascension (`highest_beaten`; shown as "A0"–"A6", or "—" if never beaten).

**Personal Bests**: Best single-run damage (`best_single_run_damage`), Longest Combo (`highest_combo_chain`), Longest B2B (`highest_b2b`).

**Lifetime Totals**: Total Damage (`total_damage`), Total Quads (`total_quads`), Total T-Spins (`total_tspins`).

#### Scenario: All sections show correct values
- **WHEN** the player opens the stats screen after 12 victories and a best combo of 14
- **THEN** the Career section SHALL show victories = 12
- **THEN** the Personal Bests section SHALL show Longest Combo = 14

#### Scenario: Unbeaten game shows dash for Best Ascension
- **WHEN** highest_beaten == -1
- **THEN** Best Ascension SHALL display "—" rather than a number

#### Scenario: Stats reflect latest ProfileSave data
- **WHEN** the player just finished a run and returns to the main menu
- **THEN** opening the stats screen SHALL show values updated to include the completed run
