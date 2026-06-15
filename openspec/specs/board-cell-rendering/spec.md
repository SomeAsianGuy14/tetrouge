### Requirement: Placed cells render with a bevelled stone-block appearance
Each non-empty, non-garbage cell SHALL be drawn with a bevelled edge: a lightened highlight on the top and left sides, and a darkened shadow on the bottom and right sides, giving a raised stone-block appearance.

#### Scenario: Active piece cells show bevel
- **WHEN** the current falling piece is drawn
- **THEN** each cell has a lightened top/left edge and a darkened bottom/right edge over the base piece colour

#### Scenario: Locked grid cells show bevel
- **WHEN** a placed (locked) piece cell is drawn
- **THEN** the same bevel is applied as for the active piece

### Requirement: Garbage cells render with bevel and a crack pattern
Garbage cells (colour ID 9) SHALL be drawn with the standard bevel and additionally overlaid with a position-derived crack pattern drawn in near-black semi-transparent lines.

#### Scenario: Crack pattern varies by cell position
- **WHEN** two garbage cells occupy different (col, row) positions
- **THEN** they MAY display different crack patterns based on their coordinates

#### Scenario: Crack pattern is consistent per cell position
- **WHEN** the same (col, row) position is filled with garbage on repeated draws
- **THEN** the same crack pattern is displayed (deterministic, not random per frame)

### Requirement: Ghost piece renders as a void-fill with piece-coloured rune outline
The ghost piece SHALL be drawn with a near-black dark fill and a coloured outline matching the current piece's colour, rather than a solid grey fill.

#### Scenario: Ghost outline matches current piece colour
- **WHEN** the ghost piece is drawn during normal play
- **THEN** the outline colour matches the active piece's colour at reduced opacity

#### Scenario: Ghost outline turns white while soft-dropping
- **WHEN** the player is holding the soft-drop input and the ghost is drawn
- **THEN** the outline colour changes to near-white to signal the soft-drop state

### Requirement: Board background uses dungeon stone colour
The board background SHALL use `Color(0.08, 0.07, 0.10)` instead of the previous `Color(0.1, 0.1, 0.1)`.

#### Scenario: Board background is darker with violet warmth
- **WHEN** the board is drawn with an empty grid
- **THEN** the background colour is `Color(0.08, 0.07, 0.10)`

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
