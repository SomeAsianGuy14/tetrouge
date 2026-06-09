## Context

`EnemyDisplay` already drives all portrait animations (lunge, pulse, damage flash, floating numbers) through tweens on `_portrait_anchor`. All animation state is self-contained in `EnemyDisplay`; `RunManager` calls in via a small public API.

When an enemy is defeated, `RunManager._end_round(true)` immediately calls `_show_round_success()` (or `_show_victory()` for a run-ending boss kill). There is currently no visual payoff at the moment of defeat — the portrait freezes and an overlay snaps on top.

`stop_animations()` is already the pause hook: it kills the lunge and flash tweens. The death tween must be included in the same cleanup.

## Goals / Non-Goals

**Goals:**
- Play a brief death animation on defeat (regular and boss variants)
- Gate the post-round overlay on animation completion via a signal
- Respect the pause system (`stop_animations()` kills the death tween)
- Apply to both `_show_round_success()` and `_show_victory()` paths

**Non-Goals:**
- Particle effects, shader effects, or new imported assets
- Per-enemy or per-ability animation variants (just regular vs. boss)
- Animating anything outside the `_portrait_anchor` node

## Decisions

### Signal-based gating instead of a timer in RunManager

RunManager connects to `EnemyDisplay.death_animation_finished` (one-shot) before calling `play_death_animation()`. When the signal fires, the deferred callback calls `_show_round_success()` or `_show_victory()`.

**Alternative considered:** `RunManager` hard-codes a `get_tree().create_timer(0.6)` delay. Rejected because the duration is duplicated and won't stay in sync if animation timing is tweaked.

**Alternative considered:** `await` on the signal inside `_end_round`. Rejected because `_end_round` is not async and converting it adds risk across all callers.

### Boss detection via `_enemy.ability != null`

`EnemyDisplay` already stores `_enemy` and checks `_enemy.ability` at line 121. Using the same guard for the boss animation variant keeps detection consistent with zero new API surface.

### Regular variant: flash → expand + fade (~0.6 s)

```
0.00s  modulate → WHITE             (0.10s, instant punch)
0.10s  modulate:a → 0.0             (0.50s, ease-in)   ─┐ parallel
0.10s  scale → Vector2(1.1, 1.1)    (0.50s, ease-out)  ─┘
0.60s  emit death_animation_finished
```

### Boss variant: flash → bigger expand + shake + longer fade (~1.0 s)

```
0.00s  modulate → WHITE             (0.10s)
0.10s  modulate:a → 0.0             (0.80s, ease-in)         ─┐ parallel
0.10s  scale → Vector2(1.18, 1.18)  (0.80s, ease-out)        ─┤ parallel
0.10s  position:x oscillate ±8px    (3 cycles over ~0.35s)   ─┘
1.00s  emit death_animation_finished
```

The shake is a quick chained tween on `_portrait_anchor.position:x`: +8 → −8 → +4 → −4 → 0, each step ~0.07s.

### Null guard in RunManager

If `_enemy_display` is null when `_end_round(true)` runs (e.g. future test path), fall through to `_show_round_success()` / `_show_victory()` immediately with no delay.

## Risks / Trade-offs

**Risk: Game paused during death animation** → `stop_animations()` is already called on pause. Adding `_death_tween` to the kill list in `stop_animations()` handles this. The signal will not fire, leaving `_show_round_success()` unresolved. Mitigation: also call `_show_round_success()` / `_show_victory()` directly from `stop_animations()` if a death was in progress (via an `_death_pending_success` boolean flag).

**Risk: _show_victory path skipped** → Both transition paths in `_end_round(true)` must be routed through the animation gate; the `is_run_complete()` branch is easy to miss. Addressed explicitly in tasks.

**Trade-off: ~0.6–1.0s added latency before success screen** → Intentional. The animation is the payoff moment; the screen appearing immediately would undercut it.
