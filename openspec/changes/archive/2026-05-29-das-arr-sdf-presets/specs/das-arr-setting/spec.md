## ADDED Requirements

### Requirement: DAS is configured via discrete presets
The Settings screen SHALL offer DAS as a set of preset buttons: 80, 90, 100, 110, 120, 130, 140, 150, 160 ms. Exactly one preset SHALL be selected at all times. The default SHALL be 130 ms. Arbitrary values outside these presets SHALL NOT be settable by the player.

#### Scenario: DAS presets are shown on settings open
- **WHEN** the player opens the Settings screen
- **THEN** nine DAS preset buttons are displayed and the saved preset (or 130 ms default) is highlighted as selected

#### Scenario: Selecting a DAS preset updates the active value
- **WHEN** the player clicks a DAS preset button
- **THEN** that preset becomes the selected value and is applied to the board at the start of the next round

#### Scenario: DAS preset persists across sessions
- **WHEN** the player selects a DAS preset and closes the game
- **THEN** the same preset is selected when the Settings screen is opened again

#### Scenario: Out-of-range saved value snaps to nearest preset
- **WHEN** `settings.cfg` contains a DAS value not in the preset list (e.g. 167 ms from an old save)
- **THEN** `Settings.load_das()` returns the nearest valid preset value

### Requirement: ARR is configured via discrete presets
The Settings screen SHALL offer ARR as a set of preset buttons: 20, 30, 40, 50 ms. Exactly one preset SHALL be selected at all times. The default SHALL be 40 ms. 0 ms (instant) SHALL NOT be a player-settable value; it is reserved for the Full Potential keystone.

#### Scenario: ARR presets are shown on settings open
- **WHEN** the player opens the Settings screen
- **THEN** four ARR preset buttons are displayed and the saved preset (or 40 ms default) is highlighted as selected

#### Scenario: Selecting an ARR preset updates the active value
- **WHEN** the player clicks an ARR preset button
- **THEN** that preset becomes the selected value and is applied to the board at the start of the next round

#### Scenario: ARR preset persists across sessions
- **WHEN** the player selects an ARR preset and closes the game
- **THEN** the same preset is selected when the Settings screen is opened again

#### Scenario: Out-of-range saved value snaps to nearest preset
- **WHEN** `settings.cfg` contains an ARR value not in the preset list (e.g. 0 ms or 33 ms from an old save)
- **THEN** `Settings.load_arr()` returns the nearest valid preset value

### Requirement: Full Potential keystone overrides ARR to instant regardless of player setting
When the Full Potential keystone is active, `RoundConfig.instant_arr` SHALL be true and the board SHALL use 0 ms ARR for that round, ignoring the player's saved ARR preset.

#### Scenario: Full Potential forces instant ARR
- **WHEN** the Full Potential keystone is equipped and a round begins
- **THEN** the board operates with 0 ms ARR regardless of the ARR preset selected in settings
