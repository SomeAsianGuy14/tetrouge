## ADDED Requirements

### Requirement: SDF is configured via discrete presets
The Settings screen SHALL offer SDF (soft drop factor) as a set of preset buttons: 5×, 10×, 15×, 20×. Exactly one preset SHALL be selected at all times. The default SHALL be 10×. Infinite SDF SHALL NOT be a player-settable value; it is reserved for the Full Potential keystone.

#### Scenario: SDF presets are shown on settings open
- **WHEN** the player opens the Settings screen
- **THEN** four SDF preset buttons are displayed and the saved preset (or 10× default) is highlighted as selected

#### Scenario: Selecting an SDF preset updates the active value
- **WHEN** the player clicks an SDF preset button
- **THEN** that preset becomes the selected multiplier and is applied to the board at the start of the next round

#### Scenario: SDF preset persists across sessions
- **WHEN** the player selects an SDF preset and closes the game
- **THEN** the same preset is selected when the Settings screen is opened again

### Requirement: SDF multiplier is applied to board gravity during soft drop
`TetrisBoard` SHALL expose a `sdf_multiplier` variable. During soft drop, the gravity speed SHALL be multiplied by `sdf_multiplier`. `RunManager` SHALL set `sdf_multiplier` from `Settings.load_sdf()` before each round begins.

#### Scenario: Soft drop speed matches selected SDF
- **WHEN** the player holds the soft drop input during a round
- **THEN** the piece falls at `GRAVITY_SPEED × sdf_multiplier` cells per second

#### Scenario: SDF default applies when no setting is saved
- **WHEN** no SDF value is present in `settings.cfg`
- **THEN** `Settings.load_sdf()` returns 10 and the board uses 10× gravity during soft drop

### Requirement: Full Potential keystone overrides SDF to infinite regardless of player setting
When the Full Potential keystone is active, `RoundConfig.instant_soft_drop` SHALL be true and the board SHALL use 1000× gravity during soft drop for that round, ignoring the player's saved SDF preset.

#### Scenario: Full Potential forces infinite soft drop
- **WHEN** the Full Potential keystone is equipped and a round begins
- **THEN** pressing soft drop moves the piece to the bottom instantly, regardless of the SDF preset selected in settings
