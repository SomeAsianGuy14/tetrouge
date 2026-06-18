## Context

`RunStats` (a `RefCounted` created fresh each run) tracks total damage, quad/T-spin damage, highest combo, and highest B2B. `ProfileSave` persists cumulative versions of these plus `highest_beaten` and `runs_completed`. Both the victory and failure screens currently ignore `RunStats` entirely — they receive only `Economy.coins` / `(ante, round_index)` respectively.

Run-end screens are shown from `RunManager._show_victory()` and `RunManager._show_failure()`. Victory calls `ProfileSave.accumulate_stats()` before instantiating the screen, which means the "old" best is already overwritten by the time the screen could compare against it.

`RunState` holds `keystones: Array` and `techniques: Array` for the duration of the run; both are still populated at the moment `_show_victory()` / `_show_failure()` are called (reset only happens when the player navigates to main menu).

## Goals / Non-Goals

**Goals:**
- Show per-run stats (damage, combo, B2B, quads, T-spins, perfect clears) on the run-end screen with accurate "★ PB" markers
- Show the player's final build (keystones + techniques) on the run-end screen
- Add a Stats screen to the main menu (career, personal bests, lifetime totals)
- Expand `RunStats` and `ProfileSave` to carry the new fields needed by both surfaces

**Non-Goals:**
- Run history / last-N-runs log
- Achievements or unlock gating tied to stats (deferred to future change)
- Per-round or per-ante breakdown (only run totals)
- Animated stat reveal sequence (static layout only)

## Decisions

### Decision 1: Compute PBs before accumulation

**Chosen**: In `_show_victory()` and `_show_failure()`, compute a `pbs: Dictionary` by comparing `_run_stats` against current `ProfileSave` fields, then call `screen.setup(...)` passing both the run stats and the PB set, then call `ProfileSave.accumulate_stats()` afterward.

**Alternative**: Accumulate first, then store "pre-accumulation snapshot." Rejected — requires cloning ProfileSave state, more bookkeeping.

**Rationale**: The current code order (accumulate → show screen) is simply wrong for this feature; swapping is the minimal fix with no downside.

### Decision 2: PBs as a Dictionary of field names

`pbs` is a `Dictionary` mapping stat-name strings to `true` (e.g. `{ "total_damage": true, "highest_combo_chain": true }`). The end screen checks `pbs.has("field_name")` to decide whether to show the ★ marker.

**Alternative**: A typed resource or Array of flags. Dictionary is simpler and requires no new class.

### Decision 3: Build summary reads from RunState directly

The end screens will read `RunState.keystones` and `RunState.techniques` at setup time. Both arrays are still intact when `_show_failure()` / `_show_victory()` are called; they are only cleared in `RunState.reset()`, which is triggered by the player choosing "Main Menu" (not by run end itself).

**Alternative**: Pass keystones/techniques as parameters to `setup()`. Rejected — RunState is an autoload available everywhere; adding more parameters to setup() is unnecessary indirection.

### Decision 4: Separate Stats screen scene, not embedded in main menu

`StatsScreen` is its own scene loaded over the main menu (same pattern as `Settings`). The main menu adds it as a child; the screen's Close button calls `queue_free()`.

**Rationale**: Consistent with existing settings pattern; allows the stats screen to be opened from other entry points in the future without rearchitecting the main menu.

### Decision 5: New stat counters tracked in RunManager, not TetrisBoard

`quads`, `tspins`, and `perfect_clears` counts are incremented in `RunManager._on_attack_event()` (already the handler for clear-type events), keeping `TetrisBoard` free of run-level bookkeeping.

## Risks / Trade-offs

- **RunState population at failure time** — If a future change calls `RunState.reset()` before `_show_failure()`, the build summary would be empty. The design relies on current call order; this should be noted in a comment.
- **Profile save field additions are additive** — Old `profile.cfg` files missing new keys will use `get_value(..., default)` fallbacks, so saves from before this change load cleanly with zeros for new fields.
- **perfect_clears counter accuracy** — `_pc_count_this_round` already exists in `RunManager` as a local counter; it resets each round. The new `_run_stats.perfect_clears` field will be incremented alongside it without changing its semantics.

## Migration Plan

No migration required. `ProfileSave.load_profile()` uses `cfg.get_value(section, key, default)` for all fields; missing keys in existing save files silently default to `0`. New fields are purely additive.
