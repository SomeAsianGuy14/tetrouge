## Context

The economy was originally tuned for frequent shop visits (after every round). With the dual-spine dungeon generation, shops now appear as 1-in-7 room types in the interior pool, yielding roughly 1-2 shops per floor. Meanwhile, the gilded enhancement (via Midas Touch keystone) generates 16-56 coins/round passively — dwarfing all other income combined (base payout 4, Slightly Magical 1, technique income 2-10). With techniques costing 3-8 coins, gilded builds trivially buy out entire shops.

The interest mechanic (1 coin per 5 held, capped at 5, applied at shop entry) was designed for a spend-earn-interest loop with frequent shops. With rare shops, it's dead weight. Vouchers (interest_cap_up, expanded_shop, consumable_expert, bonus_round) solved structural problems that should be baked into defaults.

## Goals / Non-Goals

**Goals:**
- Bring all non-gilded income sources to gilded-tier levels so economy builds are viable without Midas Touch
- Scale item prices proportionally so the shop remains a meaningful decision point ("what do I buy?" not "buy everything")
- Expand shop slot counts to make each rare visit feel like a bigger event
- Remove dead-weight systems (interest, vouchers) that no longer serve a purpose
- Rework the Wishing Well into a loot-drop encounter that fits the new economy

**Non-Goals:**
- Nerfing gilded per-cell values or the Midas Touch/Polished keystones
- Rebalancing non-economic enhancements (honed, reinforced, amplified)
- Changing shop appearance frequency or dungeon generation
- Reworking encounter frequency or adding new encounter types
- Changing the sell ratio mechanic (60%/80% with Smooth Haggling)

## Decisions

### 1. Linear rescaling of income and prices rather than curve adjustment

All income sources are multiplied by roughly 3-5× and all prices by roughly 8-10×. This creates a deliberate gap: players must invest in economy techniques/keystones to comfortably shop, rather than the current state where base income alone covers most purchases.

**Alternative considered:** Logarithmic scaling where cheap items stay cheap and only high-end items get expensive. Rejected because it would preserve the "buy everything" problem for common items.

### 2. Remove interest entirely rather than reworking it

Interest was a per-shop-visit mechanic. With 1-2 shops per floor instead of 4+, the banking incentive is gone. Removing it simplifies the Economy autoload and the shop flow.

**Alternative considered:** Scale interest up (e.g., 1 per 3 coins) to compensate for fewer shops. Rejected because it would reward hoarding over spending, which conflicts with the goal of making shops feel like meaningful events.

### 3. Bake expanded capacity into defaults rather than keeping vouchers

With vouchers removed, their beneficial effects (4th technique slot, 3rd consumable slot) become the new baseline. The shop defaults to 5 technique slots and 3 consumable slots. This makes each rare shop visit offer more choices.

**Alternative considered:** Convert voucher effects into techniques or keystones. Rejected because it would add complexity and the effects are better as defaults given rarer shops.

### 4. Wishing Well drops items instead of gold

Gold payouts would need to be 50-80 coins to be meaningful at the new scale, which feels arbitrary. Item drops (60% consumable, 30% technique, 10% keystone) make the Wishing Well a genuine loot encounter. Capped at 3 rewards per visit to prevent infinite farming.

**Alternative considered:** Scale gold payout to 50+ coins. Rejected because it would make the Wishing Well a pure gold-farm with no interesting choices.

### 5. Price mapping strategy for .tres files

Technique prices mapped from the old 3-8 range to 40-60 using a linear interpolation: `new_cost = 40 + round((old_cost - 3) / (8 - 3) * 20)`. This preserves the relative ordering (cheap techniques stay cheaper, expensive stay pricier). Consumable prices mapped from 4-6 to 30-40 using the same approach.

| Old Cost | New Technique Cost | New Consumable Cost |
|----------|-------------------|---------------------|
| 3        | 40                | —                   |
| 4        | 44                | 30                  |
| 5        | 48                | 35                  |
| 6        | 52                | 40                  |
| 7        | 56                | —                   |
| 8        | 60                | —                   |

### 6. Surplus divisor change from 3 to 2

The surplus conversion technique divides surplus attack by a divisor to produce coins. Changing from 3 to 2 makes overkill damage more rewarding and brings surplus-based income closer to gilded levels for skilled players.

## Risks / Trade-offs

- **Save compatibility**: Existing saves reference voucher IDs and interest_cap. Removing these fields could break mid-run saves. → Mitigation: RunSave should gracefully ignore missing voucher data on load (already uses `.get_value()` with defaults). Interest_cap removal is safe since it's on the Economy autoload which resets per run.

- **56 technique + 13 consumable .tres edits**: Bulk cost changes across many files risk typos. → Mitigation: Use the price mapping table above for consistency. Verify with a grep after all edits.

- **Wishing Well item overflow**: Granting techniques when at capacity or duplicate keystones. → Mitigation: Filter pools to exclude owned items. If a pool is exhausted, skip that category and reroll into the remaining categories.

- **Economy balance untested at scale**: The new numbers are theoretical. → Mitigation: Flag as a playtesting priority. All values are in constants or .tres data files, making them easy to adjust post-implementation.
