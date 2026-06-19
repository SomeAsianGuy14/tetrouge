## MODIFIED Requirements

### Requirement: Shop inventory is generated fresh each visit
Each shop visit SHALL generate a new inventory drawn randomly from the available pools. The inventory SHALL contain:
- 5 Technique slots (drawn using rarity-weighted random selection)
- 3 Consumable slots

No voucher slot SHALL be present. Each technique slot's displayed cost SHALL be the technique's rarity base cost plus a seeded random offset in [-4, +4].

#### Scenario: Shop generates inventory on open
- **WHEN** the shop opens
- **THEN** 5 technique slots are filled by weighted random draw (Common weight 5, Rare weight 3, Epic weight 1) and 3 consumable slots are filled randomly

#### Scenario: Technique cost shows rarity base ±4
- **WHEN** a technique with rarity base 52 appears in a shop slot
- **THEN** the displayed cost is 52 plus a seeded random offset between -4 and +4
