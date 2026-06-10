## ADDED Requirements

### Requirement: Technique icon pulses when its pending state is active
When a technique's corresponding `TechniqueRoundState` pending flag becomes true, the HUD icon for that technique SHALL pulse with a highlight color until the flag clears.

#### Scenario: Escalation pending — icon pulses
- **WHEN** `TechniqueRoundState.escalation_pending` becomes true and the player has an Escalation technique
- **THEN** the Escalation technique icon in the HUD pulses with a highlight modulate

#### Scenario: Pending flag clears — icon stops pulsing
- **WHEN** a technique's pending flag transitions from true to false (e.g. the clear that consumed it fires)
- **THEN** the corresponding HUD icon stops pulsing and returns to its normal modulate

#### Scenario: Technique without a pending flag is unaffected
- **WHEN** a technique has no corresponding pending flag in TechniqueRoundState (e.g. a flat-bonus technique)
- **THEN** its icon does not pulse at any time

### Requirement: HUD exposes an update method for technique pending states
`HUD` SHALL expose an `update_technique_states(states: Dictionary)` method that accepts a mapping of `technique_id -> bool` (true = pending/armed). RunManager SHALL call this after each `_update_round_state_after_eval()`.

#### Scenario: RunManager calls update after each lock
- **WHEN** a piece locks and round state is updated
- **THEN** RunManager calls `hud.update_technique_states()` with the current pending flags

#### Scenario: States dict maps known technique IDs to pending booleans
- **WHEN** `update_technique_states` is called with `{"escalation": true, "follow_up": false}`
- **THEN** the Escalation icon pulses and the Follow Up icon does not

### Requirement: Keystone icon flashes briefly when its bonus fires
When a keystone contributes a non-zero flat or multiplier bonus to an attack event, the HUD icon for that keystone SHALL play a one-shot white flash animation.

#### Scenario: Keystone quad_bonus fires — icon flashes
- **WHEN** a quad is cleared and a keystone with `quad_bonus > 0` applies its bonus
- **THEN** the keystone's HUD icon briefly flashes white and returns to normal

#### Scenario: Keystone with no bonus for the event does not flash
- **WHEN** a single-line clear occurs and a keystone only has `quad_bonus > 0`
- **THEN** that keystone's HUD icon does not flash

### Requirement: HUD exposes a flash method for keystone activations
`HUD` SHALL expose a `flash_keystone(keystone_id: String)` method. RunManager SHALL call this for each keystone that contributed a non-zero bonus during `_apply_keystone_flat_bonuses` or `_apply_keystone_multipliers`.

#### Scenario: flash_keystone triggers a short tween on the matching icon
- **WHEN** `flash_keystone("great_sword")` is called
- **THEN** the Great Sword icon in the HUD plays a white-flash tween that returns to normal modulate after ~0.2s

#### Scenario: flash_keystone with unknown id is a no-op
- **WHEN** `flash_keystone("nonexistent_id")` is called
- **THEN** no error occurs and no animation plays

### Requirement: Technique and keystone icons play a scale pop when they fire
When a technique or keystone contributes a non-zero result to a clear event, its HUD icon SHALL play a brief scale punch animation at the moment its floating popup is spawned.

#### Scenario: Icon scales up then back down on activation
- **WHEN** a technique's popup is spawned (either immediately or from the stagger schedule)
- **THEN** the corresponding HUD icon scales from `Vector2(1.0, 1.0)` to approximately `Vector2(1.35, 1.35)` and then back to `Vector2(1.0, 1.0)`

#### Scenario: Scale pop is simultaneous with its popup
- **WHEN** a staggered popup is spawned at a delayed time during the line clear window
- **THEN** the icon scale pop occurs at the same moment the floating label appears (not at evaluate time)

#### Scenario: pop_icon with unknown id is a no-op
- **WHEN** `pop_icon("nonexistent_id")` is called
- **THEN** no error occurs and no animation plays

#### Scenario: Scale pop and pending pulse can run simultaneously
- **WHEN** an icon is currently pulsing (pending state) and a pop is triggered for the same icon
- **THEN** both animations run without conflict (scale and modulate are independent properties)
