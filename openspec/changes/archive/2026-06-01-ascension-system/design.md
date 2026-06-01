## Context

The game has no cross-run persistence. `user://save.cfg` tracks only the active run and is deleted on run completion. Victory drops the player back to the main menu with no record of what they achieved. `RunManager._on_new_run()` in the main menu starts a fresh run immediately with no configuration step.

The ascension system requires: (1) a persistent store that outlasts individual runs, (2) a pre-run configuration moment for level selection, (3) application of difficulty modifiers to round generation, and (4) a framework for evaluating unlock conditions at victory.

## Goals / Non-Goals

**Goals:**
- Persist ascension progress and cumulative stats across runs and sessions
- Insert an ascension selector between "New Run" and run start when the player has beaten the game
- Apply six stacked difficulty modifiers to `_build_round_config()` based on selected level
- Increase base garbage intervals by 25% and define ascension 1 as restoring the original speeds
- Provide `UnlockCondition`, `RunStats`, and `UnlockChecker` infrastructure for future item unlocks
- Filter items with `unlock_condition_id` from pools unless their id is in `ProfileSave.unlocked_ids`

**Non-Goals:**
- Actual unlock conditions on any existing items (framework only)
- Ascension-specific UI polish or animations
- Leaderboards or cloud saves

## Decisions

### 1. `ProfileSave` as a static class mirroring `RunSave`

`RunSave` is a static `RefCounted` that wraps `ConfigFile`. `ProfileSave` follows the same pattern with `user://profile.cfg`. This keeps persistence simple, consistent, and testable without introducing an autoload.

**Alternative considered:** A new autoload (`Profile`). Rejected — the profile is read-only during a run; an autoload adds lifecycle complexity for no benefit.

### 2. `AscensionManager` as an autoload

The selected ascension level must be readable from `RunManager`, `RunState`, and eventually the victory screen. An autoload with `current_level: int` and `get_modifiers(level) -> Dictionary` is the cleanest cross-scene access point.

**Alternative considered:** Store level in `RunState`. Rejected — `RunState` resets between runs; ascension level needs to survive `RunState.reset()`.

### 3. Modifiers defined as code constants in `AscensionManager`, not data files

Six levels with simple numeric deltas don't justify separate resource files. A `const MODIFIERS` array of Dictionaries in `AscensionManager` is readable, easily tunable, and requires no resource loading.

**Alternative considered:** `.tres` resource files per level. Rejected — over-engineered for six static entries.

### 4. Modifiers applied in `_build_round_config()`, not via `apply_to_config()`

`RoundConfig` is already the centralised configuration object passed to `TetrisBoard`. Injecting ascension deltas at config build time (in `RunManager`) keeps them isolated from keystone/technique logic and easy to audit.

**Alternative considered:** A new `apply_ascension(config)` method on `AscensionManager`. Effectively the same thing — the call site is `_build_round_config()` either way; keeping it inline is simpler.

### 5. `RunStats` as a plain `RefCounted`, created fresh each run by `RunManager`

Run-condition and cumulative stat tracking only needs to accumulate values during a run and hand them to `ProfileSave` at victory. A lightweight `RefCounted` with typed fields (no autoload, no signals) avoids lifecycle issues.

### 6. `unlock_condition_id` on items; filtering in `ResourceRegistry` helper

Adding a single `unlock_condition_id: String` field (default `""`) to `Keystone` and `Technique` keeps unlock metadata with the item data. `ResourceRegistry` gains a `get_available_keystones()` / `get_available_techniques()` helper that filters out items whose `unlock_condition_id` is non-empty and not in `ProfileSave.unlocked_ids`. Existing call sites that use `all_keystones` / `all_techniques` directly continue to work.

**Alternative considered:** Filtering at every call site. Rejected — too fragile; a central helper is safer.

### 7. Ascension selector is a full-screen blocking overlay, not a separate scene transition

The selector appears after "New Run" is pressed as a full-screen `CanvasLayer` child of the main menu. A solid or heavily-dimmed `ColorRect` fills the viewport so the main menu is completely hidden behind it. The selector populates level buttons dynamically based on `ProfileSave.highest_beaten + 1`. It includes a Back button that dismisses the overlay and returns focus to the main menu without starting a run. On level confirmation it sets `AscensionManager.current_level` then starts the run. This avoids a separate scene transition while keeping the UI fully modal.

## Risks / Trade-offs

- **`ProfileSave` corruption** → `ConfigFile` load errors are handled gracefully; missing keys fall back to defaults (`highest_beaten = -1`, empty unlocked ids). A corrupt profile resets to "never beaten" state.
- **Ascension modifiers not applied to boss modifier interaction** → Ascension level 1 (faster intervals) and level 2 (more lines) stack with boss modifiers that already affect these values. This could create extreme difficulty at high ascension + hard boss combinations. Accepted for now; tune if needed.
- **`RunStats` not saved mid-run** → If the game crashes during a run, cumulative stats for that run are lost. Accepted — saves are expensive and mid-run crashes are rare.
- **Starter keystone skip (level 5) leaves the player with no keystone at round start** → Intentional design. The player must acquire keystones from post-boss selections only.

## Resolved Decisions

- **Ascension selector default**: Defaults to the highest unlocked level.
- **Stats tracked**: `runs_completed`, `total_damage`, `total_quad_damage`, `total_tspin_damage` (additive across runs), plus `highest_combo_chain` and `highest_b2b` (lifetime maximums — stored as `max(stored, run_value)` rather than summed).
