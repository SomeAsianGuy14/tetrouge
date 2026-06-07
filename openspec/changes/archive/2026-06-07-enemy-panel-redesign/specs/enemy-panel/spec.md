## ADDED Requirements

### Requirement: Enemy panel occupies the full-height right side of the screen
The EnemyDisplay SHALL be positioned as a Control node anchored to the right side of the viewport, spanning the full viewport height (900px) with a width of approximately 680px. It SHALL NOT be a child of BoardContainer. Its horizontal position SHALL leave the board, hold display, queue display, and attack buffer bar undisturbed.

#### Scenario: Panel spans full viewport height
- **WHEN** a round begins
- **THEN** the enemy panel is visible at a fixed right-side position covering the full screen height, independent of board height

#### Scenario: Panel does not overlap board or queue display
- **WHEN** the panel is visible
- **THEN** the left edge of the panel is at least 50px to the right of the queue display's right edge

### Requirement: Enemy name is displayed tinted in the enemy's color
The enemy's display name SHALL appear at the top of the panel. The name label's modulate color SHALL be set to the enemy's `color` property.

#### Scenario: Name uses enemy color
- **WHEN** the panel is set up for any enemy
- **THEN** the name label text matches the enemy's display name and its color matches the enemy's color property

### Requirement: Portrait area shows a free-floating image with no border box
The portrait area SHALL display the enemy's sprite texture inside a free-floating Control with no visible background panel or border. The Control acts as a lunge anchor and SHALL be sized to approximately 360×360px.

#### Scenario: No border visible around portrait
- **WHEN** the panel is displayed
- **THEN** no rectangular frame or background color box is visible around the portrait area

#### Scenario: Sprite fills portrait area when assigned
- **WHEN** the enemy's sprite field is non-null
- **THEN** the sprite texture is displayed centered and scaled within the portrait area; the initial-letter placeholder is hidden

### Requirement: Initial-letter placeholder is shown when no sprite is set
When the enemy has no sprite texture, the portrait area SHALL display the first character of the enemy's display name as a large label (approximately 180pt) at low opacity (approximately 0.15) tinted in the enemy's color. This placeholder SHALL be hidden when a sprite is present.

#### Scenario: Initial shown without sprite
- **WHEN** the enemy's sprite field is null
- **THEN** a large, low-opacity, color-tinted letter matching the first character of the enemy's display name is visible in the portrait area

#### Scenario: Initial hidden when sprite is present
- **WHEN** the enemy's sprite field is non-null
- **THEN** the large initial letter is not visible

### Requirement: Panel info section shows round context and combat stats
Below the portrait the panel SHALL display, in order: the current stage and round in compact format, the enemy's flavor text (if set), the boss modifier description (if applicable), the HP bar, and the ATK countdown bar. All elements SHALL be vertically stacked with consistent spacing.

#### Scenario: Stage and round label uses compact X-Y format
- **WHEN** the round begins and it is not a boss round (round_index 0–2)
- **THEN** the stage/round label reads "X-Y" where X is the stage number and Y is the round number within the stage (1 = Small, 2 = Big, 3 = Elite)

#### Scenario: Stage and round label shows BOSS for round 4
- **WHEN** the round begins and it is a boss round (round_index 3)
- **THEN** the stage/round label reads "X-BOSS" where X is the stage number

#### Scenario: Flavor text is visible when set
- **WHEN** the enemy's flavor_text field is non-empty
- **THEN** the flavor text is displayed in an italic style below the stage/round label

#### Scenario: Flavor text section is hidden when empty
- **WHEN** the enemy's flavor_text field is empty or null
- **THEN** no flavor text area is visible; no empty gap is left

#### Scenario: Boss modifier description is visible for boss rounds
- **WHEN** the round has a boss modifier
- **THEN** the boss modifier's description is displayed below the flavor text in an orange tint

#### Scenario: Boss modifier description is hidden for non-boss rounds
- **WHEN** the round has no boss modifier
- **THEN** no modifier description area is visible

### Requirement: Enemy resource exposes a flavor_text field
The `Enemy` resource class SHALL include a `flavor_text: String` export field defaulting to an empty string. All existing enemy `.tres` data files SHALL include this field (defaulting to empty). The field is displayed in the panel info section when non-empty.

#### Scenario: Flavor text defaults to empty
- **WHEN** an enemy resource is loaded that has no flavor_text value set
- **THEN** flavor_text evaluates to an empty string and the panel hides the flavor text section
