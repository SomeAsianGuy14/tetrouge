## ADDED Requirements

### Requirement: Enhanced cell styling
The board SHALL render each enhanced cell with a distinct per-type style: `honed` cells render a solid silver fill, `gilded` cells render a solid golden fill, `reinforced` cells render a solid brown fill with a silver border outline, and `amplified` cells retain their normal piece color with a small centered yellow triangle. The falling piece (and its ghost) SHALL render the same per-type styling on its cells while it carries an enhancement. Styling SHALL follow cells through row shifts (clears and garbage insertion) because it is drawn from the enhancement layer each frame.

#### Scenario: Locked honed cells render a solid silver fill
- **WHEN** a honed piece locks on the board
- **THEN** its cells render a solid silver fill until those rows clear

#### Scenario: Locked gilded cells render a solid golden fill
- **WHEN** a gilded piece locks on the board
- **THEN** its cells render a solid golden fill until those rows clear

#### Scenario: Locked reinforced cells render brown with a silver border
- **WHEN** a reinforced piece locks on the board
- **THEN** its cells render a solid brown fill with a silver border outline until those rows clear

#### Scenario: Locked amplified cells keep piece color with a yellow triangle
- **WHEN** an amplified piece locks on the board
- **THEN** its cells retain their normal piece color and render a small centered yellow triangle until those rows clear

#### Scenario: Falling enhanced piece shows the same styling
- **WHEN** the current piece carries an enhancement
- **THEN** its cells render that enhancement's per-type styling while falling

#### Scenario: Unenhanced cells render unchanged
- **WHEN** a cell has no enhancement layer entry
- **THEN** it renders exactly as before this change
