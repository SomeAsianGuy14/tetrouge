## ADDED Requirements

### Requirement: RunFlow owns room-transition state
`RunFlow` SHALL be a `RefCounted` (not a `Node`) class that owns `current_room: DungeonRoom` and `pending_room_clear: DungeonRoom`. It SHALL never call `load()`, `add_child()`, or reference any Node or scene-tree object.

#### Scenario: Instantiable without scene tree
- **WHEN** a GUT test creates `RunFlow.new()` outside any scene
- **THEN** no errors occur and all methods are callable

### Requirement: RunFlow routes room entry by type
When `enter_room(room)` is called, `RunFlow` SHALL set `current_room = room` and emit exactly one routing signal based on `room.room_type`.

#### Scenario: Combat room emits combat_entered
- **WHEN** `enter_room` is called with a room of type TYPE_COMBAT_SMALL, TYPE_COMBAT_BIG, TYPE_COMBAT_ELITE, or TYPE_BOSS
- **THEN** `combat_entered(room)` is emitted

#### Scenario: Shop room emits shop_entered
- **WHEN** `enter_room` is called with a room of type TYPE_SHOP
- **THEN** `shop_entered(room)` is emitted

#### Scenario: Encounter room emits encounter_entered
- **WHEN** `enter_room` is called with a room of type TYPE_ENCOUNTER
- **THEN** `encounter_entered(room)` is emitted

### Requirement: Combat win marks current room cleared and increments counter
On `resolve_combat(true)` for a non-boss room, `RunFlow` SHALL set `current_room.cleared = true`, increment `RunState.combat_rooms_cleared_this_floor` by 1, and emit `round_success_requested(false)`.

#### Scenario: Room is marked cleared
- **WHEN** `resolve_combat(true)` is called with a non-boss `current_room`
- **THEN** `current_room.cleared == true`

#### Scenario: Counter incremented
- **WHEN** `resolve_combat(true)` is called with a non-boss `current_room`
- **THEN** `RunState.combat_rooms_cleared_this_floor` increases by 1

#### Scenario: Success signal emitted
- **WHEN** `resolve_combat(true)` is called with a non-boss `current_room`
- **THEN** `round_success_requested` is emitted with `is_boss == false`

### Requirement: Combat loss does not modify room state
On `resolve_combat(false)`, `RunFlow` SHALL NOT modify `current_room.cleared` or `RunState.combat_rooms_cleared_this_floor`, and SHALL emit `failure_requested`.

#### Scenario: Room stays uncleared on loss
- **WHEN** `resolve_combat(false)` is called
- **THEN** `current_room.cleared` remains `false`

#### Scenario: Counter unchanged on loss
- **WHEN** `resolve_combat(false)` is called
- **THEN** `RunState.combat_rooms_cleared_this_floor` is unchanged

#### Scenario: Failure signal emitted
- **WHEN** `resolve_combat(false)` is called
- **THEN** `failure_requested` is emitted

### Requirement: Boss win marks room cleared and advances or ends the run
On `resolve_combat(true)` for a boss room, `RunFlow` SHALL set `current_room.cleared = true` and emit `round_success_requested(true)`. When the success screen is dismissed (via `confirm_boss_cleared()`), RunFlow SHALL call `RunState.advance_floor()` if `RunState.floor < RunState.TOTAL_FLOORS` and emit `keystone_selection_requested`, OR emit `victory_requested` if `RunState.floor >= RunState.TOTAL_FLOORS`.

#### Scenario: Boss room marked cleared
- **WHEN** `resolve_combat(true)` is called with a boss `current_room`
- **THEN** `current_room.cleared == true`

#### Scenario: Floor advances when not the final floor
- **WHEN** `confirm_boss_cleared()` is called and `RunState.floor < RunState.TOTAL_FLOORS`
- **THEN** `RunState.advance_floor()` is called and `keystone_selection_requested` is emitted

#### Scenario: Victory triggered on final floor
- **WHEN** `confirm_boss_cleared()` is called and `RunState.floor >= RunState.TOTAL_FLOORS`
- **THEN** `victory_requested` is emitted and `RunState.advance_floor()` is NOT called

### Requirement: Robbers combat preserves original encounter room reference
`begin_robbers_combat()` SHALL save `current_room` into `pending_room_clear` before replacing `current_room` with a synthetic elite room, and SHALL return the synthetic room.

#### Scenario: Original room saved before overwrite
- **WHEN** `begin_robbers_combat()` is called with an encounter room as `current_room`
- **THEN** `pending_room_clear` equals the original encounter room

#### Scenario: current_room replaced with synthetic elite
- **WHEN** `begin_robbers_combat()` is called
- **THEN** `current_room.room_type == DungeonRoom.TYPE_COMBAT_ELITE` and `current_room` is not the original encounter room

### Requirement: Robbers combat win clears both rooms
On `resolve_combat(true)` when `pending_room_clear` is non-null, `RunFlow` SHALL set both `pending_room_clear.cleared = true` and `current_room.cleared = true`, then clear `pending_room_clear`.

#### Scenario: Original encounter room cleared after Robbers fight win
- **WHEN** `begin_robbers_combat()` was called and then `resolve_combat(true)` is called
- **THEN** the original encounter room's `cleared` property is `true`

#### Scenario: pending_room_clear reset after win
- **WHEN** `resolve_combat(true)` is called with a non-null `pending_room_clear`
- **THEN** `pending_room_clear == null` after the call

### Requirement: Shop and encounter resolution marks room cleared
`resolve_shop(room)` and `resolve_encounter(room)` SHALL set `room.cleared = true` and emit `dungeon_map_requested`.

#### Scenario: Shop room cleared
- **WHEN** `resolve_shop(room)` is called
- **THEN** `room.cleared == true` and `dungeon_map_requested` is emitted

#### Scenario: Encounter room cleared
- **WHEN** `resolve_encounter(room)` is called
- **THEN** `room.cleared == true` and `dungeon_map_requested` is emitted
