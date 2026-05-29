## Why

The current boss modifier roster has uneven design quality — some bosses are redundant (The Surgeon overlaps The Aristocrat), some are too mild, and several new mechanically distinct modifiers are needed to make boss rounds feel unique and threatening. The attack bar's single-integer pending garbage display also makes it impossible for players to distinguish regular garbage from harder-to-clear cheese lines, removing a key strategic signal.

## What Changes

**Boss modifier renames / tweaks (data only):**
- The Oracle → **The Fateless**: hides the queue *and* the next piece entirely (was: show 1 preview)
- The Enforcer → **The Blitz**: time limit set to 60s (half of 120s standard; was: 45s)
- The Narrow → **The Thin**: rename only, no mechanical change
- **The Aristocrat**: quota whitelist narrowed to quad + all T-spin variants only (removes triple)
- **The Surgeon**: removed entirely

**New boss modifiers:**
- **The Ancient**: all generated pieces are truly random (no bag — any of the 7 types each draw)
- **The Filth**: all enemy-sent garbage arrives as individual 1-line attacks, each with its own random hole column instead of sharing one column across the batch
- **The Reflection**: does not attack the player; instead, 50% of the attack that reduces the boss's HP is reflected back to the player as pending garbage

**Attack bar rework:**
- Replace the fixed 20-segment bar with a packet-based bar rendered via `_draw()`
- Each incoming garbage "attack" is stored as a packet `{lines, is_filth}` in an ordered queue
- Packets drain from the bottom (oldest first) on line clears
- Regular garbage: red; filth garbage: yellow-orange; thin separator lines between packets

## Capabilities

### New Capabilities
- none

### Modified Capabilities
- `boss-modifiers`: adds The Fateless (no preview), The Ancient (random pieces), The Filth (individual cheese lines), The Reflection (damage reflection); removes The Surgeon; renames The Blitz, The Thin; adjusts The Aristocrat whitelist
- `attack-buffer`: **BREAKING** — `pending_garbage: int` replaced by `_garbage_packets: Array` in RunManager; `AttackBar.update_pending(int)` replaced by `update_packets(Array)`; all callers updated

## Impact

- `game/resources/boss_modifier.gd`: new fields — `hide_all_previews`, `random_pieces`, `garbage_individual_lines`, `reflect_ratio`
- `game/resources/round_config.gd`: new fields mirroring the above plus `reflect_ratio`
- `game/resources/data/boss_modifiers/`: edit 5 existing `.tres`, delete 1, add 3
- `game/resources/data/enemies/`: delete `boss_surgeon.tres`, add `boss_ancient.tres`, `boss_filth.tres`, `boss_reflection.tres`
- `game/scenes/tetris/tetris_board.gd`: `BagRandomizer` bypassed when `random_pieces` is set
- `game/scenes/game/run_manager.gd`: `pending_garbage: int` → `_garbage_packets: Array`; add reflect logic; filth packets inserted individually
- `game/scenes/game/attack_bar.gd`: full rewrite to packet-based `_draw()` renderer
- `game/tests/unit/`: new tests for reflect logic, packet queue, filth insertion
