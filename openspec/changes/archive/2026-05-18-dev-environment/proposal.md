## Why

The Tetris roguelike codebase has no testing infrastructure or developer tooling, making it hard to verify individual systems (attack calculation, T-spin detection, economy logic) in isolation and slow to reproduce specific game states for debugging. Adding a test suite and dev tooling now, before the codebase grows, prevents regressions and shortens the feedback loop during gameplay tuning.

## What Changes

- Integrate **GUT (Godot Unit Test)** as the testing framework via a git submodule or direct install in `addons/gut/`.
- Add a **test suite** covering the core deterministic systems: attack calculation, T-spin detection, B2B/combo tracking, economy (payout, interest), `RoundConfig` quota scaling, and the bag randomiser.
- Add a **debug overlay scene** that can be toggled during play, showing live board state, active keystones/techniques, quota accumulator, and combo/B2B status.
- Add a **dev console** accessible in-game (F1 or configurable key) with commands to skip rounds, set ante/round, add coins, force-activate keystones/techniques, and insert garbage rows.
- Add a **test runner scene** (`res://tests/run_tests.tscn`) that executes all GUT tests headlessly and reports results to stdout.
- Configure a `.gutconfig.json` for headless CI-compatible test runs.

## Capabilities

### New Capabilities

- `gut-integration`: GUT framework installed and configured; test runner scene and `.gutconfig.json` set up for headless and in-editor runs.
- `unit-tests`: GDScript test files covering attack system, economy, bag randomiser, `RoundConfig` quota scaling, and T-spin/B2B/combo detection.
- `debug-overlay`: In-game togglable overlay displaying live internal state (board grid hash, active relics, quota progress, combo, B2B flag, current piece type).
- `dev-console`: In-game developer console (toggle with F1) supporting commands: `skip_round`, `set_ante <n>`, `add_coins <n>`, `give_keystone <id>`, `give_technique <id>`, `insert_garbage <rows>`, `set_quota <n>`.

### Modified Capabilities

_(none — no existing spec requirements change)_

## Impact

- **New dependency**: GUT addon (`addons/gut/`) — dev/test only, not included in release exports.
- **Affected files**: `project.godot` (GUT autoload added for editor runs), new `tests/` directory, new `scenes/debug/` directory.
- **No changes to game logic**: Debug overlay and dev console are additive; they read game state but do not modify production code paths.
- **Export**: `addons/gut/` and `tests/` should be excluded from HTML5/Desktop export via export filters.
