## ADDED Requirements

### Requirement: Settings screen lists all rebindable actions
The Settings screen SHALL display a keybinding row for each of the following actions: Move Left, Move Right, Soft Drop, Hard Drop, Rotate CW, Rotate CCW, Rotate 180, Hold. Each row SHALL show the action's display name, its current bound key, and a "Rebind" button.

#### Scenario: Keybinding rows appear in settings
- **WHEN** the player opens the Settings screen
- **THEN** all 8 action rows are visible, each showing the action name, current key name, and a Rebind button

#### Scenario: Current key reflects active binding
- **WHEN** the Settings screen opens after a custom binding was saved
- **THEN** the key label for that action shows the custom key, not the default

### Requirement: Clicking Rebind enters listen mode for that action
When the player clicks a Rebind button, the Settings screen SHALL enter listen mode for that action. In listen mode, all Rebind buttons are disabled, a "Press any key…" prompt is shown, and the next key press (other than Escape) becomes the new binding.

#### Scenario: Listen mode activates on Rebind click
- **WHEN** the player clicks the Rebind button for an action
- **THEN** all Rebind buttons are disabled and a "Press any key…" prompt is displayed

#### Scenario: Key press sets new binding
- **WHEN** listen mode is active and the player presses a key (not Escape)
- **THEN** that key is set as the new binding for the action, applied to InputMap immediately, and the UI updates

#### Scenario: Escape cancels rebind
- **WHEN** listen mode is active and the player presses Escape
- **THEN** the binding is unchanged and listen mode exits

### Requirement: Custom bindings are saved to config and restored on startup
Custom bindings SHALL be saved to `user://settings.cfg` under a `[bindings]` section as `action_name = physical_keycode_int`. On each game launch, `Settings.apply_saved_bindings()` SHALL be called to reapply any saved custom bindings to the live `InputMap`.

#### Scenario: Binding persists across sessions
- **WHEN** the player sets a custom binding, closes the game, and reopens it
- **THEN** the custom binding is active from the first round

#### Scenario: Default action uses project binding when no custom binding is saved
- **WHEN** no custom binding is saved for an action
- **THEN** the project.godot default binding for that action is used

### Requirement: Reset to Defaults restores all shipped bindings
A "Reset to Defaults" button SHALL restore all actions to their `project.godot` bindings, clear the `[bindings]` section from `user://settings.cfg`, and update all key labels in the UI.

#### Scenario: Reset restores project defaults
- **WHEN** the player clicks "Reset to Defaults"
- **THEN** all 8 actions revert to their project.godot bindings and the labels update immediately
