## 1. RunManager — Hide Board and HUD During Shop

- [x] 1.1 In `run_manager.gd` `_show_shop()`, add `board_container.visible = false` and `hud.visible = false` before instantiating the shop scene
- [x] 1.2 In `run_manager.gd` `_on_shop_closed()`, add `board_container.visible = true` and `hud.visible = true` before calling `start_round()`

## 2. Scene — Section Headers and Slot Sizes

- [x] 2.1 In `shop.tscn`, add a `Label` node named `TechniquesHeader` (text: "Techniques") as a child of `VBox`, positioned immediately before `TechniqueSlots`
- [x] 2.2 In `shop.tscn`, add a `Label` node named `ItemsHeader` (text: "Items") as a child of `VBox`, positioned immediately before `BottomRow`
- [x] 2.3 Increase `custom_minimum_size.y` of `Slot0`–`Slot3` from 120 to 160
- [x] 2.4 Increase `custom_minimum_size.y` of `ConsumableSlot` and `VoucherSlot` from 100 to 140

## 3. Shop Script — Card Builder

- [x] 3.1 Add a `_buy_buttons: Dictionary = {}` variable to `shop.gd` to store slot → buy_button references for use in `_refresh_button_states`
- [x] 3.2 Replace the body of `_populate_slot(slot, item)` with a call to a new `_build_item_card(slot, item)` helper — keep the existing function signature
- [x] 3.3 Implement `_build_item_card(slot: Control, item: Resource) -> void`:
  - Clear existing children immediately: `for child in slot.get_children(): child.free()` (NOT `queue_free()` — must remove synchronously to avoid ghost-child layout corruption)
  - If `item == null`: add a centred `Label` with text "— Empty —" and return
  - Create a `VBoxContainer` with spacing; add it to the slot
  - Add a `Label` for `item.display_name` (font size 14)
  - Add a `Label` for `item.description` with `autowrap_mode = 3` (word wrap)
  - Add a `Label` for `"%d coins" % item.cost`
  - If item is Technique and owned: add a `Label` with text "OWNED"; skip buy button; store `null` in `_buy_buttons[slot]`
  - Otherwise: add a `Button` with text "Buy"; call `button.set_meta("cost", item.cost)`; connect `pressed` → `_on_purchase.bind(item, slot)`; store it in `_buy_buttons[slot]`; set `disabled = not Economy.can_afford(item.cost)`
  - Apply affordability modulate: `slot.modulate = Color(0.5, 0.5, 0.5)` if can't afford, else `Color.WHITE`

## 4. Shop Script — Refresh Affordability

- [x] 4.1 Rewrite `_refresh_button_states()` to iterate `_buy_buttons`: for each `slot, btn` pair, if `btn != null`, set `btn.disabled = not Economy.can_afford(btn.get_meta("cost"))` and update `slot.modulate` accordingly; if `btn == null` (owned), leave modulate as-is

## 5. Verification

- [ ] 5.1 Open the shop and confirm the game board and HUD are hidden behind it
- [ ] 5.2 Exit the shop and confirm the board and HUD reappear correctly
- [ ] 5.3 Confirm each non-empty slot shows name, description, and cost as separate elements
- [ ] 5.4 Confirm items you can't afford are visibly dimmed and their Buy button is disabled
- [ ] 5.5 Buy an item — confirm remaining slots update their affordability state immediately
- [ ] 5.6 Confirm owned Techniques show "OWNED" with no Buy button
- [ ] 5.7 Confirm "Techniques" and "Items" section headers are visible above their respective rows
- [ ] 5.8 Confirm empty slots show "— Empty —" centred in the slot
