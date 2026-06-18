## MODIFIED Requirements

### Requirement: Profile accumulates cumulative stats
`ProfileSave` SHALL track the following stats across all completed runs:

Additive (summed across runs): `runs_completed`, `total_damage`, `total_quad_damage`, `total_tspin_damage`, `total_quads`, `total_tspins`, `total_perfect_clears`, `victories`, `total_play_time`.

Lifetime maximums (stored as `max(stored, run_value)`): `highest_combo_chain`, `highest_b2b`, `best_single_run_damage`.

`accumulate_stats(run_stats)` SHALL update all of the above fields. `victories` SHALL be incremented by 1 only when called from the victory path (via a `is_victory: bool` parameter or a dedicated `record_victory_stats()` method — see design).

#### Scenario: Additive stats accumulate across victories
- **WHEN** the player wins a run dealing 150 total damage, 40 quad damage, 30 T-spin damage, 5 quads, 3 T-spins, and 1 perfect clear
- **THEN** `total_damage` SHALL increase by 150
- **THEN** `total_quad_damage` SHALL increase by 40
- **THEN** `total_tspin_damage` SHALL increase by 30
- **THEN** `total_quads` SHALL increase by 5
- **THEN** `total_tspins` SHALL increase by 3
- **THEN** `total_perfect_clears` SHALL increase by 1
- **THEN** `runs_completed` SHALL increase by 1
- **THEN** `victories` SHALL increase by 1
- **THEN** `total_play_time` SHALL increase by the run's `run_time`

#### Scenario: Lifetime maximum stats update only when exceeded
- **WHEN** the player wins a run with a highest combo chain of 8 and total damage of 2000
- **AND** the stored `highest_combo_chain` is 5 and `best_single_run_damage` is 1500
- **THEN** `highest_combo_chain` SHALL be updated to 8
- **THEN** `best_single_run_damage` SHALL be updated to 2000

#### Scenario: Lifetime maximum stats do not decrease
- **WHEN** the player wins a run with a highest combo chain of 3
- **AND** the stored `highest_combo_chain` is 8
- **THEN** `highest_combo_chain` SHALL remain 8

#### Scenario: Stats do not accumulate on failure
- **WHEN** a run ends in failure
- **THEN** cumulative stats SHALL NOT be updated
- **THEN** `victories` SHALL NOT increase

#### Scenario: New fields default to zero when profile file predates this change
- **WHEN** `ProfileSave.load_profile()` reads a `user://profile.cfg` that has no `total_quads`, `total_tspins`, `total_perfect_clears`, `victories`, `best_single_run_damage`, or `total_play_time` keys
- **THEN** all missing fields SHALL default to `0`
