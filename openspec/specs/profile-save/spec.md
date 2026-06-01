### Requirement: Profile save persists cross-run data
The system SHALL maintain a persistent save file at `user://profile.cfg` that survives run completion, run failure, and game restarts. This file is distinct from `user://save.cfg` (the in-progress run save).

#### Scenario: Profile file survives run completion
- **WHEN** a run ends (victory or failure)
- **THEN** `user://profile.cfg` SHALL remain intact and readable

#### Scenario: Profile defaults when file absent
- **WHEN** `ProfileSave.load()` is called and `user://profile.cfg` does not exist
- **THEN** `highest_beaten` SHALL default to `-1`
- **THEN** `unlocked_ids` SHALL default to an empty array
- **THEN** all cumulative stats SHALL default to `0`

### Requirement: Profile tracks highest ascension beaten
`ProfileSave` SHALL store `highest_beaten: int` representing the highest ascension level the player has cleared. A value of `-1` means the game has never been beaten.

#### Scenario: Record first victory
- **WHEN** the player beats the game at ascension level 0 for the first time
- **THEN** `highest_beaten` SHALL be set to `0`

#### Scenario: Record higher victory
- **WHEN** the player beats the game at ascension level N where N > `highest_beaten`
- **THEN** `highest_beaten` SHALL be updated to N

#### Scenario: Lower victory does not downgrade record
- **WHEN** the player beats the game at ascension level N where N <= `highest_beaten`
- **THEN** `highest_beaten` SHALL remain unchanged

### Requirement: Profile accumulates cumulative stats
`ProfileSave` SHALL track the following stats across all completed runs:

Additive (summed across runs): `runs_completed`, `total_damage`, `total_quad_damage`, `total_tspin_damage`.

Lifetime maximums (stored as `max(stored, run_value)`): `highest_combo_chain`, `highest_b2b`.

#### Scenario: Additive stats accumulate across victories
- **WHEN** the player wins a run dealing 150 total damage, 40 quad damage, and 30 T-spin damage
- **THEN** `total_damage` SHALL increase by 150
- **THEN** `total_quad_damage` SHALL increase by 40
- **THEN** `total_tspin_damage` SHALL increase by 30
- **THEN** `runs_completed` SHALL increase by 1

#### Scenario: Lifetime maximum stats update only when exceeded
- **WHEN** the player wins a run with a highest combo chain of 8
- **AND** the stored `highest_combo_chain` is 5
- **THEN** `highest_combo_chain` SHALL be updated to 8

#### Scenario: Lifetime maximum stats do not decrease
- **WHEN** the player wins a run with a highest combo chain of 3
- **AND** the stored `highest_combo_chain` is 8
- **THEN** `highest_combo_chain` SHALL remain 8

#### Scenario: Stats do not accumulate on failure
- **WHEN** a run ends in failure
- **THEN** cumulative stats SHALL NOT be updated

### Requirement: Profile stores unlocked item ids
`ProfileSave` SHALL store an array of item ids (`unlocked_ids`) that have been unlocked through gameplay. Items in this array are available in the pool; items with an `unlock_condition_id` not present here are filtered out.

#### Scenario: Unlocked id persists after restart
- **WHEN** an item id is added to `unlocked_ids` and the game is restarted
- **THEN** `ProfileSave.load()` SHALL return that id in `unlocked_ids`
