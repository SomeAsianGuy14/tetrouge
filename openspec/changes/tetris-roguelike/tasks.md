## 1. Project Setup

- [x] 1.1 Create new Godot 4 project with GDScript, configure export presets for HTML5 and Desktop
- [x] 1.2 Set up folder structure: `scenes/`, `scripts/`, `resources/`, `assets/`, `autoloads/`
- [x] 1.3 Create `Economy` autoload singleton with coin balance, payout, and interest logic
- [x] 1.4 Create `RunState` autoload singleton to track ante, round index, active Techniques, Augments, and Consumables

## 2. Tetris Core — Playfield

- [x] 2.1 Create `TetrisBoard` scene with a 10×22 grid (20 visible + 2 hidden spawn rows)
- [x] 2.2 Implement grid state representation and cell rendering (empty, filled by colour, ghost, garbage)
- [x] 2.3 Implement the 7-bag piece randomiser
- [x] 2.4 Implement piece spawn at guideline positions in the hidden rows
- [x] 2.5 Implement SRS rotation with all wall kick tables (J, L, S, Z, T, I, O pieces)
- [x] 2.6 Implement horizontal movement with DAS (167ms) and ARR (33ms), both configurable
- [x] 2.7 Implement gravity (piece falls at fixed rate; soft drop at 20× normal speed)
- [x] 2.8 Implement hard drop (instant move to ghost position and lock)
- [x] 2.9 Implement ghost piece (shadow showing hard drop destination, updates on every move/rotate)
- [x] 2.10 Implement lock delay (500ms timer, resets on move/rotate, max 15 resets)
- [x] 2.11 Implement hold piece slot; enforce hold lockout until next piece locks
- [x] 2.12 Implement line clear detection: identify full rows, remove them, shift rows above down
- [x] 2.13 Emit `piece_locked` and `lines_cleared(count, clear_type)` signals from `TetrisBoard`
- [x] 2.14 Implement game-over detection (block-out: new piece cannot spawn)

## 3. Attack System

- [x] 3.1 Implement T-spin detection using the 3-corner rule on piece lock
- [x] 3.2 Implement perfect clear detection (all cells empty after line clear)
- [x] 3.3 Implement back-to-back tracking (flag set by qualifying clears, broken by non-qualifying)
- [x] 3.4 Implement combo counter (increments on consecutive clears, resets on empty lock)
- [x] 3.5 Implement `attack_generated(raw_attack: int, event_type: String)` signal emission from `TetrisBoard` for each clear event using guideline attack values
- [x] 3.6 Implement `RunManager` receiver for `attack_generated` that applies active Technique modifiers and accumulates toward quota

## 4. Round and Run Structure

- [x] 4.1 Create `RunManager` scene that owns the run loop: ante counter, round index, quota, timer
- [x] 4.2 Implement `RoundConfig` resource with fields: quota, time_limit, boss_modifier, augments
- [x] 4.3 Implement round start: build `RoundConfig`, instantiate `TetrisBoard`, pass config, start timer
- [x] 4.4 Implement quota tracking: accumulate modified attack, detect when quota is met, end round as success
- [x] 4.5 Implement timer countdown display and expiry detection (end round as failure)
- [x] 4.6 Implement round success flow: stop board, calculate speed bonus, call `Economy.pay_round()`, transition to Augment selection (boss) or shop
- [x] 4.7 Implement round failure flow: stop board, show failure screen, return to main menu
- [x] 4.8 Implement run victory detection (Boss Blind of Ante 5 cleared) and victory screen
- [x] 4.9 Implement run initialisation: set starting coin balance, draw and assign starting Augment from starter pool

## 5. Boss Modifiers

- [x] 5.1 Create `BossModifier` resource type with an id, display name, description, and effect enum/type
- [x] 5.2 Implement modifier application in `TetrisBoard` via `RoundConfig`: disable hold (The Void), reduce preview count (The Blinder), disable B2B (The Silencer), narrow board (The Narrow)
- [x] 5.3 Implement The Tide: periodic timer in `RunManager` that inserts a garbage row every 20 seconds during Boss rounds
- [x] 5.4 Implement The Enforcer: override time limit to 45s in `RoundConfig` for boss rounds with this modifier
- [x] 5.5 Implement The Purge and The Surgeon: filter which attack events count toward quota in `RunManager`
- [x] 5.6 Implement boss modifier pool and random selection without repetition within a run
- [x] 5.7 Add visual indicator for active boss modifier during play (name and icon displayed on HUD)

## 6. Augments

- [x] 6.1 Create `Augment` resource type with id, display name, description, and effect parameters
- [x] 6.2 Implement Foresight: pass preview_count = 7 via `RoundConfig` to `TetrisBoard`
- [x] 6.3 Implement Extended Buffer: second hold slot logic in `TetrisBoard`, toggled via `RoundConfig`
- [x] 6.4 Implement Loose Lock: pass lock_delay_ms = 650 via `RoundConfig`
- [x] 6.5 Implement Quick Swap: disable hold lockout in `TetrisBoard` via `RoundConfig`
- [x] 6.6 Implement Bag Shift: subclass randomiser to reset every 5 pieces, selected via `RoundConfig`
- [x] 6.7 Implement Iron Will: pass lock_max_resets = 25 via `RoundConfig`
- [x] 6.8 Implement Deep Sight: display numeric distance on ghost piece, toggled via `RoundConfig`
- [x] 6.9 Implement Second Wind: `RunManager` monitors timer and pauses it once per round when ≤10s remain and quota not met
- [x] 6.10 Implement Augment selection screen: display 3 drawn Augments after boss, player picks 1, update `RunState`
- [x] 6.11 Implement starter Augment pool and run-start random draw

## 7. Economy and Shop

- [x] 7.1 Implement `Economy.pay_round(base, speed_bonus, technique_income)` — credits all round earnings
- [x] 7.2 Implement `Economy.apply_interest()` — called on shop open, applies 1 per 5 cap 5 formula
- [x] 7.3 Create shop scene with slots: 3 Technique slots, 1 Consumable slot, 1 Voucher slot
- [x] 7.4 Implement shop inventory generation: random draw from respective pools per slot type
- [x] 7.5 Implement purchase flow: check balance, deduct cost, add item to `RunState`, mark slot empty
- [x] 7.6 Implement "already owned" display for Techniques already in `RunState`
- [x] 7.7 Implement exit shop button; transition to next round on exit
- [x] 7.8 Implement coin display and balance updates in shop UI

## 8. Techniques

- [x] 8.1 Create `Technique` resource type with id, name, description, target event types, and modifier values
- [x] 8.2 Implement all 10 launch Techniques as resource instances (Specialist, Chain Reaction, Perfectionist, Momentum, Efficiency, Avalanche, Persistence, Windfall, Surplus, Stylist)
- [x] 8.3 Implement Technique modifier pipeline in `RunManager.on_attack_generated()`: apply flat bonuses and multipliers in purchase order
- [x] 8.4 Implement economy-stream Techniques (Windfall, Surplus, Stylist): accumulate coin events during round, credit via `Economy` at round end

## 9. Consumables and Vouchers

- [x] 9.1 Create `Consumable` resource type with id, name, description, use timing, and effect type
- [x] 9.2 Implement all 5 launch Consumables (Clean Slate, Piece Lock, Time Shard, Coin Purse, Attack Surge)
- [x] 9.3 Implement consumable inventory UI (2 slots visible during round start and in shop)
- [x] 9.4 Implement consumable use flow: apply effect, remove from inventory
- [x] 9.5 Implement inventory cap enforcement (max 2 consumables; block purchase when full)
- [x] 9.6 Create `Voucher` resource type with id, name, description, and effect type
- [x] 9.7 Implement all 5 launch Vouchers (Interest Cap Up, Expanded Shop, Consumable Expert, Bonus Round, Sharp Eye)
- [x] 9.8 Implement voucher effects: modify `Economy` caps, shop slot count, speed bonus formula, Sharp Eye modifier preview

## 10. UI and Polish

- [x] 10.1 Implement main menu (New Run, Settings, Quit)
- [x] 10.2 Implement HUD during rounds: quota progress bar, timer countdown, coin balance, active Augment icons, active boss modifier indicator
- [x] 10.3 Implement round success screen: payout breakdown (base + speed + technique income), proceed button
- [x] 10.4 Implement run failure screen: ante/round reached, restart button, main menu button
- [x] 10.5 Implement run victory screen: win message, final coin balance, restart button
- [x] 10.6 Implement settings screen: DAS and ARR slider controls
- [x] 10.7 Add visual and audio feedback for line clears, T-spins, perfect clears, B2B, and combos
- [x] 10.8 Test web export: verify timing accuracy, audio latency, and input responsiveness in browser
