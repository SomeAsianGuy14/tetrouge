## Why

The current run structure sends the player through a fixed linear sequence (Small → Big → Elite → Boss) with no agency over what comes next, making each run feel mechanically identical between rounds. Replacing this with a dungeon-map exploration system gives the player meaningful routing decisions, adds variety through encounter rooms, and makes each floor feel like a distinct space to navigate rather than a conveyor belt.

## What Changes

- **BREAKING**: The linear ante/round progression (5 stages × 4 rounds) is replaced by a 4-floor dungeon map system
- Each floor is a 6×6-tile dungeon map containing 8–12 rooms of varying types, displayed at variable visual sizes (1–4 tiles)
- The player navigates from a fixed start corner to the Boss/Exit room at the opposite corner; rooms are only accessible once an orthogonally-adjacent room has been cleared
- Fog of war: unvisited tiles are grayed out; accessible encounter rooms show as "?" (type hidden until entered); accessible combat/shop rooms show their type; the Boss/Exit is always visible
- Non-combat encounter rooms are introduced: Wishing Well, Altar (Technique), Altar (Keystone), Library, Robbers, Unfortunate Head Trauma, Pickpocket, Museum
- Combat room difficulty scales with `combat_rooms_cleared_this_floor`; the Boss has a fixed power level per floor
- The shop is now an optional room on the map rather than a mandatory stop after every combat
- Between floors: Boss defeat → keystone selection → next floor dungeon map (preserving existing keystone reward)
- Run length changes from 20 rounds (5×4) to 4 floors; quota/difficulty scaling formulas adjust accordingly

## Capabilities

### New Capabilities

- `dungeon-floor`: Floor map structure — 6×6 tile grid, room placement, start/exit positions, adjacency rules, fog-of-war visibility state, seeded procedural generation
- `dungeon-map-ui`: Map screen rendered between rooms — tile grid display, room icons, fog overlay, clickable room selection, "?" encounter indicator
- `encounter-rooms`: All non-combat, non-shop room types with their interaction flows: Wishing Well, Altar (Technique & Keystone), Library, Robbers, Head Trauma, Pickpocket, Museum

### Modified Capabilities

- `run-structure`: Floor count changes from 5 stages to 4 floors; round advancement is replaced by room-based progression within a floor; `combat_rooms_cleared_this_floor` counter added for within-floor difficulty scaling
- `shop-system`: Shop is now an optional encounter room on the dungeon map rather than a mandatory post-round screen; shop availability is determined by map generation, not automatic after every combat

## Impact

- `game/autoloads/run_state.gd` — `stage`/`round_index` replaced by `floor`/`current_floor_data`; new `combat_rooms_cleared_this_floor` counter; floor grid state and room cleared tracking
- `game/scenes/game/run_manager.gd` — between-room flow replaced by dungeon map scene; `start_round()` flow becomes `enter_room(room)`; shop is no longer auto-shown after combat
- New scene: `game/scenes/dungeon/dungeon_map.tscn` + script
- New resource: `game/resources/dungeon_room.gd` and `DungeonFloor` data class
- New scene: `game/scenes/dungeon/encounter_room.tscn` for the text-choice encounter UI
- `game/scenes/screens/round_success.tscn` — remains for post-combat income display; now returns to dungeon map rather than shop
- Quota/difficulty scaling formulas in `RunState.calculate_quota()` and `RunManager._build_round_config()` updated for 4-floor structure
- `game/scripts/run_save.gd` — save format must include floor map state and cleared rooms
