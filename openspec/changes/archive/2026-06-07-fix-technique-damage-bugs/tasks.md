## 1. Fix hybrid_reactor tag bonus (run_manager.gd)

- [x] 1.1 In `_on_attack_generated`, add `and not is_bonus_event` to the `if modified > 0` guard that wraps the tag bonus calculation block (around line 513)

## 2. Fix every_nth_clear off-by-one (technique_evaluator.gd)

- [x] 2.1 In `_eval_attack`, change the `"every_nth_clear"` condition from `rs.clears_this_round % p.get("n", 4) == 0` to `(rs.clears_this_round + 1) % p.get("n", 4) == 0`
- [x] 2.2 Remove the `rs.clears_this_round > 0` guard from the same condition (it is no longer needed and would incorrectly block the 1st-clear case where `clears_this_round == 0`)

## 3. Testing

- [x] 3.1 In `test_keystones.gd`: add test asserting hybrid_reactor tag bonus does NOT apply when `event_type == "b2b"` (call `_on_attack_generated` or replicate the guard logic directly)
- [x] 3.2 In `test_keystones.gd`: add test asserting hybrid_reactor tag bonus does NOT apply when `event_type == "combo"`
- [x] 3.3 In `test_technique_system.gd`: add test asserting `every_nth_clear` (n=4) fires when `clears_this_round == 3` (the 4th clear)
- [x] 3.4 In `test_technique_system.gd`: add test asserting `every_nth_clear` (n=4) does NOT fire when `clears_this_round == 2` (the 3rd clear)
- [x] 3.5 In `test_technique_system.gd`: add test asserting `every_nth_clear` (n=4) fires again when `clears_this_round == 7` (the 8th clear)
