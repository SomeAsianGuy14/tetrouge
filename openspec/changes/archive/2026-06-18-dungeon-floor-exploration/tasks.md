## 1. Data Model — DungeonRoom and DungeonFloor

- [x] 1.1 Create `game/resources/dungeon_room.gd`: fields for `room_type` (String), `tile_footprint` (Array[Vector2i]), `visual_size` (Vector2i), `cleared` (bool), `adjacency` (Array[int] — indices into floor.rooms)
- [x] 1.2 Create `game/resources/dungeon_floor.gd`: fields for `rooms` (Array[DungeonRoom]), `floor_number` (int); methods `get_start_room()`, `get_boss_room()`, `get_accessible_rooms()`, `get_cleared_rooms()`
- [x] 1.3 Add `floor: int`, `current_floor_data: DungeonFloor`, and `combat_rooms_cleared_this_floor: int` to `game/autoloads/run_state.gd`
- [x] 1.4 Remove `stage` and `round_index` from `RunState`; remove `advance_round()` and replace with `advance_floor()` (increments floor, resets counter, generates new floor)
- [x] 1.5 Remove `TOTAL_STAGES`, `ROUNDS_PER_STAGE`, `ROUND_NAMES` constants from `RunState`; add `TOTAL_FLOORS = 4` and room tier constants
- [x] 1.6 Update `RunState.reset()` to initialise `floor = 1`, `combat_rooms_cleared_this_floor = 0`, and generate first floor via the generator

## 2. Floor Generation Algorithm

- [x] 2.1 Create `game/scripts/dungeon_generator.gd`: static class with `generate(floor_number: int, rng: RandomNumberGenerator) -> DungeonFloor`
- [x] 2.2 Implement fixed placement: start room (1×1) at tile (0,5); Boss/Exit room (2×2) at tiles (4,0)–(5,1)
- [x] 2.3 Implement seeded interior room placement: draw 6–8 rooms, assign types from distribution pool (min 1 shop, combat tiers, encounter types), assign visual sizes 1–4 tiles; place without overlapping existing footprints
- [x] 2.4 Implement adjacency computation: after all rooms are placed, build adjacency lists for every room pair whose tile footprints share an orthogonal edge
- [x] 2.5 Implement BFS connectivity validation: verify start room can reach Boss/Exit through adjacency; retry with seed offset (up to 10 times) if not; fall back to guaranteed-connected template on failure
- [x] 2.6 Implement room type distribution: draw types using `RunState.rng` with weighted pool (combat tiers weighted by floor number, encounter pool, shop)
- [x] 2.7 Mark start room as cleared at generation time so adjacent rooms are immediately accessible

## 3. Quota and Difficulty Scaling Updates

- [x] 3.1 Replace `RunState.calculate_quota(stage, round_index)` with `calculate_quota(floor: int, room_tier: String) -> int` using formula `20 * (2^(floor-1)) + tier_bonus` (tier bonuses: Small=0, Big=12, Elite=24, Boss=36)
- [x] 3.2 Add within-floor multiplier in `RunManager._build_round_config()`: for non-boss rooms, multiply quota by `(1.0 + RunState.combat_rooms_cleared_this_floor * 0.08)`, rounded up
- [x] 3.3 Update `RunManager._draw_enemy()` to accept room tier string directly instead of deriving from `round_index`
- [x] 3.4 Update garbage interval/line constants: enemy tier still maps to `SMALL_/BIG_/ELITE_/BOSS_` constants (unchanged); ensure tier is passed from room rather than inferred from round index

## 4. RunManager — Room Dispatch and Flow

- [x] 4.1 Replace `RunManager.start_round()` call sites with `RunManager.enter_room(room: DungeonRoom)`; route to `_start_combat_room()`, `_open_shop_room()`, or `_start_encounter_room()` based on `room.room_type`
- [x] 4.2 Remove the automatic shop-after-combat flow from `RunManager._on_success_proceed()`: on combat success, show round success screen then return to dungeon map (not shop)
- [x] 4.3 Implement `RunManager._show_dungeon_map()`: hide board/HUD, instantiate `DungeonMap` scene, connect `room_selected` signal to `enter_room()`
- [x] 4.4 On combat room clear: increment `RunState.combat_rooms_cleared_this_floor`; if room is boss, call `_on_boss_cleared()` instead of showing map directly
- [x] 4.5 Implement `RunManager._on_boss_cleared()`: if `RunState.floor < 4`, show keystone selection then generate next floor and show dungeon map; if `RunState.floor == 4`, show victory screen
- [x] 4.6 Remove `_pending_keystone` flag logic (keystone selection now only after boss, handled in `_on_boss_cleared`)
- [x] 4.7 Implement `RunManager._open_shop_room()`: open shop scene; on shop closed, mark room cleared, save run, show dungeon map
- [x] 4.8 Implement `RunManager._start_encounter_room(room)`: instantiate `EncounterRoom` scene with room type; on encounter completed, mark room cleared, save run, show dungeon map

## 5. Dungeon Map Scene

- [x] 5.1 Create `game/scenes/dungeon/dungeon_map.tscn` with a Control root; grid of 6×6 tile slots rendered as a panel
- [x] 5.2 Implement `game/scenes/dungeon/dungeon_map.gd`: `setup(floor: DungeonFloor)` method that places room buttons/labels on the tile grid according to each room's `tile_footprint` and `visual_size`
- [x] 5.3 Implement fog-of-war rendering: tiles not adjacent to any cleared room render as grayed-out overlay; tiles adjacent to cleared rooms render with room info
- [x] 5.4 Implement room icon logic: encounter rooms show "?"; combat rooms show tier label (Small/Big/Elite); shop rooms show shop icon; Boss/Exit always visible with boss icon regardless of adjacency
- [x] 5.5 Implement cleared-room visual state: cleared rooms render in a distinct dimmed/checked style and are not selectable
- [x] 5.6 Wire room selection: clicking an accessible, uncleared room emits `room_selected(room: DungeonRoom)` signal; locked and cleared rooms do not emit
- [x] 5.7 Ensure Boss/Exit room is always rendered at full visibility from floor start (bypass fog check for boss room)

## 6. Encounter Room Scene

- [x] 6.1 Create `game/scenes/dungeon/encounter_room.tscn`: shared Control scene with a text panel, choice button area, and optional "Leave" button
- [x] 6.2 Implement `game/scenes/dungeon/encounter_room.gd`: `setup(room_type: String, run_state: RunState)` routes to the appropriate sub-panel; emits `encounter_completed` when done
- [x] 6.3 Implement **Wishing Well** sub-panel: coin spend button, probability tracker label, success/failure result display; reset probability on success; leave button
- [x] 6.4 Implement **Altar (Technique)** sub-panel: list player's techniques as selectable buttons; confirm sacrifice removes technique and grants blind random; leave button
- [x] 6.5 Implement **Altar (Keystone)** sub-panel: list player's keystones as selectable buttons; confirm sacrifice removes keystone and grants blind random; leave button
- [x] 6.6 Implement **Library** sub-panel: draw 10 techniques via `RunState.rng`; show as selectable list; selecting one adds it free; leave button
- [x] 6.7 Implement **Robbers** sub-panel: two buttons only (surrender gold / fight); surrender sets `Economy.coins = 0`; fight exits encounter and triggers Elite combat via `RunManager`
- [x] 6.8 Implement **Unfortunate Head Trauma** sub-panel: on entry remove random technique if any; show appropriate flavor message; dismiss button returns to map
- [x] 6.9 Implement **Pickpocket** sub-panel: on entry deduct `floor(Economy.coins * 0.5)`; display numeric loss; dismiss button returns to map
- [x] 6.10 Implement **Museum** sub-panel: draw one keystone via `RunState.rng` and display name + description; take button adds it free; leave button

## 7. Save / Load Updates

- [x] 7.1 Update `game/scripts/run_save.gd` to serialise `RunState.floor`, `RunState.combat_rooms_cleared_this_floor`, and `RunState.current_floor_data` (rooms array with type, footprint, cleared state, adjacency)
- [x] 7.2 Implement deserialization: on load, reconstruct `DungeonFloor` and `DungeonRoom` objects from saved JSON and restore to `RunState`
- [x] 7.3 Bump save format version field; old saves are treated as incompatible (no migration — abandoned on update)
- [x] 7.4 Trigger `RunSave.save()` after every room resolution (combat clear, shop close, encounter complete) in `RunManager`

## 8. Cleanup and Removal

- [x] 8.1 Remove the `SCENE_ROUND_SUCCESS`-to-shop linear flow wiring in `RunManager` (shop no longer auto-follows combat)
- [x] 8.2 Remove `RunManager._show_shop()` direct calls that were triggered post-combat; ensure shop is only opened via `_open_shop_room()`
- [x] 8.3 Update failure screen setup call in `RunManager._show_failure()`: remove `stage`/`round_index` args, pass `floor` instead
- [x] 8.4 Update `RunState.is_boss_round()` → `is_boss_room(room: DungeonRoom) -> bool` check on room type
- [x] 8.5 Update all references to `RunState.stage` and `RunState.round_index` across the codebase (HUD, stats screen, run save, ascension checks)

## 9. Testing

- [x] 9.1 Add `test_dungeon_floor.gd`: test `calculate_quota` returns correct value for each floor (1–4) and tier (Small/Big/Elite/Boss)
- [x] 9.2 Add test: within-floor quota multiplier — `combat_rooms_cleared = 3` produces `ceil(base * 1.24)` for non-boss; boss is unaffected
- [x] 9.3 Add test: `DungeonFloor.get_accessible_rooms()` returns only start room at floor start; returns newly adjacent rooms after clearing start
- [x] 9.4 Add test: orthogonal adjacency — rooms sharing a tile edge are adjacent; diagonally-only rooms are not
- [x] 9.5 Add test: BFS connectivity — generated floor always has a path from start to boss (run 20 iterations with different seeds)
- [x] 9.6 Add test: `combat_rooms_cleared_this_floor` increments on combat clear, does not increment on shop/encounter clear, resets on `advance_floor()`
- [x] 9.7 Add test: Wishing Well probability — starts at 1%, increments by 1% per failure, resets to 1% on success
- [x] 9.8 Add test: Pickpocket deducts `floor(coins * 0.5)` correctly for even and odd coin amounts, and no-op at 0 coins
- [x] 9.9 Add test: Head Trauma removes one technique when techniques exist; no-op when techniques array is empty
- [x] 9.10 Add test: seeded floor generation — same `floor_number` + same `rng` seed produces identical room layout
- [x] 9.11 Add test: `RunState.reset()` sets `floor = 1`, `combat_rooms_cleared_this_floor = 0`, and generates a valid floor
