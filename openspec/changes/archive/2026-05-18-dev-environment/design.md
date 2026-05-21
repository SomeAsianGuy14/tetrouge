## Context

The game is a Godot 4 / GDScript project with no existing test infrastructure. Core systems (attack calculation, T-spin detection, economy, bag randomiser) are pure logic with no UI dependencies, making them straightforward to unit test. The debug overlay and dev console are additive tools that sit outside the production game loop.

GUT (Godot Unit Testing) is the de-facto standard for GDScript unit testing, with active maintenance, Godot 4 support, and headless CLI runner support — making it suitable for both interactive and CI use.

## Goals / Non-Goals

**Goals:**
- Install GUT and verify it runs both in-editor and headlessly via CLI
- Cover all deterministic, pure-logic systems with unit tests
- Provide a live debug overlay to inspect internal state during manual play
- Provide a dev console to manipulate game state without restarting
- Exclude all dev/test tooling from release export builds

**Non-Goals:**
- Integration tests that drive the full game loop (scene instantiation, input simulation)
- Automated CI pipeline setup (out of scope — local dev only per the proposal)
- Performance benchmarking or profiling tooling
- Visual regression testing

## Decisions

### D1: GUT via direct folder install (not submodule)

Copy GUT source into `addons/gut/` directly rather than using a git submodule. The project has no existing git repository, so submodule management adds overhead without benefit. GUT can be downloaded as a zip from its GitHub releases page.

**Alternative considered:** Godot's built-in `GDScriptTests` (not a real framework — no assertions or test runner UI). Rejected: far less capable than GUT.

### D2: Tests mirror the `scripts/` and `autoloads/` structure

Test files live in `tests/unit/` and are named `test_<module>.gd`. Each test file extends `GutTest`. This keeps tests close conceptually to the code they cover without co-locating them in the source tree (which would include them in exports unless explicitly excluded).

```
tests/
  unit/
    test_attack_system.gd
    test_economy.gd
    test_bag_randomizer.gd
    test_round_config.gd
    test_tspin_detection.gd
```

### D3: Debug overlay as a CanvasLayer added by RunManager

The debug overlay is a `CanvasLayer` (always on top) instantiated by `RunManager` in debug builds only. It connects directly to `TetrisBoard` signals and reads `RunState`/`Economy` autoloads each frame. Toggle is `F2` (distinct from the dev console toggle `F1`) to avoid conflict.

**Why CanvasLayer:** Renders above all game content regardless of scene tree position. No z-index wrestling.

**Why RunManager instantiates it:** RunManager already owns the board reference needed to read live state. Avoids a global singleton for a dev-only tool.

### D4: Dev console as a standalone CanvasLayer scene

The dev console is a separate `CanvasLayer` scene (`scenes/debug/dev_console.tscn`) that registers itself as an autoload equivalent by being added to the scene tree root at startup — but only when the `DEBUG` feature flag is present or a dev build constant is set.

Commands are parsed from a `LineEdit` input. The console maintains a scrollable log of output. Commands call directly into `RunState`, `Economy`, and the active `RunManager` (located via `get_tree().get_nodes_in_group("run_manager")`).

**Why not an autoload:** Autoloads always load; this should only exist in dev builds. Adding it programmatically based on a flag is cleaner.

### D5: Export exclusion via Godot export filters

In the Godot export dialog, add `addons/gut/*` and `tests/*` and `scenes/debug/*` to the export filter exclusion list. This is documented in the tasks rather than automated, since export presets are editor-configured.

### D6: `.gutconfig.json` for headless runs

A `.gutconfig.json` at the project root configures GUT for `godot --headless -s addons/gut/gut_cmdln.gd` invocation. This enables `godot --headless -s addons/gut/gut_cmdln.gd -gconfig=.gutconfig.json` to run all tests from a terminal without opening the editor.

## Risks / Trade-offs

**GUT version compatibility with Godot 4.6** → GUT actively tracks Godot releases; check the GUT GitHub for the latest 4.x-compatible release before installing.

**TetrisBoard tests require a mocked RoundConfig** → `TetrisBoard.setup()` expects a `RoundConfig` resource. Tests must construct a minimal config. This is straightforward but means tests are slightly integration-flavoured for board-level logic.

**Dev console command parser is hand-rolled** → Simple `split(" ")` parsing is fragile for edge cases. Acceptable for a dev tool; document supported syntax clearly in the console help command.

**Debug overlay performance** → Reading grid state every frame is cheap (200 cells), but string formatting in `_draw()` or label updates can be slow if overdone. Mitigate by updating labels on a timer (4× per second) rather than every frame.

## Open Questions

- Should the debug overlay persist across scene changes (i.e., be a permanent autoload in dev builds), or only exist during active rounds? Recommend: only during rounds — RunManager controls it.
- Which GUT version to pin? Check gut GitHub for latest Godot 4.6 compatible tag before install.
