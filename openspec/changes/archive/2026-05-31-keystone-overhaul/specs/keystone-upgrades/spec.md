## ADDED Requirements

### Requirement: Keystone resource supports upgrade replacement
The Keystone resource SHALL include a `replaces_keystone_id: String` field (default `""`). When non-empty, it identifies the id of the keystone that is removed from the player's active keystones when this keystone is acquired.

#### Scenario: Field defaults to empty
- **WHEN** a Keystone resource is created with no explicit `replaces_keystone_id`
- **THEN** `replaces_keystone_id` SHALL equal `""`

### Requirement: Acquiring an upgrade removes the base keystone
When `RunState.add_keystone()` is called with a keystone whose `replaces_keystone_id` is non-empty, the system SHALL remove the matching keystone from `RunState.keystones` before appending the new one.

#### Scenario: Base keystone is removed on upgrade pick
- **WHEN** the player picks an upgrade keystone whose `replaces_keystone_id` matches an active keystone
- **THEN** the matched keystone SHALL be removed from `RunState.keystones`
- **THEN** the upgrade keystone SHALL be present in `RunState.keystones`

#### Scenario: Replaced id is retained in used_keystone_ids
- **WHEN** an upgrade keystone replaces a base keystone
- **THEN** the replaced keystone's id SHALL remain in `RunState.used_keystone_ids`
- **THEN** the replaced keystone SHALL NOT be offered again in the keystone selection screen

#### Scenario: No removal when replaces_keystone_id is empty
- **WHEN** the player picks a keystone with `replaces_keystone_id == ""`
- **THEN** no existing keystone SHALL be removed from `RunState.keystones`

#### Scenario: No removal when replaced keystone is not currently held
- **WHEN** the player picks an upgrade keystone whose `replaces_keystone_id` does not match any active keystone
- **THEN** no removal occurs and the upgrade is added normally

### Requirement: Upgrade keystones carry correct prerequisite and replacement ids
Each upgrade keystone data file SHALL set both `requires_keystone_id` (so it is only offered when the base is held) and `replaces_keystone_id` (so the base is removed on pick) to the same base keystone id.

#### Scenario: Great Sword requires and replaces Simple Sword
- **WHEN** the player holds Simple Sword and picks Great Sword
- **THEN** Simple Sword SHALL be removed and Great Sword SHALL be active

#### Scenario: Mace and Chain requires and replaces Simple Flail
- **WHEN** the player holds Simple Flail and picks Mace and Chain
- **THEN** Simple Flail SHALL be removed and Mace and Chain SHALL be active

#### Scenario: Legionnaire's Shield requires and replaces Simple Shield
- **WHEN** the player holds Simple Shield and picks Legionnaire's Shield
- **THEN** Simple Shield SHALL be removed and Legionnaire's Shield SHALL be active

#### Scenario: Crystal Staff requires and replaces Simple Wand
- **WHEN** the player holds Simple Wand and picks Crystal Staff
- **THEN** Simple Wand SHALL be removed and Crystal Staff SHALL be active

#### Scenario: Magical Coin requires and replaces Slightly Magical Coin
- **WHEN** the player holds Slightly Magical Coin and picks Magical Coin
- **THEN** Slightly Magical Coin SHALL be removed and Magical Coin SHALL be active
