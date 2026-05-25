## 1. HUD — Boss Modifier Description Display

- [x] 1.1 In `hud.setup(config)`, update the `modifier_big_label` assignment to include the description: `modifier_big_label.text = config.boss_modifier.display_name + "\n" + config.boss_modifier.description`
- [x] 1.2 In `hud.setup(config)`, set `modifier_label.tooltip_text = config.boss_modifier.description` when a boss modifier is present
- [x] 1.3 Verify the `else` branch (non-boss rounds) clears or leaves `modifier_label.tooltip_text` so no stale tooltip persists
