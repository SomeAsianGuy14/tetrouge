## Context

All 57 techniques currently have individual `cost` values (40-60 range from the economy rebalance) and appear with equal probability everywhere. Adding rarity creates 3 tiers that drive cost, appearance frequency, and visual color.

## Goals / Non-Goals

**Goals:**
- Add rarity field to Technique resource with 3 tiers (Common, Rare, Epic)
- Rarity determines base cost with ±4 random variance in shops
- Weighted random draw in shops, Wishing Well, and Library
- Color-coded technique names across all UI surfaces

**Non-Goals:**
- Rarity on consumables or keystones (future consideration)
- Floor-gated availability (all rarities can appear on any floor)
- Rarity affecting mastery or technique amplification

## Decisions

### 1. Rarity stored as a string field on Technique resource

`@export var rarity: String = "common"` — values: `"common"`, `"rare"`, `"epic"`. Using strings for simplicity and .tres readability.

### 2. Cost derived from rarity with shop variance

Constants on Technique or a global lookup:

| Rarity | Base Cost | Shop Range (±4) |
|--------|-----------|-----------------|
| Common | 40        | 36-44           |
| Rare   | 52        | 48-56           |
| Epic   | 64        | 60-68           |

The `cost` field on the .tres stays as the base cost for sell-price calculation. Shop display cost is `base + rng.randi_range(-4, 4)` computed at shop population time. Sell price uses the base cost (not the variance), so `floor(base * sell_ratio)`.

**Alternative considered:** Remove cost field entirely. Rejected because sell price still needs a stable base, and the Coupon/Specialist Discount techniques apply percentage modifiers that need a consistent reference.

### 3. Weighted draw via pool expansion

When drawing techniques for shop/Wishing Well/Library, build a weighted pool:
- Common techniques added with weight 5
- Rare techniques added with weight 3
- Epic techniques added with weight 1

Use `RunState.seeded_randf()` to pick from the weighted pool. This is the same pattern used for Wishing Well item categories.

### 4. Rarity colors

| Rarity | Color                          | Usage                              |
|--------|--------------------------------|------------------------------------|
| Common | White `Color(1, 1, 1)`         | Default — no special treatment     |
| Rare   | Blue `Color(0.3, 0.5, 1.0)`   | Name labels in shop, HUD icons     |
| Epic   | Purple `Color(0.7, 0.3, 1.0)` | Name labels in shop, HUD icons     |

Applied to: shop technique name labels, HUD technique icon labels, shop collection technique buttons, Library choice buttons.

### 5. Rarity constants location

Add to `technique.gd` as class constants:

```
const RARITY_BASE_COST := {"common": 40, "rare": 52, "epic": 64}
const RARITY_COLOR := {"common": Color(1,1,1), "rare": Color(0.3,0.5,1.0), "epic": Color(0.7,0.3,1.0)}
const RARITY_WEIGHT := {"common": 5, "rare": 3, "epic": 1}
```

## Risks / Trade-offs

- **31 .tres file edits**: Each technique file needs `rarity` added and `cost` updated to match the rarity base. → Scripted batch update to minimize errors.

- **Coupon/Specialist Discount**: These apply percentage discounts to technique cost. With variance, the discount applies to the shop display cost (base + variance), not the raw base. This is consistent with current behavior where `_effective_cost()` reads `item.cost`.

- **Sell price consistency**: If shop cost varies but sell price uses `item.cost` (the base), selling a technique bought at base-4 still refunds based on the base. This means you can't "profit" from variance. → Acceptable.
