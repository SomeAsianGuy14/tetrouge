## ADDED Requirements

### Requirement: Shop inventory is deterministic per seed
All random draws used to populate shop inventory (technique slots, consumable slots, voucher slots) SHALL use the run-seeded PRNG. Reloading the game before visiting the shop SHALL produce the same inventory.

#### Scenario: Same shop inventory after reload
- **WHEN** a round is completed and the save is present, the game is closed and reopened, and the player visits the shop
- **THEN** the shop displays the same items in the same slots as would have appeared without the reload
