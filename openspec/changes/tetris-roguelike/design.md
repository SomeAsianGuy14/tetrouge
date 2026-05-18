## Context

This is a greenfield Godot 4 game project. There is no existing codebase. The design must establish the architecture for a real-time Tetris engine embedded inside a turn-structured roguelike progression system — two paradigms that operate on very different timescales and need clean separation.

The Tetris core must conform to the Tetris guideline (SRS, 7-bag, standard timing values) to feel correct to players familiar with modern Tetris. The roguelike layer sits above it, interpreting the results of each Tetris round and managing economy, shop, and progression state.

## Goals / Non-Goals

**Goals:**
- Implement guideline-compliant Tetris as a self-contained system that can be parameterised by the roguelike layer
- Run structure: 5 antes × 4 rounds, each round a real-time Tetris session with a quota and time limit
- Shop between non-boss rounds with coin economy and interest
- Augment selection (1 of 3) after each boss round
- Boss modifiers that alter round rules independently of augments
- Techniques and Augments that modify the attack calculation and game mechanics respectively
- Web export as primary platform target

**Non-Goals:**
- Multiplayer or online features
- Procedural map traversal (Balatro's linear ante structure is used, not StS's branching map)
- Unlockable starting decks or characters for the initial build
- Meta-progression across runs (achievements, unlocks) — post-launch scope
- Mobile touch controls
- Cursed/negative relics — post-launch scope

## Decisions

### D1: Scene Architecture — Tetris Core as an Isolated Scene

The Tetris playfield, piece logic, input handling, and attack calculation live in a single self-contained scene (`TetrisBoard`). The roguelike layer (`RunManager`) instantiates this scene per round, passes a configuration object (active Augments, active Techniques, boss modifier if applicable), and receives signals for round completion, quota met, and time expired.

**Why this over a monolith:** The roguelike state and the real-time Tetris state have completely different update frequencies. Keeping them separate prevents coupling and makes it easier to test the Tetris core independently.

**Alternative considered:** A single scene with flags — rejected because Tetris timing logic (DAS, ARR, lock delay, gravity) becomes hard to reason about when mixed with shop/economy state.

### D2: Attack System as the Score Contract

The `TetrisBoard` emits attack events (lines sent) rather than a raw score. The roguelike layer intercepts these events, applies active Technique multipliers, and accumulates the modified total toward the round quota.

Attack values follow guideline defaults:
```
Single:            0 lines sent
Double:            1
Triple:            2
Tetris:            4
T-spin Single:     2
T-spin Double:     4
T-spin Triple:     6
Back-to-Back:     +1 to any qualifying clear
Combo table:       0,0,1,1,2,2,3,3,4,4,4... (guideline)
Perfect Clear:     10
```

Techniques plug into this calculation as multipliers or flat bonuses per event type. The `TetrisBoard` does not know about Techniques — the `RunManager` transforms the raw attack signal.

**Why this over scoring in the board:** Keeps the Tetris core clean and reusable. Techniques are roguelike concerns, not Tetris concerns.

### D3: Two Relic Types with Different Application Points

- **Techniques** (bought in shop): Modify the attack output calculation. Applied by `RunManager` when it receives attack signals from `TetrisBoard`. Examples: T-spin doubles send +2, B2B never resets on singles.
- **Augments** (awarded after boss): Modify `TetrisBoard` configuration at round start. Examples: hold piece stores 2 pieces, preview shows 7 pieces, lock delay +100ms.

This separation means Techniques are stateless transformers and Augments are board parameters. Both are serialisable data structs, not code — making save/load and future unlocks straightforward.

### D4: Round Configuration Object

Each round, `RunManager` constructs a `RoundConfig` resource and passes it to `TetrisBoard`:
```
RoundConfig:
  quota: int                  # attack lines required
  time_limit: float           # seconds
  boss_modifier: Modifier     # null for non-boss rounds
  augments: Array[Augment]    # active augments for this run
```

`TetrisBoard` reads from `RoundConfig` at initialisation only. Mid-round state changes are not supported (boss modifiers apply from the start, not partway through).

### D5: Economy as a Separate Autoload

Shop economy (coin balance, interest calculation, payout) lives in a `Economy` autoload singleton. It persists across scenes and rounds. The shop UI reads from and writes to `Economy`. `RunManager` calls `Economy.pay_round(base, speed_bonus)` after each round.

Interest is calculated at the start of each shop visit: 1 coin per 5 held, capped at 5 coins per visit (adjustable via Vouchers).

### D6: Godot 4 / GDScript

Godot 4 with GDScript throughout. No C# or GDNative — GDScript is sufficient for a 2D game of this scope and keeps the toolchain simple.

Web export (HTML5) is the primary target. Desktop export is secondary and requires no extra work given Godot's export system.

### D7: Piece Randomiser — Standard 7-Bag

Standard 7-bag randomiser. No modification to the bag in the initial build. Future Augments that affect bag composition (e.g., "bag resets every 5 pieces") will be implemented by subclassing the randomiser and passing the subclass via `RoundConfig`.

## Risks / Trade-offs

**Precise Tetris timing is hard to get right** → Mitigation: Use published guideline values (DAS 167ms, ARR 33ms, lock delay 500ms, gravity by level). Test against reference implementations (Tetr.io, Jstris) subjectively before adding roguelike layer.

**Attack system as quota may frustrate players who can't T-spin** → Mitigation: Quota scaling is tuned so early antes are clearable with basic Tetrises. T-spin/combo Techniques amplify, not gate, progression.

**GDScript performance for real-time Tetris** → Minimal risk — Tetris is computationally trivial. No pathfinding, physics, or large grids.

**Web export audio latency** → Known Godot limitation. Mitigation: Keep audio non-critical to gameplay feel; focus on visual feedback for clears and attacks.

**Scope creep in relic design** → Mitigation: Ship with a small but complete set of Techniques (10–15), Augments (8–10), and Consumables (5–8). Expand post-launch.

## Open Questions

- **Quota scaling formula**: Needs playtesting to tune. Starting point: `base_quota = 20 + (ante - 1) * 15 + (round - 1) * 8`.
- **Coin payout values**: TBD through playtesting. Starting point: base 4 coins per round, speed bonus 0–3 coins scaled to time remaining.
- **Boss modifier pool size**: How many distinct boss modifiers for launch? Suggest 8–10 to avoid repetition across a 5-ante run.
- **Starting augment**: Randomly drawn from full pool, or from a curated "starter" subset? Starter subset recommended to avoid overwhelming starts.
- **Elite round (round 3) distinction**: Does it differ from Small/Big beyond quota? Could have a minor modifier (non-boss level). Decide during implementation.
