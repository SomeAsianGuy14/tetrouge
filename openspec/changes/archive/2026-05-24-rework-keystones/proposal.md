## Why

The current keystones are exclusively mechanical (lock delay, hold slots, preview count) and don't interact with the attack system, making them feel disconnected from the core Tetris gameplay loop. Replacing them with a designed set of 29 keystones across 8 thematic categories gives players meaningful build paths that reward committing to specific clear styles.

## What Changes

- **BREAKING** Remove all 8 existing keystone `.tres` resource files and their effects
- Add 29 new keystones across 8 categories: Starter, Tetris, T-Spin, B2B, Combo, PC, Economic, Utility
- Add a starter keystone selection screen at the beginning of every run (before the first board loads); the player chooses one from a seeded draw of 3 starter keystones
- Extend the `Keystone` resource class to support damage flat bonuses, damage multipliers, clear-type suppression, conditional availability, economy effects, and new in-round mechanics
- Add 2 conditionally-available keystones (Great Sword, Magical Coin) that only appear in selection if the player owns Slightly Magical Coin
- Introduce new in-round mechanics: enemy stun (Daze), B2B safety net (Safety Net), B2B break burst (Final Blow), all-spin B2B (Flexible), t-spin spin counter (Dizzy), overkill-to-coins (Midas Touch), time-remaining coins (Golden Watch), top-row damage bonus (Risky Business), instant ARR/soft-drop (Full Potential)

## Capabilities

### New Capabilities
- `keystones`: Complete keystone catalog — 29 keystones with all effect definitions, categories, conditional availability rules, and the extended Keystone data model

### Modified Capabilities
- `economy`: New keystone-driven coin acquisition paths — end-of-round coin grants (Slightly Magical Coin, Magical Coin), overkill damage converted to coins (Midas Touch), time-remaining coin bonus at round end (Golden Watch)
- `enemy-encounters`: Enemy stun mechanic — Daze keystone delays the enemy's next garbage timer fire by 2 seconds each time the player sends a quad

## Impact

- `game/resources/keystone.gd` — extended with ~15 new fields for the new effect types
- `game/resources/data/keystones/` — all 8 existing `.tres` files removed; 29 new `.tres` files added
- `game/scenes/game/run_manager.gd` — keystone effects applied after attack generation (damage bonuses/multipliers, suppression, stun, economy payouts)
- `game/autoloads/run_state.gd` — spin counter for Dizzy, first-PC-this-round flag for Beginner's/Veteran's Luck, B2B-disabled-this-round flag for Final Blow
- `game/scenes/keystone_selection/keystone_selection.gd` — conditional filtering for Great Sword / Magical Coin; `starter_only` mode for run-start selection
- `game/scenes/game/run_manager.gd` — `start_run()` shows starter keystone selection before the first round
- `game/tests/unit/test_keystones.gd` — new test file covering all keystone effects
