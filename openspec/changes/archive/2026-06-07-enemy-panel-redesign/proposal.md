## Why

The enemy display is a small 140×140 widget squeezed to the right of the piece queue, leaving ~580px of dead space on the right side of the screen. Moving it to a proper right-side panel gives the enemy visual presence, makes combat information readable at a glance, and sets up the foundation for future sprite animations.

## What Changes

- Replace the current narrow `EnemyDisplay` widget with a full-height right-side panel (~680×900px)
- Enemy portrait becomes free-floating (no border box): large stylised initial letter as placeholder, replaced by sprite when art is added
- Enemy name tinted in the enemy's `color` property
- Portrait has a lunge animation: slams left toward the board when the enemy fires an attack, returns with ease-out
- Subtle scale pulse on the portrait at 80%+ windup as an anticipation telegraph
- Portrait flashes red and a floating damage number rises and fades when the player deals damage to the enemy
- Panel info section (below portrait): stage/round label, flavor text (italic, hidden if empty), boss modifier description (orange, hidden if no modifier), HP bar, ATK countdown bar
- Add `flavor_text` field to the `Enemy` resource — all existing `.tres` files default to empty, content filled in later
- `ModifierBigLabel` floating HUD label removed (description now lives in the panel)
- `EnemyDisplay` repositioned as a Control under HUD instead of a Node2D child of BoardContainer
- Attack lunge triggered by an explicit `on_attack_fired()` call from `RunManager` (not detected heuristically)
- Attack buffer bar (left of board) is **untouched**

## Capabilities

### New Capabilities

- `enemy-panel`: Full-height right-side enemy panel with portrait, name, round info, flavor text, boss modifier description, HP bar, and ATK countdown bar
- `enemy-combat-animations`: Lunge-toward-board animation with windup anticipation pulse (enemy fires); portrait red flash and floating damage number (player damages enemy)

### Modified Capabilities

- `enemy-display`: Requirements change — enemy display is no longer a compact widget but a full-height panel; `flavor_text` is a new required field on the Enemy resource

## Impact

- `game/resources/enemy.gd` — add `flavor_text` field
- `game/resources/data/enemies/*.tres` — all enemy data files updated with empty `flavor_text`
- `game/scenes/game/enemy_display.gd` / `.tscn` — full rewrite
- `game/scenes/game/run_manager.gd` — update enemy display instantiation, position, and add `on_attack_fired()` call when garbage is queued
- `game/scenes/game/run_manager.tscn` — remove `ModifierBigLabel` node
- `game/scenes/game/hud.gd` — remove `ModifierBigLabel` references, remove `set_enemy_display()` / `update_quota()` delegation (panel owns HP updates)
