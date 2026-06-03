## ADDED Requirements

### Requirement: RoundConfig carries a timer visibility flag
`RoundConfig` SHALL include a `show_timer: bool` field (default `false`). The flag is set to `true` at round build time when either the player holds the Golden Watch keystone or the active boss modifier is The Blitz.

#### Scenario: Timer hidden in standard rounds
- **WHEN** no Golden Watch keystone is held and the boss modifier is not The Blitz
- **THEN** `RoundConfig.show_timer` SHALL be `false`

#### Scenario: Timer shown when Golden Watch is held
- **WHEN** the player holds the Golden Watch keystone
- **THEN** `RoundConfig.show_timer` SHALL be `true`

#### Scenario: Timer always shown during The Blitz
- **WHEN** the active boss modifier is The Blitz
- **THEN** `RoundConfig.show_timer` SHALL be `true` regardless of keystones held

### Requirement: HUD timer label visibility follows RoundConfig.show_timer
`HUD.setup(config)` SHALL show the timer label when `config.show_timer` is `true` and hide it when `false`. `HUD.update_timer()` SHALL early-return without updating text or colour when the label is hidden.

#### Scenario: Timer label hidden at round start
- **WHEN** a round begins with `show_timer = false`
- **THEN** the HUD timer label SHALL not be visible

#### Scenario: Timer label visible at round start
- **WHEN** a round begins with `show_timer = true`
- **THEN** the HUD timer label SHALL be visible and update each frame
