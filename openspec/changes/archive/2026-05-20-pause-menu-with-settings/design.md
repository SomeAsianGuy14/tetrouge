## Context

`RunManager` drives gameplay via `_process(delta)`, calling `current_board.tick(delta)` and `_tick_timer(delta)` every frame. Pausing simply means stopping these calls. `TetrisBoard.is_active` already gates all board logic; setting it to `false` freezes the board without any extra mechanism. The Settings screen (`settings.tscn`) is already a self-contained `Control` that saves to disk and calls `queue_free()` on close — it can be instantiated as a child of any scene. RunManager also hosts the shop, round success, and keystone selection screens as child nodes during their respective phases; during these phases `current_board` is null.

## Goals / Non-Goals

**Goals:**
- Open the pause overlay from any screen within an active run (round, shop, transitions) via a configurable keybind (default Escape).
- During an active round: also freeze the board and timer.
- During shop/transition screens: show the overlay without touching board state.
- Embed the existing `settings.tscn` directly inside the pause overlay (no duplication).
- Propagate DAS/ARR changes to the live board on resume.
- Pressing the pause keybind again closes the overlay.
- The pause keybind is itself rebindable via the Settings screen.

**Non-Goals:**
- Pausing from the main menu (RunManager is not active there).
- Animated transitions or dimming effects.
- Saving run state across sessions (no persistence of paused runs).

## Decisions

### 1. Pause is managed entirely by RunManager — no new autoload

**Alternatives considered:**
- **A) RunManager owns pause** — checks `Input.is_action_just_pressed("pause")` in `_process`, sets a `_paused` flag, instantiates the pause menu scene. Zero new infrastructure. Naturally covers all run phases because RunManager persists across rounds, shop, and transitions.
- **B) Separate PauseManager autoload** — global pause state, observable by any scene. Overkill for a single-scene game with one board at a time.

**Decision: Option A.** RunManager already persists across all run states. Adding a `_paused: bool` flag and checking the pause action in `_process` covers rounds, shop, and transition screens with a single code path.

### 2. Pause keybind is a new named input action registered in project.godot

A new `pause` action (default: Escape) is registered in project.godot. It is added to `REBINDABLE_ACTIONS` in `settings.gd` so it appears in the rebind list alongside game actions.

**Why a dedicated action rather than `ui_cancel`?** `ui_cancel` is Godot's built-in action used by UI elements (e.g., closing dialogs). Reusing it would cause conflicts. A dedicated `pause` action is unambiguous and rebindable without affecting UI behaviour.

### 3. Pause overlay is a new lightweight scene — Settings is instantiated inside it

The pause menu scene (`pause_menu.tscn` / `pause_menu.gd`) contains:
- A dimming `ColorRect` background
- Resume button, Quit button
- A container where `settings.tscn` is instantiated as a child

**Why not embed settings.tscn directly in run_manager.tscn?** The pause menu needs to be added and removed dynamically. Keeping it as a separate instantiable scene is cleaner than toggling visibility on a permanently-present node.

**Settings close button:** When Settings is opened from the pause menu, its close button (`_on_close → queue_free()`) frees the Settings instance and returns focus to the pause overlay. No changes needed to `settings.gd`.

### 4. DAS/ARR propagation on resume via direct board property write

On resume, RunManager reads `Settings.load_das()` and `Settings.load_arr()` and writes them directly to `current_board.das_delay` and `current_board.arr_rate`. This mirrors what `start_round()` already does, requiring no new API.

### 5. Board freeze via `is_active` flag, timer freeze via `_paused` flag in RunManager

`current_board.is_active = false` stops board ticking (only when a round is active). `_paused = true` in RunManager skips `_tick_timer` and `_handle_input` in `_process`. On resume, both are restored. When opened from the shop or a transition screen, `current_board` is null so no board state is changed — the overlay is purely cosmetic over the existing screen.

## Risks / Trade-offs

- [Player holds a key when pausing] → DAS/ARR state in the board is frozen mid-press. On resume the board continues from that state, which may cause a spurious horizontal movement. Mitigation: call `current_board.input_move_released()` before pausing.
- [Quit to Main Menu during a round] → Run state is not cleaned up automatically. Mitigation: call `RunState.reset()` and `Economy.reset()` before loading the main menu scene, matching the existing run-failure cleanup path.
- [Settings keybind rebind mode open when player resumes] → Rebind listen mode uses `_unhandled_input` inside the Settings node; since Settings is freed when the pause menu closes, this cleans up automatically.

## Migration Plan

1. Register `pause` input action (default Escape) in `project.godot`.
2. Add `{"action": "pause", "label": "Pause / Settings"}` to `REBINDABLE_ACTIONS` in `settings.gd`.
3. Create `game/scenes/game/pause_menu.tscn` and `pause_menu.gd` with the overlay layout.
4. Add `_paused` flag, `_pause_menu` reference, `_open_pause()`, and `_close_pause()` methods to `run_manager.gd`.
5. Wire `pause` action check in `RunManager._process()` — works in all run states (board active, board null).
6. Wire Resume/Close and Quit buttons in `pause_menu.gd` via signals back to RunManager.
7. On resume when board is active: propagate DAS/ARR to live board and restore `is_active`.

No rollback risk — all changes are additive. Removing the feature is as simple as deleting the pause menu scene and the `_paused` logic block.
