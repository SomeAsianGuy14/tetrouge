# Changelog

## [0.4.0] — 2026-06-28

### New Features
- **Compendium** — A new screen accessible from the main menu tracks all discovered keystones, techniques, consumables, enemies, and bosses across runs. Five tabs with discovery counters. Discovered items show name and details; undiscovered show "???" with unlock progress if applicable.
- **17 new techniques** — Guard, Staff Spin, Brace, Volley, Perfect Placement, Slow and Steady, Safe Distance, Double Barrel, Whirlwind, Charging Up (technique), Thrash, Retribution, Concentrate, Blood Offering, Relentless Assault, and more.
- **19 new keystones** — Investment, Hardened Steel, Shield Bash, Cripple, Nothing to Waste, Equivalent Exchange, Big Brain, Ramping Rhythm, Ignition, Master of None, Master of One, Burning Board (moved from technique), and more.
- **7 new encounter rooms** — Tutor, Sleeping Beast, Laboratory, Demonic Deal, Mimic (disguised as Treasure Chest), Beggar, Map Room (reveals all fog).
- **Encounter reworks** — Museum → Treasure Chest. Pickpocket spawns a revenge combat room. Head Trauma dodgeable with speed items.
- **6 new enemies** — Corrupted Mage, Venomous Archer, Possessed Blade, Insane Adventurer, Giant Frog, Unstable Construct. Plus 3 encounter-specific enemies.
- **5 new bosses** — The Ram (ignores shields), The Jester (punishes same clears), The Berserker (faster at low HP), The Forgotten (hidden UI), The Furnace (5s fixed attacks).
- **Final boss pool** — Floor 4 draws from a separate pool: The Mutant (2 random boss effects), The Titan (2× HP/attack), The Klepto (drains mastery), The Origin (scales with kills).
- **Granular clear tracking** — Stats screen tracks all clear types individually with per-type breakdowns.
- **Best mastery tracking** — Stats screen shows highest mastery level reached per clear type across runs.
- **Damage-over-time system** — Ignition keystone delivers damage as a burn over 5 seconds.
- **Garbage-reactive techniques** — Thrash and Retribution fire when enemy sends garbage.
- **Persistent technique state** — Blood Offering's damage permanently increases per kill within a run.
- **Mastery keystones** — Master of None (no techniques, 2× mastery XP) and Master of One (×3 highest mastery, suppress others).

### Visual
- **Metallic enhancement cells** — Honed (silver) and Gilded (gold) cells render with a polished metallic look across board, queue, and hold display.

### Balance
- **Major technique rebalance** — 16 technique damage buffs, 7 technique reworks, 5 rarity moves. Dualcasting reduced.
- **Major keystone rebalance** — Simple Sword/Wand +3, Simple Shield 10, Legionnaire's Shield 20, Simplicity/Holy Cheese 3×, Dizzy +8, Golden Watch 1 coin/second.
- **Burning Board** moved to keystone with ×1.5 all-damage multiplier. **Enchant** moved to rare technique (+3 per tspin technique).
- **Boss scaling** — Bosses now scale with rooms cleared (8% per room), same as other enemies.
- **Flat technique capacity** — Fixed at 5 for all floors (was 4→7).
- **Room distribution rebalanced** — More combats, fewer encounters. ~3 shops, ~7-8 combats, ~3 encounters per floor.
- **Removed** — Chain Starter, Mini Spark, Chain Battery, Four Disciplines, Hybrid Reactor, Whirl, Flexible, Gilded Touch.
- **Renames** — Coupon → Haggling, Bounty List → Bounty Connections, Hone → Slash, Smooth Haggling → Upcharging, Simple Flail → Simple Bow, Mace and Chain → Recurve Bow, Charging Up → Supercharge. Enemy renames: Rock Crawler → Stone Crab, The Warden → Dungeon Warden, Void Knight → Fallen Knight, Crimson Drake → Lesser Drake, Iron Shambler → Armored Skeleton.

### Bug Fixes
- **Total damage tracked correctly** — Was overwriting run total with last round's damage.
- **Enhancement overflow no longer dropped** — Blocked enhancements now queue for next piece.
- **Shield bar overflow indicator visible** — Moved above the bar.
- **Popup events no longer fire twice** — Duplicate keystone/technique popups fixed.
- **Run time tracks wall-clock time** — Was tracking timer remaining instead of elapsed.
- **Consumables disabled outside combat** — Backpack greyed out on map/encounters.
- **Victories stat no longer inflated by tests** — Test suite now saves/restores profile correctly.

## [0.3.0] — 2026-06-15

### New Features
- **Piece enhancements** — Pieces can now spawn with a special enhancement, granted by certain techniques and consumables: Honed (silver) adds bonus attack when cleared, Amplified (yellow marker) multiplies attack when cleared, Gilded (gold) pays coins when cleared, and Reinforced (brown with a silver border) builds up a garbage-shield that blocks incoming attacks. A new shield bar next to the board tracks your current shield charges. Enhancements show on the board, the falling piece, and carry over through hold.
- **Queue shows upcoming enhancements** — The next pieces shown in the queue now preview which will arrive Honed, Amplified, Gilded, or Reinforced, using the same styling as the hold and board pieces.
- **Clear type popup** — After every line clear a label briefly appears below the hold piece naming what you just did (Single, Double, Triple, Quad, T-Spin variants, Perfect Clear). Plain clears fade out quietly in white; Quads pop in cyan, T-Spins in purple, and Perfect Clears in gold with a brief scale-up animation. The popup fades over 1 second, and a new clear during that fade replaces it instead of stacking another label.
- **Enemy panel redesign** — The right side of the screen now shows a full-height enemy panel with the enemy name, a large portrait area (initial-letter placeholder in enemy colour until artwork is added), stage/round label, optional flavor text, and boss modifier description.
- **Enemy flavor text field** — Enemy data now has an optional flavor text field for lore descriptions (currently blank, to be filled in a future update).
- **New techniques** — Sharpen (replaces Keen Edge; every 6th piece spawns Honed), Barricade (every 6th piece spawns Reinforced), The Best Defense (converts 25% of your attack into shield), Last Stand (the first time your board height exceeds 80% each round, gain 10 shield), Preparation (after a Quad, your next piece is Honed), Backpedaling (after your combo exceeds 5, your next piece is Reinforced), and Golden Blade (deal +2 damage on any clear containing a Gilded cell).
- **New keystones** — Extraordinary Bag (every 7th piece spawns with a random enhancement), Charging Up (every 10th piece spawns Amplified), Jack of All Trades (doubles all piece-enhancement clear benefits), Refined (+2 damage per Honed cell), Armored (+2 shield per Reinforced cell), Polished (+1 coin per Gilded cell), and Overclocked (Amplified pieces are 50% more effective).
- **New consumable** — Lottery Ticket: your next 3 pieces spawn with a random enhancement.
- **Round-end income breakdown** — The round complete screen now shows where your coins came from: Base Payout, Tech/Keystone income (technique economy bonuses, surplus conversion, Greedy Hands, Bounty List, end-of-round keystone payouts, Golden Watch), and Enhancements (Gilded cells cleared during the round), plus a Total. Rows with no income are hidden.

### Visual
- **Enemy death animation** — When an enemy's HP hits zero the portrait flashes white, expands, and dissolves before the results screen appears. Boss enemies get a more dramatic version: a larger scale punch, a horizontal shake, and an extended fade.
- **Lunge animation** — The enemy portrait lunges toward the board when an attack fires, then eases back into place.
- **Anticipation pulse** — At 80% or more charge the portrait pulses slightly, signalling the incoming attack.
- **Damage feedback** — When the player deals damage the portrait flashes red and a floating damage number drifts upward.
- **Line clear delay** — When a piece clears one or more rows, the board briefly pauses (~0.5s) and flashes the cleared rows before removing them and spawning the next piece. Gives a satisfying moment of feedback on every clear. The Full Potential keystone skips the delay entirely to match its instant-play identity.
- **Technique visual feedback** — Techniques and keystones now announce themselves during play. When a clear fires, each contributing technique and keystone produces a floating popup label that drifts upward (white for attack, gold for economy-only, blue for keystone bonuses) near the keystone list in the bottom-left HUD. Popups cascade sequentially across the line clear delay window. Technique icons in the HUD pulse when their trigger condition is armed (e.g. Escalation ready). Keystones flash blue when their bonus fires. Every icon also plays a brief scale-pop at the moment it contributes to a clear.

### Balance
- **Midas Touch reworked** — No longer converts overkill damage to coins; every 7th piece now spawns Gilded instead.
- **Simple Shield / Legionnaire's Shield reworked** — No longer reduce incoming garbage. Instead, grant 5 / 10 shield charges at the start of each round.
- **Consumables renamed** — Whetstone → Sharpening Stone, Gilding Kit → Gold Leaf, Reinforcing Plate → Steel Plates, Arcane Battery → Charged Battery (now enhances your next 2 pieces instead of 4).
- **Gold Leaf reined in** — Now enhances your next 2 pieces with Gilded instead of 4, to tone down its coin output.
- **Enhancement grants now queue** — Using an enhancement consumable while a different one is already active queues it instead of overwriting the current grant, so the active grant finishes first.

### Bug Fixes
- **Renamed items no longer vanish from saves** — Continuing a run saved before this update no longer silently drops Sharpen, Sharpening Stone, Gold Leaf, Steel Plates, or Charged Battery from your inventory; old save data now maps to their renamed counterparts.
- **Hold / rotate / hard drop during line clear** — Pressing hold, rotate, or hard drop during the clear flash no longer corrupts the held piece or skips a piece from the queue.
- **Directional input during line clear** — Pressing a direction during the clear flash now correctly primes DAS so the new piece responds immediately on spawn.
- **Enemy portrait stops animating on pause** — Anticipation pulse, lunge, and damage flash now stop immediately when the pause menu opens.
- **Hybrid Reactor damage spike on B2B combos** — The keystone's tag bonus now fires once per clear instead of once per attack signal (which could triple the bonus on B2B combo quads).
- **Attack Battery triggers on correct clear** — The "every 4th clear" bonus now fires on clears 4, 8, 12… instead of 5, 9, 13…
- **Board height conditions fixed** — The board height measurement was inverted (a tall stack read as a low one), so every height-based technique triggered backwards: Redzone and Aggressive Positioning fired on near-empty boards, Low Pressure and Compact Setup on tall ones. Height is also now measured on every piece lock instead of only after clears, so these techniques react to the current stack rather than a stale one.
- **Adrenaline Rush actually requires a tall stack** — Previously it fired on almost any clear; now it correctly requires the stack to reach the top 4 rows.
- **Full Potential no longer changes technique behaviour** — Skipping the line clear delay used to make techniques evaluate after the clear was processed, so combo techniques shifted by one step, Back-to-Back techniques fired one clear early, and Whirl missed the current clear. All techniques now behave identically with or without the keystone.
- **Single-clear keystones work** — Simple Flail, Mace and Chain, and Holy Cheese builds now add damage to Singles (which have 0 base attack); previously the bonus was silently dropped. Their popups now show too.
- **Flash Step ARR restored correctly** — Flash Step's instant auto-repeat used to stay on for the rest of the round; it now lasts exactly one piece, and restoring it no longer cancels Full Potential's instant ARR.
- **Pausing no longer disables instant ARR** — Closing the pause menu used to reset auto-repeat to your settings value, cancelling Full Potential (and an active Flash Step) until the next round.
- **Side Strike counts for Sharpen** — Its quad tag had an outdated name so Sharpen ignored it.
- **Enchant counts all T-Spin-applicable techniques** — General-tagged techniques now count toward its per-technique bonus (matching how Sharpen counts them for Quads), and the bonus now applies to T-Spin Minis.
- **Final Blow can finish a round** — Its burst damage now updates the enemy HP bar immediately and ends the round if it meets the quota, instead of waiting for your next attack.
- **Surge consumables no longer waste charges** — A zero-damage Single no longer consumes a surge charge.
- **Enhanced cells flash with their own color on clear** — Honed, Gilded, and Reinforced cells now flash silver/gold/brown during the line clear delay instead of flashing their original piece color.
- **Enhancement consumables apply immediately** — Using a Honed/Amplified/Gilded/Reinforced consumable now enhances the piece currently in play right away, instead of waiting for the next piece to spawn.

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
