## Why

Tetris is one of the most mechanically refined puzzle games ever made, but its score-attack format leaves no persistent decision-making between sessions. Roguelike deck-builders like Balatro and Slay the Spire have demonstrated that layering build-crafting and run-to-run progression on top of a skill-based core creates deeply replayable experiences. This project combines modern Tetris mechanics with a Balatro-style shop and progression system to produce a game where each run crystallizes around a distinct playstyle.

## What Changes

- **New game**: A standalone Tetris roguelike built in Godot 4, starting from scratch.
- Modern guideline Tetris mechanics (SRS rotation, DAS/ARR, ghost piece, hold piece, 7-bag randomizer) form the playable core.
- The modern attack system (lines sent) replaces traditional scoring as the per-stage metric; each stage requires a quota of attack output within a time limit.
- A run consists of 5 stages, each with 4 rounds (Small, Big, Elite, Boss blinds).
- A Balatro-style shop appears between every non-boss round, selling Techniques (playstyle modifiers), Consumables, and Vouchers.
- Boss rounds feature a unique modifier that challenges the player's current build independently of the augment reward.
- Clearing a boss round presents a choice of 1 from 3 Augments — permanent rule-level changes to how Tetris operates.
- An interest mechanic rewards holding unspent coins between shops.
- Players start each run with a base gold amount and one randomly assigned Augment.

## Capabilities

### New Capabilities

- `tetris-core`: Standard guideline Tetris playfield — SRS rotation, 7-bag piece randomizer, hold piece, ghost piece, DAS/ARR controls, lock delay, hard/soft drop.
- `attack-system`: Line-clear attack calculation (singles, doubles, triples, Tetrises, T-spins, back-to-back chains, combos, perfect clears) used as the per-stage score metric.
- `run-structure`: 5-ante run loop with 4 rounds per ante (Small, Big, Elite, Boss). Quota and time limit scale per ante. Permadeath on failure.
- `shop-system`: Between-round shop selling Techniques, Consumables, and Vouchers using a coin economy with interest on unspent gold.
- `techniques`: Passive modifiers purchased from the shop that alter attack output calculations and reward rates, driving playstyle crystallization (e.g., T-spin focused, combo focused, perfect clear focused).
- `keystones`: Permanent mechanic-level rule changes awarded after each boss round (pick 1 of 3). Affect capabilities, information, and game rules rather than scoring.
- `boss-modifiers`: Per-boss-round challenge modifiers that constrain or alter gameplay rules for that round only, independent of the augment reward.
- `economy`: Coin earn/spend system — base payout, speed bonus, technique-gated income streams, interest on unspent coins.
- `consumables`: Single-use items purchased from the shop that provide immediate or next-round effects.
- `vouchers`: Permanent meta-upgrades purchased from the shop that modify shop behavior, economy, or run-wide rules.

### Modified Capabilities

_(none — this is a new project)_

## Impact

- **Engine**: Godot 4 (GDScript), new project from scratch.
- **Platform targets**: Web (HTML5 export, primary), Desktop (Windows/Linux/Mac, secondary).
- **Dependencies**: No external libraries beyond Godot 4 standard library.
- **No existing codebase is affected** — this is a greenfield game project.
