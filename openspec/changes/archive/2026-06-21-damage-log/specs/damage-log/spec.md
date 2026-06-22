## ADDED Requirements

### Requirement: DamageLog autoload lifecycle
`DamageLog` SHALL be registered as an autoload. On `_ready()`, it SHALL set `_enabled = true` if `OS.is_debug_build()` returns true, otherwise `_enabled = false`. When `_enabled` is false, all public logging methods SHALL return immediately without performing any I/O or string formatting.

#### Scenario: Debug build enables logging
- **WHEN** the game starts in a debug build
- **THEN** `DamageLog._enabled` SHALL be `true`

#### Scenario: Release build disables logging
- **WHEN** the game starts in a release build
- **THEN** `DamageLog._enabled` SHALL be `false`

#### Scenario: Disabled logging performs no I/O
- **WHEN** `_enabled` is `false` and any logging method is called
- **THEN** the method SHALL return immediately without writing to disk

### Requirement: CSV file per run
When a run starts and logging is enabled, `DamageLog` SHALL create a new CSV file at `user://damage_logs/run_<YYYYMMDD_HHmmss>.csv`. The file SHALL be opened for writing at run start and closed at run end (victory or failure).

#### Scenario: File created on run start
- **WHEN** a new run begins and logging is enabled
- **THEN** a CSV file SHALL be created at `user://damage_logs/run_<timestamp>.csv`

#### Scenario: File closed on run end
- **WHEN** a run ends (victory or failure)
- **THEN** the CSV file handle SHALL be closed

### Requirement: RUN_START row
When a run begins, `DamageLog` SHALL write a row with `row_type=RUN_START`, the run seed, ascension level, and a human-readable timestamp.

#### Scenario: RUN_START row emitted
- **WHEN** a new run begins
- **THEN** a CSV row SHALL be written with `row_type=RUN_START`, `seed=<run_seed>`, `ascension=<level>`, `timestamp=<ISO-ish>`

### Requirement: BUILD row on build changes
`DamageLog` SHALL write a `BUILD` row listing all current keystone IDs, technique IDs, and consumable IDs whenever the build changes. `RunState` SHALL emit a `build_changed` signal after any call to `add_keystone()`, `add_technique()`, `add_consumable()`, `remove_technique()`, or `remove_consumable()`. `DamageLog` SHALL connect to this signal and emit a BUILD row. A BUILD row SHALL also be emitted at run start after the initial build is established.

#### Scenario: BUILD row on keystone addition
- **WHEN** a keystone is added to the build
- **THEN** a CSV row SHALL be written with `row_type=BUILD` and the updated keystone, technique, and consumable ID lists

#### Scenario: BUILD row on technique removal
- **WHEN** a technique is removed from the build (e.g. Head Trauma encounter)
- **THEN** a CSV row SHALL be written with `row_type=BUILD` reflecting the updated technique list

#### Scenario: BUILD row at run start
- **WHEN** a run begins and the starter keystone is selected
- **THEN** a BUILD row SHALL be emitted reflecting the initial build state

### Requirement: ATTACK row per damage event
For each non-suppressed attack event, `DamageLog` SHALL write a row with `row_type=ATTACK` containing: `floor`, `room_tier`, `event_type`, `base` (raw_attack), `technique` (technique_atk), `mastery` (mastery_atk), `honed` (honed_bonus), `keystone_flat` (delta from keystone flat bonuses), `consumable_flat` (delta from consumable flat bonuses), `surge_mult` (1.0 or 2.0), `keystone_mult` (combined keystone multiplier), `amplified_mult` (amplified cell multiplier), `tag_bonus` (Hybrid Reactor delta), and `final` (the modified value sent to quota).

#### Scenario: Quad attack with technique and keystone contributions
- **WHEN** a quad clears with raw_attack=4, technique_atk=2, mastery=1, honed=0, keystone_flat=3, consumable_flat=0, surge_mult=1.0, keystone_mult=1.5, amplified_mult=1.0, tag_bonus=0
- **THEN** an ATTACK row SHALL be written with all listed values and `final=15` (int((4+2+1+0+3+0) * 1.0 * 1.5 * 1.0) + 0)

#### Scenario: Suppressed attack not logged
- **WHEN** a keystone suppresses an attack (modified set to 0)
- **THEN** no ATTACK row SHALL be written for that event

#### Scenario: B2B bonus event logged
- **WHEN** a b2b bonus event fires with raw_attack=1
- **THEN** an ATTACK row SHALL be written with `event_type=b2b` and additive fields (technique, mastery, honed) at 0

### Requirement: ROUND_END summary row
When a combat round ends, `DamageLog` SHALL write a row with `row_type=ROUND_END` containing: `floor`, `room_tier`, `quota` (the round's target), `total_damage` (sum of all `final` values for the round), and per-source sums: `sum_base`, `sum_technique`, `sum_mastery`, `sum_honed`, `sum_keystone_flat`, `sum_consumable_flat`, `sum_tag_bonus`, plus `time_elapsed` and `pieces_placed`.

#### Scenario: Round end summary after victory
- **WHEN** a combat round ends in victory
- **THEN** a ROUND_END row SHALL be written with accumulated totals for that round

#### Scenario: Round end summary after failure
- **WHEN** a combat round ends in failure (top-out)
- **THEN** a ROUND_END row SHALL be written with accumulated totals for that round

### Requirement: RUN_END row
When the run ends (victory or failure), `DamageLog` SHALL write a row with `row_type=RUN_END`, `result` ("victory" or "failure"), and `total_damage` (sum across all rounds).

#### Scenario: Victory run end
- **WHEN** the player wins the run
- **THEN** a RUN_END row SHALL be written with `result=victory`

#### Scenario: Failure run end
- **WHEN** the player loses the run
- **THEN** a RUN_END row SHALL be written with `result=failure`
