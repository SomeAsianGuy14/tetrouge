## MODIFIED Requirements

### Requirement: Shop inventory is generated fresh each visit
Each shop visit SHALL generate a new inventory drawn randomly from the available pools. The inventory SHALL contain:
- 5 Technique slots
- 3 Consumable slots

No voucher slot SHALL be present.

#### Scenario: Shop generates inventory on open
- **WHEN** the shop opens
- **THEN** 5 technique slots and 3 consumable slots are filled by randomly drawing from the appropriate pool (Techniques, Consumables)

#### Scenario: Purchased items show a PURCHASED state
- **WHEN** the player buys an item
- **THEN** the slot retains the item's name, description, and cost labels but the buy button is replaced by a "PURCHASED" label; the slot is no longer interactive

### Requirement: Shop rows are labelled with section headers
The shop SHALL display a section header label above the Technique row ("Techniques") and above the bottom row containing Consumables ("Items"), so the player can orient themselves at a glance.

#### Scenario: Section headers visible
- **WHEN** the shop opens
- **THEN** a "Techniques" label appears above the technique slots and an "Items" label appears above the consumable slots

### Requirement: Shop does not display interest
The shop SHALL NOT calculate or display interest on entry. No interest label or calculation SHALL be present.

#### Scenario: No interest on shop open
- **WHEN** the shop opens
- **THEN** no interest is calculated, no interest coins are added, and no interest label is displayed

## REMOVED Requirements

### Requirement: Voucher slot in shop
**Reason**: The voucher system is removed entirely. Voucher effects (expanded shop, consumable capacity) are baked into the new default slot counts.
**Migration**: Remove the voucher slot from the shop scene (shop.tscn) and shop.gd. Remove `_populate_voucher_slot()`, `_all_vouchers`, and voucher purchase handling from shop.gd.
