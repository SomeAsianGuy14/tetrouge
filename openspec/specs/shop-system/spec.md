## ADDED Requirements

### Requirement: Shop appears after every non-boss round
A shop SHALL be presented to the player after the Small Blind, Big Blind, and Elite Blind rounds of each ante, and also after the Boss Blind (following the Augment selection). The shop does not appear mid-round.

#### Scenario: Shop after non-boss round
- **WHEN** a Small, Big, or Elite Blind round ends in success
- **THEN** the shop screen is shown before the next round begins

#### Scenario: Shop after boss round
- **WHEN** a Boss Blind round ends in success and the Augment selection is complete
- **THEN** the shop screen is shown

### Requirement: Shop inventory is generated fresh each visit
Each shop visit SHALL generate a new inventory drawn randomly from the available pools. The inventory SHALL contain:
- 3 Technique slots
- 1 Consumable slot
- 1 Voucher slot (with a chance of being empty for early antes)

#### Scenario: Shop generates inventory on open
- **WHEN** the shop opens
- **THEN** each slot is filled by randomly drawing from the appropriate pool (Techniques, Consumables, Vouchers)

#### Scenario: Purchased items are removed from the shop
- **WHEN** the player buys an item
- **THEN** that slot becomes empty for the remainder of this shop visit

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

### Requirement: Player can leave the shop without buying
The player SHALL be able to exit the shop at any time, proceeding to the next round with whatever they have purchased (including nothing).

#### Scenario: Exit without purchase
- **WHEN** the player exits the shop
- **THEN** the next round begins regardless of whether any items were bought

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
