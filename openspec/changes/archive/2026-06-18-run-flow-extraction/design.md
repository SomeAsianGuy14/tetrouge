## Context

`RunManager` (`game/scenes/game/run_manager.gd`, ~1,600 lines, `extends Node`) is the single coordinator for an entire run. It currently mixes six concerns: game flow state, combat simulation, technique/keystone evaluation, enhancement tracking, economy calculation, and UI scene lifecycle. Because it `extends Node` and uses `@onready` vars and `add_child()` throughout, none of its logic is exercisable from GUT unit tests without a full scene tree.

The two most recent bugs — inaccessible dungeon rooms and the Robbers room not clearing on a combat win — both lived in the flow state machine fragment (~13 functions, ~80 lines) scattered across RunManager. A test would have caught both in seconds; manual play was required instead.

The narrow scope of this change is to extract only that flow state machine into a `RefCounted` class, leaving all combat simulation, technique evaluation, and UI lifecycle exactly where they are.

## Goals / Non-Goals

**Goals:**
- Create `RunFlow extends RefCounted` owning `current_room` and `pending_room_clear`
- Give `RunFlow` signal-only output so it can be instantiated in tests without a scene tree
- Cover all room-transition paths with GUT tests (combat win/loss, boss win, shop close, encounter close, robbers start/win/loss, floor advance, victory condition)
- Keep all public RunManager call sites (`start_run`, `enter_room`, `start_robbers_combat`) unchanged so no other code needs updating

**Non-Goals:**
- Extracting economy calculation (`_calculate_surplus_income`, `_apply_keystone_economy`) — separate follow-on
- Extracting combat config building (`_build_round_config`) — separate follow-on
- Changing any scene files, resources, or autoloads
- Changing save/load behaviour

## Decisions

### RunFlow communicates via signals, not return values

RunFlow cannot call `load()`, `add_child()`, or access any Node. The only way it can trigger UI is by emitting signals that RunManager listens to. This keeps RunFlow side-effect-free from the test's perspective: a test can connect to those signals to assert what transition was requested without anything being rendered.

Signals emitted by RunFlow:
```
signal combat_entered(room: DungeonRoom)
signal shop_entered(room: DungeonRoom)
signal encounter_entered(room: DungeonRoom)
signal dungeon_map_requested()
signal round_success_requested(is_boss: bool)
signal keystone_selection_requested()
signal victory_requested()
signal failure_requested()
```

**Alternative considered**: RunFlow returns an enum/struct describing what should happen next (a command object). Rejected because Godot signals are already the idiomatic decoupling mechanism and avoid an extra dispatch loop in RunManager.

### RunFlow reads RunState and DungeonRoom directly; does not own copies

`RunState` is a global autoload; `DungeonRoom` objects are reference-counted and shared with `current_floor_data`. RunFlow reads and writes these directly (incrementing `combat_rooms_cleared_this_floor`, calling `RunState.advance_floor()`, setting `room.cleared = true`) rather than being passed values. This matches how RunState is already used everywhere and keeps call sites simple.

**Alternative considered**: Pass all relevant state as parameters so RunFlow has zero autoload access (fully pure). Rejected as over-engineering for this scope — RunState is already well-tested and its mutation is the desired side effect.

### RunManager keeps `_round_income_breakdown` and passes it when emitting round_success_requested

The success screen needs income figures that are computed inside `_end_round` (surplus income, keystone income). RunFlow doesn't know these; RunManager does. RunManager calls `flow.resolve_combat(won)`, and RunFlow emits `round_success_requested(is_boss)`. RunManager's signal handler then opens the success screen using its locally-computed breakdown. This keeps income calculation out of RunFlow's scope without requiring RunFlow to accept income data it doesn't own.

### pending_room_clear is internal to RunFlow

The Robbers pattern — save original room before overwriting `current_room` — is entirely encapsulated inside RunFlow. `begin_robbers_combat()` saves the reference and returns the synthetic elite room; `resolve_combat(true)` clears both. RunManager never touches `pending_room_clear` directly.

### RunManager.enter_room and start_robbers_combat remain public

These are called by `DungeonMap` (via signal) and `EncounterRoom` respectively. Making them delegate into `RunFlow` instead of doing the work themselves keeps all callers unchanged.

## Risks / Trade-offs

**Risk: RunManager signal wiring becomes hard to follow** — RunManager currently reads as a linear call graph. After this change, some transitions become: RunManager calls RunFlow method → RunFlow emits signal → RunManager handler fires. For developers unfamiliar with the pattern this can be harder to trace.
→ Mitigation: Comment each RunFlow signal connection in RunManager with a one-line description of what it triggers.

**Risk: Signal not connected before first emit** — If RunFlow emits a signal before RunManager has connected its handlers (e.g., `start_run` calls `flow.enter_room` before `_ready` wires the signals), the event is silently dropped.
→ Mitigation: Instantiate and connect RunFlow in `_ready` before `start_run` is ever callable. Covered by test that asserts signal was received.

**Risk: Regression in transition order** — The current code has implicit ordering (income calculated, then `_pending_round_end` set, then animation plays, then callback fires). Extracting the state change must not alter this order.
→ Mitigation: RunManager still controls animation timing via `_pending_round_end`. `flow.resolve_combat(won)` is called at the same point `_end_round` currently mutates state — after income is calculated, before the success screen shows.

## Migration Plan

1. Create `game/scripts/run_flow.gd` with full signal and method surface
2. In RunManager `_ready`, instantiate `RunFlow`, connect all its signals to new private handlers
3. Redirect `enter_room`, `start_robbers_combat`, and the relevant block of `_end_round` to call into `flow`
4. Remove `_current_room` and `_pending_room_clear` fields from RunManager (now owned by RunFlow)
5. Write `test_run_flow.gd` and confirm all tests pass
6. Manual smoke test: start a run, enter each room type, defeat a boss, reach floor 4 victory, lose a run

No rollback complexity — this is a pure refactor with identical observable behaviour. If tests regress, revert the RunManager changes; RunFlow itself has no persistent state.

## Open Questions

- None. Scope is fully defined and all dependencies (DungeonRoom, RunState, the existing signal pattern) are stable.
