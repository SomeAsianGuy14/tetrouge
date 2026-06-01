### Requirement: Keystone and Technique resources support unlock conditions
Both `Keystone` and `Technique` resources SHALL include an `unlock_condition_id: String` field (default `""`). When empty the item is always available. When non-empty the item is available only if its id appears in `ProfileSave.unlocked_ids`.

#### Scenario: Item with empty unlock_condition_id is always available
- **WHEN** a Keystone has `unlock_condition_id == ""`
- **THEN** it SHALL appear in the keystone pool regardless of `ProfileSave.unlocked_ids`

#### Scenario: Item with unlock_condition_id is hidden when not unlocked
- **WHEN** a Keystone has `unlock_condition_id == "some_condition"`
- **AND** `"some_condition"` is not in `ProfileSave.unlocked_ids`
- **THEN** it SHALL NOT appear in any keystone selection or shop pool

#### Scenario: Item with unlock_condition_id is available when unlocked
- **WHEN** a Keystone has `unlock_condition_id == "some_condition"`
- **AND** `"some_condition"` is in `ProfileSave.unlocked_ids`
- **THEN** it SHALL appear in the keystone pool normally

### Requirement: ResourceRegistry provides filtered pool helpers
`ResourceRegistry` SHALL expose `get_available_keystones()` and `get_available_techniques()` methods that return only items whose `unlock_condition_id` is empty or present in `ProfileSave.unlocked_ids`. The existing `all_keystones` and `all_techniques` arrays remain unfiltered.

#### Scenario: Filtered helper excludes locked items
- **WHEN** `get_available_keystones()` is called
- **AND** one keystone has a non-empty `unlock_condition_id` not in `ProfileSave.unlocked_ids`
- **THEN** that keystone SHALL NOT be in the returned array

#### Scenario: Filtered helper includes all unlocked items
- **WHEN** `get_available_keystones()` is called
- **AND** all keystones have empty `unlock_condition_id`
- **THEN** the returned array SHALL equal `all_keystones`

### Requirement: RunStats tracks per-run and cumulative-ready data
`RunStats` SHALL be a `RefCounted` object created at run start and populated throughout the run. It SHALL track: `total_damage: int`, `quad_damage: int`, `tspin_damage: int`. At victory, `RunStats` is passed to `ProfileSave.accumulate_stats()`.

#### Scenario: RunStats initialises at zero
- **WHEN** a new `RunStats` is created
- **THEN** all stat fields SHALL equal 0

### Requirement: UnlockChecker evaluates conditions at victory
`UnlockChecker.check_all(run_stats)` SHALL be called at the end of every victorious run. It SHALL iterate all known `UnlockCondition` entries, evaluate each against `ProfileSave` and `run_stats`, and add newly met condition ids to `ProfileSave.unlocked_ids`. With no unlock conditions defined, this is a no-op.

#### Scenario: UnlockChecker is a no-op with no conditions defined
- **WHEN** `UnlockChecker.check_all(run_stats)` is called
- **AND** no `UnlockCondition` entries exist
- **THEN** `ProfileSave.unlocked_ids` SHALL remain unchanged

### Requirement: UnlockCondition resource type exists
An `UnlockCondition` resource class SHALL exist with fields: `target_id: String`, `condition_type: String` (`"cumulative_stat"` or `"run_condition"`), `params: Dictionary`. No instances are created in this change.

#### Scenario: UnlockCondition can be instantiated
- **WHEN** `UnlockCondition.new()` is called
- **THEN** `target_id`, `condition_type`, and `params` SHALL all have valid default values
