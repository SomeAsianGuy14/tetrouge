## ADDED Requirements

### Requirement: Consumables are single-use items purchased from the shop
Consumables SHALL be purchasable from the shop and usable exactly once. After use, the consumable is removed from the player's inventory.

#### Scenario: Consumable removed after use
- **WHEN** the player uses a consumable
- **THEN** it is removed from inventory and cannot be used again

#### Scenario: Unused consumables persist
- **WHEN** the player does not use a consumable in the shop or during a round
- **THEN** it remains in inventory for future use

### Requirement: Consumables can be used between rounds or at round start
Consumables that affect the board state (e.g., board manipulation) SHALL be usable at the start of a round before the first piece spawns, or between rounds from the inventory screen. Consumables that affect the economy SHALL be usable from the shop or inventory screen.

#### Scenario: Board consumable used at round start
- **WHEN** the player activates a board-affecting consumable before the first piece spawns
- **THEN** the effect is applied to the board before play begins

### Requirement: Player inventory can hold up to 2 consumables
The player's consumable inventory SHALL be capped at 2 slots. Purchasing a 3rd consumable is not permitted until a slot is freed.

#### Scenario: Inventory full
- **WHEN** the player has 2 consumables and attempts to buy a third
- **THEN** the purchase is rejected with a visual indicator showing inventory is full

### Requirement: Consumable pool for launch
The following consumables SHALL be available in the initial build:

| Name | Effect | When Usable |
|------|--------|-------------|
| **Clean Slate** | Remove all garbage and partially-filled rows from the board | Round start |
| **Piece Lock** | Guarantee the next piece drawn is a T-piece | Round start |
| **Time Shard** | Add 8 seconds to the round timer | During round |
| **Coin Purse** | Gain 6 coins immediately | Shop / between rounds |
| **Attack Surge** | Next 3 clears of any type send double attack | Round start |

#### Scenario: Clean Slate clears garbage
- **WHEN** Clean Slate is used at round start
- **THEN** all rows that are not fully empty are removed from the board before the first piece spawns

#### Scenario: Piece Lock guarantees T-piece
- **WHEN** Piece Lock is used at round start
- **THEN** the very next piece drawn from the bag is replaced with a T-piece regardless of bag state

#### Scenario: Time Shard extends timer mid-round
- **WHEN** Time Shard is used during an active round
- **THEN** 8 seconds are added to the current timer, not to exceed the original time limit plus 8
