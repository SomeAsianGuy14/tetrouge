## Why

Rounds currently feel mechanical — the player fills a quota bar with no narrative framing, making each stage indistinguishable in feel. Framing every round as a fight against a named enemy with a health bar and periodic attacks gives the run structure visual identity and makes each encounter feel meaningful.

## What Changes

- A new `Enemy` resource defines each encounter: name, color (placeholder art), optional sprite, garbage attack interval, and an optional board-rule ability for boss enemies.
- Every round is assigned an enemy drawn from a seeded tier pool (Small, Big, Elite, Boss). Common enemies are reused across stages; boss enemies are unique per run.
- The quota bar is replaced by an enemy HP bar that drains as the player attacks. The numeric quota is overlaid on the bar for precision.
- All rounds generate periodic garbage rows from the enemy (not just boss rounds). The interval scales with stage progression.
- `BossModifier.garbage_interval` is removed — garbage is now an enemy property. The Tide boss modifier is removed entirely.
- An `EnemyDisplay` panel is added to the right of the queue showing the enemy sprite/placeholder, name, HP bar, and a wind-up indicator for the next garbage attack.
- The viewport is widened from 1280×720 to 1440×900 to reduce dead margins and give comfortable vertical clearance for the 640px board.

## Capabilities

### New Capabilities

- `enemy-encounters`: The Enemy resource, tier pool draw system, and per-round enemy assignment. Covers enemy data model, roster of placeholder enemies, seeded draw logic, and garbage attack generalisation.
- `enemy-display`: The in-game EnemyDisplay UI panel — sprite/placeholder rect, name label, HP bar with overlaid quota number, and garbage wind-up indicator.

### Modified Capabilities

- `run-structure`: Every round now has an assigned enemy; boss rounds additionally carry a board-rule ability. The round lifecycle includes enemy assignment and a scaling garbage attack that was previously boss-only.
- `boss-modifiers`: `BossModifier` loses the `garbage_interval` field; The Tide modifier is removed. The remaining modifiers become the ability pool for boss enemies.
- `tetris-core`: Garbage row insertion is now triggered by the enemy attack timer for all round types, not exclusively by a boss modifier.

## Impact

- `Enemy` — new Resource class (`game/resources/enemy.gd` + `.tres` files in `game/resources/data/enemies/`)
- `BossModifier` — remove `garbage_interval` field; delete `the_tide.tres`
- `RoundConfig` — add `enemy: Enemy` and `effective_garbage_interval: float` fields
- `RunManager` — enemy assignment via seeded tier pool draw; generalise `_tick_tide()` to use enemy interval for all rounds; compute scaled interval at round build time
- `RunSave` — no changes needed (enemy is derived from seed, not saved separately)
- `HUD` — quota bar either removed or replaced by a smaller label; HP bar lives in EnemyDisplay
- New scene: `EnemyDisplay` instantiated to the right of the queue display
- `project.godot` — viewport width/height updated to 1440×900
