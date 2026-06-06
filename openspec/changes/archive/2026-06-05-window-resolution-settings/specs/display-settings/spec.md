## ADDED Requirements

### Requirement: Player can toggle fullscreen mode
The Settings screen SHALL provide a toggle that switches the game between windowed and fullscreen (OS fullscreen). The selected mode SHALL be persisted to `user://settings.cfg` and restored automatically at startup.

#### Scenario: Enter fullscreen
- **WHEN** the player presses the Fullscreen button in Settings
- **THEN** the window switches to OS fullscreen mode

#### Scenario: Return to windowed
- **WHEN** the player is in fullscreen and presses the Windowed button in Settings
- **THEN** the window returns to the last saved windowed size

#### Scenario: Fullscreen persists across sessions
- **WHEN** the player saves fullscreen mode and restarts the game
- **THEN** the game launches in fullscreen

### Requirement: Player can choose a windowed size preset
The Settings screen SHALL provide three windowed size presets: Small (1280×720), Medium (1600×900), and Large (1920×1080). Selecting a preset SHALL resize the window immediately. The selected size SHALL be persisted to `user://settings.cfg` and restored at startup when in windowed mode.

#### Scenario: Apply Small preset
- **WHEN** the player selects Small in windowed mode
- **THEN** the window resizes to 1280×720

#### Scenario: Apply Medium preset
- **WHEN** the player selects Medium in windowed mode
- **THEN** the window resizes to 1600×900

#### Scenario: Apply Large preset
- **WHEN** the player selects Large in windowed mode
- **THEN** the window resizes to 1920×1080

#### Scenario: Size persists across sessions
- **WHEN** the player saves a window size and restarts in windowed mode
- **THEN** the window opens at the saved size

#### Scenario: Size presets are no-ops in web builds
- **WHEN** the player selects any size preset in an HTML5 build
- **THEN** no error occurs and the canvas size is unchanged

### Requirement: Display settings are applied before the first scene renders
`Settings.apply_saved_display()` SHALL be called during autoload initialisation so that the window is in the correct mode and size before any scene is displayed.

#### Scenario: Startup applies saved display settings
- **WHEN** the game starts and a display preference is saved in `user://settings.cfg`
- **THEN** the window mode and size match the saved values before the main menu appears

#### Scenario: Startup with no saved display settings uses defaults
- **WHEN** the game starts and no display preference exists in `user://settings.cfg`
- **THEN** the game launches windowed at 1600×900 (Medium)
