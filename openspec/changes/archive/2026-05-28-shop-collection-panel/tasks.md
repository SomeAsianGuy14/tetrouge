## 1. RunState — Add remove_technique

- [x] 1.1 In `game/autoloads/run_state.gd`, add `func remove_technique(technique) -> void` that removes the matching entry from `techniques` by id (parallel to `remove_consumable`)

## 2. Scene — Add Collection Section Nodes

- [x] 2.1 In `game/scenes/shop/shop.tscn`, add a `CollectionHeader` Label node under `Panel/VBox` after `Footer`, with text "Your Collection"
- [x] 2.2 Add a `CollectionPanel` VBoxContainer under `Panel/VBox` after `CollectionHeader`
- [x] 2.3 Add a `KeystonesRow` HBoxContainer under `CollectionPanel` with a `KeystonesLabel` Label showing "Keystones:" and a `KeystoneIcons` HBoxContainer
- [x] 2.4 Add a `TechniquesRow` HBoxContainer under `CollectionPanel` with a `TechniquesLabel` Label showing "Techniques:" and a `TechniqueIcons` HBoxContainer
- [x] 2.5 Add a `BackpackRow` HBoxContainer under `CollectionPanel` with a `BackpackLabel` Label showing "Backpack:" and 3 Button children (`CollectionSlot0`, `CollectionSlot1`, `CollectionSlot2`) each with `custom_minimum_size = Vector2(80, 32)`

## 3. Script — Wire Up @onready Refs

- [x] 3.1 In `game/scenes/shop/shop.gd`, add `@onready` refs for `keystone_icons: HBoxContainer`, `technique_icons: HBoxContainer`, and the 3 collection slot buttons as `_collection_slots: Array`

## 4. Script — Build Collection Display

- [x] 4.1 In `game/scenes/shop/shop.gd`, add `func _build_collection() -> void` that calls `_build_keystone_icons()`, `_build_technique_icons()`, and `_refresh_collection_backpack()`
- [x] 4.2 Add `func _build_keystone_icons() -> void` that clears `keystone_icons` children and adds a non-interactive Label per `RunState.keystones` entry showing `keystone.display_name[0]` with tooltip `keystone.display_name + "\n" + keystone.description`; set `mouse_filter = Control.MOUSE_FILTER_STOP`
- [x] 4.3 Add `func _build_technique_icons() -> void` that clears `technique_icons` children and adds a Button per `RunState.techniques` entry; button text is `technique.display_name[0] + " • " + str(_sell_price(technique)) + "¢"`; tooltip is `technique.display_name + "\n" + technique.description`; connect `pressed` to `_on_sell_technique.bind(technique)`
- [x] 4.4 Add `func _refresh_collection_backpack() -> void` that iterates `_collection_slots`: for an occupied slot sets button text to `item.display_name + "\nSell • " + str(_sell_price(item)) + "¢"` and enables it; for an empty slot sets text to "—" and disables it
- [x] 4.5 Call `_build_collection()` at the end of `_ready()`

## 5. Script — Sell Logic

- [x] 5.1 In `game/scenes/shop/shop.gd`, add `func _sell_price(item) -> int` that returns `int(item.cost * 0.6)`
- [x] 5.2 Add `func _on_sell_technique(technique) -> void`: call `Economy.add_coins(_sell_price(technique))`; call `RunState.remove_technique(technique)`; call `_build_technique_icons()`
- [x] 5.3 Connect each `CollectionSlot` button's `pressed` signal in `_ready()` to `_on_sell_consumable.bind(i)`
- [x] 5.4 Add `func _on_sell_consumable(index: int) -> void`: guard if `index >= RunState.consumables.size()`; call `Economy.add_coins(_sell_price(RunState.consumables[index]))`; call `RunState.remove_consumable(RunState.consumables[index])`; call `_refresh_collection_backpack()`

## 6. Shop — Keep Purchased Slots Visible

- [x] 6.1 In `game/scenes/shop/shop.gd`, update `_on_purchase` to NOT call `_populate_slot(slot, null)` after a successful purchase; instead call a new `_mark_slot_purchased(slot, item)` function
- [x] 6.2 Add `func _mark_slot_purchased(slot: Control, item: Resource) -> void` that removes only the buy button from the slot (leaves name/desc/cost labels intact) and adds a Label with text "PURCHASED" in place of the buy button; remove the slot from `_buy_buttons` so `_refresh_button_states` skips it

## 7. Testing

- [x] 7.1 In `game/tests/unit/test_shop_collection.gd` (create file), add a test verifying `RunState.remove_technique` removes a technique by id and leaves others intact
- [x] 7.2 Add a test verifying `_sell_price` returns `int(cost * 0.6)` for cost 5 (expect 3) and cost 4 (expect 2)
- [x] 7.3 Add a test verifying that after `_on_sell_consumable(0)` with one consumable in the backpack, `RunState.consumables` is empty and `Economy.coins` increased by the sell price
- [x] 7.4 Add a test verifying that after `_on_sell_technique(technique)` with one technique owned, `RunState.techniques` is empty and `Economy.coins` increased by the sell price
