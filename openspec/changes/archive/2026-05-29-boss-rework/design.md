## Context

The boss modifier system is a `BossModifier` resource with flag fields applied to `RoundConfig` via `apply_to_config()`. RunManager consumes those fields during the round. The attack buffer currently stores a single `pending_garbage: int`; the attack bar reads that via `update_pending(int)`. Both the boss pool and the buffer need coordinated changes.

## Goals / Non-Goals

**Goals:**
- Rename/retune five existing boss modifiers and delete The Surgeon
- Add three new modifiers: The Ancient, The Filth, The Reflection
- Replace `pending_garbage: int` with a packet queue `_garbage_packets: Array` in RunManager
- Rewrite AttackBar to use `_draw()` with per-packet colored rectangles and thin separators
- Drain packets bottom-first; filth packets visualized in a distinct color

**Non-Goals:**
- Changing how the boss modifier is selected or rotated per run
- Adding new visual effects for individual bosses beyond their mechanical changes
- Saving/loading the packet queue across round saves

## Decisions

**Packet data structure: `Array` of Dictionaries**
Each entry `{lines: int, is_filth: bool}`. Dictionaries are idiomatic in GDScript for small structured data without requiring a new class. The array is ordered oldest-first (index 0 = bottom of bar = drains first).

**Draining: consume from index 0, partial depletion in place**
When `drain(n)` is called, subtract from `packets[0].lines`. If that packet reaches 0, remove it. Continue into the next packet if more drain is needed. This mirrors how existing `pending_garbage` cancellation works, preserving the "attacks cancel garbage 1:1" spec.

**AttackBar rewrite: `_draw()` on a Control node**
The VBoxContainer + ColorRect array is replaced by a single Control that overrides `_draw()`. The bar height is always `VISIBLE_ROWS * CELL_SIZE` (720px). Each packet is drawn as a filled rect proportional to its line count, colored by type, with a 1px separator between packets. `queue_redraw()` is called after any packet change.

```
pixels_per_line = bar_height / VISIBLE_ROWS  (= 36px, matches cell size)

draw from bottom up:
  for packet in _packets (index 0 first = bottom):
    h = packet.lines * pixels_per_line
    color = FILTH_COLOR if packet.is_filth else WARNING_COLOR
    fill rect at current_y - h
    draw 1px separator line at top of rect
    current_y -= h
```

Total filled height capped at bar_height to avoid overflow on large queues.

**Reflection: hooks into `to_quota` inside `_on_attack_generated`**
`to_quota` is already computed as the portion of attack that actually reduces the boss's HP (capped at quota remaining). `floor(to_quota * reflect_ratio)` is appended as a new regular (non-filth) packet immediately after. This fires after all keystone/consumable bonuses so the reflected amount is based on final effective damage.

**The Ancient: flag on BagRandomizer call site**
`RoundConfig.random_pieces: bool`. In `TetrisBoard.refill_queue()`, when this flag is set, call `rng.randi_range(1, 7)` directly instead of `bag.next()`. No change to BagRandomizer itself — the bypass is at the call site.

**The Filth: individual packet per garbage interval fire**
When `RoundConfig.garbage_individual_lines` is true, each garbage interval fire appends N separate 1-line packets (each with a randomly re-rolled hole column) instead of one N-line flush. Each line is inserted individually via `insert_garbage_rows(1, col)` with a fresh column per line. Stored as `is_filth: true` packets in the queue.

**The Fateless: `hide_all_previews: bool` flag**
Cleaner than changing `preview_override` semantics. `apply_to_config` sets `config.preview_count = 0` when true. TetrisBoard already handles `preview_count == 0` — the queue refill loop condition `< preview_count + 1` still works (maintains 1 piece ahead, just never shows any).

**The Blitz: 60s (half of 120s standard)**
Was 45s. 60s is exactly half, more principled.

## Risks / Trade-offs

- [Packet queue size] Long rounds with many enemy attacks could accumulate many packets → Mitigation: packets merge when same type and adjacent (optional optimization; cap visual at bar height regardless)
- [Reflection + keystone interaction] Keystones that multiply attack (e.g. Great Sword) will amplify reflection too → Intentional; high-power builds face higher self-risk on The Reflection
- [_draw() performance] Called every frame while visible → Mitigation: only call `queue_redraw()` on packet changes, not every frame; with 20 packets max visible, draw cost is negligible
