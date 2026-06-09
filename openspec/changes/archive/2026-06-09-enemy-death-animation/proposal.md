## Why

When an enemy's quota is filled the round currently ends abruptly — the enemy panel just freezes in place while the success screen snaps on top. There is no payoff moment for defeating the enemy, which makes kills feel flat and unearned.

## What Changes

- **EnemyDisplay** gains a `play_death_animation()` method that plays a flash-then-dissolve sequence on the portrait anchor.
- Boss enemies (those with an `ability` set) get a longer, more dramatic variant: larger scale punch, extended fade, and a brief shake.
- A `death_animation_finished` signal is emitted when the animation completes.
- **RunManager** delays calling `_show_round_success()` and `_show_victory()` until `death_animation_finished` fires; if `_enemy_display` is null it falls through immediately.
- `stop_animations()` on EnemyDisplay also kills the death tween (so pausing mid-animation works correctly).

## Capabilities

### New Capabilities
- none

### Modified Capabilities
- `enemy-combat-animations`: New requirements for a death animation that plays when the enemy is defeated, with distinct normal and boss variants, and a signal that gates the post-round transition.

## Impact

- `game/scenes/game/enemy_display.gd` — new signal, new method, updated `stop_animations()`
- `game/scenes/game/run_manager.gd` — `_end_round(true)` defers `_show_round_success()` / `_show_victory()` until death animation completes
- No new scenes, nodes, or assets required
