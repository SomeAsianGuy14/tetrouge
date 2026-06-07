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
