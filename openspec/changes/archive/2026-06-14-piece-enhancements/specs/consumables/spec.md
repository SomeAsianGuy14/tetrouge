## ADDED Requirements

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
