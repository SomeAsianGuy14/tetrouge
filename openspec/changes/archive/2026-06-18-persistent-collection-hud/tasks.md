## 1. Add Coin Label to InventoryPanel

- [x] 1.1 Add a `CoinLabel` node to the `InventoryPanel` VBoxContainer in `run_manager.tscn` (above or below the backpack section)
- [x] 1.2 Wire up the new coin label in `hud.gd`: add an `@onready` reference and connect it to the `Economy.coins_changed` signal to keep it updated

## 2. Split HUD Visibility

- [x] 2.1 Add a `hide_combat_elements()` method to `hud.gd` that hides the TopBar (round info, timer, modifier — but not the persistent coin label), InfoPanel, and disables backpack slot buttons
- [x] 2.2 Add a `show_combat_elements()` method to `hud.gd` that restores visibility of TopBar and InfoPanel and re-enables backpack slots
- [x] 2.3 Add a `refresh_inventory()` method to `hud.gd` that calls `_refresh_keystone_icons()`, `_refresh_technique_icons()`, `_refresh_backpack_slots()`, and updates the InventoryPanel coin label

## 3. Update RunManager Transitions

- [x] 3.1 Update `_hide_board_ui()` in `run_manager.gd`: instead of `hud.visible = false`, call `hud.hide_combat_elements()` and `hud.refresh_inventory()`; keep `hud.visible = true`
- [x] 3.2 Update `_show_board_ui()` in `run_manager.gd`: instead of `hud.visible = true`, call `hud.show_combat_elements()`; ensure `hud.visible` remains true
- [x] 3.3 Hide the InventoryPanel during shop visits: in `_open_shop_room()` call `hud.hide_inventory()`, in `_on_shop_room_closed()` call `hud.show_inventory()`
- [x] 3.4 Ensure the InventoryPanel renders above encounter overlays by setting a z-index or adjusting node order in the scene tree

## 4. Layout Adjustment

- [x] 4.1 Verify the InventoryPanel (bottom-left, 200px wide) does not overlap with encounter room content (80px left margin) and adjust offsets if needed
- [x] 4.2 Verify the InventoryPanel does not overlap with the shop layout and adjust if needed
- [x] 4.3 Verify the InventoryPanel does not overlap with the dungeon map and adjust if needed
