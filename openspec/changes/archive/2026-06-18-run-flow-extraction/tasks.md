## 1. Create RunFlow class

- [x] 1.1 Create `game/scripts/run_flow.gd`: `class_name RunFlow extends RefCounted` with fields `current_room: DungeonRoom` and `pending_room_clear: DungeonRoom`
- [x] 1.2 Declare all output signals: `combat_entered(room)`, `shop_entered(room)`, `encounter_entered(room)`, `dungeon_map_requested`, `round_success_requested(is_boss: bool)`, `keystone_selection_requested`, `victory_requested`, `failure_requested`
- [x] 1.3 Implement `enter_room(room: DungeonRoom)`: set `current_room = room`, emit the correct routing signal based on `room.room_type`
- [x] 1.4 Implement `resolve_combat(won: bool)`: on win, mark `current_room.cleared`, clear `pending_room_clear` if set, increment or advance floor as appropriate, emit `round_success_requested` or `failure_requested`; on loss emit `failure_requested`
- [x] 1.5 Implement `confirm_boss_cleared()`: if `RunState.floor >= RunState.TOTAL_FLOORS` emit `victory_requested`; otherwise call `RunState.advance_floor()` and emit `keystone_selection_requested`
- [x] 1.6 Implement `begin_robbers_combat() -> DungeonRoom`: save `current_room` to `pending_room_clear`, create and assign a synthetic `TYPE_COMBAT_ELITE` room to `current_room`, return the synthetic room
- [x] 1.7 Implement `resolve_shop(room: DungeonRoom)`: set `room.cleared = true`, emit `dungeon_map_requested`
- [x] 1.8 Implement `resolve_encounter(room: DungeonRoom)`: set `room.cleared = true`, emit `dungeon_map_requested`

## 2. Wire RunFlow into RunManager

- [x] 2.1 Add `var _flow: RunFlow` field to RunManager; instantiate it in `_ready()` and connect all RunFlow signals to new private handler methods
- [x] 2.2 Replace the body of `enter_room(room)` with delegation to `_flow.enter_room(room)`; keep the method public and its signature unchanged
- [x] 2.3 Add RunFlow signal handlers in RunManager: `_on_flow_combat_entered(room)` → calls existing `_start_combat_room(room)`; `_on_flow_shop_entered(room)` → calls existing `_open_shop_room(room)`; `_on_flow_encounter_entered(room)` → calls existing `_start_encounter_room(room)`
- [x] 2.4 Add handler `_on_flow_dungeon_map_requested()` → calls `_show_dungeon_map()`; replace the `_show_dungeon_map()` call in `_on_shop_room_closed` and `_on_encounter_completed` with `_flow.resolve_shop(room)` / `_flow.resolve_encounter(room)`
- [x] 2.5 In `_end_round(true)` non-boss path: replace direct mutations of `_current_room.cleared`, `_pending_room_clear`, and `RunState.combat_rooms_cleared_this_floor` with a call to `_flow.resolve_combat(true)`; add handler `_on_flow_round_success_requested(is_boss)` that continues the animation/success-screen chain
- [x] 2.6 In `_end_round(false)` path: call `_flow.resolve_combat(false)` instead of calling `_show_failure()` directly; add handler `_on_flow_failure_requested()` → `_show_failure()`
- [x] 2.7 In `_end_round(true)` boss path: after death animation, call `_flow.confirm_boss_cleared()` instead of `_on_boss_cleared()`; add handlers `_on_flow_keystone_selection_requested()` → `_show_keystone_selection_then_map()` and `_on_flow_victory_requested()` → `_show_victory()`
- [x] 2.8 Replace `start_robbers_combat()` body: call `_flow.begin_robbers_combat()` to get the synthetic room, then call `_show_board_ui()` and `start_round(synthetic_room)`
- [x] 2.9 Remove `_current_room` and `_pending_room_clear` fields from RunManager (now owned by RunFlow); update any remaining internal references to read from `_flow.current_room` instead

## 3. Testing

- [x] 3.1 Create `game/tests/unit/test_run_flow.gd` extending `GutTest`; add `before_each`/`after_each` to save and restore `RunState.floor` and `RunState.combat_rooms_cleared_this_floor`
- [x] 3.2 Add test: `RunFlow.new()` instantiates without errors outside a scene tree
- [x] 3.3 Add test: `enter_room` with each combat type emits `combat_entered` and sets `current_room`
- [x] 3.4 Add test: `enter_room` with shop type emits `shop_entered`
- [x] 3.5 Add test: `enter_room` with encounter type emits `encounter_entered`
- [x] 3.6 Add test: `resolve_combat(true)` on non-boss room sets `current_room.cleared = true`
- [x] 3.7 Add test: `resolve_combat(true)` on non-boss room increments `RunState.combat_rooms_cleared_this_floor` by 1
- [x] 3.8 Add test: `resolve_combat(true)` on non-boss room emits `round_success_requested` with `is_boss == false`
- [x] 3.9 Add test: `resolve_combat(false)` does not change `current_room.cleared` and emits `failure_requested`
- [x] 3.10 Add test: `resolve_combat(false)` does not change `RunState.combat_rooms_cleared_this_floor`
- [x] 3.11 Add test: `resolve_combat(true)` on boss room sets `current_room.cleared = true` and emits `round_success_requested(true)`
- [x] 3.12 Add test: `confirm_boss_cleared()` on floor < TOTAL_FLOORS calls `RunState.advance_floor()` and emits `keystone_selection_requested`
- [x] 3.13 Add test: `confirm_boss_cleared()` on floor == TOTAL_FLOORS emits `victory_requested` and does NOT call `advance_floor`
- [x] 3.14 Add test: `begin_robbers_combat()` saves original room to `pending_room_clear` and replaces `current_room` with a TYPE_COMBAT_ELITE room
- [x] 3.15 Add test: after `begin_robbers_combat()`, `resolve_combat(true)` sets original encounter room's `cleared = true`
- [x] 3.16 Add test: after `begin_robbers_combat()`, `resolve_combat(true)` clears `pending_room_clear` to null
- [x] 3.17 Add test: `resolve_shop(room)` sets `room.cleared = true` and emits `dungeon_map_requested`
- [x] 3.18 Add test: `resolve_encounter(room)` sets `room.cleared = true` and emits `dungeon_map_requested`
