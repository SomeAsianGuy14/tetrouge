# Changelog

## Unreleased

### New Features
- **Clear type popup** — After every line clear a label briefly appears below the hold piece naming what you just did (Single, Double, Triple, Quad, T-Spin variants, Perfect Clear). Plain clears fade out quietly in white; Quads pop in cyan, T-Spins in purple, and Perfect Clears in gold with a brief scale-up animation.
- **Enemy panel redesign** — The right side of the screen now shows a full-height enemy panel with the enemy name, a large portrait area (initial-letter placeholder in enemy colour until artwork is added), stage/round label, optional flavor text, and boss modifier description.
- **Enemy flavor text field** — Enemy data now has an optional flavor text field for lore descriptions (currently blank, to be filled in a future update).

### Visual
- **Enemy death animation** — When an enemy's HP hits zero the portrait flashes white, expands, and dissolves before the results screen appears. Boss enemies get a more dramatic version: a larger scale punch, a horizontal shake, and an extended fade.
- **Lunge animation** — The enemy portrait lunges toward the board when an attack fires, then eases back into place.
- **Anticipation pulse** — At 80% or more charge the portrait pulses slightly, signalling the incoming attack.
- **Damage feedback** — When the player deals damage the portrait flashes red and a floating damage number drifts upward.

### Visual
- **Line clear delay** — When a piece clears one or more rows, the board briefly pauses (~0.5s) and flashes the cleared rows before removing them and spawning the next piece. Gives a satisfying moment of feedback on every clear. The Full Potential keystone skips the delay entirely to match its instant-play identity.
- **Technique visual feedback** — Techniques and keystones now announce themselves during play. When a clear fires, each contributing technique and keystone produces a floating popup label that drifts upward (white for attack, gold for economy-only, blue for keystone bonuses). Popups cascade sequentially across the line clear delay window. Technique icons in the HUD pulse when their trigger condition is armed (e.g. Escalation ready). Keystones flash blue when their bonus fires. Every icon also plays a brief scale-pop at the moment it contributes to a clear.

### Bug Fixes
- **Hold / rotate / hard drop during line clear** — Pressing hold, rotate, or hard drop during the clear flash no longer corrupts the held piece or skips a piece from the queue.
- **Directional input during line clear** — Pressing a direction during the clear flash now correctly primes DAS so the new piece responds immediately on spawn.
- **Enemy portrait stops animating on pause** — Anticipation pulse, lunge, and damage flash now stop immediately when the pause menu opens.
- **Hybrid Reactor damage spike on B2B combos** — The keystone's tag bonus now fires once per clear instead of once per attack signal (which could triple the bonus on B2B combo quads).
- **Attack Battery triggers on correct clear** — The "every 4th clear" bonus now fires on clears 4, 8, 12… instead of 5, 9, 13…

---

## [0.2.2] — 2026-06-05

### New Features
- **Window mode and size settings** — Settings screen now has Window and Size rows. Toggle between Windowed and Fullscreen; choose Small (1280×720), Medium (1600×900), or Large (1920×1080) when windowed. Preferences persist across sessions.

### Visual
- **Dungeon board style** — Tetris cells now render with a bevelled stone-block look (highlight top/left, shadow bottom/right). Garbage blocks gain a position-varied crack pattern. The ghost piece renders as a dark void fill with a piece-coloured rune outline that turns white while soft-dropping. Board background shifted to a darker tone with slight violet warmth.

### Bug Fixes
- Web: starter keystone selection (Simple Sword, Flail, Shield, Wand, Slightly Magical Coin) now appears correctly on New Run.
- Settings: window mode and size buttons no longer emit "Embedded window" warnings when used inside the Godot editor.

---

## [0.1.0] — 2026-05-30
Initial public release.

---

## [0.2.1] — 2026-06-03

### New Features
- **Flush threshold marker** — The attack bar now shows a line indicating the 8-line flush cap.
- **Keystone flavor text** — Keystones with flavor text now display it in the selection screen, styled below the description.
- **Timer removed as failure condition** — The round timer no longer kills the run on expiry. Topping out is now the only way to lose a round. The timer is hidden from the HUD entirely.
- **Golden Watch reworked** — Now reveals a personal 3-minute timer and earns 1 coin per 5 seconds remaining at round end.
- **The Blitz reworked** — Timer raised to 2 minutes. The timer is always visible during a Blitz round and failing to defeat the enemy before it expires still ends the run.
- **Attack bar column visualization** — Garbage packets that share a hole column are shown as one solid block. When consecutive packets land in different columns a black separator bar appears between them.
- **Garbage freeze on clear** — Incoming garbage is not flushed to the board on the same piece lock that clears lines, giving a brief moment of relief after a clear.


### Balance
- **Simple Shield / Legionnaire's Shield** — Damage reduction now applies when the attack enters the buffer (lines blocked before queuing), rather than reducing flush capacity. A 2-line attack with Simple Shield now puts only 1 line in the buffer; Legionnaire's Shield can block small attacks entirely.


### Bug Fixes
- The Reflection boss: enemy attack windup bar is now hidden (boss never attacks).
- The Reflection boss: reflected garbage is now non-drainable — player attacks no longer cancel their own reflections.
- The Reflection boss: fixed a bug where reflected lines were silently discarded instead of reaching the board.
- The Blitz boss: timer now correctly starts at 2 minutes.
- Victory screen: Main Menu button now correctly returns to the main menu; restarting no longer leaves the victory screen visible behind the new run.
- Shop: "Technique slots full" label removed — greyed-out buy buttons communicate this on their own.
- HUD: Timer labels no longer flash briefly before being hidden at round start.
- HUD: HUD is now hidden during the starter keystone selection screen.
- Saves: Fixed a crash when pressing Continue after a run (leftover reference to removed speed bonus field).

---

## [0.2.0] — 2026-06-02

### New Features
- **Ascension system** — Beat the game to unlock harder difficulty levels. Each ascension adds a new modifier on top of all previous ones (faster attacks, more garbage damage, reduced backpack capacity, increased enemy HP, no starter keystone, reduced technique capacity). The ascension selector appears before each new run once you've cleared the game at least once.
- **Starter weapon upgrades** — Great Sword, Mace and Chain, Legionnaire's Shield, Crystal Staff, and Magical Coin are new keystones that replace their starter counterpart when picked.
- **New keystones** — Blessed Stone (one-time revive: clears your board and adds 2 minutes on death), Hybrid Reactor (attacks deal bonus damage per technique with 2+ tags), Reflect (incoming garbage deals 50% back as damage to the enemy).
- **Persistent profile save** — Ascension progress, run count, and damage stats are saved to a separate profile file that persists across runs.

### Balance
- **Enemy attacks slowed** — Base garbage intervals increased by ~25% across all enemy tiers, giving more breathing room at Ascension 0.
- **Simple Shield** — Garbage reduction 2 → 1 line per flush.
- **Great Sword** — Now requires Simple Sword (was Slightly Magical Coin); damage bonus 8 → 10.
- **Double Trouble** — T-Spin Singles and Triples no longer deal 0 damage; only the 2x Double bonus remains.
- **Triple Threat** — T-Spin Singles and Doubles no longer deal 0 damage; only the 3x Triple bonus remains.
- **Magical Coin** — Now replaces Slightly Magical Coin on pick; coins per round 2 → 4.

### Bug Fixes
- The Reflection boss: attack bar is now hidden during the fight since the boss never sends garbage.
- The Reflection boss: reflected garbage now enters the attack buffer and is visible before hitting the board, rather than being applied instantly on the same piece lock.
- Web export: fixed shop slots and keystone selection not loading (directory scanning doesn't work in browser builds; replaced with preloaded registry).
- Web export: fixed ⚡ emoji rendering as a box; replaced with "ATK:" text.
- Burning Board: now correctly inserts a garbage row into the player's board every 5 seconds instead of healing the enemy.
- Shop: selling a technique while at capacity now correctly re-enables Buy buttons on the remaining slots.
