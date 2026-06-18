## Why

`RunManager` is a 1,600-line Godot Node that handles game flow state, combat simulation, technique evaluation, UI scene lifecycle, and economy calculation all in one class. Because every function ultimately relies on the scene tree or other Node state, none of the room-routing or floor-progression logic can be exercised from unit tests — bugs (like the Robbers room not clearing on win) are only discoverable through manual play.

## What Changes

- Extract a new `RunFlow` class (`game/scripts/run_flow.gd`, `extends RefCounted`) that owns all room-transition state and floor-progression decisions
- `RunFlow` communicates back to `RunManager` exclusively via signals — it never loads scenes, calls `add_child`, or references any Node
- `RunManager` is refactored to hold a `RunFlow` instance, delegate routing decisions to it, and respond to its signals to drive UI
- A new GUT test file covers `RunFlow` in isolation with no scene tree

## Capabilities

### New Capabilities

- `run-flow-state-machine`: Pure-GDScript state machine owning `current_room`, `pending_room_clear`, room routing, room-clear marking, floor-advancement logic, and victory/failure decisions. Communicates via signals only.

### Modified Capabilities

- `run-manager`: Loses direct room-state fields (`_current_room`, `_pending_room_clear`) and routing logic; gains a `RunFlow` instance and signal handlers that translate RunFlow events into scene operations.

## Impact

- **New file**: `game/scripts/run_flow.gd`
- **New test file**: `game/tests/unit/test_run_flow.gd`
- **Modified**: `game/scenes/game/run_manager.gd` — fields removed, signal wiring added, routing methods replaced by delegation
- No changes to `RunState`, `Economy`, `DungeonRoom`, `DungeonFloor`, save system, or any scene files
- No breaking changes to external call sites (`start_run()`, `enter_room()`, `start_robbers_combat()` remain public on `RunManager`)
