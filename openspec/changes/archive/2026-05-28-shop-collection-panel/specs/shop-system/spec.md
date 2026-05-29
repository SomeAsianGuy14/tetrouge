## ADDED Requirements

### Requirement: Shop displays player's owned collection
The shop SHALL include a "Your Collection" section below the for-sale items showing the player's currently owned keystones, techniques, and backpack consumables. This section SHALL be built when the shop opens and reflects the state of `RunState` at that moment.

#### Scenario: Collection section visible on shop open
- **WHEN** the shop opens
- **THEN** the "Your Collection" section is visible below the for-sale slots, showing owned keystones, techniques, and backpack contents

#### Scenario: No keystones or techniques owned
- **WHEN** the player has no keystones or techniques at shop open
- **THEN** the respective icon rows are empty (headers remain visible)

### Requirement: Owned keystones are shown as read-only icon labels
Keystones SHALL be displayed as a row of compact non-interactive Labels, one per owned keystone, showing the first character of the keystone's `display_name`. Each label SHALL have a tooltip containing the keystone's `display_name` and `description`. Keystones are not sellable.

#### Scenario: Keystone icon label displays initial and tooltip
- **WHEN** the player owns a keystone with display_name "Great Sword"
- **THEN** a label showing "G" appears in the Keystones row with tooltip "Great Sword\n<description>" and is non-interactive

### Requirement: Owned techniques are shown as sell buttons
Techniques SHALL be displayed as a row of compact Buttons, one per owned technique. Each button SHALL show the first character of the technique's `display_name` and its sell price (e.g. "E • 3¢"). Each button SHALL have a tooltip containing the technique's `display_name` and `description`. Clicking a technique button SHALL sell the technique: add `floor(technique.cost * 0.6)` coins via `Economy.add_coins`, remove it from `RunState` via `RunState.remove_technique`, and rebuild the technique icon row.

#### Scenario: Technique sell button displays initial and sell price
- **WHEN** the player owns a technique with display_name "Efficiency" and cost 4
- **THEN** a button showing "E • 2¢" appears in the Techniques row with tooltip "Efficiency\n<description>"

#### Scenario: Selling a technique adds coins and removes it from the row
- **WHEN** the player clicks a technique sell button
- **THEN** `floor(technique.cost * 0.6)` coins are added, the technique is removed from `RunState.techniques`, and the Techniques row is rebuilt without that entry

#### Scenario: For-sale technique slots unchanged after technique sell
- **WHEN** the player sells a technique from the collection panel
- **THEN** the for-sale technique slots in the shop are not modified

### Requirement: Backpack slots in the shop are sell buttons
The 3 backpack slots in the "Your Collection" section SHALL each render as a Button. An occupied slot SHALL display the item's `display_name` and a sell price of `floor(item.cost * 0.6)` coins. Clicking an occupied slot SHALL sell the item: deduct nothing (coins are added), add `floor(item.cost * 0.6)` coins via `Economy.add_coins`, remove the consumable from `RunState`, and refresh the backpack display. The for-sale slots in the shop SHALL NOT refresh after a sell.

#### Scenario: Sell button shows name and sell price
- **WHEN** the player has a Power Fragment (cost 5) in a backpack slot
- **THEN** the slot button displays the item name and "Sell • 3¢" (floor(5 * 0.6) = 3)

#### Scenario: Selling a consumable adds coins and empties the slot
- **WHEN** the player clicks a sell button for an occupied slot
- **THEN** `floor(item.cost * 0.6)` coins are added, the consumable is removed from the backpack, and the slot becomes an empty disabled placeholder

#### Scenario: Empty backpack slot is disabled
- **WHEN** a backpack slot contains no item
- **THEN** the slot button is disabled and displays "—"

#### Scenario: For-sale slots unchanged after sell
- **WHEN** the player sells a consumable from the backpack
- **THEN** the technique, consumable, and voucher slots available for purchase are not modified

### Requirement: Purchased for-sale slots show a PURCHASED state instead of going empty
When the player buys an item from a for-sale slot, the slot SHALL retain its name, description, and cost labels but replace the buy button with a "PURCHASED" label. The slot SHALL NOT be replaced with an empty placeholder. The initial shop layout SHALL remain visually intact for the full duration of the shop visit.

#### Scenario: Slot shows PURCHASED after buying a technique
- **WHEN** the player buys a technique from a for-sale slot
- **THEN** the slot still shows the technique name, description, and cost, but the buy button is replaced by a "PURCHASED" label

#### Scenario: Slot shows PURCHASED after buying a consumable
- **WHEN** the player buys a consumable from a for-sale slot
- **THEN** the slot still shows the consumable name, description, and cost, but the buy button is replaced by a "PURCHASED" label

#### Scenario: PURCHASED slot is not interactive
- **WHEN** a slot is in the PURCHASED state
- **THEN** no buy action can be triggered from it
