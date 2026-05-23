## Context

Each round currently has a `BossModifier` (boss rounds only) and a quota. The quota bar fills as the player sends attack lines. Garbage rows are only sent on boss rounds via `RunManager._tick_tide()`, which checks `current_config.boss_modifier.garbage_interval`. Non-boss rounds have no active threat beyond the timer.

The run uses a seeded `RandomNumberGenerator` on `RunState` (added in `seeded-run-rng`). Enemy assignment can use the same PRNG, making encounters deterministic per seed.

Current RNG / layout call sites relevant to this change:
- `RunManager._select_boss_modifier()` — draws a boss modifier via `RunState.seeded_shuffle()`
- `RunManager._tick_tide()` — triggers garbage only when boss modifier has `garbage_interval > 0`
- `_queue_display.position = Vector2(COLS * CELL_SIZE + 16, 0)` — queue anchored right of board
- `project.godot` — viewport 1280×720

## Goals / Non-Goals

**Goals:**
- Every round has a named enemy with a color-coded placeholder (sprite-ready later).
- Garbage attacks occur every round, scaling faster with stage.
- The quota bar becomes a draining HP bar with numeric overlay.
- An `EnemyDisplay` panel sits to the right of the queue.
- The Tide boss modifier is removed; its effect generalised to all enemies.
- Viewport widens to 1440×900.

**Non-Goals:**
- Enemy sprite art (placeholder colored rectangles only for now).
- Enemy death animation (noted for future).
- Enemy intro / pre-round reveal screen.
- Per-enemy unique mechanics beyond garbage rate and boss ability.
- Narrative text or lore.

## Decisions

### 1. Enemy resource wraps BossModifier rather than absorbing it

**Decision:** `Enemy` has an optional `ability: BossModifier` field. Boss enemies reference one of the existing modifiers; common enemies leave it null.

**Why:** The seven remaining `BossModifier` resources (`the_enforcer`, `the_narrow`, etc.) already apply cleanly to `RoundConfig` via `modifier.apply_to_config(cfg)`. Reusing that mechanism unchanged avoids rewriting the modifier application logic. The Enemy layer is purely additive.

**Alternative considered:** Flatten all BossModifier fields into Enemy. Rejected — doubles the field count on Enemy and breaks the clean separation between "who you're fighting" and "what rule they impose."

### 2. Tier pool draw via RunState.seeded_shuffle, not BossModifier-style tracking

**Decision:** Each tier has a flat pool of Enemy resources. At round build time, `RunManager` calls `RunState.seeded_shuffle(pool)` and picks `pool[0]`. No "used enemy" tracking for common tiers (repeats across stages are intentional). Boss tier tracks `used_boss_enemy_ids` on `RunState` the same way `used_boss_modifiers` does today.

**Why:** Common enemies are explicitly reusable; tracking them adds overhead with no gameplay benefit. Boss enemies must stay unique per run (same as the current boss modifier logic), so they inherit the same deduplication pattern.

**Alternative considered:** Weighted pools that favour different enemies by stage. Rejected for now — adds complexity without a clear balance goal. Stage difficulty comes from the garbage scaling formula instead.

### 3. Garbage scaling via formula on Enemy's base interval

**Decision:** `effective_garbage_interval = enemy.garbage_interval × max(0.5, 1.0 - (stage - 1) × 0.1)`

Stage 1 = base rate. Stage 5 = 60% of base (40% faster). Floor at 0.5 prevents intervals shorter than half the base. Computed once in `_build_round_config()` and stored as `cfg.effective_garbage_interval`.

**Why:** Keeps enemy data simple (one authored number) while providing meaningful stage progression without requiring per-stage variants of each enemy.

### 4. EnemyDisplay is a Control scene instantiated by RunManager, positioned after queue

**Decision:** `EnemyDisplay` is a `Control` node added to `board_container` at `x = COLS * CELL_SIZE + 16 + queue_panel_width + 16`. Queue display width at `mini_cell=24` is `4×24 + 16 = 112px`, so enemy panel starts at `x = 336 + 112 + 16 = 464`.

**Why:** Mirrors the existing pattern for `_hold_display` and `_queue_display` — instantiated by RunManager, positioned as a child of `board_container`, freed and recreated each round.

### 5. HP bar lives in EnemyDisplay; HUD quota bar is replaced by a label

**Decision:** The `EnemyDisplay` owns the HP bar (`ProgressBar`, value = `quota - accumulated`, descending). The HUD's existing `quota_bar` (`ProgressBar`) is replaced with a plain `Label` showing the round name only. `HUD.update_quota()` still exists but calls `_enemy_display.update_hp()` via a signal or direct reference passed at setup.

**Why:** Having two quota indicators is redundant. The enemy panel is the primary combat feedback. The HUD top strip retains the round label for context.

**Alternative considered:** Remove `HUD.update_quota()` entirely. Rejected — RunManager calls it; keeping the method avoids touching RunManager's signal handler. The method body just delegates.

### 6. BossModifier.garbage_interval removed; the_tide.tres deleted

**Decision:** Strip `garbage_interval` and related logic from `BossModifier`. Delete `the_tide.tres`. The Tide's effect is now universal (every enemy has garbage); the modifier served no other purpose.

**Why:** Leaving a dead field invites confusion. The Tide has no board-rule effect, so it has no reason to exist as a modifier once garbage is generalised.

## Risks / Trade-offs

- **Balance: garbage in Stage 1** — Adding garbage from round 1 increases early difficulty. Common small enemies should have a slow base interval (≥30s) to keep Stage 1 accessible. → Author enemy data conservatively; can tune per-enemy intervals after playtesting.
- **Queue panel width assumption** — `EnemyDisplay` position is computed from a hardcoded queue width (112px at `mini_cell=24`). If queue width changes (e.g. Foresight augment showing 7 pieces at a smaller cell), the enemy panel is still at a fixed offset. → Acceptable: queue panel width is stable; the `mini_cell` scaling is capped at 24.
- **HUD.update_quota delegation** — RunManager calls `hud.update_quota()` on every attack event. The HUD delegates to EnemyDisplay. EnemyDisplay must outlive every attack event during a round. → No issue: EnemyDisplay is freed only in `start_round()`, after the board is deactivated.

## Migration Plan

1. Widen viewport (`project.godot`).
2. Add `Enemy` resource class and create `.tres` files for all enemies.
3. Strip `garbage_interval` from `BossModifier`; delete `the_tide.tres`.
4. Add `enemy` and `effective_garbage_interval` to `RoundConfig`.
5. Update `RunManager`: enemy draw logic, generalised garbage tick, enemy panel instantiation.
6. Build `EnemyDisplay` scene.
7. Update HUD: replace quota bar with label; add delegation to EnemyDisplay.
8. Add `used_boss_enemy_ids` to `RunState` and `RunSave`.

No rollback needed — all changes are additive or internal. No save format breakage (enemy is re-derived from seed on load).

## Open Questions

- None. Design is fully specified from the exploration session.
