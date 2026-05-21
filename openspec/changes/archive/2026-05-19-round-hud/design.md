## Context

`HUD` is a `Control` node that lives as a child of `RunManager`. It has a `setup(config)` method intended to be called at round start, but `RunManager.start_round()` never calls it. The result: `quota_bar.max_value` stays at Godot's ProgressBar default (100), the round label never changes, and `Economy.coins_changed` is never connected. The timer and quota label do update (their callers exist) but the quota display is meaningless without the correct `max_value`.

The HUD layout is a single `HBoxContainer` (TopBar) at the top of the screen holding all elements horizontally. There is also a `SidePanel` on the right for keystone icons. The board is positioned at `(460, 64)` and is `320px × 640px`.

## Goals / Non-Goals

**Goals:**
- `hud.setup(current_config)` called at every `start_round()`
- Economy signal connected once (in `_ready()`, not repeated in `setup()`)
- Prominent score/target labels and large timer visible without squinting
- Round name and modifier label clearly shown

**Non-Goals:**
- Animations or tweens on the HUD
- Per-technique income breakdown during play
- Mini-map or board thumbnail

## Decisions

### D1: Economy signal in _ready(), not setup()

`Economy.connect("coins_changed", _on_coins_changed)` in `setup()` creates a new connection each round. Moving it to `HUD._ready()` connects exactly once. `setup()` still sets `coin_label.text` directly to reflect the current balance immediately on setup.

### D2: New InfoPanel below the TopBar for score/target/timer

Rather than trying to fit large text into the existing `TopBar` HBoxContainer, add a second panel (`InfoPanel`) below the TopBar on the left side of the screen (next to the hold display). This contains three large Labels stacked vertically:

```
SCORE
123 / 400

TIME
0:45

Ante 2 — Boss Blind
```

The existing `TopBar` shrinks to just show coins and modifier (utility info). The `InfoPanel` shows the three elements the player needs most during play.

**Why not expand TopBar:** The TopBar already spans the full width. Making labels larger there would overlap the board or force a very wide minimum window. A sidebar panel is more legible and doesn't interfere with the board area.

### D3: Timer turns red below 10s (existing behaviour, made larger)

`update_timer()` already applies `Color.RED` at ≤10s. The larger font size makes this colour change more impactful.

### D4: InfoPanel positioned to the left of the board

The hold display sits at approximately x=340 (460 board x − 120 hold width). The InfoPanel goes at x=20, leaving room between it and the hold panel. Width ~140px. This uses the left margin that was previously empty.

## Risks / Trade-offs

**`hud.setup()` called before HUD nodes are ready** → `hud.setup()` is called from `start_round()` which runs after `_ready()` completes on all nodes. No issue.

**InfoPanel overlapping hold display at low window widths** → At 1280px the layout has ample space. No layout enforcement for smaller windows in this build.
