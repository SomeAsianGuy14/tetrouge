## Why

Balancing damage numbers across techniques, keystones, enhancements, and mastery requires visibility into how much each source contributes during actual play. Currently the only feedback is the final damage number — there's no way to see whether techniques are carrying 5% or 50% of a build's output. A per-run CSV log of every attack event, broken down by source, lets us analyze balance in a spreadsheet without adding any in-game UI.

## What Changes

- New autoload `DamageLog` that writes a CSV file per run to `user://damage_logs/`
- Automatically enabled when running in debug builds (`OS.is_debug_build()`), off in release
- Logs four row types:
  - **RUN_START** — seed, ascension level, timestamp
  - **BUILD** — current keystones, techniques, and consumables (emitted at run start and whenever the build changes mid-run)
  - **ATTACK** — one row per attack event with full damage breakdown: base, technique, mastery, honed, keystone flat, consumable flat, surge multiplier, keystone multiplier, amplified multiplier, tag bonus, and final damage
  - **ROUND_END** — per-round summary with totals for each damage source
  - **RUN_END** — victory/failure result and cumulative totals
- Suppressed attacks (zero damage from keystone suppression) are not logged
- Build-change events hooked into `RunState.add_keystone()`, `add_technique()`, `add_consumable()`, `remove_technique()`, `remove_consumable()`

## Capabilities

### New Capabilities
- `damage-log`: CSV-based per-run damage logging with per-source breakdown, build tracking, and round/run summaries

### Modified Capabilities

_(none — this is a dev tool layered on top of existing damage pipeline, no gameplay changes)_

## Impact

- **New file**: `game/autoloads/damage_log.gd` (autoload)
- **Modified**: `RunManager._on_attack_generated()` — instrument the damage pipeline to capture per-source values and call `DamageLog`
- **Modified**: `RunState` — add `DamageLog.log_build()` calls in `add_keystone()`, `add_technique()`, `add_consumable()`, `remove_technique()`, `remove_consumable()`
- **Modified**: `project.godot` — register `DamageLog` autoload
- **Output**: CSV files written to `user://damage_logs/` (Godot user data directory)
