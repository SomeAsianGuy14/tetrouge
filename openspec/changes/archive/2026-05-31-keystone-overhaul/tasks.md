## 1. Resource Schema Changes

- [x] 1.1 Add `replaces_keystone_id: String = ""` export field to `game/resources/keystone.gd`
- [x] 1.2 Add `flavor_text: String = ""` export field to `game/resources/keystone.gd`
- [x] 1.3 Add `blessed_stone: bool = false` export field to `game/resources/keystone.gd`
- [x] 1.4 Add `per_attack_tag_bonus: int = 0` export field to `game/resources/keystone.gd`
- [x] 1.5 Add `reflect_on_flush: float = 0.0` export field to `game/resources/keystone.gd`
- [x] 1.6 Add `flavor_text: String = ""` export field to `game/resources/technique.gd`

## 2. RunState: Upgrade Replacement Logic

- [x] 2.1 In `RunState.add_keystone()`, after appending to `used_keystone_ids` and before calling `_apply_keystone_effects()`, check if `keystone.replaces_keystone_id != ""` and remove the matching keystone from `RunState.keystones` if found

## 3. Modify Existing Keystone Data Files

- [x] 3.1 `simple_shield.tres` — set `garbage_flush_reduction = 1`
- [x] 3.2 `great_sword.tres` — set `requires_keystone_id = "simple_sword"`, add `replaces_keystone_id = "simple_sword"`, set `quad_bonus = 10`, update description
- [x] 3.3 `double_trouble.tres` — remove `suppress_tspin_single = true` and `suppress_tspin_triple = true`, update description
- [x] 3.4 `triple_threat.tres` — remove `suppress_tspin_single = true` and `suppress_tspin_double = true`, update description
- [x] 3.5 `magical_coin.tres` — set `requires_keystone_id = "slightly_magical_coin"`, add `replaces_keystone_id = "slightly_magical_coin"`, set `end_round_coins = 4`, update description

## 4. New Keystone Data Files

- [x] 4.1 Create `game/resources/data/keystones/mace_and_chain.tres` — `requires_keystone_id = "simple_flail"`, `replaces_keystone_id = "simple_flail"`, `single_bonus = 3`, `double_bonus = 3`
- [x] 4.2 Create `game/resources/data/keystones/legionnaires_shield.tres` — `requires_keystone_id = "simple_shield"`, `replaces_keystone_id = "simple_shield"`, `garbage_flush_reduction = 3`
- [x] 4.3 Create `game/resources/data/keystones/crystal_staff.tres` — `requires_keystone_id = "simple_wand"`, `replaces_keystone_id = "simple_wand"`, `tspin_any_bonus = 10`
- [x] 4.4 Create `game/resources/data/keystones/blessed_stone.tres` — `blessed_stone = true`, no `requires_keystone_id`
- [x] 4.5 Create `game/resources/data/keystones/hybrid_reactor.tres` — `per_attack_tag_bonus = 3`, no `requires_keystone_id`
- [x] 4.6 Create `game/resources/data/keystones/reflect.tres` — `reflect_on_flush = 0.5`, no `requires_keystone_id`

## 5. ResourceRegistry: Register New Keystones

- [x] 5.1 Add `preload()` entries for all 6 new keystones to `ResourceRegistry.all_keystones` in `game/autoloads/resource_registry.gd`

## 6. RunManager: Blessed Stone

- [x] 6.1 Investigate whether `TetrisBoard` exposes a `clear_board()` or equivalent method; add one if absent
- [x] 6.2 Add `var _blessed_stone_spent: bool = false` to RunManager
- [x] 6.3 Reset `_blessed_stone_spent = false` at the start of `_start_round()` — wait, it should persist across rounds; reset only in `reset()` logic or at run start. Add reset in the run initialisation path (not per-round)
- [x] 6.4 In `_on_game_over()`, before calling `_end_round(false)`, check if Blessed Stone is active and unspent — if so: clear board, add 120s to `round_timer`, set `_blessed_stone_spent = true`, return early
- [x] 6.5 In `_tick_timer()`, before calling `_end_round(false)` on timeout, apply the same Blessed Stone check (set `round_timer = 120.0` instead of adding)

## 7. RunManager: Hybrid Reactor

- [x] 7.1 In `_on_attack_generated()`, after `_apply_keystone_multipliers()` and before `_drain_attack()`, if `modified > 0`, compute the sum of `per_attack_tag_bonus` across active keystones and the count of techniques with `tags.size() >= 2`; add `bonus × count` to `modified`

## 8. RunManager: Reflect Keystone

- [x] 8.1 In `_flush_pending_garbage()`, after each batch of lines is sent to the board via `insert_garbage_rows()`, check if any active keystone has `reflect_on_flush > 0`; if so, add `floori(lines_flushed × reflect_on_flush)` to `quota_accumulated` and call `hud.update_quota()`

## 9. Language: Remove "Quota" from Player-Facing Strings

- [x] 9.1 In `game/scenes/screens/run_failure.gd`, update the message to "Failed to defeat the enemy in time."
- [x] 9.2 Search for any other player-visible strings containing "quota" in scenes/scripts and update to enemy-kill framing

## 10. Testing

- [x] 10.1 Add test: `add_keystone` with `replaces_keystone_id` set removes the base keystone from `RunState.keystones`
- [x] 10.2 Add test: replaced keystone id remains in `used_keystone_ids` after upgrade
- [x] 10.3 Add test: `add_keystone` with empty `replaces_keystone_id` does not remove any existing keystones
- [x] 10.4 Add test: `add_keystone` with `replaces_keystone_id` that doesn't match any held keystone adds normally without error
- [x] 10.5 Add test: Hybrid Reactor bonus is applied when `modified > 0` and N techniques qualify
- [x] 10.6 Add test: Hybrid Reactor bonus is NOT applied when `modified == 0`
- [x] 10.7 Add test: Hybrid Reactor bonus is zero when no techniques have 2+ tags
- [x] 10.8 Add test: Reflect keystone adds `floor(lines × 0.5)` to quota when garbage is flushed
- [x] 10.9 Add test: Reflect keystone floors fractional result (3 lines → 1 damage, not 2)
- [x] 10.10 Add test: Blessed Stone spent state persists across rounds within a run (unit-level flag test)
- [x] 10.11 Update existing suppression tests for Double Trouble and Triple Threat to verify no suppression flags

## 11. Run Tests

- [x] 11.1 Run the full GUT test suite via `game/tests/run_tests.tscn` and confirm all tests pass
