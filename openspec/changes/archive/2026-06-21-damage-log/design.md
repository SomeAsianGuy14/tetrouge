## Context

The damage pipeline in `RunManager._on_attack_generated()` takes a raw attack value and transforms it through ~8 stages (techniques, mastery, honed bonus, keystone flats, consumable flats, surge, keystone multipliers, amplified multiplier, tag bonus). Each stage modifies a running `modified` value. To produce a per-source breakdown we need to snapshot the value before and after each stage.

Build state (keystones, techniques, consumables) changes at several points: starter keystone selection, shops, encounter rooms (Altar, Library, Wishing Well, Museum, Head Trauma, Robbers). All mutations flow through `RunState.add_keystone()`, `add_technique()`, `add_consumable()`, `remove_technique()`, `remove_consumable()`.

## Goals / Non-Goals

**Goals:**
- Emit a CSV file per run with every attack event broken down by damage source
- Track build changes (keystones, techniques, consumables) throughout the run
- Emit round-end and run-end summary rows for quick scanning
- Auto-enable in debug builds, no-op in release builds
- Zero gameplay impact — logging is fire-and-forget, no return values consumed

**Non-Goals:**
- In-game UI for damage breakdown (this is a dev/balance tool)
- Real-time streaming or external tool integration
- Logging non-damage events (coins, shield, garbage received)
- Configurable column selection or log format options

## Decisions

### 1. New autoload `DamageLog` rather than instrumenting RunManager directly

All CSV logic (file handle, formatting, row emission) lives in a dedicated `DamageLog` autoload. RunManager calls `DamageLog.log_attack(...)` etc. This keeps RunManager's damage pipeline readable — the logging calls are single lines that pass the values already computed.

Alternative: Embed CSV writing directly in RunManager. Rejected because it would clutter the already-long `_on_attack_generated()` and mix I/O concerns with game logic.

### 2. Capture multiplier values, not deltas

For multiplicative stages (surge, keystone multipliers, amplified), log the multiplier value itself (e.g. `2.0`, `1.5`, `1.75`) rather than the damage delta. Multipliers compound, so deltas are misleading without knowing the order. Raw multiplier values are more useful for balance analysis, and deltas can be derived in a spreadsheet.

### 3. One CSV per run, named by timestamp

Files go to `user://damage_logs/run_<YYYYMMDD_HHmmss>.csv`. One file per run avoids mixing data across runs and makes it easy to compare specific runs. The timestamp in the filename provides natural ordering.

Alternative: Single rolling log file. Rejected because separating runs in a single file requires filtering, and files would grow unbounded.

### 4. Guard with `OS.is_debug_build()` at autoload `_ready()`

`DamageLog` sets an `_enabled` flag in `_ready()`. When disabled, every public method returns immediately — no file I/O, no string formatting. This means release builds pay zero cost. The flag could also be toggled manually via the dev console for release-build testing.

### 5. BUILD rows emitted via signal rather than modifying RunState methods

`RunState` already centralizes build mutations. Rather than adding direct `DamageLog` calls inside each method, emit a signal `build_changed` from `RunState` after any mutation. `DamageLog` connects to this signal and writes a BUILD row. This keeps RunState decoupled from the logging system.

Alternative: Direct calls in each RunState mutation method. Works but couples RunState to DamageLog.

### 6. Snapshot approach for pipeline instrumentation

In `_on_attack_generated()`, capture the `modified` value before and after each stage to compute the delta for that stage. The existing code already has clear sequential stages, so this is straightforward:

```
pre_keystone_flat = modified
modified = _apply_keystone_flat_bonuses(modified, event_type)
keystone_flat_delta = modified - pre_keystone_flat
```

The final `DamageLog.log_attack()` call passes all captured values. Suppressed attacks (where the pipeline returns early with `modified = 0`) are skipped — the log call is placed after the suppression check.

## Risks / Trade-offs

**File I/O on every attack event** → Each `log_attack()` call writes one line and flushes. At ~50–200 attack events per run this is negligible. No buffering needed.

**Log directory growth** → Old CSV files accumulate in `user://damage_logs/`. Acceptable for a dev tool — can be manually cleaned. No auto-pruning.

**Signal-based BUILD tracking adds a signal emission to every build mutation** → Negligible cost since build changes happen a few times per run at most.
