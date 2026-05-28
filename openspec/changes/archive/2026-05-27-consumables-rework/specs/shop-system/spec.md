## MODIFIED Requirements

### Requirement: Shop inventory is generated fresh each visit
Each shop visit SHALL generate a new inventory drawn randomly from the available pools. The inventory SHALL contain:
- 3 Technique slots
- 2 Consumable slots
- 1 Voucher slot (with a chance of being empty for early antes)

#### Scenario: Shop generates inventory on open
- **WHEN** the shop opens
- **THEN** each slot is filled by randomly drawing from the appropriate pool (Techniques, Consumables, Vouchers)

#### Scenario: Purchased items are removed from the shop
- **WHEN** the player buys an item
- **THEN** that slot becomes empty for the remainder of this shop visit
