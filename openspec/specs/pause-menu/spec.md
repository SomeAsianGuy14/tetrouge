## ADDED Requirements

### Requirement: A configurable Pause keybind opens the overlay from any run screen
The game SHALL register a `pause` input action (default key: Escape) in the project. This action SHALL be listed in the Settings rebind UI so the player can change it. Pressing the pause keybind from any screen within an active run (active round, shop, round success, keystone selection) SHALL open the pause overlay. Pressing it again while the overlay is open SHALL close it.

#### Scenario: Pause keybind opens overlay during a round
- **WHEN** the player presses the pause keybind during an active round
- **THEN** the pause overlay appears, the round timer stops, and the board stops ticking

#### Scenario: Pause keybind opens overlay during the shop
- **WHEN** the player presses the pause keybind while the shop screen is open
- **THEN** the pause overlay appears over the shop; no board state is affected

#### Scenario: Pause keybind closes the overlay
- **WHEN** the pause overlay is open and the player presses the pause keybind
- **THEN** the overlay closes and the previous state resumes

#### Scenario: Pause keybind is rebindable
- **WHEN** the player assigns a different key to the Pause / Settings action in Settings
- **THEN** the new key opens and closes the overlay; the old key no longer does

### Requirement: Pause overlay contains Close/Resume, Settings, and Quit to Main Menu
The pause overlay SHALL display three actions: Close/Resume (closes the overlay and continues from where the player was), Settings (opens the existing Settings screen inside the overlay), and Quit to Main Menu (safely ends the run and returns to the main menu).

#### Scenario: Close button continues the session
- **WHEN** the player clicks Close/Resume in the pause overlay
- **THEN** the overlay closes; if a round was active, the timer and board resume

#### Scenario: Close button during shop returns to shop
- **WHEN** the player clicks Close/Resume while the overlay was opened from the shop
- **THEN** the overlay closes and the shop is interactive again

#### Scenario: Settings opens inside pause overlay
- **WHEN** the player clicks Settings in the pause overlay
- **THEN** the existing Settings screen is shown within the overlay without leaving the run

#### Scenario: Settings close returns to pause overlay
- **WHEN** the player closes the Settings screen while the overlay is open
- **THEN** the pause overlay is visible again (Settings frees itself; the overlay remains)

#### Scenario: Quit to Main Menu ends the run from any state
- **WHEN** the player clicks Quit to Main Menu from the pause overlay
- **THEN** the current run is abandoned, run and economy state is reset, and the main menu loads regardless of whether a round or shop was active

### Requirement: DAS and ARR changes made while paused apply immediately on resume
If the player adjusts DAS or ARR in the Settings screen while the game is paused, the new values SHALL be propagated to the currently active board when the round resumes, taking effect for the remainder of that round.

#### Scenario: DAS change takes effect after resume
- **WHEN** the player changes DAS in the pause menu settings and then resumes
- **THEN** the board uses the new DAS value for the remainder of the round

#### Scenario: ARR change takes effect after resume
- **WHEN** the player changes ARR in the pause menu settings and then resumes
- **THEN** the board uses the new ARR value for the remainder of the round

### Requirement: Held directional input is released on pause
When the game is paused, any in-progress horizontal DAS movement SHALL be cancelled so that the piece does not lurch on resume.

#### Scenario: DAS state cleared on pause
- **WHEN** the player is holding a directional key and presses Escape to pause
- **THEN** the horizontal movement state is reset and the piece does not move immediately on resume
