## Context

The HUD already renders boss modifier state via two labels set in `hud.setup(config)`:
- `modifier_label` (TopBar) — compact one-liner, always visible
- `modifier_big_label` (InfoPanel) — larger text in the side info panel

Both are currently set to `config.boss_modifier.display_name` only. `BossModifier` already has a `description: String` field populated in all seven `.tres` files. No data model or scene changes are required.

## Goals / Non-Goals

**Goals:**
- `modifier_big_label` shows the modifier name and its description on separate lines.
- `modifier_label` (TopBar) gains a tooltip with the description for players who want the detail without cluttering the compact bar.

**Non-Goals:**
- No animation, iconography, or styled pop-up for modifier reveal.
- No changes to non-boss rounds (labels remain hidden as today).
- No localisation support beyond what already exists.

## Decisions

**Inline text vs. separate label node for description**
Chosen: append `"\n" + modifier.description` directly to `modifier_big_label.text`. This requires zero scene changes and the InfoPanel label already has enough vertical space. A dedicated description label node would add scene complexity for no benefit at this scale.

**TopBar: tooltip vs. second line**
Chosen: tooltip (`modifier_label.tooltip_text = modifier.description`). The TopBar is compact; a second line would push other elements. A tooltip gives access to the description without layout impact.

## Risks / Trade-offs

- [Long descriptions wrap unpredictably in `modifier_big_label`] → All seven current descriptions are short one-liners; this is a non-issue for the current content set. If descriptions grow, autowrap is already enabled on the label.
- [Tooltip not discoverable on controller/touch] → Acceptable for now; modifier context can be added to a future "round preview" screen if needed.
