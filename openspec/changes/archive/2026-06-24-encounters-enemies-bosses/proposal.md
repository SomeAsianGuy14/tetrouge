## Why

The dungeon needs more room variety and enemy diversity to keep runs feeling fresh. New encounters add meaningful decision points (trade mastery for gold, reveal the map, risk a mimic fight), new enemies fill out the combat pool with themed names, and a final boss tier creates a climactic floor 4 endpoint.

## What Changes

### New Encounters
- **Tutor**: Choose to gain +1 level in a mastery of your choice
- **Sleeping Beast**: Choose to fight a combat one tier higher than normal. Winning grants a random technique and coins
- **Laboratory**: Contains 3 random consumables the player can take
- **Demonic Deal**: Available only if player has 3+ levels of a mastery. Trade 3 mastery levels for 150 coins
- **Mimic**: Appears as a treasure chest room. Claiming the treasure triggers combat with a Mimic enemy
- **Beggar**: Offer 50 gold for a random rare-or-lower technique, or leave
- **Map Room**: Examine the map to reveal all fogged rooms, or leave

### Encounter Modifications
- **Museum** → reworked into **Treasure Chest** (same function, new theme)
- **Pickpocket**: Now generates a corresponding combat room later in the floor path where the player can fight to reclaim stolen gold
- **Head Trauma**: If the player has a technique or keystone relating to speed, they avoid the falling rock and keep their technique

### New Enemies
- **Pickpocket** (encounter-specific): Spawns only after Pickpocket encounter, drops stolen gold on death
- **Robbers** (encounter-specific): Only appears during Robber encounter if player chooses to fight
- **Mimic** (encounter-specific): Only appears during Mimic encounter, drops 50 coins on death
- **Corrupted Mage**, **Venomous Archer**, **Possessed Blade**, **Insane Adventurer**, **Giant Frog**, **Unstable Construct**: New general combat pool enemies

### Enemy Renames
- Rock Crawler → Stone Crab
- The Warden → Dungeon Warden
- Void Knight → Fallen Knight
- Crimson Drake → Lesser Drake
- Rust Golem → Rusty Golem
- Slimeling → Slime
- Iron Shambler → Armored Skeleton

### New Bosses (normal pool)
- **The Ram**: Attacks ignore shields
- **The Jester**: Attacks that are the same as the previous clear deal no damage
- **The Berserker**: Attack interval decreases at lower health
- **The Forgotten**: Hidden HP bar, attack interval bar, and windup animation
- **The Furnace**: Sends 1 garbage attack every 5 seconds

### New Final Bosses (floor 4 only)
- **The Mutant**: Combines two random normal boss effects
- **The Titan**: Double HP and attack of a normal boss
- **The Klepto**: All mastery reduced by 5 levels
- **The Origin**: Grows stronger based on total enemies killed during the run

## Capabilities

### New Capabilities
- `new-encounters`: Seven new encounter room types with player choice mechanics
- `encounter-reworks`: Modifications to existing encounters (Pickpocket revenge, Head Trauma dodge, Museum → Treasure Chest)
- `new-enemies`: New combat pool enemies and encounter-specific enemies
- `new-bosses`: Five new normal bosses with unique boss modifiers
- `final-boss-pool`: Separate boss pool for floor 4 with escalated mechanics (composite effects, stat scaling, mastery drain)

### Modified Capabilities

_(none)_

## Impact

- **New**: 7 encounter room scenes/scripts
- **New**: ~11 enemy `.tres` resource files
- **New**: ~9 boss `.tres` resource files with new boss modifier scripts
- **Modified**: Dungeon floor generator — Mimic room disguise, Pickpocket revenge room insertion, final boss pool selection for floor 4
- **Modified**: Encounter room system for new room types
- **Modified**: Enemy pool loading for encounter-specific enemies
- **Modified**: Boss modifier system for new abilities (shield bypass, same-clear suppression, scaling intervals, hidden UI, composite modifiers)
- **Modified**: RunState for kill counter tracking (The Origin)
- **New concept**: Floor 4 draws from a separate final boss pool instead of the normal boss pool
