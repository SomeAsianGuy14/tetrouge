## Context

The shop currently hides the HUD entirely when open, so players have no visibility into their keystones, techniques, or backpack consumables. All three are already stored in `RunState` (keystones, techniques, consumables arrays) and the HUD already has display logic for each. The shop's GDScript has full access to `RunState` and `Economy` as autoloads.

The shop panel is a VBoxContainer inside a PanelContainer with ~60px side margins, leaving ample vertical room below the existing footer row for a new section.

## Goals / Non-Goals

**Goals:**
- Add a "Your Collection" section at the bottom of the shop panel
- Show owned keystones as read-only icon labels (initial + tooltip) — not sellable
- Show owned techniques as interactive sell buttons (initial + sell price, tooltip with name/description)
- Show backpack as 3 interactive sell buttons showing item name + sell price
- Sell price for both techniques and consumables: `floor(cost * 0.6)`
- Update coin display and relevant collection row immediately after a sell
- Empty backpack slots are disabled placeholders

**Non-Goals:**
- Selling keystones (permanent, non-sellable)
- Activation of consumables from the shop (activation is a HUD/pre-round concern)
- Refreshing for-sale slots after a sell

## Decisions

**Keystones: read-only labels; Techniques: sell buttons**
Keystones use the same single-character Label + tooltip pattern as the HUD — purely for reference. Techniques use Buttons with the initial character and sell price inline (e.g. "E • 3¢"), tooltip showing full name and description. This makes the interactive/non-interactive distinction visually obvious without changing the overall compact icon style.

**Sell price: `floor(item.cost * 0.6)`**
60% refund is a standard roguelite feel — meaningful partial refund without making selling a dominant strategy. Computed at display time and shown in the button text ("Sell • 3¢") so players always know what they're getting before clicking.

**One-click sell, no confirmation**
The sell price shown on the button serves as the "confirmation signal". Consistent with the genre convention (Balatro, Slay the Spire).

**Minimal RunState addition: `remove_technique`**
`RunState` already has `remove_consumable`. Adding `remove_technique(technique)` as a parallel method keeps the pattern consistent. No other RunManager or HUD changes needed.

**For-sale slots show PURCHASED state instead of going empty**
Currently `_on_purchase` calls `_populate_slot(slot, null)` which replaces the slot with "— Empty —". Instead, after a successful purchase the slot keeps its item info labels and the buy button is swapped for a "PURCHASED" label. This preserves the initial shop layout for the full visit — players can see what was available and what they bought. Implementation: a `_mark_slot_purchased(slot, item)` helper removes just the buy button and inserts the label; the slot is removed from `_buy_buttons` so `_refresh_button_states` skips it.

**Technique for-sale slots don't refresh after a technique sell**
When the shop opens, `_populate_technique_slots` excludes already-owned techniques from the draw pool. A technique in the collection panel was purchased in a prior visit, so it cannot be in the current shop's for-sale slots. Selling it mid-visit therefore has no visible effect on for-sale slots — no refresh needed.

**Collection rebuilt selectively on sell**
Keystones don't change during a shop visit (read-only), built once in `_ready`. Techniques can be sold, so `_build_technique_icons()` is called again after each technique sell. Backpack is refreshed via `_refresh_collection_backpack()` after each consumable sell.

## Risks / Trade-offs

- [Cosmetic overlap with shop slot count] If the player has many keystones/techniques, the icon rows could wrap awkwardly → Mitigation: use HBoxContainer with wrapping disabled; truncation via overflow is acceptable at this stage.
- [Sell button misclick] One-click with no undo → Mitigation: sell price is shown on button, price is intentionally visible as the signal.
