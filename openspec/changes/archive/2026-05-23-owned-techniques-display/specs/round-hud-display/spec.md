## ADDED Requirements

### Requirement: HUD side panel displays owned Techniques as icon labels
The HUD side panel SHALL display a Techniques section below the Keystones section. Each owned Technique SHALL be rendered as a compact label showing the first character of its display name, with a tooltip containing the full name and description. The section SHALL include a "Techniques" header label. The display SHALL be rebuilt at the start of every round via `hud.setup()`.

#### Scenario: Technique icons appear when techniques are owned
- **WHEN** the player owns one or more Techniques and a round begins
- **THEN** each owned Technique is shown as a single-character label in the Techniques section of the side panel

#### Scenario: Technique tooltip shows full name and description
- **WHEN** the player hovers over a Technique icon in the side panel
- **THEN** a tooltip displays the Technique's full name and description

#### Scenario: Techniques section is empty when no techniques are owned
- **WHEN** the player owns no Techniques at the start of a round
- **THEN** the Techniques icon row is empty (the header label remains visible)

#### Scenario: Technique icons update after shop visit
- **WHEN** the player purchases a Technique in the shop and a new round begins
- **THEN** the newly acquired Technique appears in the side panel for that round
