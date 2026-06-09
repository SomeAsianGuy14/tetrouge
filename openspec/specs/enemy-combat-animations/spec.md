## ADDED Requirements

### Requirement: Portrait lunges toward the board when the enemy fires an attack
When the enemy fires a garbage attack, the portrait anchor SHALL animate by translating its x position leftward (approximately −90px) rapidly, holding briefly, then returning to origin with an ease-out curve. The lunge SHALL be driven by a Tween and triggered by an explicit method call from RunManager at the moment garbage is queued — not detected heuristically from the windup timer.

#### Scenario: Portrait slams left on attack
- **WHEN** the enemy fires a garbage attack (garbage is added to the packet queue)
- **THEN** the portrait anchor translates left by approximately 90px over approximately 0.09 seconds (linear or ease-in)

#### Scenario: Portrait holds at lunge position briefly
- **WHEN** the lunge translation completes
- **THEN** the portrait anchor pauses at the leftmost position for approximately 0.1 seconds before returning

#### Scenario: Portrait returns to origin with ease-out
- **WHEN** the hold phase completes
- **THEN** the portrait anchor slides back to x=0 over approximately 0.45 seconds with an ease-out curve

#### Scenario: Mid-return lunge restarts cleanly
- **WHEN** a second attack fires while the portrait is still returning from a previous lunge
- **THEN** the in-progress return Tween is cancelled, and the lunge animation restarts from the current position

### Requirement: Portrait pulses during windup anticipation
When the windup timer reaches 80% or more of the garbage interval, the portrait anchor SHALL display a subtle repeating scale pulse (approximately 1.0 → 1.04) as a visual telegraph that an attack is imminent. The pulse SHALL stop and the scale SHALL return to 1.0 when the attack fires or when the windup resets below 80%.

#### Scenario: Pulse starts at 80% windup
- **WHEN** the windup timer crosses 80% of the garbage interval
- **THEN** the portrait anchor begins a looping scale oscillation between 1.0 and approximately 1.04

#### Scenario: Pulse stops on attack fire
- **WHEN** the enemy fires and the lunge begins
- **THEN** the pulse Tween is killed and the portrait scale returns to 1.0 as part of the lunge sequence

#### Scenario: Pulse stops if windup drops below threshold
- **WHEN** the windup timer resets to 0 without having fired (e.g. on round start)
- **THEN** any active pulse Tween is killed and the portrait scale returns to 1.0

### Requirement: Portrait flashes red when the player deals damage
When the player's accumulated attack increases (the enemy takes damage), the portrait anchor SHALL briefly flash red via a modulate Tween. The flash SHALL transition to red in approximately 0.08 seconds, then return to normal over approximately 0.2 seconds. The flash SHALL not interrupt or be interrupted by the lunge animation — both effects MAY run concurrently.

#### Scenario: Flash triggers on damage
- **WHEN** `update_hp()` is called with a higher accumulated value than the previous call
- **THEN** the portrait anchor modulate animates to red and back to white within approximately 0.28 seconds total

#### Scenario: No flash when HP is unchanged
- **WHEN** `update_hp()` is called with the same accumulated value as the previous call
- **THEN** no modulate change occurs on the portrait anchor

#### Scenario: Flash and lunge can play simultaneously
- **WHEN** the enemy fires an attack and the player simultaneously clears lines that deal damage
- **THEN** both the red flash and the lunge animation play without cancelling each other

### Requirement: Floating damage number rises and fades when the player damages the enemy
When the player deals damage, a Label showing the damage amount SHALL appear over the portrait area, animate upward by approximately 50px, and fade from fully opaque to transparent over approximately 0.9 seconds, then be removed from the scene tree. Multiple floating numbers from rapid successive attacks MAY overlap visually.

#### Scenario: Damage number appears and rises
- **WHEN** the player deals damage (accumulated HP delta is positive)
- **THEN** a Label with the damage amount appears near the portrait, translates upward ~50px, and fades to invisible over ~0.9 seconds

#### Scenario: Label is freed after animation completes
- **WHEN** the fade animation on a floating damage number finishes
- **THEN** the Label node is freed from the scene tree

#### Scenario: Zero delta shows no floating label
- **WHEN** `update_hp()` is called but the accumulated value has not increased
- **THEN** no floating damage label is spawned

### Requirement: ATK countdown bar is hidden for enemies that do not attack
For enemies whose boss modifier disables direct attacks (e.g. The Reflection), the ATK countdown bar SHALL be hidden. This is controlled by the existing `set_attack_bar_visible()` API on EnemyDisplay, which SHALL continue to work in the redesigned panel.

#### Scenario: ATK bar hidden for no-attack boss
- **WHEN** the round is set up with a boss modifier that has no garbage interval
- **THEN** the ATK countdown bar is not visible in the enemy panel

#### Scenario: ATK bar visible for attacking enemies
- **WHEN** the round is set up with an enemy that attacks
- **THEN** the ATK countdown bar is visible and updates each frame

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
