## Why

Players have no way to see their owned keystones, techniques, or backpack consumables while browsing the shop, making it hard to evaluate purchases or decide which consumables to sell. Adding a "Your Collection" panel to the shop screen gives players the context they need to make informed decisions — and the ability to sell unwanted consumables directly from the shop for a partial refund.

## What Changes

- Add a **"Your Collection" section** at the bottom of the shop panel, below the existing for-sale slots
- Display owned **keystones** as read-only icon labels (initial letter + tooltip) for synergy reference
- Display owned **techniques** as interactive sell buttons (initial letter + sell price + tooltip) — clicking sells the technique for 60% of its cost
- Display the **backpack** (3 slots) as interactive sell buttons — clicking a slot sells that consumable for 60% of its cost (one-click, no confirmation)
- Selling a technique or consumable updates the relevant collection display and the player's coin balance immediately; for-sale slots in the shop are unaffected
- Owned **keystones** are read-only (not sellable) — shown as icon labels for synergy reference only
- Empty backpack slots appear as disabled "—" buttons

## Capabilities

### New Capabilities
- none

### Modified Capabilities
- `shop-system`: Shop now displays player's owned collection (keystones, techniques, backpack) and supports selling techniques and consumables for 60% of cost

## Impact

- `game/scenes/shop/shop.gd`: Add collection section build logic and sell handler
- `game/scenes/shop/shop.tscn`: Add collection section nodes (labels, icon containers, backpack slot buttons)
- `game/autoloads/run_state.gd`: Add `remove_technique(technique)` method (parallel to existing `remove_consumable`)
- No changes to RunManager or HUD
