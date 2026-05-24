## ADDED Requirements

### Requirement: Keystone data model
Each `Keystone` resource SHALL carry the following exported fields in addition to `id`, `display_name`, `description`, and `is_starter`:

- `category: String` — one of "Starter", "Tetris", "T-Spin", "B2B", "Combo", "PC", "Economic", "Utility"
- `requires_keystone_id: String` — if non-empty, the keystone only enters the selection pool when the player already owns the keystone with that ID

Attack-modifier fields (all default 0 / 0.0 / false):
- `single_bonus`, `double_bonus`, `triple_bonus`, `quad_bonus` — flat damage added to that clear type
- `tspin_mini_bonus`, `tspin_single_bonus`, `tspin_double_bonus`, `tspin_triple_bonus`, `tspin_any_bonus` — flat damage added to that T-spin type
- `b2b_bonus` — flat damage added to the B2B event
- `per_technique_quad_bonus` — flat damage added per owned Technique with a quad-related event bonus
- `per_technique_tspin_bonus` — flat damage added per owned Technique with a T-spin–related event bonus
- `quad_multiplier` — multiplier applied to the quad clear attack (1.0 = no effect)
- `tspin_double_multiplier`, `tspin_triple_multiplier` — multiplier for those specific T-spin types
- `single_multiplier` — multiplier applied to single-clear attack
- `combo_multiplier`, `combo_multiplier_threshold` — multiplier applied to combo events when combo count exceeds the threshold
- `pc_first_multiplier` — multiplier applied to the first PC each round
- `pc_after_first_multiplier` — multiplier applied to every PC after the first in a round
- `consecutive_quad_multiplier` — multiplier applied when a quad immediately follows another quad
- `suppress_spins: bool` — zeroes attack for all T-spin events
- `suppress_tspin_single: bool` — zeroes attack for tspin_single events
- `suppress_tspin_double: bool` — zeroes attack for tspin_double events
- `suppress_tspin_triple: bool` — zeroes attack for tspin_triple events
- `suppress_non_singles: bool` — zeroes attack for all events except single clears

Mechanic flags:
- `daze_stun_seconds: float` — seconds added to the enemy garbage timer on each quad clear
- `dizzy: bool` — next T-spin deals +4 if the T-piece was rotated more than 4 times before locking
- `safety_net: bool` — grants one B2B shield per round (B2B does not break the first time it would)
- `final_blow: bool` — when B2B breaks, deal the B2B streak × 2 as bonus quota and disable further B2B gain this round
- `flexible_b2b: bool` — all spin clears (not only T-spins) maintain B2B

Economy fields:
- `end_round_coins: int` — coins granted at the end of a won round
- `overkill_coins: bool` — surplus damage (quota overflow) converts 1:1 to coins at round end
- `time_coins: bool` — at round end (win), grants `floor(time_remaining / 5)` coins

Utility fields:
- `hold_slots_bonus: int` — added to the default `RoundConfig.hold_slots` (1)
- `preview_count_bonus: int` — added to the default `RoundConfig.preview_count` (5)
- `instant_arr: bool` — sets auto-repeat rate to 0 ms
- `instant_soft_drop: bool` — sets soft-drop delay to 0 ms
- `garbage_flush_reduction: int` — reduces the number of garbage rows flushed per piece lock (floor 0)

#### Scenario: Keystone applies RoundConfig utility bonuses at round start
- **WHEN** the player owns a keystone with `hold_slots_bonus = 1` and `preview_count_bonus = 2`
- **THEN** `RoundConfig.hold_slots` is 2 and `RoundConfig.preview_count` is 7 at round start

#### Scenario: Unknown field defaults do not crash apply_to_config
- **WHEN** a keystone with all bonus fields at their zero defaults is applied
- **THEN** `apply_to_config` makes no changes to RoundConfig

### Requirement: Keystone attack-modifier pipeline
When the player generates an attack event, `RunManager` SHALL apply keystone effects in this order after `_apply_techniques`:
1. Suppressions — if the event type is suppressed, set the running total to 0
2. Flat bonuses — add all applicable flat and per-technique bonuses
3. Multipliers — apply all applicable multipliers (multiplicative with each other)

Keystone effects run after the Technique phase so Technique bonuses are always honoured first.

#### Scenario: Suppression zeroes the event before bonuses
- **WHEN** `suppress_spins` is true and the event is `tspin_double`
- **THEN** the attack value after the keystone pipeline is 0 regardless of any flat bonuses that apply

#### Scenario: Flat bonus added after suppression check
- **WHEN** `suppress_tspin_single` is true and the event is `tspin_double` and `tspin_double_bonus` is 3
- **THEN** the tspin_double attack is not suppressed and 3 is added to the total

#### Scenario: Multiplier applied after flat bonus
- **WHEN** technique phase yields 4 and `quad_bonus` is 2 and `quad_multiplier` is 2.0
- **THEN** the result is (4 + 2) × 2.0 = 12

### Requirement: Run-start starter keystone selection
Before the first board of every run is loaded, the game SHALL present the keystone selection screen in starter-only mode. The pool SHALL contain only keystones with `is_starter = true`. Three options SHALL be drawn using the seeded run PRNG (same draw mechanic as post-boss selections). The player SHALL choose one; the chosen keystone is added to RunState before `start_round()` is called. No shop is shown between the starter pick and round 1.

#### Scenario: Starter selection screen shown before round 1
- **WHEN** a new run begins
- **THEN** the keystone selection screen appears showing 3 starter keystones before any board is loaded

#### Scenario: Only is_starter keystones appear in the run-start pool
- **WHEN** the run-start selection pool is drawn
- **THEN** no keystone with `is_starter = false` is included in the offered options

#### Scenario: Chosen starter is added to RunState before round 1
- **WHEN** the player picks a starter keystone
- **THEN** `RunState.keystones` contains that keystone when `start_round()` is called

### Requirement: Conditional keystone availability
A keystone with a non-empty `requires_keystone_id` SHALL only appear in the selection pool if the player's `RunState.used_keystone_ids` contains that ID. It SHALL NOT appear otherwise, even if the player has unused keystone picks remaining.

#### Scenario: Great Sword hidden without Slightly Magical Coin
- **WHEN** the player's `used_keystone_ids` does not contain `"slightly_magical_coin"`
- **THEN** Great Sword is not included in the pool of three offered keystones

#### Scenario: Great Sword available after Slightly Magical Coin is obtained
- **WHEN** the player's `used_keystone_ids` contains `"slightly_magical_coin"`
- **THEN** Great Sword is eligible for the selection pool alongside other unlocked keystones

### Requirement: Starter keystones catalog
The following keystones SHALL have `is_starter = true` and be available from the first keystone selection:

| ID | Display Name | Key Effect |
|---|---|---|
| `simple_bow` | Simple Bow | `single_bonus = 1`, `double_bonus = 1` |
| `simple_shield` | Simple Shield | `garbage_flush_reduction = 2` |
| `simple_sword` | Simple Sword | `quad_bonus = 2` |
| `simple_wand` | Simple Wand | `tspin_single_bonus = 2`, `tspin_double_bonus = 2`, `tspin_triple_bonus = 2` |
| `simple_bag` | Simple Bag | `hold_slots_bonus = 1` |
| `slightly_magical_coin` | Slightly Magical Coin | `end_round_coins = 1` |

#### Scenario: Simple Bow adds 1 to singles and doubles only
- **WHEN** a single-clear attack fires and the player owns Simple Bow
- **THEN** 1 is added to the attack value; quad clears are unaffected

#### Scenario: Simple Shield reduces flush by 2
- **WHEN** `pending_garbage` is 5 and Simple Shield is owned
- **THEN** only 3 garbage rows are flushed on piece lock (5 − 2, within the 8-row cap)

#### Scenario: Simple Bag increases hold slots to 2
- **WHEN** a round starts and Simple Bag is owned
- **THEN** `RoundConfig.hold_slots` is 2

#### Scenario: Slightly Magical Coin grants 1 coin at round end
- **WHEN** a round ends in a win and the player owns Slightly Magical Coin
- **THEN** 1 coin is credited before the payout screen

### Requirement: Tetris keystones catalog
The following non-starter keystones SHALL be in the "Tetris" category:

| ID | Display Name | Key Effect |
|---|---|---|
| `dual_wielding` | Dual Wielding | `consecutive_quad_multiplier = 2.0` |
| `sharpen` | Sharpen | `per_technique_quad_bonus = 2` |
| `daze` | Daze | `daze_stun_seconds = 2.0` |
| `simplicity` | Simplicity | `quad_multiplier = 2.0`, `suppress_spins = true` |
| `great_sword` | Great Sword | `quad_bonus = 8`, `requires_keystone_id = "slightly_magical_coin"` |

#### Scenario: Dual Wielding doubles damage on consecutive quads
- **WHEN** the player sends two quads in a row without any other clear between them
- **THEN** the second quad's attack is multiplied by 2; the first is not

#### Scenario: Dual Wielding resets on a non-quad clear
- **WHEN** a quad is followed by a double and then another quad
- **THEN** the third clear (quad) does NOT get the consecutive multiplier

#### Scenario: Sharpen adds 2 per quad-related technique
- **WHEN** the player owns Sharpen and 2 Techniques with quad-related bonuses, and sends a quad
- **THEN** the quad attack is increased by 4 (2 per applicable technique)

#### Scenario: Simplicity multiplies quads and suppresses spins
- **WHEN** Simplicity is owned and a T-spin double fires
- **THEN** the T-spin attack is zeroed; a quad clear on the same lock deals double damage

#### Scenario: Daze delays enemy garbage timer on quad
- **WHEN** the player sends a quad and owns Daze
- **THEN** the enemy garbage timer is extended by 2 seconds

### Requirement: T-Spin keystones catalog
The following non-starter keystones SHALL be in the "T-Spin" category:

| ID | Display Name | Key Effect |
|---|---|---|
| `dizzy` | Dizzy | `dizzy = true` (see mechanic requirement) |
| `double_trouble` | Double Trouble | `tspin_double_multiplier = 2.0`, `suppress_tspin_single = true`, `suppress_tspin_triple = true` |
| `triple_threat` | Triple Threat | `tspin_triple_multiplier = 3.0`, `suppress_tspin_single = true`, `suppress_tspin_double = true` |
| `enchant` | Enchant | `per_technique_tspin_bonus = 2` |

#### Scenario: Dizzy bonus fires only when T-piece rotated more than 4 times
- **WHEN** the player owns Dizzy and rotates the T-piece 5 or more times before locking on a T-spin
- **THEN** 4 is added to that T-spin attack; the rotation counter resets after the lock

#### Scenario: Dizzy bonus does not fire for 4 or fewer rotations
- **WHEN** the player rotates the T-piece exactly 4 times before locking
- **THEN** no Dizzy bonus is applied

#### Scenario: Double Trouble doubles tspin_double, suppresses single and triple
- **WHEN** Double Trouble is owned and a T-spin single fires
- **THEN** the T-spin single attack is zeroed; T-spin doubles deal twice their technique-modified value

#### Scenario: Enchant adds 2 per T-spin–related technique
- **WHEN** Enchant is owned and 3 Techniques each have T-spin bonuses, and a T-spin fires
- **THEN** the T-spin attack is increased by 6

### Requirement: B2B keystones catalog
The following non-starter keystones SHALL be in the "B2B" category:

| ID | Display Name | Key Effect |
|---|---|---|
| `consistency` | Consistency | `b2b_bonus = 1` |
| `safety_net` | Safety Net | `safety_net = true` |
| `final_blow` | Final Blow | `final_blow = true` |
| `flexible` | Flexible | `flexible_b2b = true` |

#### Scenario: Consistency adds 1 to every B2B event
- **WHEN** Consistency is owned and a B2B bonus fires
- **THEN** 1 is added to the B2B attack value

#### Scenario: Safety Net prevents the first B2B break each round
- **WHEN** Safety Net is owned and B2B would break for the first time this round
- **THEN** B2B is preserved; the shield is consumed and will not prevent a second break

#### Scenario: Safety Net shield does not regenerate mid-round
- **WHEN** the shield has been consumed and B2B would break again
- **THEN** B2B breaks normally

#### Scenario: Final Blow deals streak × 2 on B2B break and disables B2B
- **WHEN** Final Blow is owned and B2B breaks with a streak of 4
- **THEN** 8 bonus damage is added to quota and the player can no longer build B2B this round

#### Scenario: Flexible allows non-T-spin spins to maintain B2B
- **WHEN** Flexible is owned and the player performs an I-spin or S-spin
- **THEN** the B2B chain is maintained as if a T-spin had been cleared

### Requirement: Combo keystones catalog
The following non-starter keystones SHALL be in the "Combo" category:

| ID | Display Name | Key Effect |
|---|---|---|
| `flurry` | Flurry | `combo_multiplier = 2.0`, `combo_multiplier_threshold = 5` |
| `holy_cheese` | Holy Cheese | `single_multiplier = 2.0`, `suppress_non_singles = true` |

#### Scenario: Flurry doubles combo attack only above threshold
- **WHEN** Flurry is owned and the current combo count is 6
- **THEN** the combo attack event is multiplied by 2; at combo count 5 or below there is no multiplier

#### Scenario: Holy Cheese doubles singles and zeroes all other clears
- **WHEN** Holy Cheese is owned and the player sends a triple
- **THEN** the triple attack is zeroed; singles deal twice their normal value

### Requirement: PC keystones catalog
The following non-starter keystones SHALL be in the "PC" category:

| ID | Display Name | Key Effect |
|---|---|---|
| `beginners_luck` | Beginner's Luck | `pc_first_multiplier = 3.0` |
| `veterans_luck` | Veteran's Luck | `pc_after_first_multiplier = 2.0` |

#### Scenario: Beginner's Luck triples the first PC each round
- **WHEN** Beginner's Luck is owned and the player performs their first PC of the round
- **THEN** the PC attack is multiplied by 3; subsequent PCs in the same round are unaffected

#### Scenario: Veteran's Luck doubles all PCs after the first
- **WHEN** Veteran's Luck is owned and the player performs their second PC of the round
- **THEN** the PC attack is multiplied by 2; the first PC of the round is unaffected

### Requirement: Economic keystones catalog
The following non-starter keystones SHALL be in the "Economic" category:

| ID | Display Name | Key Effect |
|---|---|---|
| `midas_touch` | Midas Touch | `overkill_coins = true` |
| `golden_watch` | Golden Watch | `time_coins = true` |
| `magical_coin` | Magical Coin | `end_round_coins = 2`, `requires_keystone_id = "slightly_magical_coin"` |

#### Scenario: Midas Touch converts surplus damage to coins
- **WHEN** Midas Touch is owned and the player finishes the round with 5 surplus attack above quota
- **THEN** 5 coins are added at round end

#### Scenario: Golden Watch grants coins based on time remaining
- **WHEN** Golden Watch is owned and the round ends with 12 seconds remaining
- **THEN** 2 coins are granted (floor(12 / 5) = 2)

#### Scenario: Magical Coin grants 2 coins at round end (requires Slightly Magical Coin)
- **WHEN** Magical Coin is owned (implying Slightly Magical Coin is also owned)
- **THEN** 2 coins are granted at round end from Magical Coin (plus 1 from Slightly Magical Coin = 3 total)

### Requirement: Utility keystones catalog
The following non-starter keystones SHALL be in the "Utility" category:

| ID | Display Name | Key Effect |
|---|---|---|
| `full_potential` | Full Potential | `instant_arr = true`, `instant_soft_drop = true` |
| `foresight` | Foresight | `preview_count_bonus = 2` |
| `risky_business` | Risky Business | `risky_business = true` (see mechanic requirement) |

#### Scenario: Full Potential sets ARR and soft drop to instant
- **WHEN** Full Potential is owned and a round starts
- **THEN** `RoundConfig.instant_arr` and `RoundConfig.instant_soft_drop` are both true, and TetrisBoard applies 0ms delays accordingly

#### Scenario: Foresight increases the queue by 2
- **WHEN** Foresight is owned and a round starts
- **THEN** `RoundConfig.preview_count` is 7 (default 5 + 2)

### Requirement: Risky Business — top-row damage bonus
When the player clears one or more lines that include a row in the top 5 visible rows of the board, `RunManager` SHALL double the attack generated from that clear event. This check applies to any clear-type attack; it does not apply to B2B or combo bonus events.

`TetrisBoard` SHALL emit a `lines_cleared(row_indices: Array[int])` signal immediately before the corresponding `attack_generated`, where row index 0 is the topmost visible row.

#### Scenario: Risky Business doubles attack for clears in top 5 rows
- **WHEN** Risky Business is owned and a line clear includes a row at index 3 (within the top 5)
- **THEN** the clear attack is multiplied by 2

#### Scenario: Risky Business does not apply to low-board clears
- **WHEN** Risky Business is owned and all cleared rows are below index 4
- **THEN** no multiplier is applied

### Requirement: Dizzy — T-piece rotation tracking
`TetrisBoard` SHALL emit a `piece_rotated(piece_type: String)` signal each time the active piece is rotated. `RunManager` SHALL track the count of rotations for the active T-piece (resetting on each `lock_processed` event). When a T-spin attack fires and the rotation count exceeded 4, `RunManager` SHALL add 4 to the attack and reset the counter.

#### Scenario: Counter resets after Dizzy bonus fires
- **WHEN** Dizzy bonus fires on a T-spin (rotation count > 4)
- **THEN** the rotation counter is 0 after the lock

#### Scenario: Counter resets on non-T-spin piece lock
- **WHEN** the player locks a piece that is not a T-piece
- **THEN** the rotation counter is 0

### Requirement: Safety Net — B2B shield via RoundConfig
`RoundConfig` SHALL carry a `b2b_shield_count: int` field (default 0). When Safety Net is owned, `apply_to_config` sets `b2b_shield_count = 1`. `TetrisBoard` SHALL consume one shield (decrement by 1) instead of breaking B2B when `b2b_shield_count > 0`.

#### Scenario: Shield set to 1 at round start with Safety Net
- **WHEN** Safety Net is owned and `apply_to_config` runs
- **THEN** `RoundConfig.b2b_shield_count` is 1

### Requirement: Final Blow — B2B break signal
`TetrisBoard` SHALL emit `b2b_broken(streak: int)` immediately when B2B breaks, carrying the B2B count at that moment. `RunManager` SHALL listen for this signal: if Final Blow is owned, add `streak × 2` to `quota_accumulated` and set `current_config.b2b_disabled = true`.

#### Scenario: Final Blow fires on B2B break with streak of 3
- **WHEN** Final Blow is owned and B2B breaks with streak = 3
- **THEN** 6 is added to quota and B2B cannot be built for the rest of the round

### Requirement: Dual Wielding — consecutive quad state
`RunManager` SHALL maintain `_last_attack_was_quad: bool`, reset to false at round start. After processing each attack event, if the event type was `"tetris"`, set `_last_attack_was_quad = true`; otherwise set it to `false`. Dual Wielding's `consecutive_quad_multiplier` applies only when `_last_attack_was_quad` is already `true` at the start of processing a new `"tetris"` event.

#### Scenario: State resets after non-quad clear
- **WHEN** a quad fires then a single fires then a quad fires
- **THEN** the last quad does not receive the consecutive multiplier

### Requirement: PC round tracking
`RunManager` SHALL maintain `_pc_count_this_round: int`, reset to 0 at round start. Each time a `perfect_clear` event fires, the count is incremented after the keystone multiplier is applied. `pc_first_multiplier` applies when the count is 0 (first PC). `pc_after_first_multiplier` applies when the count is 1 or more.

#### Scenario: First PC gets pc_first_multiplier, second gets pc_after_first_multiplier
- **WHEN** Beginner's Luck (pc_first_multiplier = 3) and Veteran's Luck (pc_after_first_multiplier = 2) are both owned, and the player achieves two PCs in one round
- **THEN** the first PC is multiplied by 3 and the second is multiplied by 2
