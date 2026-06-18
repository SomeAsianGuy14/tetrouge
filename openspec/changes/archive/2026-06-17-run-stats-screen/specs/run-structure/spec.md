## MODIFIED Requirements

### Requirement: Victory triggers profile update and unlock check
When the player clears the Boss Blind of Ante 5, before showing the victory screen the system SHALL: compute personal best flags by comparing `_run_stats` against current `ProfileSave` values, then show the victory screen passing `_run_stats` and the PB flags, then call `ProfileSave.record_victory(AscensionManager.current_level)`, call `ProfileSave.accumulate_stats(_run_stats)`, and call `UnlockChecker.check_all(_run_stats, ProfileSave)`. Profile accumulation SHALL occur after the screen is shown, not before, so that PB comparisons reflect the record prior to the current run.

#### Scenario: Profile updated on victory
- **WHEN** the player wins a run at ascension level 2
- **THEN** `ProfileSave.highest_beaten` SHALL be updated to at least 2
- **THEN** cumulative stats SHALL reflect the completed run's damage totals

#### Scenario: PB flags computed before accumulation
- **WHEN** the player wins a run with total_damage = 2000
- **AND** ProfileSave.best_single_run_damage was 1500 before this run
- **THEN** the victory screen SHALL receive a PB flag for damage
- **THEN** ProfileSave.best_single_run_damage SHALL be updated to 2000 after the screen is shown

#### Scenario: Victory screen receives RunStats and PB flags
- **WHEN** the victory screen is shown
- **THEN** it SHALL receive the completed run's RunStats object
- **THEN** it SHALL receive a dictionary of which stat fields are new personal bests

## ADDED Requirements

### Requirement: Failure screen receives RunStats and PB flags
When a run ends in failure, `RunManager._show_failure()` SHALL compute personal best flags by comparing `_run_stats` against current `ProfileSave` values, then show the failure screen passing `_run_stats`, the PB flags, the ante, and the round index. Stats SHALL NOT be accumulated into ProfileSave on failure.

#### Scenario: Failure screen receives run stats
- **WHEN** a run ends in failure at Stage 3, Elite Blind
- **THEN** the failure screen SHALL receive the run's RunStats with all counters populated up to the point of failure

#### Scenario: Profile not updated on failure
- **WHEN** a run ends in failure
- **THEN** `ProfileSave.accumulate_stats()` SHALL NOT be called
- **THEN** cumulative stats in ProfileSave SHALL remain unchanged

### Requirement: RunManager tracks quad, T-spin, and perfect clear counts in RunStats
`RunManager` SHALL increment `_run_stats.quads` on every quad clear event, `_run_stats.tspins` on every T-spin clear event (mini, single, double, or triple), and `_run_stats.perfect_clears` on every perfect clear event. These counters are incremented in `_on_attack_event()` alongside existing damage tracking.

#### Scenario: Quad increments quads counter
- **WHEN** the player clears four lines at once
- **THEN** `_run_stats.quads` SHALL increase by 1

#### Scenario: T-Spin increments tspins counter
- **WHEN** the player performs any T-spin (mini, single, double, or triple)
- **THEN** `_run_stats.tspins` SHALL increase by 1

#### Scenario: Perfect clear increments perfect_clears counter
- **WHEN** the player achieves a perfect clear
- **THEN** `_run_stats.perfect_clears` SHALL increase by 1

#### Scenario: Counters start at zero each run
- **WHEN** a new run begins
- **THEN** `_run_stats.quads`, `_run_stats.tspins`, and `_run_stats.perfect_clears` SHALL all be 0

### Requirement: RunManager accumulates round time into RunStats
`RunManager` SHALL add the current `round_timer` value to `_run_stats.run_time` at the end of every round (both on round success and on board topout/failure), before showing any end screen. This accumulates only active in-round time; time spent in shops, between-round screens, or while paused is excluded.

#### Scenario: Round time accumulates across rounds
- **WHEN** the player completes two rounds lasting 45s and 60s respectively
- **THEN** `_run_stats.run_time` SHALL be 105.0

#### Scenario: Partial round time captured on failure
- **WHEN** the board tops out 38 seconds into a round
- **THEN** `_run_stats.run_time` SHALL include those 38 seconds

### Requirement: RunManager tracks per-clear-type counts in RunStats
`RunManager` SHALL increment the count for the current clear type in `_run_stats.clear_counts` on every clear event. `clear_counts` is a Dictionary mapping clear-type strings (matching `CLEAR_TYPE_DISPLAY` keys) to integer counts. It is initialised as an empty Dictionary at run start; missing keys default to 0 when incremented.

#### Scenario: Clear type count incremented on each clear
- **WHEN** the player performs three singles and one quad
- **THEN** `_run_stats.clear_counts["single"]` SHALL be 3
- **THEN** `_run_stats.clear_counts["quad"]` SHALL be 1

#### Scenario: clear_counts starts empty each run
- **WHEN** a new run begins
- **THEN** `_run_stats.clear_counts` SHALL be an empty Dictionary
