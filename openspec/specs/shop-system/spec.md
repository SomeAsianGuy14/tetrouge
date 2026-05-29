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
- 2 Consumable slots
- 1 Voucher slot (with a chance of being empty for early antes)

#### Scenario: Shop generates inventory on open
- **WHEN** the shop opens
- **THEN** each slot is filled by randomly drawing from the appropriate pool (Techniques, Consumables, Vouchers)

#### Scenario: Purchased items show a PURCHASED state
- **WHEN** the player buys an item
- **THEN** the slot retains the item's name, description, and cost labels but the buy button is replaced by a "PURCHASED" label; the slot is no longer interactive

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
The 3 backpack slots in the "Your Collection" section SHALL each render as a Button. An occupied slot SHALL display the item's `display_name` and a sell price of `floor(item.cost * 0.6)` coins. Clicking an occupied slot SHALL sell the item: add `floor(item.cost * 0.6)` coins via `Economy.add_coins`, remove the consumable from `RunState`, and refresh the backpack display. The for-sale slots in the shop SHALL NOT refresh after a sell.

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

### Requirement: Shop inventory is deterministic per seed
All random draws used to populate shop inventory (technique slots, consumable slots, voucher slots) SHALL use the run-seeded PRNG. Reloading the game before visiting the shop SHALL produce the same inventory.

#### Scenario: Same shop inventory after reload
- **WHEN** a round is completed and the save is present, the game is closed and reopened, and the player visits the shop
- **THEN** the shop displays the same items in the same slots as would have appeared without the reload
