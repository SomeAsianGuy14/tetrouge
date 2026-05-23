## Context

The HUD `SidePanel` (a `VBoxContainer`) currently contains one child: `KeystoneIcons` (an `HBoxContainer`). `hud.gd` builds the keystone display in `_refresh_keystone_icons()`, which is called from `setup()`. Each keystone is rendered as a `Label` whose text is the first character of `keystone.display_name` and whose `tooltip_text` is the full name.

Techniques live in `RunState.techniques` (an `Array` of `Technique` resources). Each `Technique` has `display_name` and `description` properties. There is no existing refresh hook for techniques — `setup()` is called at the start of every round, which is the correct time to rebuild the technique list (techniques can only be acquired between rounds, in the shop).

## Goals / Non-Goals

**Goals:**
- Show all owned Techniques as compact icon labels in the side panel below Keystones.
- Tooltip on each icon shows the full technique name and description.
- Display refreshes at round start via `setup()`.

**Non-Goals:**
- Real-time updates mid-round (techniques cannot be gained during a round).
- Showing technique stats or numeric bonuses in the HUD.
- A separate popup or detailed panel.

## Decisions

### 1. Mirror the keystone pattern exactly

The keystone icons use a `Label` with a single character and a tooltip. Technique icons use the same approach. This keeps the visual language consistent and requires minimal new code.

### 2. Add a header label for each section

A small `Label` ("Keystones" / "Techniques") is added above each icon row so the player can distinguish the two sections. The keystone header is added alongside the technique header in the same change for visual consistency.

### 3. `_refresh_technique_icons()` called from `setup()`

`setup(config)` is already called at the start of every round. Rebuilding technique icons there guarantees they're always current without needing a separate signal.

## Risks / Trade-offs

- [Many techniques could overflow the side panel] → With up to ~10 techniques possible and 1-char labels, this is unlikely to overflow given the available vertical space. No truncation logic needed.
- [SidePanel currently has no header for Keystones] → Adding headers for both sections in the same change improves clarity but is a minor visual addition — no layout changes required beyond adding Labels.
