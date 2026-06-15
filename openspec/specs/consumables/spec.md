## ADDED Requirements

### Requirement: Consumables are one-round attack buffs stored in a persistent backpack
Consumables SHALL be purchasable from the shop and stored in the player's backpack (maximum 3 slots). Each consumable applies a flat attack bonus to one round's `RoundConfig` when activated by the player from the HUD before that round begins. After activation, the consumable is removed from the backpack. Unused consumables persist in the backpack across rounds and shop visits.

#### Scenario: Consumable removed after activation
- **WHEN** the player activates a consumable from the HUD backpack before a round starts
- **THEN** it is removed from the backpack and its bonuses are applied to that round's config

#### Scenario: Unused consumables persist across rounds
- **WHEN** the player does not activate a consumable before a round
- **THEN** it remains in the backpack and is available for future rounds

#### Scenario: Consumable cannot be activated once the round is live
- **WHEN** the round is in progress and the consumable is an attack-buff type
- **THEN** the backpack slot is non-interactive (attack-buff items are pre-round only)

### Requirement: Player backpack holds up to 3 consumables
The player's backpack SHALL be capped at 3 slots. Purchasing a 4th consumable is not permitted until a slot is freed.

#### Scenario: Backpack full
- **WHEN** the player has 3 consumables and attempts to buy a fourth
- **THEN** the purchase is rejected with a visual indicator showing the backpack is full

#### Scenario: Backpack slot freed after activation
- **WHEN** the player activates a consumable before a round
- **THEN** that backpack slot becomes empty and a new consumable can be purchased

### Requirement: Consumable pool for launch
The following consumables SHALL be available in the initial build:

| Name | Effect | Activation Timing |
|------|--------|------------------|
| **Power Shard** | +3 to all clear types | Pre-round |
| **Battle Tonic** | +2 to all clear types | Pre-round |
| **Quad Charge** | +5 to quad attacks | Pre-round |
| **Spin Amp** | +5 to any T-spin attack | Pre-round |
| **B2B Booster** | +4 to B2B streak attacks | Pre-round |
| **Combo Coil** | +3 to combo bonus attacks | Pre-round |
| **PC Bomb** | +8 to perfect clear attacks | Pre-round |
| **Attack Surge** | First 3 clears deal double attack | Pre-round |

#### Scenario: Attack-buff consumable raises clear damage for the round
- **WHEN** an attack-buff consumable is activated before a round
- **THEN** all attacks of the specified clear type deal additional damage for that round's duration

#### Scenario: Attack Surge doubles the first 3 clears
- **WHEN** Attack Surge is activated before a round and the player clears lines
- **THEN** the first 3 attacks that round deal double damage; the 4th and subsequent attacks are unaffected

#### Scenario: Bonus expires at round end
- **WHEN** a round ends after an attack-buff consumable was activated
- **THEN** the bonus no longer applies in subsequent rounds

### Requirement: Enhancement-granting consumables
The `Consumable` resource SHALL support an enhancement grant via `enhance_type: String` and `enhance_pieces: int`. Using such a consumable mid-round SHALL activate a timed grant: the next `enhance_pieces` spawned pieces carry `enhance_type`. Using the same consumable again while its grant is active SHALL extend the remaining piece count; using a different enhancement consumable SHALL replace the active grant (last use wins).

#### Scenario: Consumable activates a timed grant
- **WHEN** the player uses a "next 4 pieces gilded" consumable mid-round
- **THEN** the next 4 spawned pieces are gilded-enhanced

#### Scenario: Same-type use extends the grant
- **WHEN** a gilded grant has 2 pieces remaining and the player uses another 4-piece gilded consumable
- **THEN** the grant has 6 pieces remaining

#### Scenario: Different-type use replaces the grant
- **WHEN** a gilded grant is active and the player uses a 4-piece honed consumable
- **THEN** the active grant becomes honed with 4 pieces remaining

## REMOVED Requirements

### Requirement: Time Shard adds seconds to the round timer
**Reason:** Without the timer as a failure condition, adding time has no survival value. The consumable is vestigial.
**Migration:** Remove `time_shard.tres` from the data folder and remove its preload entry from `ResourceRegistry.all_consumables`. Any save file referencing `time_shard` in the consumable inventory will silently drop it on next load (the `_load_by_ids` helper already handles missing ids gracefully).
