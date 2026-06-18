## REMOVED Requirements

### Requirement: Voucher pool for launch
**Reason**: The voucher system is removed entirely. Interest is removed (interest_cap_up is dead). Shop and consumable capacity are baked into new defaults (expanded_shop and consumable_expert are redundant). Bonus Round had no effect already.
**Migration**: Delete all voucher .tres data files (interest_cap_up.tres, expanded_shop.tres, consumable_expert.tres, bonus_round.tres). Delete voucher.gd resource script. Remove `vouchers` array, `has_voucher()`, `add_voucher()`, and `_apply_voucher_effects()` from RunState. Remove voucher references from ResourceRegistry (`all_vouchers` constant). Remove voucher save/load from RunSave. Remove voucher-related tests. Update `shop_technique_slots` default to 5 and `consumable_capacity` default to 3 in RunState.
