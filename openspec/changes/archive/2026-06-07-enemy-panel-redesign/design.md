## Context

The current `EnemyDisplay` is a 140px-wide Control node instantiated as a child of `BoardContainer` (a Node2D) and positioned by a hardcoded pixel offset from the board edge. It contains a colour-filled portrait panel, name label, HP bar, and ATK windup bar. This leaves ~580px of empty screen space on the right side of the 1600×900 viewport unused.

The redesign expands this into a full-height right-side panel (≈680×900px) that consolidates all enemy-related combat information, adds a free-floating portrait with a placeholder initial letter, and introduces a lunge animation when the enemy attacks.

## Goals / Non-Goals

**Goals:**
- Replace the compact widget with a dramatic full-height right-side panel
- Enemy portrait is free-floating (no border box); TextureRect for now, swappable to AnimatedSprite2D later with zero animation rework
- Lunge animation (toward board) triggered explicitly when enemy fires; anticipation pulse at 80%+ windup
- Damage feedback when player deals damage: portrait red flash + floating damage number
- Panel shows: name (enemy-colour tinted), free-floating portrait with initial-letter placeholder, stage/round label, flavor text (optional), boss modifier description (optional), HP bar, ATK countdown bar
- Add `flavor_text` to the `Enemy` resource
- Clean up the stale floating `ModifierBigLabel` from the HUD

**Non-Goals:**
- Actual sprite artwork — `flavor_text` fields and `sprite` fields left empty for now
- Animated sprite frames — architecture supports it but no AnimatedSprite2D yet
- Moving or modifying the attack buffer bar (the 12px vertical strip left of the board)
- Any changes to shop, keystone selection, or other screens

## Decisions

**D1 — EnemyDisplay lives under HUD, not BoardContainer**

Currently EnemyDisplay is a Node2D child, positioned with board-relative pixel math. A full-height panel needs to be anchored to the viewport, not the board coordinate system. Moving it to a direct child of `RunManager` (alongside HUD and BoardContainer) lets us position it using Control anchors at a fixed screen x-position independently of board layout.

*Alternative considered:* Keep it in BoardContainer with a large offset. Rejected — the panel height (900px) exceeds the board height (720px) so anchoring to the board origin would require viewport-height overrides anyway.

**D2 — Lunge animates an inner "portrait anchor" node, not the root EnemyDisplay**

Only the portrait image lunges; the name, bars, and info section stay fixed. A lightweight inner Control (`_portrait_anchor`) acts as the translate target for the Tween. The image (TextureRect or future AnimatedSprite2D) is a child of this anchor.

*Why this matters for future sprites:* Swapping TextureRect → AnimatedSprite2D only touches what's inside the anchor. The Tween moves `_portrait_anchor.position.x` — completely sprite-agnostic.

**D3 — Lunge triggered by `on_attack_fired()` called from RunManager**

RunManager already knows the exact frame garbage is queued (`_tick_enemy_garbage`). Calling `_enemy_display.on_attack_fired()` there is causally correct and avoids heuristic detection (e.g. watching for timer reset to 0, which could false-fire on round start).

*Alternative considered:* Detect reset inside `update_windup()` by comparing new vs old timer. Rejected — fragile, fires spuriously on round initialisation.

**D4 — Anticipation pulse via Tween scale on portrait anchor**

At 80%+ windup, `update_windup()` drives a subtle scale pulse on `_portrait_anchor` (e.g. 1.0 → 1.04 oscillation) using a looping Tween. When the attack fires the pulse Tween is killed and the lunge Tween takes over. Scale returns to 1.0 as part of the lunge wind-down.

**D5 — Initial-letter placeholder rendered via Label, not drawn**

A large Label (font size ~180) with the first character of the enemy name, at low opacity (~0.15) and enemy colour, sits inside the portrait anchor. When `enemy.sprite` is set, the sprite TextureRect is shown and the label hidden. This is trivially swappable and requires no custom `_draw()` code.

**D7 — Damage animation driven by delta in `update_hp()`**

`update_hp()` receives the new accumulated value each frame. By tracking the previous HP value, EnemyDisplay detects when damage was dealt (remaining HP decreased). On a positive delta it triggers two concurrent effects: a short red modulate flash on `_portrait_anchor` (Tween: WHITE → RED over ~0.08s, back to WHITE over ~0.2s), and a floating Label spawned as a child of EnemyDisplay showing the damage amount, animating position.y upward ~50px and alpha 1.0 → 0.0 over ~0.9s before `queue_free()`. No additional signal or RunManager involvement is needed.

*Alternative considered:* A dedicated `on_damage_taken(amount)` call from RunManager. Rejected — RunManager calculates damage as a delta from quota tracking which is non-trivial to surface cleanly. `update_hp()` already has everything needed; the delta is computable locally.

**D6 — HP updates owned by EnemyDisplay directly**

Currently `RunManager → HUD.update_quota() → EnemyDisplay.update_hp()`. With EnemyDisplay no longer under HUD, the delegation is unnecessary. `RunManager` calls `_enemy_display.update_hp()` directly, and `hud.update_quota()` is simplified to not forward to the enemy display. `HUD.set_enemy_display()` is removed.

## Risks / Trade-offs

[Portrait area is visually empty without sprites] → Mitigated by the initial-letter placeholder (D5); looks intentional rather than broken.

[Lunge could clip into queue display area] → The lunge distance (≈90px left) is bounded so the portrait anchor stays within the right panel column (x≥880). Queue display ends at x≈828; 52px clearance at peak lunge.

[Tween conflicts if `on_attack_fired()` is called while a previous lunge is mid-return] → The lunge Tween is killed and restarted on each call; the portrait snaps to its current mid-return position and re-lunges. Acceptable for the attack cadence of this game.

[Removing `ModifierBigLabel` from HUD] → The label was floating at a hardcoded position over the enemy area anyway; no other system references it. Low-risk removal.

## Open Questions

*(All resolved)*

- ~~ATK countdown bar for The Reflection~~ → **Hidden entirely** via the existing `set_attack_bar_visible(false)` call. No static placeholder needed.
- ~~Stage/round label format and HUD relationship~~ → **Compact format in the panel: "X-Y" for rounds 1–3, "X-BOSS" for round 4.** Expressed as `"%d-%s" % [stage, "BOSS" if round_index == 3 else str(round_index + 1)]`. HUD top bar `RoundLabel` is kept as-is (supplements the panel for peripheral visibility while playing).
