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
Every item in the shop SHALL display a coin cost. The player can only purchase an item if their current coin balance meets or exceeds the cost.

#### Scenario: Sufficient funds
- **WHEN** the player selects an item and their balance ≥ item cost
- **THEN** the item is purchased, the cost is deducted from balance, and the item is added to the player's collection

#### Scenario: Insufficient funds
- **WHEN** the player selects an item and their balance < item cost
- **THEN** the purchase is rejected and balance is unchanged

### Requirement: Player can leave the shop without buying
The player SHALL be able to exit the shop at any time, proceeding to the next round with whatever they have purchased (including nothing).

#### Scenario: Exit without purchase
- **WHEN** the player exits the shop
- **THEN** the next round begins regardless of whether any items were bought

### Requirement: Techniques already owned cannot be purchased again
If the player already owns a Technique, it SHALL still appear in the shop but SHALL be visually marked as owned and cannot be repurchased.

#### Scenario: Duplicate Technique display
- **WHEN** a Technique the player already owns appears in the shop
- **THEN** it is shown with an "owned" indicator and the purchase action is disabled
