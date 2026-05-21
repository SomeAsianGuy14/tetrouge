## Why

The shop has two visibility problems. First, `_show_shop()` never hides the game board or HUD, so the tetris board and all its UI remain visible behind the shop — cluttering the screen and making the shop hard to focus on. Second, every shop item is rendered as a single `Button` with its name, description, cost, and owned status all concatenated into the text property, producing a wall of text with no visual hierarchy, no affordability feedback, and no section structure.

## What Changes

- Hide `board_container` and `hud` when the shop opens; restore them when the shop closes and the next round begins.
- Replace the single-button item format with a structured card layout: item name (prominent), description (smaller, wrapping), and cost displayed as separate UI elements within each slot.
- Add a dedicated "Buy" button below each item's info so the buy action is clearly separate from the item display.
- Colour-code slots based on affordability: items the player cannot afford are visually dimmed; items they can afford are clearly distinguished.
- Add section header labels above the Technique row and the bottom (Consumable / Voucher) row so the player can orient themselves at a glance.
- Keep the "OWNED" state visually clear — show it as a distinct label rather than appended text in a button.

## Capabilities

### New Capabilities

*(none)*

### Modified Capabilities

- `shop-system`: Item slot visual presentation changes from a single concatenated button to a structured card with separate name, description, cost, and buy-button elements, plus affordability visual feedback and section headers.

## Impact

- `game/scenes/game/run_manager.gd` — hide `board_container` and `hud` in `_show_shop()`; restore in `_on_shop_closed()`
- `game/scenes/shop/shop.gd` — replace `_populate_slot` with a card-building helper; add section header logic; update `_refresh_button_states` to cover new button references
- `game/scenes/shop/shop.tscn` — add section `Label` nodes for "Techniques" and "Items" headers
- No new scenes or external dependencies
