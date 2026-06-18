## Context

The current run progression is a rigid linear sequence managed by `RunManager` (`run_manager.gd`): after each Tetris round the player is funnelled through a fixed pipeline (round success screen → optional keystone selection → shop → next round). `RunState` tracks position via `stage` (1–5) and `round_index` (0–3). There is no player agency between rounds and every run visits the same sequence of room types.

The change replaces this pipeline with a dungeon-map layer: each of 4 floors is a procedurally-generated 6×6 tile map containing mixed room types. Players navigate from a fixed start corner to the Boss/Exit corner by clearing rooms and unlocking orthogonally adjacent ones. `RunManager` becomes a room dispatcher rather than a linear sequencer.

## Goals / Non-Goals

**Goals:**
- Player chooses which rooms to enter (routing agency) within each floor
- Non-combat encounter rooms add variety without touching Tetris mechanics
- Shop is optional (a map room) rather than mandatory
- Fog of war makes exploration feel meaningful; encounter room types are hidden until entered
- Boss has fixed per-floor difficulty; other combat rooms scale with `combat_rooms_cleared_this_floor`
- All dungeon state is seeded from `RunState.rng` for determinism and save/load correctness

**Non-Goals:**
- Procedural corridor generation between rooms (rooms are nodes; adjacency is tile-footprint based)
- True multi-tile mechanical room entry (rooms are single encounter nodes displayed at variable visual sizes)
- Branching floor paths or multiple exit options
- Story/narrative text beyond encounter room dialogue strings

## Decisions

### 1. Floor map as a data resource, not a live scene graph

**Decision:** The floor is represented as a `DungeonFloor` GDScript object (not a scene) containing an array of `DungeonRoom` objects, each holding its tile footprint, room type, cleared state, and adjacency list. The `DungeonMap` scene reads from this data to render.

**Why:** Keeps map state serialisable (save/load via `RunSave`), testable without a running scene tree, and decoupled from rendering. The alternative — encoding floor state directly in scene nodes — would make save/load and unit testing significantly harder.

**Alternatives considered:** Storing state in a TileMap scene node directly. Rejected because TileMap state is not trivially serialisable to JSON and couples data to the renderer.

---

### 2. 6×6 display-tile grid, rooms as visual-size nodes

**Decision:** The map canvas is a 6×6 tile grid. Rooms are single encounter nodes but rendered at variable visual sizes (1–4 tiles). The underlying data is a graph of rooms with tile-footprint arrays; the grid is only used for layout and adjacency computation.

**Why:** Variable visual sizes give the map a dungeon feel without the complexity of multi-tile mechanical room entry (multiple entry points, partial adjacency, corridor pathfinding). The start room is 1×1 at (0,5), the Boss/Exit is 2×2 anchored at (4,0)–(5,1) (top-right area).

**Alternatives considered:** Option A (mechanically multi-tile rooms with multiple entry points). Rejected as significantly higher complexity for minimal gameplay gain at this stage.

---

### 3. Fog-of-war and room type visibility

**Decision:**
- Tiles not adjacent to any cleared room: grayed-out overlay (existence known, nothing else)
- Tiles adjacent to a cleared room (accessible): room icon visible, EXCEPT encounter rooms which show "?" until entered
- Combat rooms (Small/Big/Elite) and Shop rooms show their type when accessible
- Boss/Exit room is always fully visible regardless of adjacency

**Why:** Encounter rooms hiding as "?" preserves tension for events (positive and negative alike). Showing combat tier lets players make informed routing decisions about which fights to take. Always showing the Boss/Exit gives the player a navigation landmark.

---

### 4. RunState floor tracking replaces stage/round_index

**Decision:** `RunState` replaces `stage` and `round_index` with:
- `floor: int` (1–4)
- `current_floor_data: DungeonFloor` (null between floors)
- `combat_rooms_cleared_this_floor: int`

`advance_round()` is removed. Floor advancement happens when the Boss/Exit room is cleared: `RunManager` triggers keystone selection then calls `RunState.advance_floor()` which increments `floor`, generates a new `DungeonFloor`, and resets `combat_rooms_cleared_this_floor`.

**Why:** The old `advance_round()` linear model is incompatible with map-based navigation. Floor is a cleaner abstraction — one unit of dungeon to explore.

**Alternatives considered:** Keeping `stage`/`round_index` and adding a map layer on top. Rejected because `round_index` has no meaning in a graph-based room system and would cause confusion.

---

### 5. Combat difficulty scaling within a floor

**Decision:** Non-boss combat rooms use a tier drawn at floor-generation time (Small/Big/Elite) but apply a `combat_rooms_cleared_this_floor` scalar to the quota and garbage parameters at round-config build time. Formula: `effective_quota = base_quota * (1.0 + combat_rooms_cleared * 0.08)`. Boss quota uses only the floor-based formula with no within-floor scalar.

**Why:** Rewards exploration with power (shop, events, keystone options) while making late-floor fights genuinely harder. The 8% per room cleared is a starting balance point subject to playtesting. Boss being fixed gives the player a stable target to plan around.

---

### 6. Dungeon map as an overlay scene, not a separate scene tree root

**Decision:** `DungeonMap` is instantiated and added as a child of `RunManager` (like the existing shop scene), not pushed as a new scene-tree root. When the map is showing, the board and HUD are hidden. On room selection the map is removed and the appropriate room flow begins.

**Why:** Consistent with how the existing shop, keystone selection, and round success screens work. Avoids scene-tree ownership complexity and keeps `RunManager` as the single coordinator.

---

### 7. Encounter room UI: single generic scene with type-driven content

**Decision:** All encounter rooms share one `EncounterRoom` scene. Room type is passed in at instantiation and drives which panel/interaction is shown. Each encounter type is a sub-panel (or state in a state machine) within the same scene.

**Why:** Encounter rooms all follow the same outer shell (enter, interact, leave/return to map). A shared scene avoids duplicating the frame, back-to-map logic, and RunManager hookup for each of the 9 encounter types.

---

### 8. Procedural floor generation algorithm

**Decision:** Seeded generation using `RunState.rng`:
1. Place start room (1×1) at bottom-left corner.
2. Place Boss/Exit room (2×2) at top-right corner (tiles (4,0),(5,0),(4,1),(5,1)).
3. Generate 6–8 interior rooms with seeded type and size selection, placed via a flood-fill-style algorithm that guarantees at least one valid path from start to boss.
4. Room type distribution per floor: minimum 1 Shop, 1 combat at each tier present on floor, rest drawn from encounter pool.
5. After placement, compute adjacency list for every room pair whose tile footprints share an orthogonal edge.
6. Validate connectivity: BFS from start must reach boss; regenerate with new seed offset if not (retry cap: 10).

**Why:** Seeding from `RunState.rng` keeps floors deterministic per run seed (important for save/load and fairness). The retry cap prevents infinite loops on degenerate layouts.

---

### 9. Save/load format extension

**Decision:** `RunSave` serialises `DungeonFloor` as a nested dictionary: room array with type, tile footprint, cleared flag, and adjacency list. `combat_rooms_cleared_this_floor` and `floor` are added as top-level fields alongside the existing run-state fields.

**Why:** The existing `RunSave` is already JSON-based. Adding floor state follows the same pattern as existing fields. Cleared-room state is essential for resuming mid-floor.

## Risks / Trade-offs

**Floor generation producing disconnected maps** → Mitigation: BFS validation step in generation; retry up to 10 times with seed offset before falling back to a guaranteed-connected template layout.

**Encounter room "?" hiding negative rooms (Head Trauma, Pickpocket) feels unfair** → Accepted trade-off by design: all event rooms carry risk/reward ambiguity. Negative rooms are relatively rare in the pool.

**combat_rooms_cleared scaling making late-floor fights too hard** → Mitigated by: starting balance at 8% per room, boss being unaffected, and shop/event rooms being free to visit. Adjust scalar during playtesting.

**RunState breaking change affects RunSave format** → RunSave version field should be bumped; old saves are not compatible (no migration, existing runs are abandoned on update — acceptable for early access).

**Wishing Well probability could drain coins unexpectedly** → No cap on coin cost is intentional (player controls when to leave). The escalating probability curve means very long sessions become increasingly profitable.

## Resolved Questions

- **Encounter room distribution**: Encounter room types are drawn uniformly at random from the full pool. No weighting by floor or positive/negative ratio. With 7 non-negative and 2 negative encounter types the natural distribution is acceptable.
- **Room counter on the map**: No counter needed. The visual map itself is sufficient for the player to orient themselves relative to the Boss/Exit.
- **Robbers combat tier**: Fixed at Elite tier always. Does not scale with `combat_rooms_cleared_this_floor`.
