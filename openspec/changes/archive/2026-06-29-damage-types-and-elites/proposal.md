## Why

Every combat currently plays the same: clear lines, deal damage, absorb garbage. Enemy attacks are generic garbage rows with random holes. Feedback indicates the game needs mechanics that make each fight feel distinct. Damage types (burn, poison, true) give enemies unique attack signatures, elite enemies create notable encounters with board-modifying attacks, and cursed keystones let players opt into self-harm for power.

## What Changes

### Damage Types
Three new damage types that modify the player's board beyond standard garbage:
- **Burn**: Adds 1 garbage line to the attack buffer every 3 seconds. Shield blocks burn lines. Binary state (active or not, does not stack).
- **Poison**: Adds 1 garbage line directly onto the board every 5 seconds, bypassing the buffer. Binary state.
- **True Damage**: Instantly places a permanent unclearable row at the bottom of the board. Cannot be removed (future encounter may allow removal).

### Elite Enemies
A new enemy class with a distinct map tile. One guaranteed per floor. Elites have normal attacks plus a bonus board-modifying effect:
- **Corrupted Mage**: Randomly fills unfilled cells in patterns on the player's board.
- **Possessed Blade**: Deletes a random 3 contiguous row section on the board (both player cells and garbage).
- **Crimson Drake**: Unblocked damage applies burn for 4 seconds.
- **Venomous Archer**: Unblocked damage applies poison for 6 seconds.

"Unblocked" means at least 1 garbage line hits the board (shield didn't fully absorb the attack).

### Boss Reworks
- **The Tide** (new): Deals 1 true damage every 30 seconds.
- **The Serpent** (new): Applies permanent poison for the duration of the fight.
- **The Furnace** (modified): Applies permanent burn for the duration of the fight (replaces fixed 5s interval).

### Cursed Keystones
Three keystones that all grant ×2 all-damage multiplier with different self-harm:
- **Poisoned Blood** (replaces Burning Board): Permanent poison. ×2 all damage.
- **Blazing Heart** (new): Permanent burn. ×2 all damage.
- **Glass Cannon** (modified, moved to keystone): 10 lines of true damage at round start. ×2 all damage.

### Debuff Status Display
Burn and poison status indicators appear on the left side of the board showing:
- An icon for the active debuff type (burn/poison)
- A countdown timer or bar showing remaining duration
- Permanent debuffs show the icon without a countdown

### Discovery
Elite enemy attack patterns are discovered by fighting them, then revealed in the compendium.

## Capabilities

### New Capabilities
- `damage-types`: Burn, poison, and true damage systems with timers and board effects
- `elite-enemies`: New enemy class with board-modifying bonus attacks and guaranteed floor spawn
- `debuff-display`: Status icons with duration indicators next to the board

### Modified Capabilities
- `balance-pass`: Burning Board → Poisoned Blood, Glass Cannon → keystone with true damage

## Impact

- **New**: Burn/poison tick system in RunManager (timers, board insertion, buffer insertion)
- **New**: True damage system (permanent unclearable rows in TetrisBoard)
- **New**: Debuff status display UI (icons + countdown next to board)
- **New**: Elite enemy class with `TYPE_COMBAT_ELITE_SPECIAL` room type and guaranteed spawn
- **Modified**: `TetrisBoard` — support for unclearable cells, pattern-filling, row deletion
- **Modified**: `RunManager` — burn/poison state tracking, tick functions, elite attack handlers
- **Modified**: `BossModifier` — new properties for burn/poison/true damage
- **Modified**: `Enemy` — elite bonus attack type field
- **Modified**: `DungeonGenerator` — guarantee one elite per floor
- **Modified**: Burning Board keystone → Poisoned Blood, Glass Cannon technique → keystone
- **Modified**: Compendium — show elite attack descriptions for discovered elites
