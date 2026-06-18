## Why

Run-end screens currently show almost no information — victory shows final coins and ascension unlock, failure shows only where the player died. A player's run stats (damage, combos, quad count, T-spins) are tracked in memory but never shown, making each run feel disposable. Surfacing these stats at run end and in a main-menu screen gives every run a meaningful summary and creates a sense of progression over time.

## What Changes

- **Run-end screen** (victory and failure) replaces the current bare screens with a full stats summary: total damage, best combo, best B2B, quad count, T-spin count, perfect clear count, total run time (MM:SS of active round time), and most common clear type — with "★ PB" markers where the run set a personal best. Also shows the player's final build (keystones + techniques active at run end).
- **Main menu Stats screen** — new screen accessible from a "Stats" button on the main menu, showing career stats (runs played, victories, best ascension), personal bests (single-run damage, combo, B2B), and lifetime totals (total damage, quads, T-spins, total play time).
- **Data model expansion** — `RunStats` gains quad count, T-spin count, perfect clear count, `run_time: float`, and `clear_counts: Dictionary` fields. `ProfileSave` gains matching lifetime totals, victory count, best single-run damage, and `total_play_time: float` for PB comparison and lifetime display.
- **PB comparison ordering fix** — personal bests are computed before accumulation so "★ PB" markers correctly reflect the previous best, not the newly updated one.

## Capabilities

### New Capabilities

- `run-end-stats`: Run-end screen (victory and failure) showing per-run stats with PB markers and final build summary
- `stats-screen`: Persistent stats screen accessible from the main menu showing career, personal best, and lifetime stats

### Modified Capabilities

- `run-structure`: Victory and failure screens now receive `RunStats` and PB flags; accumulation happens after screen setup (not before)
- `profile-save`: Adds new fields: `victories`, `best_single_run_damage`, `total_quads`, `total_tspins`, `total_perfect_clears`

## Impact

- `game/scripts/run_stats.gd` — new fields: `quads`, `tspins`, `perfect_clears`, `run_time`, `clear_counts`
- `game/scripts/profile_save.gd` — new fields: `victories`, `best_single_run_damage`, `total_quads`, `total_tspins`, `total_perfect_clears`, `total_play_time`; `accumulate_stats` updated
- `game/scenes/game/run_manager.gd` — `_show_victory()` and `_show_failure()` pass `RunStats` + PB flags to end screens; accumulation moved after screen setup; quad/T-spin/PC/clear_counts counters wired into clear event handler; `round_timer` accumulated into `run_stats.run_time` at round end
- `game/scenes/screens/run_victory.gd` — replaced with stats-aware layout
- `game/scenes/screens/run_failure.gd` — replaced with stats-aware layout
- `game/scenes/main_menu/main_menu.gd` — new Stats button added
- New scene: `game/scenes/screens/stats_screen.tscn` + `.gd`
- `game/tests/unit/` — new unit tests for PB comparison logic and stat accumulation
