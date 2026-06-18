## ADDED Requirements

### Requirement: Run consists of 4 floors
A full run SHALL consist of exactly 4 floors. Each floor is a procedurally generated dungeon map. Clearing the Boss/Exit room of floor 4 ends the run in victory.

#### Scenario: Run ends after floor 4 Boss/Exit
- **WHEN** the player clears the Boss/Exit room of floor 4
- **THEN** the run is marked as a victory and the victory screen is shown

#### Scenario: Clearing Boss/Exit on floors 1–3 advances to next floor
- **WHEN** the player clears the Boss/Exit room of floor 1, 2, or 3
- **THEN** the keystone selection screen is shown, followed by the dungeon map for the next floor

### Requirement: Each floor is a 6×6 tile dungeon map
Each floor SHALL be represented as a 6×6 grid of display tiles. Rooms are placed on this grid at generation time and occupy 1–4 tiles each (visual size only — each room is a single encounter node). The total number of rooms per floor SHALL be between 8 and 12, including the start room and the Boss/Exit room.

#### Scenario: Floor tile grid dimensions
- **WHEN** a floor is generated
- **THEN** the underlying grid is 6 columns × 6 rows of display tiles

#### Scenario: Room count within bounds
- **WHEN** a floor is generated
- **THEN** the floor contains between 8 and 12 rooms inclusive

### Requirement: Start room and Boss/Exit room are at fixed corners
The start room SHALL always be a 1×1 room at the bottom-left corner (tile (0,5)). The Boss/Exit room SHALL always be a 2×2 room anchored at tiles (4,0)–(5,1) in the top-right area. These positions are not randomised.

#### Scenario: Start room position
- **WHEN** a floor is generated
- **THEN** a 1×1 room of type "start" occupies tile (0,5)

#### Scenario: Boss/Exit room position
- **WHEN** a floor is generated
- **THEN** a 2×2 room of type "boss" occupies tiles (4,0), (5,0), (4,1), (5,1)

### Requirement: Floor generation uses RunState.rng
All random choices during floor generation — room type assignment, room size selection, interior room placement — SHALL use `RunState.rng` (the run-seeded PRNG). Reloading the game before a floor begins SHALL produce the same floor layout.

#### Scenario: Deterministic floor layout after reload
- **WHEN** a run is saved before a floor begins, the game is closed and reopened, and the player continues
- **THEN** the floor layout, room types, and sizes are identical to what would have appeared without the reload

### Requirement: Floor generation guarantees a valid path from start to Boss/Exit
After placing all rooms, the generator SHALL verify via BFS that at least one path exists from the start room to the Boss/Exit room through orthogonally adjacent rooms. If no valid path exists, the generator SHALL retry with a seed offset up to 10 times before falling back to a guaranteed-connected template layout.

#### Scenario: Valid path always exists
- **WHEN** any floor is generated
- **THEN** a BFS from the start room reaches the Boss/Exit room through room adjacency

### Requirement: Two rooms are adjacent if their tile footprints share an orthogonal edge
Two rooms SHALL be considered adjacent if any tile in one room's footprint is directly above, below, left of, or right of any tile in the other room's footprint. Diagonal adjacency does not count.

#### Scenario: Orthogonal adjacency
- **WHEN** room A occupies tile (2,3) and room B occupies tile (3,3)
- **THEN** rooms A and B are adjacent

#### Scenario: Diagonal adjacency is not counted
- **WHEN** room A occupies tile (2,3) and room B occupies tile (3,4) with no shared orthogonal edge
- **THEN** rooms A and B are NOT adjacent

### Requirement: A room is accessible once an adjacent room is cleared
A room SHALL become accessible as soon as any orthogonally adjacent room has been cleared. The start room is accessible from the beginning of the floor (no prerequisite). No other room is accessible before an adjacent room is cleared.

#### Scenario: Start room is immediately accessible
- **WHEN** a floor begins
- **THEN** the start room is accessible and the player may enter it

#### Scenario: Clearing a room unlocks adjacent rooms
- **WHEN** the player clears a room
- **THEN** all rooms orthogonally adjacent to that room become accessible (if not already cleared)

#### Scenario: Non-adjacent rooms remain locked
- **WHEN** a room has no cleared orthogonal neighbors
- **THEN** it is not accessible regardless of other cleared rooms on the floor

### Requirement: Floor room type distribution
Each generated floor SHALL contain at minimum: 1 Shop room, at least 1 combat room of each tier present on that floor, and the Boss/Exit room. Remaining room slots are drawn from the full room type pool (combat, shop, encounter) using RunState.rng. Encounter room type is determined at generation time but hidden from the player until entered.

#### Scenario: Shop guaranteed per floor
- **WHEN** a floor is generated
- **THEN** at least one room of type "shop" is present

#### Scenario: Boss/Exit always present
- **WHEN** a floor is generated
- **THEN** exactly one room of type "boss" is present at the fixed corner position

### Requirement: combat_rooms_cleared_this_floor tracks cleared combat rooms
`RunState` SHALL maintain a counter `combat_rooms_cleared_this_floor` that increments by 1 each time the player successfully clears a non-boss combat room on the current floor. The counter SHALL be reset to 0 when a new floor begins.

#### Scenario: Counter increments on combat room clear
- **WHEN** the player successfully clears a combat room (not the boss)
- **THEN** `combat_rooms_cleared_this_floor` increases by 1

#### Scenario: Counter resets on new floor
- **WHEN** a new floor begins
- **THEN** `combat_rooms_cleared_this_floor` is 0

#### Scenario: Shop and encounter rooms do not increment the counter
- **WHEN** the player enters and completes a shop or encounter room
- **THEN** `combat_rooms_cleared_this_floor` is unchanged

### Requirement: Non-boss combat room quota scales with combat_rooms_cleared_this_floor
The quota for a non-boss combat room SHALL be multiplied by `(1.0 + combat_rooms_cleared_this_floor * 0.08)`. This multiplier is applied after all other quota modifiers (floor scaling, ascension multiplier). The Boss/Exit room quota SHALL NOT use this multiplier.

#### Scenario: First combat room of the floor has no scaling
- **WHEN** the player enters the first combat room of a floor (combat_rooms_cleared_this_floor == 0)
- **THEN** the effective quota equals the base quota with no within-floor multiplier

#### Scenario: Third combat room cleared increases scaling
- **WHEN** `combat_rooms_cleared_this_floor` is 2 before entering a combat room
- **THEN** the effective quota is `ceil(base_quota * 1.16)`

#### Scenario: Boss quota is not affected by the counter
- **WHEN** the player enters the Boss/Exit room after clearing 4 combat rooms
- **THEN** the Boss quota uses only the floor-based formula, not the within-floor multiplier

### Requirement: Floor state is persisted in the save file
The current floor's room layout, each room's cleared state, and `combat_rooms_cleared_this_floor` SHALL be included in the save data written by `RunSave`. On load, the floor map SHALL be reconstructed from this data so the player resumes in the exact same room state.

#### Scenario: Resuming mid-floor restores cleared rooms
- **WHEN** the player saves mid-floor and reloads
- **THEN** the floor map shows the same rooms as cleared or accessible as before the reload
