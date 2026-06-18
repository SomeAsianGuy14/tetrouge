## Why

Players cannot see their keystones, techniques, backpack contents, or coin balance during encounter rooms (Wishing Well, Altar, Library, Museum, etc.) or the dungeon map. The HUD's InventoryPanel already displays all of this during combat, but `_hide_board_ui()` hides the entire HUD when transitioning to non-combat screens. This forces blind decision-making — e.g., sacrificing a technique at the Altar without seeing what else you own, or not knowing your backpack is full when the Wishing Well awards an item.

## What Changes

- **Keep the HUD's InventoryPanel and coin label visible** during shop, encounter, and map screens instead of hiding the entire HUD
- **Selectively hide only combat-specific HUD elements** (timer, B2B/combo counters, round info, modifier label) when leaving combat, rather than hiding the whole HUD
- **Refresh the inventory display** when entering encounter/map screens so it reflects current state (keystones, techniques, backpack, coins)

## Capabilities

### New Capabilities

None — the InventoryPanel and coin display already exist in the HUD. This change is about visibility management.

### Modified Capabilities

- `round-hud-display`: The HUD's visibility behavior changes — InventoryPanel and coin label persist across all screens, while combat-specific elements (timer, B2B, combo, round info) are hidden during non-combat screens

## Impact

- **RunManager** (`run_manager.gd`): `_hide_board_ui()` and `_show_board_ui()` need to selectively toggle combat elements vs. persistent elements
- **HUD** (`hud.gd`): May need a method to refresh inventory state on demand (for entering encounters/shops after purchases)
- **HUD scene** (`run_manager.tscn`): The InventoryPanel and CoinLabel may need z-order or layout adjustments to render correctly above encounter/shop overlays
