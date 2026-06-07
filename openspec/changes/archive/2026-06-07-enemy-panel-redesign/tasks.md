## 1. Enemy Resource

- [x] 1.1 Add `flavor_text: String = ""` export field to `game/resources/enemy.gd`
- [x] 1.2 Add `flavor_text = ""` to all enemy `.tres` files in `game/resources/data/enemies/`

## 2. EnemyDisplay Rewrite

- [x] 2.1 Clear out the existing `_build_ui()` body in `enemy_display.gd` — keep the class shell, `setup()`, `update_hp()`, `update_windup()`, and `set_attack_bar_visible()` signatures
- [x] 2.2 Add member variables for the lunge anchor (`_portrait_anchor: Control`), initial-letter label (`_initial_label: Label`), sprite rect (`_sprite_rect: TextureRect`), Tween handles (`_lunge_tween`, `_pulse_tween`, `_flash_tween`), and previous HP tracker (`_prev_accumulated: float`)
- [x] 2.3 Build the name label at the top of the panel, modulated to `enemy.color`
- [x] 2.4 Build the portrait anchor Control (~360×360px, no background); add the TextureRect (hidden by default) and initial-letter Label inside it
- [x] 2.5 Show TextureRect and hide initial label when `enemy.sprite` is non-null; show initial label and hide TextureRect otherwise
- [x] 2.6 Build the info section below the portrait: stage/round label in compact format (`"%d-%s" % [RunState.stage, "BOSS" if RunState.round_index == 3 else str(RunState.round_index + 1)]`), flavor text label (italic, hidden if empty), boss modifier description label (orange, hidden if `enemy.ability` is null)
- [x] 2.7 Build the HP bar with overlaid label (existing logic, adapted to new layout)
- [x] 2.8 Build the ATK countdown bar with label; wire `set_attack_bar_visible()` to show/hide this element
- [x] 2.9 Update `update_hp()` to reflect the new HP bar node reference; store the incoming accumulated value in `_prev_accumulated` each call
- [x] 2.10 Update `update_windup()` to reflect the new windup bar node reference and trigger the anticipation pulse when `timer / interval >= 0.8`

## 3. Combat Animations

- [x] 3.1 Implement `on_attack_fired()` — kills any active `_pulse_tween`, snaps scale to 1.0, then runs a Tween sequence: translate `_portrait_anchor.position.x` to −90px (0.09s linear) → hold 0.1s → return to 0 (0.45s ease-out)
- [x] 3.2 Implement the anticipation pulse in `update_windup()`: when threshold crossed, start a looping Tween on `_portrait_anchor.scale` oscillating 1.0→1.04; when threshold drops below 0.8, kill the pulse and reset scale
- [x] 3.3 Ensure a mid-return lunge kills the in-flight return Tween before starting a new one (use `_lunge_tween.kill()` guard)
- [x] 3.4 In `update_hp()`, compute delta (`accumulated - _prev_accumulated`); if delta > 0, trigger the red flash: run `_flash_tween` animating `_portrait_anchor.modulate` WHITE → RED (0.08s) → WHITE (0.2s); this Tween runs independently of `_lunge_tween`
- [x] 3.5 In `update_hp()`, if delta > 0, spawn a floating damage Label as a child of EnemyDisplay: position it centered over the portrait area, text = `str(int(delta))`, then run a Tween animating `position.y -= 50` and `modulate.a` 1.0 → 0.0 over 0.9s; connect the tween's `finished` signal to `queue_free()` the label

## 4. RunManager Integration

- [x] 4.1 In `run_manager.gd`, move enemy display instantiation out of `BoardContainer` — add it as a child of `RunManager` directly (alongside `HUD` and `BoardContainer`)
- [x] 4.2 Set the panel's anchors/position so it sits at approximately x=900, spanning the full viewport height (Control anchors: left=x/1600, right=1.0, top=0, bottom=1.0, or equivalent pixel offset)
- [x] 4.3 In `_tick_enemy_garbage()`, after appending a garbage packet to `_garbage_packets`, call `_enemy_display.on_attack_fired()` if `_enemy_display` is not null
- [x] 4.4 In `_end_round()` / cleanup, ensure `_enemy_display` is freed and the reference set to null (existing queue_free call should already cover this)
- [x] 4.5 Remove the `hud.set_enemy_display(_enemy_display)` call — HUD no longer delegates HP updates to the enemy display
- [x] 4.6 Replace `hud.update_quota(accumulated, current_config.quota)` calls with direct `_enemy_display.update_hp(accumulated)` calls (RunManager already has the reference)

## 5. HUD Cleanup

- [x] 5.1 Remove `_enemy_display` member variable, `set_enemy_display()`, and the `_enemy_display.update_hp()` call inside `update_quota()` from `hud.gd`
- [x] 5.2 Remove the `ModifierBigLabel` node from `run_manager.tscn` and delete the corresponding `modifier_big_label` `@onready` reference and all usages in `hud.gd`
- [x] 5.3 Confirm `modifier_label` in the HUD top bar is still set (it shows the modifier name as a compact label — keep this)

## 6. CHANGELOG

- [x] 6.1 Add player-facing notes to `CHANGELOG.md` under `## Unreleased`: enemy redesign, lunge animation, flavor text field

## 7. Testing

- [x] 7.1 Add test: `update_hp` with accumulated > quota clamps HP display to 0 (not negative)
- [x] 7.2 Add test: `set_attack_bar_visible(false)` hides the ATK bar; `set_attack_bar_visible(true)` shows it
- [x] 7.3 Add test: flavor text label is hidden when `enemy.flavor_text` is empty, visible when non-empty (instantiate EnemyDisplay, call setup with a mock Enemy)
- [x] 7.4 Add test: initial-letter label shows first character of display name when sprite is null
- [x] 7.5 Add test: `on_attack_fired()` does not error when called with no active Tween (null guard)
- [x] 7.6 Add test: `update_hp()` with increasing accumulated value triggers damage delta > 0 (unit-test the delta calculation, not the Tween itself)
- [x] 7.7 Add test: `update_hp()` called twice with the same value produces delta = 0 (no spurious damage animation)
