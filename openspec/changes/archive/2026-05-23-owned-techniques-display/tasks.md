## 1. Scene — Add Technique Nodes to Side Panel

- [x] 1.1 In `run_manager.tscn`, add a `Label` node named `KeystonesHeader` (text: "Keystones", font size 11) as the first child of `HUD/SidePanel`, before `KeystoneIcons`
- [x] 1.2 In `run_manager.tscn`, add a `Label` node named `TechniquesHeader` (text: "Techniques", font size 11) as a child of `HUD/SidePanel`, after `KeystoneIcons`
- [x] 1.3 In `run_manager.tscn`, add an `HBoxContainer` node named `TechniqueIcons` as a child of `HUD/SidePanel`, after `TechniquesHeader`

## 2. HUD Script — Wire and Refresh

- [x] 2.1 Add `@onready var technique_icons: HBoxContainer = $SidePanel/TechniqueIcons` to `hud.gd`
- [x] 2.2 Add `_refresh_technique_icons()` method to `hud.gd` — mirrors `_refresh_keystone_icons()`: clear children, then for each technique in `RunState.techniques` create a `Label` with `text = technique.display_name[0]` and `tooltip_text = "%s\n%s" % [technique.display_name, technique.description]`
- [x] 2.3 Call `_refresh_technique_icons()` at the end of `hud.setup()`

## 3. Verification

- [x] 3.1 Start a run with no techniques — confirm the Techniques icon row is empty and the header is visible
- [x] 3.2 Buy a technique in the shop and start the next round — confirm the technique's initial appears in the side panel
- [x] 3.3 Hover over a technique icon — confirm the tooltip shows the full name and description
- [x] 3.4 Buy multiple techniques across rounds — confirm all appear as separate icons
