## MODIFIED Requirements

### Requirement: Items have a coin cost
Every item in the shop SHALL display its name, description, and coin cost as separate, clearly labelled UI elements within its slot. The buy action SHALL be triggered by a dedicated "Buy" button that is distinct from the item information display. The buy button SHALL be disabled when the player cannot afford the item.

#### Scenario: Sufficient funds
- **WHEN** the player selects an item and their balance ≥ item cost
- **THEN** the item is purchased, the cost is deducted from balance, and the item is added to the player's collection

#### Scenario: Insufficient funds
- **WHEN** the player selects an item and their balance < item cost
- **THEN** the purchase is rejected and balance is unchanged

#### Scenario: Item card shows name, description, and cost separately
- **WHEN** the shop is open and a slot contains an item
- **THEN** the slot displays the item name, description, and cost as distinct labelled elements — not as a single concatenated string

### Requirement: Shop slots provide visual affordability feedback
Item slots SHALL visually distinguish between items the player can and cannot currently afford. Slots for unaffordable items SHALL appear visually dimmed. Slots the player can afford SHALL appear at full brightness.

#### Scenario: Unaffordable item is dimmed
- **WHEN** the player's coin balance is less than an item's cost
- **THEN** that item's slot is rendered at reduced brightness

#### Scenario: Affordable item is at full brightness
- **WHEN** the player's coin balance meets or exceeds an item's cost
- **THEN** that item's slot is rendered at full brightness

#### Scenario: Affordability updates after purchase
- **WHEN** the player buys an item and their balance changes
- **THEN** all remaining item slots update their brightness to reflect the new balance

### Requirement: Techniques already owned cannot be purchased again
If the player already owns a Technique, it SHALL still appear in the shop with its name and description visible but SHALL show a clear "OWNED" indicator in place of the buy button, and the buy action SHALL be unavailable.

#### Scenario: Duplicate Technique display
- **WHEN** a Technique the player already owns appears in the shop
- **THEN** it is shown with its name, description, and an "OWNED" label; no buy button is present

## ADDED Requirements

### Requirement: The game board and HUD are hidden while the shop is open
The game board, hold display, queue display, and HUD SHALL be hidden when the shop opens and restored to visible when the shop closes. No game state is affected — this is a visibility-only change.

#### Scenario: Board hidden on shop open
- **WHEN** the shop screen opens after a round
- **THEN** the tetris board and HUD are no longer visible behind the shop

#### Scenario: Board restored on shop close
- **WHEN** the player exits the shop
- **THEN** the board container and HUD become visible again before the next round initialises

### Requirement: Shop rows are labelled with section headers
The shop SHALL display a section header label above the Technique row ("Techniques") and above the bottom row containing Consumables and Vouchers ("Items"), so the player can orient themselves at a glance.

#### Scenario: Section headers visible
- **WHEN** the shop opens
- **THEN** a "Techniques" label appears above the technique slots and an "Items" label appears above the consumable and voucher slots
