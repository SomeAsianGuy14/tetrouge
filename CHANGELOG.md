# Changelog

## Unreleased

### New Features
- **Granular clear tracking** — The stats screen and run-end summary now track all clear types individually: Singles, Doubles, Triples, Quads, T-Spin Singles, T-Spin Doubles, T-Spin Triples, and Perfect Clears. The old combined "T-Spins" counter has been replaced with per-type breakdowns.
- **Best mastery tracking** — The stats screen now shows a "Best Mastery" section under Personal Bests, recording the highest mastery level you've ever reached for each clear type across all runs.

### Visual
- **Metallic enhancement cells** — Honed (silver) and Gilded (gold) cells now render with a metallic look: a two-tone gradient with a specular highlight band and sharper bevels, replacing the previous flat fill. The effect is consistent across the board, queue preview, and hold display.

### Balance
- **Boss scaling** — Boss enemies now scale with rooms cleared on the current floor (8% per room, same as other enemies). Previously bosses had a fixed quota regardless of how many rooms you'd cleared, which could make them easier than late-floor regular enemies.
- **Flat technique capacity** — Technique capacity is now fixed at 5 for all floors, instead of growing from 4 to 7. This keeps builds tighter and more deliberate throughout the run.
- **Technique damage buffs** — Clean Strike +1→+2, Low Pressure +1→+2, Opening Blow +3→+5, Patience +1→+2, Quad Echo +1→+3, Side Strike +1→+3, Flatline +2→+5, Flow Step +2→+5, Golden Blade +2→+4, Recycling +3→+4, Redzone +3→+4, Adrenaline Rush +5→+8, Glass Cannon +4→+8, Reckless Assault +4→+6, Finisher +1→+4. Dualcasting reduced +3→+2.
- **Keystone buffs** — Simple Sword/Wand +2→+3, Simple Shield 5→10, Legionnaire's Shield 10→20, Simplicity 2×→3×, Holy Cheese 2×→3×, Dizzy +4→+8, Golden Watch now earns 1 coin per second remaining (up from 1 per 5 seconds).
- **Rarity moves** — Sharpen, Barricade, Finisher moved to Rare. Perfect Spark, Compact Setup moved from Epic to Rare (Compact Setup threshold reduced to 30%).
- **Technique reworks** — Backpedaling now grants 1 shield per clear while combo >3 (was: next piece Reinforced). Escalation fires every 5 attacks for +5 (was: every 10 pieces for +2). Switch-Up grants +2 when clear type differs from previous (was: hard-drop/soft-drop alternation). Green Thumb awards 20 coins after 6 garbage lines (was: 4 coins per 5 lines). Combo Spike triggers every 3rd combo clear (was: 5th). Delayed Cannon → One-Two Punch: +6 when clear matches previous (was: alternating quad bonus). Gambler's Blade 50/50 for +8/-4 (was: 25/25 for +4/-2).
- **Burning Board** moved from Epic technique to keystone. Now multiplies all damage by ×1.5 (was: flat +3). Self-damage unchanged.
- **Enchant** moved from keystone to Rare technique. Now +3 damage per tspin-tagged technique on T-Spins (was: +2 per tspin/general technique as keystone).
- **Sticky Fingers** (was Greedy Hands) coin gain increased from 8 to 15.
- **Removed** — Chain Starter, Mini Spark, Chain Battery, Four Disciplines (techniques); Hybrid Reactor, Whirl, Flexible (keystones).
- **Renames** — Coupon → Haggling, Bounty List → Bounty Connections, Hone → Slash, Smooth Haggling → Upcharging, Simple Flail → Simple Bow, Mace and Chain → Recurve Bow, Charging Up → Supercharge.

### Bug Fixes
- **Total damage tracked correctly** — Total run damage was being overwritten with only the final round's damage at victory, making it look like the game tracked highest single-round damage instead of cumulative damage. Fixed by removing the overwrite; incremental tracking was already correct.
- **Enhancement overflow no longer dropped** — When two enhancement sources (technique + keystone, or periodic + consumable) fired on the same piece, the lower-priority enhancement was silently lost. It is now queued as a 1-piece grant and applied to the next unenhanced piece.
- **Shield bar overflow indicator visible** — The "+N" overflow text on the shield bar was drawn inside the bar area where it was hidden by full shield blocks. Moved above the bar.

### New Features
- **Technique rarity** — Techniques now have 3 rarity tiers: Common (white), Rare (blue), and Epic (purple). Rarity determines base cost (40/52/64), shop appearance frequency (commons appear most often), and name color across all UI. Shop prices vary ±4 around the base. Wishing Well and Library also use weighted draws.
- **Clear mastery** — Performing clears in combat now builds XP toward permanent attack bonuses. 7 mastery tracks (Singles, Doubles, Triples, Quads, T-Spin Single/Double/Triple) each grant +1 flat attack per level. XP thresholds escalate with level. Mastery also amplifies matching techniques (+1 per 2 mastery levels). A collapsible mastery panel in the HUD shows progress, and level-up popups appear when thresholds are crossed.
- **Persistent collection HUD** — Your keystones, techniques, backpack, and coin balance are now visible during encounters and the dungeon map, so you can make informed decisions at the Altar, Wishing Well, Library, and Museum. The panel is hidden during shop visits to avoid duplicating the shop's own collection display.
- **Wishing Well rework** — The Wishing Well no longer awards gold. Instead, each successful throw drops a random item: 60% consumable, 30% technique, 10% keystone. Rewards are capped at 3 per visit. The well handles full backpacks, technique caps, and exhausted pools gracefully.

### Balance
- **Economy rebalance** — All income sources buffed to match gilded-tier levels. Base payout increased from 4 to 15. Starting coins increased from 8 to 30. Keystone income buffed (Slightly Magical Coin 1→5, Magical Coin 4→15, Golden Watch 1→3 coins per 5 seconds). Economy technique rewards buffed (Combo Payout 5→20, Greedy Hands 2→8, Green Thumb 1→4 per trigger, Bounty List 10→40). Surplus attack conversion improved (÷3 → ÷2).
- **Price rescaling** — Technique costs raised from 3–8 to 40–60 range. Consumable costs raised from 4–6 to 30–40 range. Prices scale proportionally so relative ordering is preserved.
- **Bigger shops** — Shops now display 5 technique slots and 3 consumable slots (up from 3 and 2). Each rare shop visit feels like a bigger event with more choices.
- **Guaranteed shops** — Each dungeon floor now guarantees at least 2 shops (one per spine path). You'll always have somewhere to spend.
- **Interest removed** — The interest-on-unspent-coins mechanic has been removed. It was designed for frequent shop visits and no longer serves a purpose with rarer shops.
- **Vouchers removed** — The voucher system (Interest Cap Up, Expanded Shop, Consumable Expert, Bonus Round) has been removed. Their beneficial effects are now baked into the default shop and backpack sizes.

### New Features
- **Dungeon floor exploration** — Runs are now structured as 4 floors, each represented by a 6×6 dungeon map you navigate room by room. You start at the bottom-left corner and work toward the top-right Boss room, which is always visible from the start.
- **Dungeon map** — Each floor has 8–12 rooms of varying sizes. Fog of war hides rooms you can't reach yet; cleared-room neighbors are revealed and show their type. You choose your own path.
- **Room variety** — Eight new encounter rooms alongside the standard combat rooms and shops: Wishing Well (gamble coins for a payout), Altar of Techniques (sacrifice a technique for a random one), Altar of Keystones (sacrifice a keystone for a random one), Library (pick a free technique from a pool of 10), Robbers (surrender gold or fight an Elite), Unfortunate Head Trauma (lose a random technique), Pickpocket (lose half your coins), and Museum (claim a free keystone on display).
- **Within-floor scaling** — The more combat rooms you clear before fighting the boss, the tougher (and more rewarding) later encounters become. Boss difficulty is fixed per floor, giving you a meaningful choice between a riskier longer path and a quicker beeline.
- **Shop as optional room** — The shop is now a map room you discover and opt into rather than appearing automatically after every fight.
- **Run stats screen** — After every run (win or loss) a stats summary shows Total Damage, Best Combo, Best B2B, Quads, T-Spins, Perfect Clears, Run Time, and Most Common Clear. Personal-best values are marked with a gold ★ PB badge. A build summary lists the keystones and techniques you were running.
- **Stats menu** — A new Stats button on the main menu opens a persistent stats screen with three sections: Career (runs played, victories, best ascension), Personal Bests (best single-run damage, longest combo, longest B2B), and Lifetime Totals (total damage, quads, T-spins, total play time).
- **The Best Defense (keystone)** — Converts 25% of each attack into garbage shield charges. Moved from the technique pool to the keystone pool to better reflect its power level.

### Balance
- **4 floors replace 5 stages** — Run length is unchanged overall; enemy quota now scales exponentially per floor (same formula, retuned for 4 tiers). Technique capacity grows from 4 at floor 1 to 7 at floor 4.

### Balance
- **Enemy HP scales exponentially** — Enemy HP now doubles each stage (base × 2ⁿ⁻¹) with a growing per-round offset, replacing the previous flat +15/stage formula. Stage 1 is unchanged (20–44 HP). Stage 2 rises to 40–82, stage 3 to 80–140, stage 4 to 160–238, and stage 5 to 320–416. Builds that came online early no longer trivialise mid-game enemies.

### Bug Fixes
- **All dungeon rooms are now reachable** — Rooms that were placed with no adjacency path from the start room are now automatically removed before the floor is finalised, so you can never encounter a room on the map that is permanently inaccessible.
- **Defeating the Robbers now clears the encounter room** — Choosing to fight and winning the Elite combat now correctly marks the Robbers encounter room as cleared so it no longer shows as incomplete on the dungeon map.
- **Library shows its technique list** — The scroll area in the Library encounter now constrains button widths correctly so all available techniques are visible and selectable.
- **Wishing Well probability now accumulates correctly** — Each failed throw reliably increases the success chance by 1%; the display now reflects the true running probability.
- **Enemy health bar no longer persists into the shop or encounter rooms** — The enemy display, attack bar, and shield bar are now properly freed when leaving a combat room.
- **Boss room tile is now clickable** — The Boss tile on the dungeon map was enabled when adjacent but had no press handler wired; it now correctly navigates into the boss fight.
- **Continue now returns to the dungeon map** — Pressing Continue from the main menu no longer crashes; the game resumes at the floor map so you can choose your next room.
- **Combat now works correctly after leaving an encounter room** — The encounter room overlay was not being freed when leaving via the Leave/Dismiss button, causing it to cover the combat board on the next fight. The overlay is now properly removed.
- **RunFlow state machine** — Room-transition logic (routing, clearing, floor advancement, victory/failure decisions) is now in a dedicated `RunFlow` class that can be fully unit tested without a scene tree. RunManager delegates to it via signals.
- **Dungeon floors are now uniquely shaped every run** — Floor generation previously fell back to a fixed L-shaped template on almost every seed because random room placement rarely produced a connected path between the start and boss corners. Floors now use a spine-first approach: a seeded random path from start to boss is always placed first, then 1–3 branch rooms grow outward from it, producing a varied branching map that is always fully connected.
- **Stats and ascension records now persist when debugging** — Profile data is loaded at startup (in the autoload) instead of only when the main menu scene initialises, so records are available regardless of which scene you enter from.
- **Build summary shows correct names** — The keystone and technique names on the run-end screen now display the item's display name instead of showing a blank (the internal `name` property of a bare Resource).

### Removed
- **Gilded Touch (technique)** — Removed from the technique pool.

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
