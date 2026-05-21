## Context

Input actions in Godot 4 support multiple `events` per action. `project.godot` stores each action as a dictionary with an `"events"` array. Adding a second key is done by appending another `Object(InputEventKey,...)` entry to that array. No GDScript changes are needed for the input routing — `_handle_input()` in `RunManager` already calls `Input.is_action_pressed("soft_drop")` and `Input.is_action_just_pressed("rotate_cw")`, which will automatically pick up the new bindings.

The soft drop visual is a one-line change in `TetrisBoard._draw()`: swap the ghost colour constant for a brighter version when `soft_dropping` is true.

The controls HUD label is a static `Label` node added to the existing HUD scene; no script changes are needed beyond placing the text.

## Goals / Non-Goals

**Goals:**
- X key triggers clockwise rotation (right rotation)
- S key triggers soft drop (alternative to Down arrow)
- Ghost piece is visually distinct when soft dropping
- A compact controls reference is visible during play

**Non-Goals:**
- Full rebinding UI (the Settings screen already handles DAS/ARR; full remapping is a separate scope)
- Soft drop attack/scoring (soft drop does not generate attack in guideline Tetris)
- Any change to the Tetris engine logic

## Decisions

### D1: Add bindings directly in project.godot, not via the Settings screen

The Settings screen only exposes DAS and ARR sliders. Rebinding keys is editor-level configuration. Adding X and S as secondary bindings in `project.godot` is the standard Godot approach for shipping default key maps. Players can still remap in Godot's Project Settings if needed.

### D2: Soft drop ghost colour — brighter, same hue

The ghost piece currently renders as `Color(0.5, 0.5, 0.5)` (mid-grey). When soft dropping, use `Color(0.85, 0.85, 0.85)` (bright white-grey). Same visual language, clearly distinct. No new colour constants or textures needed.

**Alternative considered:** Tint the ghost with the active piece's colour. Rejected — too busy visually and harder to read board state.

### D3: Controls reference as a static Label in the HUD scene

A single multiline `Label` node at the bottom of the HUD's side panel. Text is hardcoded — it reflects the default bindings and does not update dynamically. Simple and zero maintenance cost.

**Alternative considered:** Dynamic label built from `InputMap.action_get_events()`. Overkill for a static default layout.

## Risks / Trade-offs

**project.godot format sensitivity** → Godot 4's input event serialisation format is exact. Appending a second event object to the array must match the same `Object(InputEventKey,...)` format exactly. Adding it via the Godot editor (Project → Project Settings → Input Map) is safer than editing the text file directly. The task list reflects this.

**X key conflict with rotate_180's implicit "X" convention** → Some Tetris implementations use A for CCW, X for CW, and S for 180. Our layout uses Z/CCW, X/CW, A/180 which matches the most common convention. No conflict.
