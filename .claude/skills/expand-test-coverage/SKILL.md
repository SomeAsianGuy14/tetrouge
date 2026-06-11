---
name: expand-test-coverage
description: Audit a class or module for test coverage gaps and write tests to fill them. Covers three gap types: state × action interactions, invariant assertions, and cross-component boundary tests. Use when asked to improve test coverage, after adding a new feature, or after finding a bug that tests didn't catch.
---

## Overview

Most coverage gaps in this codebase fall into three categories. This skill audits a target class for all three, then writes the missing tests in `game/tests/unit/`.

## Step 1 — Identify the target

Accept the target as input (e.g. "TetrisBoard", "RunManager", or a file path). If not given, infer from recent conversation or ask.

Read the source file. Read the existing test file(s) for that class if they exist.

## Step 2 — Extract the three gap inventories

### A. State × Action matrix

**States** are variables that gate or change behaviour: booleans (`is_active`, `_in_line_clear_delay`, `hold_used`), counters that trigger branch logic (`lock_resets >= lock_max_resets`), or mode flags.

**Actions** are methods that the caller invokes to drive the class: `input_hold()`, `input_hard_drop()`, `input_rotate_*()`, `tick()`, `_lock_piece()`, etc.

For each (state, action) pair, ask: *does a test exist that verifies what happens when `action` is called while `state` is active?*

Build a table in your head:

```
State                  | input_hold | input_hard_drop | input_rotate | ...
-----------------------|------------|-----------------|--------------|----
is_active = false      | tested?    | tested?         | tested?      |
_in_line_clear_delay   | tested?    | tested?         | tested?      |
hold_used = true       | tested?    | N/A             | N/A          |
```

Cells that are missing tests = gap A.

### B. Invariants

**Invariants** are constraints that must hold after any operation:
- `piece_queue.size() == config.preview_count + 1` after any lock/spawn cycle
- `held_pieces.size() <= config.hold_slots` at all times
- `grid` row counts never change (always `TOTAL_ROWS`)
- `combo` is always >= -1
- `quota_accumulated` only increases
- Autoload state (RunState, Economy) is fully restored in `after_each`

For each operation or sequence, ask: *does any test assert these invariants afterward?*

Single-operation tests (call one function, check one return value) almost never assert invariants. Gaps = any operation whose post-state invariants aren't verified.

### C. Cross-component boundary

When a class gains a new state, its callers may need to know. Ask: *for every method or signal that crosses the boundary into this class, does the caller handle each state correctly?*

Specifically for TetrisBoard / RunManager:
- `RunManager._handle_input()` calls every `input_*` method — does it skip them in each board state?
- `RunManager._on_attack_generated()` reacts to board signals — are there tests for each event type × each relevant board state?
- `RunManager._on_lock_processed()` checks `_last_cleared_rows` — are there tests for the cleared vs no-cleared branches?

## Step 3 — Write the missing tests

Follow the project conventions exactly:

```gdscript
extends GutTest

# ── Shared setup ─────────────────────────────────────────────────────────────

var _board: TetrisBoard
var _cfg: RoundConfig

func before_each() -> void:
    _cfg = RoundConfig.new()
    _board = TetrisBoard.new()
    _board.setup(_cfg)

func after_each() -> void:
    _board.free()

# ── State × Action: _in_line_clear_delay ─────────────────────────────────────

func test_hold_during_delay_is_ignored() -> void:
    # set up state
    # assert invariant before
    # call action
    # assert state unchanged / invariant still holds
```

Rules for writing tests:
- One failure scenario per test — don't pack multiple assertions about unrelated things
- Name: `test_<action>_during_<state>_<expected_outcome>` or `test_<invariant>_holds_after_<operation>`
- Use `watch_signals(obj)` + `assert_signal_emitted` / `assert_signal_not_emitted` for signal ordering
- For autoload-dependent tests: save/restore in `before_each`/`after_each` as in `test_keystones.gd`
- Group related tests under `# ── Section ──────────────────────────────────────` headers

### Writing state × action tests

Template:
```gdscript
func test_<input>_during_<state>_is_ignored() -> void:
    # Reach the state
    <setup code to enter the state>
    # Snapshot observable state
    var <field>_before := _board.<field>
    # Fire the input
    _board.<input>()
    # Assert nothing changed that shouldn't have
    assert_eq(_board.<field>, <field>_before, "<input> during <state> should not change <field>")
    assert_true(_board.<state_flag>, "<state> should still be active")
```

For TetrisBoard states, the common setup helpers are:
```gdscript
# Enter _in_line_clear_delay:
func _fill_row(row: int) -> void:
    for col in range(10):
        _board.grid[row][col] = 1

func _set_safe_piece() -> void:
    _board.current_type = "O"
    _board.current_pivot = Vector2i(0, 0)
    _board.current_rotation = 0

_cfg.line_clear_delay = 0.5
_fill_row(21)
_set_safe_piece()
_board._lock_piece()
# board is now in _in_line_clear_delay
```

### Writing invariant tests

Template:
```gdscript
func test_<invariant>_preserved_after_<operation>() -> void:
    var expected_queue_size := _cfg.preview_count + 1
    # Perform operation sequence
    <operations>
    # Assert invariant
    assert_eq(_board.piece_queue.size(), expected_queue_size,
        "Queue size should be preview_count+1 after <operation>")
```

Key invariants to assert at end of sequence tests:
- `piece_queue.size() == config.preview_count + 1`
- `held_pieces.size() <= config.hold_slots`
- `combo >= -1`
- `is_b2b` is boolean (not corrupted)
- For RunManager tests: `Economy.coins >= saved_coins - max_spend` (coins never go negative without spend)

### Writing cross-component boundary tests

When RunManager is the caller, the pattern from `test_keystones.gd` applies:
```gdscript
var _rm: RunManager
var _saved_keystones: Array
# ... (save/restore all autoloads in before_each/after_each)

func test_handle_input_skips_hold_when_board_in_delay() -> void:
    # Set up board in delay state
    # Simulate a hold keypress via _rm._held_this_piece = ... 
    # or directly call _rm methods that trigger board input
    # Assert board state unchanged
```

Note: `RunManager._handle_input()` reads `Input` singleton, which can't be simulated in headless tests. For RunManager boundary tests, call `current_board.input_hold()` directly and verify that `RunManager`'s tracking state (`_held_this_piece`) remains consistent. OR write the test at the TetrisBoard level (as done for the hold-during-delay fix).

## Step 4 — Prioritise

Not all gaps need filling immediately. Prioritise in this order:

1. **Any state that has input handlers** — if you add a new state, ALL input handlers need a test for that state. Non-negotiable.
2. **Queue/collection invariants** — things that can be silently corrupted (piece queue, held pieces, garbage packets).
3. **Sequence tests for the main game loop** — lock → spawn, lock → delay → spawn, hold → lock → hold again.
4. **Cross-component boundaries** — lower priority if the component tests already cover all states.

## Step 5 — Run tests to confirm

After writing the new tests, run the suite:

```powershell
.\.claude\skills\run-tests\scripts\run_tests.ps1
```

All tests must pass. If a new test fails, that is a real bug — fix the implementation, not the test.

## What NOT to do

- Don't write tests that duplicate what already exists. Check existing test names before writing.
- Don't write tests for Godot internals (signals firing, `queue_free` timing, node tree structure).
- Don't test visual/scene layout — that's manual.
- Don't weaken assertions to make tests pass. A failing new test means the code has a bug.
- Don't write a single test that checks many unrelated things — split it.

## Coverage gap quick-reference

When reviewing a PR or a new feature, ask these questions:

| Question | Gap type |
|---|---|
| Does this class have a new state variable that gates behaviour? | A — write state × all-inputs matrix |
| Does any method modify a collection (queue, array, dictionary)? | B — write invariant assertion |
| Does this class emit a new signal? | B + C — write signal-ordering test AND caller-side test |
| Does a caller iterate over this class's state per frame? | C — write boundary test for each state |
| Was this bug found by a user, not a test? | Write the failing test FIRST, then fix |
