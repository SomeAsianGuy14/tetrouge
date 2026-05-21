## 1. HUD Scene — Add Label Nodes

- [x] 1.1 Open `game/scenes/game/hud.tscn` and add a `Label` node named `B2BLabel` inside `InfoPanel`
- [x] 1.2 Set `B2BLabel` text to "B2B" and set `visible = false` in the scene
- [x] 1.3 Add a `Label` node named `ComboLabel` inside `InfoPanel`
- [x] 1.4 Set `ComboLabel` text to "Combo x1" (placeholder) and set `visible = false` in the scene

## 2. HUD Script — Wire Nodes and Add Update Method

- [x] 2.1 Add `@onready var b2b_label: Label = $InfoPanel/B2BLabel` to `hud.gd`
- [x] 2.2 Add `@onready var combo_label: Label = $InfoPanel/ComboLabel` to `hud.gd`
- [x] 2.3 Add `update_b2b_combo(is_b2b: bool, combo: int)` method to `hud.gd` that sets `b2b_label.visible = is_b2b`, `combo_label.visible = combo >= 0`, and `combo_label.text = "Combo x%d" % (combo + 1)`
- [x] 2.4 Call `update_b2b_combo(false, -1)` at the end of `hud.setup()` to initialise both indicators hidden

## 3. RunManager — Connect piece_locked and Call HUD

- [x] 3.1 In `run_manager.gd` `start_round()`, connect `current_board.piece_locked` to a new handler `_on_piece_locked`
- [x] 3.2 Implement `_on_piece_locked()` in `run_manager.gd` to call `hud.update_b2b_combo(current_board.is_b2b, current_board.combo)`

## 4. Verification

- [ ] 4.1 Start a round and confirm neither indicator is visible before any piece locks
- [ ] 4.2 Perform two consecutive Tetrises and confirm the B2B label appears after the second
- [ ] 4.3 Perform a non-qualifying clear and confirm the B2B label disappears
- [ ] 4.4 Clear lines on two consecutive pieces and confirm the combo counter shows "Combo x2"
- [ ] 4.5 Lock a piece without clearing and confirm the combo counter hides
