## Context

The HUD (`hud.gd` / `run_manager.tscn`) already contains an `InventoryPanel` (keystones, techniques, backpack) and a `CoinLabel` in the top bar. These are fully functional with refresh methods and signal connections. However, `RunManager._hide_board_ui()` sets `hud.visible = false` when transitioning to any non-combat screen (shop, encounter, map), hiding everything.

The HUD has two logical groups:
- **Combat elements**: TopBar (round info, timer, modifier), InfoPanel (timer big, B2B, combo)
- **Persistent elements**: InventoryPanel (keystones, techniques, backpack), CoinLabel

## Goals / Non-Goals

**Goals:**
- Keep the InventoryPanel and coin display visible across all run screens (combat, shop, encounter, map)
- Refresh the inventory display when entering non-combat screens so it reflects any changes
- Hide only combat-specific HUD elements during non-combat screens

**Non-Goals:**
- Changing the shop's built-in "Your Collection" panel (it stays as-is with sell functionality)
- Making backpack slots interactive during non-combat screens (they're display-only outside combat)
- Adding new UI elements — this uses entirely existing HUD components
- Showing the HUD InventoryPanel during shop visits (the shop has its own collection panel — no duplicate info)

## Decisions

### 1. Split HUD visibility into combat vs. persistent groups

Instead of `hud.visible = false`, toggle visibility on sub-containers:
- `TopBar` (minus CoinLabel), `InfoPanel` → hidden during non-combat
- `InventoryPanel`, `CoinLabel` → always visible

The CoinLabel lives inside TopBar currently. Rather than restructuring the scene tree, we'll reparent CoinLabel to sit outside TopBar, or add a dedicated persistent coin label near the InventoryPanel.

**Alternative considered:** Move InventoryPanel out of the HUD entirely into its own scene. Rejected because the HUD already has all the refresh logic and signal connections wired up.

### 2. Add a dedicated coin display to the InventoryPanel

Rather than reparenting the TopBar's CoinLabel, add a coin label directly to the InventoryPanel. This keeps the TopBar intact for combat and gives the persistent panel its own self-contained coin display. The TopBar CoinLabel continues to work during combat as it does today.

### 3. Refresh inventory on screen transitions

Add a `refresh_inventory()` method on HUD that calls `_refresh_keystone_icons()`, `_refresh_technique_icons()`, and `_refresh_backpack_slots()`. Call it from `_hide_board_ui()` (which runs on every transition to shop/encounter/map) so the panel is always current.

### 4. Z-order: HUD renders above overlays

Encounter rooms and shop scenes are added as children of RunManager. The HUD is also a child. Since Godot renders children in tree order, the HUD needs to be moved to render after overlays, or the InventoryPanel needs to be on a higher z-index. The simplest approach is setting a higher z-index on the InventoryPanel.

## Risks / Trade-offs

- **Layout overlap**: The InventoryPanel is anchored to the bottom-left (offset 16px left, 180px from bottom). Encounter rooms use a full-screen panel with 80px horizontal margins and 60px vertical margins. The inventory panel at 200px wide should fit in the left margin area, but may need position adjustment to avoid overlap with encounter content. → Mitigation: Test visually and adjust offsets if needed.
