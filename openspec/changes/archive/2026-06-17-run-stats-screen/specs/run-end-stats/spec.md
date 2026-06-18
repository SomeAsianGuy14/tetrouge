## ADDED Requirements

### Requirement: Run-end screen displays per-run stats
Both the victory and failure run-end screens SHALL display a stats summary for the completed run, including: total damage dealt, best combo chain reached, best B2B chain reached, number of quads landed, number of T-spins landed, and number of perfect clears achieved.

#### Scenario: Victory screen shows all stat rows
- **WHEN** the player wins a run
- **THEN** the victory screen SHALL display total_damage, highest_combo_chain, highest_b2b, quads, tspins, perfect_clears, run_time, and most_common_clear from the run's RunStats

#### Scenario: Failure screen shows all stat rows
- **WHEN** a run ends in failure
- **THEN** the failure screen SHALL display the same stat rows populated from the run's RunStats
- **THEN** the failure screen SHALL also display the ante and round name at which the run ended

#### Scenario: Zero values are shown
- **WHEN** a stat has a value of zero (e.g. the player landed no T-spins)
- **THEN** that row SHALL still appear with a value of 0 rather than being hidden

### Requirement: Run-end screen shows personal best markers
For each displayed stat, if the current run's value exceeds the player's previous best stored in ProfileSave, the stat row SHALL display a "★ PB" marker. PB status is computed before ProfileSave accumulation so the marker reflects the previous record, not the new one.

#### Scenario: New personal best is marked
- **WHEN** a run ends with highest_combo_chain = 14
- **AND** the stored ProfileSave.highest_combo_chain was 10 before this run
- **THEN** the combo row SHALL display "★ PB"

#### Scenario: Tied personal best is not marked
- **WHEN** a run ends with highest_combo_chain = 10
- **AND** the stored ProfileSave.highest_combo_chain was 10
- **THEN** the combo row SHALL NOT display "★ PB"

#### Scenario: No PB marker when stat is lower
- **WHEN** a run ends with total_damage = 500
- **AND** ProfileSave.best_single_run_damage was 1000
- **THEN** the damage row SHALL NOT display "★ PB"

#### Scenario: PB markers appear on failure screens too
- **WHEN** a run ends in failure
- **AND** the run set a new best combo
- **THEN** the failure screen SHALL display "★ PB" on the combo row

### Requirement: Run-end screen displays total run time
The run-end screen SHALL display the total active round time for the completed run, drawn from `RunStats.run_time` (a cumulative sum of `round_timer` at the end of each round). Time SHALL be formatted as MM:SS (e.g. "12:34"). Time in shops, on screens between rounds, or while paused is not included.

#### Scenario: Run time shown in MM:SS format
- **WHEN** a run ends with run_time = 754.0 seconds
- **THEN** the run-end screen SHALL display "12:34"

#### Scenario: Run time shown on both victory and failure screens
- **WHEN** a run ends in either victory or failure
- **THEN** the run time row SHALL be present and populated

### Requirement: Run-end screen displays most common clear type
The run-end screen SHALL display the clear type the player performed most often during the run, derived from `RunStats.clear_counts` (a Dictionary mapping clear-type keys to counts). The display name SHALL use the same labels as `RunManager.CLEAR_TYPE_DISPLAY` (e.g. "Quad", "T-Spin Double"). If multiple types share the highest count, the type with the highest scoring value is shown (perfect_clear > quad > tspin_triple > tspin_double > tspin_single > tspin_mini > triple > double > single). If no clears were made, the field displays "—".

#### Scenario: Most common clear shown correctly
- **WHEN** a run ends with clear_counts = {"single": 40, "quad": 15, "double": 8}
- **THEN** the most common clear row SHALL display "Single"

#### Scenario: Tie resolved by scoring value
- **WHEN** a run ends with clear_counts = {"single": 10, "quad": 10}
- **THEN** the most common clear row SHALL display "Quad"

#### Scenario: No clears shows dash
- **WHEN** a run ends with an empty clear_counts dictionary
- **THEN** the most common clear row SHALL display "—"

### Requirement: Run-end screen displays final build
The run-end screen SHALL display the player's keystones and techniques that were active at the moment the run ended.

#### Scenario: Victory screen shows final keystones and techniques
- **WHEN** the player wins a run with two keystones and four techniques active
- **THEN** the victory screen SHALL list those two keystones and four techniques

#### Scenario: Failure screen shows final keystones and techniques
- **WHEN** a run ends in failure
- **THEN** the failure screen SHALL list the keystones and techniques that were active at the time of failure

#### Scenario: Empty build shown cleanly
- **WHEN** a run ends with no keystones and no techniques (e.g. early failure before any shop)
- **THEN** the build section SHALL either be hidden or display a placeholder indicating no items were held
