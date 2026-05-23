## Why

The keystone selection and run failure screens are functional but sparse — buttons lack visual hierarchy, the failure screen's "Try Again" path is broken (it loads the RunManager scene without calling `start_run()`, leaving the player on a blank screen), and neither screen communicates clearly enough for the moment they represent.

## What Changes

- **Keystone selection**: Replace the single-text buttons with card-style panels that separate the augment name (prominent) from its description (secondary), making choices easier to read at a glance
- **Run failure message**: Make the failure message more specific — show the ante, round name, and a brief cause
- **Run failure "Try Again" bug fix**: `_on_restart()` currently calls `change_scene_to_file` which loads RunManager but never calls `start_run()`, resulting in a broken blank game; fix it to properly start a fresh run
- **Run failure "Try Again" renamed to "New Run"**: Clarify that restarting begins a fresh run, not a retry of the same run

## Capabilities

### New Capabilities
- None

### Modified Capabilities
- `augments`: Keystone selection screen layout requirements — cards with separated name/description instead of raw button text
- `run-structure`: Run failure screen requirements — correct restart behaviour and clearer presentation

## Impact

- `game/scenes/keystone_selection/keystone_selection.gd` — populate cards instead of buttons
- `game/scenes/keystone_selection/keystone_selection.tscn` — scene layout for card panels
- `game/scenes/screens/run_failure.gd` — fix `_on_restart()` and improve message
- `game/scenes/screens/run_failure.tscn` — minor layout/label tweaks
