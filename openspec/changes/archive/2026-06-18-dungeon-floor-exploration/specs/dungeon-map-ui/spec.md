## ADDED Requirements

### Requirement: Dungeon map is shown after every room is resolved
After any room interaction concludes (combat cleared, shop closed, encounter completed), the dungeon map screen SHALL be shown. The dungeon map is the hub the player returns to between all rooms. The map is not shown during combat, during shop interactions, or during encounter room interactions.

#### Scenario: Map shown after combat room cleared
- **WHEN** the player successfully clears a combat room
- **THEN** the round success income screen is shown, then the dungeon map is displayed

#### Scenario: Map shown after shop or encounter room
- **WHEN** the player exits a shop room or completes an encounter room
- **THEN** the dungeon map is displayed immediately (no income screen)

#### Scenario: Map not shown during active rooms
- **WHEN** the player is inside a combat, shop, or encounter room
- **THEN** the dungeon map is not visible

### Requirement: Fog of war — unvisited non-adjacent tiles are grayed out
Any tile that has no cleared room orthogonally adjacent to it SHALL be rendered as a grayed-out tile. Grayed-out tiles communicate that something exists there but provide no information about room type or size.

#### Scenario: Unopened far tiles are grayed
- **WHEN** the floor begins and only the start room is accessible
- **THEN** all tiles except those adjacent to the start room are rendered grayed out

#### Scenario: Clearing a room reveals adjacent tiles
- **WHEN** the player clears a room
- **THEN** tiles belonging to adjacent rooms transition from grayed-out to their accessible state

### Requirement: Encounter rooms show as "?" when accessible but unvisited
An accessible room of any encounter type (Wishing Well, Altar, Library, Robbers, Head Trauma, Pickpocket, Museum) SHALL display a "?" icon rather than its specific type name or icon. The room type is revealed only after the player enters the room.

#### Scenario: Encounter room shows question mark before entry
- **WHEN** an encounter room becomes accessible
- **THEN** it is displayed with a "?" indicator and no further type information

#### Scenario: Encounter room type revealed on entry
- **WHEN** the player selects and enters the room
- **THEN** the encounter room interaction begins (type is revealed through the interaction itself)

### Requirement: Combat and Shop rooms show their type when accessible
An accessible combat room SHALL display its tier (Small, Big, or Elite). An accessible Shop room SHALL display a shop icon. These are shown as soon as the room is accessible.

#### Scenario: Combat room tier visible when accessible
- **WHEN** a combat room of tier "Elite" becomes accessible
- **THEN** it is displayed with an "Elite" label or icon

#### Scenario: Shop room icon visible when accessible
- **WHEN** a shop room becomes accessible
- **THEN** it is displayed with a shop icon

### Requirement: Boss/Exit room is always visible from floor start
The Boss/Exit room SHALL be visible with its type (Boss) at all times, regardless of whether adjacent rooms have been cleared. It SHALL be rendered at full visibility (not grayed out) even before any room is cleared.

#### Scenario: Boss/Exit visible on floor start
- **WHEN** a new floor begins and only the start room is accessible
- **THEN** the Boss/Exit room is rendered at full visibility with a boss indicator

### Requirement: Only accessible, uncleared rooms are selectable
The player SHALL only be able to select rooms that are both accessible (an adjacent room has been cleared) and not yet cleared. Grayed-out rooms, already-cleared rooms, and the start room (auto-cleared at floor start) SHALL not be selectable.

#### Scenario: Accessible uncleared room is clickable
- **WHEN** a room is accessible and not yet cleared
- **THEN** the player can select it to enter

#### Scenario: Cleared room is not re-enterable
- **WHEN** a room has already been cleared
- **THEN** it cannot be selected again

#### Scenario: Locked room cannot be selected
- **WHEN** a room has no cleared orthogonal neighbor
- **THEN** it cannot be selected

### Requirement: Cleared rooms are visually distinguished on the map
Rooms that have been cleared SHALL be rendered in a distinct visual state (e.g., dimmed or checked) so the player can see their progress through the floor at a glance.

#### Scenario: Cleared room appears distinct
- **WHEN** a room is cleared
- **THEN** its map tile is rendered in a visually distinct "cleared" state, different from accessible-uncleared and grayed-out states

### Requirement: The start room is treated as cleared from floor start
The start room SHALL be rendered in the cleared state immediately when the floor begins, without requiring the player to perform any action. Its adjacent rooms SHALL be accessible from the first frame.

#### Scenario: Start room cleared at floor begin
- **WHEN** a floor begins
- **THEN** the start room is in the cleared state and its neighbors are accessible
