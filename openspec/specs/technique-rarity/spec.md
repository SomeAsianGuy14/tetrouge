## ADDED Requirements

### Requirement: Techniques have a rarity tier
Each Technique resource SHALL have a `rarity` field with one of three values: `"common"`, `"rare"`, or `"epic"`. The rarity determines the technique's base cost, appearance weight, and display color.

#### Scenario: Common technique has base cost 40
- **WHEN** a technique has `rarity = "common"`
- **THEN** its base cost is 40

#### Scenario: Rare technique has base cost 52
- **WHEN** a technique has `rarity = "rare"`
- **THEN** its base cost is 52

#### Scenario: Epic technique has base cost 64
- **WHEN** a technique has `rarity = "epic"`
- **THEN** its base cost is 64

### Requirement: All 57 techniques are assigned to a rarity tier
31 techniques SHALL be Common, 14 SHALL be Rare, and 12 SHALL be Epic. Every technique SHALL have a rarity field set.

#### Scenario: No technique without rarity
- **WHEN** the technique pool is loaded
- **THEN** every technique has a non-empty `rarity` field

### Requirement: Rarity colors distinguish tiers visually
Common techniques SHALL be displayed in white `Color(1, 1, 1)`, Rare in blue `Color(0.3, 0.5, 1.0)`, and Epic in purple `Color(0.7, 0.3, 1.0)`. These colors SHALL be applied to technique name labels in the shop, HUD technique icons, shop collection buttons, and Library choice buttons.

#### Scenario: Epic technique name shown in purple in shop
- **WHEN** the shop displays an Epic technique
- **THEN** the technique name label uses purple color

#### Scenario: Common technique icon in HUD is white
- **WHEN** the HUD shows a Common technique icon
- **THEN** the icon label uses white color (default)

### Requirement: Weighted technique draw for shops and encounters
When drawing techniques for shop slots, the Wishing Well, or the Library, the draw SHALL be weighted by rarity: Common weight 5, Rare weight 3, Epic weight 1. Higher-weight techniques appear more frequently.

#### Scenario: Shop populates with weighted draw
- **WHEN** the shop generates its 5 technique slots
- **THEN** each slot draws from the available technique pool using rarity weights

#### Scenario: Wishing Well technique drop uses weighted draw
- **WHEN** the Wishing Well awards a technique
- **THEN** the technique is selected from the pool using rarity weights

#### Scenario: Library technique pool uses weighted draw
- **WHEN** the Library builds its list of 10 candidate techniques
- **THEN** candidates are drawn from the pool using rarity weights

### Requirement: Shop technique cost varies ±4 around rarity base
When a technique appears in the shop, its displayed cost SHALL be the rarity base cost plus a random offset in the range [-4, +4], determined by the seeded RNG. The sell price SHALL use the unmodified base cost.

#### Scenario: Common technique in shop costs between 36 and 44
- **WHEN** a Common technique (base 40) appears in a shop slot
- **THEN** the displayed cost is between 36 and 44 inclusive

#### Scenario: Sell price uses base cost not shop variance
- **WHEN** the player sells a technique with rarity base 52
- **THEN** the sell price is calculated from 52, not from the shop's displayed cost
