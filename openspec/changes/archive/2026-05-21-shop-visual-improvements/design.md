## Context

`_populate_slot(slot, item)` in `shop.gd` currently creates one `Button` node whose `.text` contains all item information. The slot container (`PanelContainer`) has a fixed `custom_minimum_size` set in the scene. `_refresh_button_states` iterates slots looking for `Button` nodes to update `disabled`.

## Goals / Non-Goals

**Goals:**
- Each slot renders a card with: name label, description label, cost label, and buy button as separate nodes.
- Slots visually indicate affordability (dimmed modulate when can't afford).
- Section header Labels appear above the Technique row and the bottom row in the scene.
- Empty slots show a centred "— Empty —" label (unchanged behaviour).
- Owned Techniques show the item info plus an "OWNED" label; buy button hidden or removed.

**Non-Goals:**
- New `.tscn` file for the item card — cards are built programmatically in `_populate_slot` to keep the existing dynamic slot system intact.
- Animated transitions or hover effects.
- Changing item costs, pool logic, or purchase behaviour.

## Decisions

### 1. Card built programmatically in `_populate_slot` — no new scene

The existing slot system creates `PanelContainer` nodes dynamically (for the 4th technique slot) and populates them at runtime. Keeping card construction in `_populate_slot` via a new `_build_item_card(slot, item)` helper requires no new scene and stays consistent with the dynamic slot approach.

The card layout (VBoxContainer → name Label, description Label, cost Label, buy Button) is built via code and added as children of the slot `PanelContainer`.

### 2. Affordability feedback via `modulate` on the slot

Setting `slot.modulate = Color(0.5, 0.5, 0.5)` when `can't_afford` dims the entire card including the name and description. The buy button is still `disabled` as before. On `_refresh_button_states`, modulate is also updated alongside `disabled`.

### 3. Section headers added as Label nodes in shop.tscn

Two `Label` nodes — "Techniques" and "Items" — are added directly in the scene above each row. This is a static scene change, no code required.

### 4. Owned state: item card shown, buy button replaced with "OWNED" label

When a Technique is owned, `_build_item_card` adds the name/description/cost labels normally but replaces the buy `Button` with a `Label` reading "OWNED". This is visually clearer than disabled-button text.

## Risks / Trade-offs

- [Existing `queue_free()` ghost-children bug] → The current `_populate_slot` uses `queue_free()` to clear children, which defers deletion to end-of-frame. The new child is added while the old one still exists, causing PanelContainer layout confusion and incorrect `_refresh_button_states` targeting. The new `_build_item_card` MUST use `node.free()` (after `slot.remove_child(node)`) or simply iterate `get_children()` calling `free()` directly for immediate removal.
- [_refresh_button_states iterates slots looking for Button nodes] → With the new card layout, the buy button is a child of a VBoxContainer inside the slot, not a direct child. `_refresh_button_states` must search recursively or use a stored reference. Mitigation: store buy button references in a dictionary keyed by slot node, cleared and rebuilt on each `_build_item_card` call.
- [Slot minimum size may need adjustment for taller cards] → The card is taller with separate elements. Minimum size in the scene may need to increase from 120→160px for technique slots and 100→140px for bottom slots.
