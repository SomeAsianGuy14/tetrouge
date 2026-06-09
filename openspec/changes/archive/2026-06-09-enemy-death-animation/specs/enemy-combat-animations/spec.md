## ADDED Requirements

### Requirement: Portrait plays a death animation when the enemy is defeated
When the player fills the enemy's quota and the round ends in success, `EnemyDisplay` SHALL play a death animation on the portrait anchor. The animation SHALL complete before the post-round overlay (success screen or victory screen) is shown. A `death_animation_finished` signal SHALL be emitted when the animation is done. Boss enemies (those whose `Enemy.ability` is non-null) SHALL play a more dramatic variant than regular enemies.

#### Scenario: Death animation plays on quota filled
- **WHEN** the enemy's quota is fully accumulated and `play_death_animation()` is called
- **THEN** the portrait anchor begins a flash-then-dissolve animation sequence

#### Scenario: Regular enemy flash and dissolve
- **WHEN** `play_death_animation()` is called on a non-boss enemy
- **THEN** the portrait anchor modulate flashes to WHITE over approximately 0.10 seconds, then scale expands to approximately 1.1× and alpha fades to 0 in parallel over approximately 0.50 seconds

#### Scenario: Boss enemy dramatic variant
- **WHEN** `play_death_animation()` is called on a boss enemy (`ability != null`)
- **THEN** the portrait anchor flashes to WHITE over approximately 0.10 seconds, then scale expands to approximately 1.18×, alpha fades to 0, and the portrait shakes horizontally (oscillates ±8px) in parallel over approximately 0.80 seconds

#### Scenario: death_animation_finished signal fires when animation completes
- **WHEN** the death animation tween finishes all steps
- **THEN** the `death_animation_finished` signal is emitted

#### Scenario: Pre-existing animations are stopped before death begins
- **WHEN** `play_death_animation()` is called while a pulse or lunge tween is active
- **THEN** all active portrait tweens (lunge, pulse, flash) are killed before the death animation starts

### Requirement: Post-round overlay is gated on death animation completion
The post-round overlay (round success screen or run victory screen) SHALL NOT be shown until after `death_animation_finished` fires. `RunManager` SHALL connect to the signal one-shot before triggering the animation. If `_enemy_display` is null when the round ends, the overlay SHALL appear immediately without delay.

#### Scenario: Success screen waits for death animation
- **WHEN** the quota is filled and the round is not a run-completion
- **THEN** the round success overlay does not appear until `death_animation_finished` fires

#### Scenario: Victory screen waits for death animation
- **WHEN** the final boss quota is filled and the run is complete
- **THEN** the run victory overlay does not appear until `death_animation_finished` fires

#### Scenario: Immediate fallthrough when display is absent
- **WHEN** `_enemy_display` is null at the time `_end_round(true)` runs
- **THEN** `_show_round_success()` or `_show_victory()` is called immediately without waiting

### Requirement: Death tween is stopped by the pause hook
`stop_animations()` SHALL kill any in-progress death tween. If a death animation was interrupted by a pause, the system SHALL still proceed to show the post-round overlay (it SHALL NOT remain stuck waiting for a signal that will never fire).

#### Scenario: Pause kills death tween
- **WHEN** `stop_animations()` is called while the death animation is playing
- **THEN** the death tween is killed and the portrait anchor is left in its current state

#### Scenario: Overlay proceeds after pause interrupts death animation
- **WHEN** the death animation is killed by `stop_animations()`
- **THEN** the deferred post-round transition still completes (no stuck state)
