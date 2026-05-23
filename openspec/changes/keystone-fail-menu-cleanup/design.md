## Context

Two screens need cleanup:

**Keystone selection** — currently renders each choice as a single `Button` with `"%s\n%s" % [name, description]` as its text. This works but gives no visual hierarchy; the name and description are indistinguishable at a glance.

**Run failure** — has a critical bug: `_on_restart()` calls `get_tree().change_scene_to_file("res://scenes/game/run_manager.tscn")`, which instantiates RunManager but never calls `start_run()`. The player lands on a blank, unresponsive screen. Additionally, the button label "Try Again" implies retrying the same run, but the game is permadeath — it starts a fresh run.

## Goals / Non-Goals

**Goals:**
- Keystone cards show name and description as visually distinct elements
- Run failure screen properly starts a fresh run when the player clicks the restart button
- Run failure button copy reflects permadeath semantics ("New Run", not "Try Again")
- Run failure message is readable and correctly references ante/round

**Non-Goals:**
- Animations, transitions, or particle effects
- Sound effects
- Persisting keystone descriptions anywhere beyond the existing `.tres` files
- Changes to the round success or victory screens

## Decisions

**Keystone card layout — PanelContainer with two Labels**
Each keystone option becomes a `PanelContainer` containing a `VBoxContainer` with a name `Label` (larger/bold) and a description `Label` (normal, wrapping). A transparent `Button` is overlaid or the entire panel is made clickable via `gui_input`. Using a separate name label and description label is the simplest approach in pure GDScript without requiring a custom theme — no RichTextLabel needed.

Alternative considered: `RichTextLabel` with BBCode inside a single button. Rejected because BBCode in buttons is unreliable across Godot themes and adds complexity for no benefit here.

**Run failure restart — instantiate RunManager and call `start_run()` directly**
Mirror the pattern already used in `main_menu.gd:_on_new_run()`: delete the save, instantiate RunManager, add to root, queue_free self, then call `start_run()`. This keeps all run-init logic in one place.

Alternative considered: `change_scene_to_file` then signal `start_run` via group. Rejected — `change_scene_to_file` is fire-and-forget with no hook to call `start_run()` after the scene is ready without extra autoload machinery.

## Risks / Trade-offs

- [Keystone card click area] Overlaying a transparent button over a PanelContainer can have z-order quirks → use `mouse_filter = PASS` on the inner labels and make the Panel itself the clickable area via `connect("gui_input", ...)`, or build the card as a Button subclass. Simplest is to keep the Button as the root and use `add_theme_*_override` to increase font size for the name portion, accepting slightly less visual separation.
- [Restart path and RunState] The fix must call `RunState.reset()` and `Economy.reset()` via `start_run()` — these are already called inside `start_run()`, so mirroring the main menu pattern is safe.
