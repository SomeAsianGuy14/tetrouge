## MODIFIED Requirements

### Requirement: Shop appears after every non-boss round
**Reason**: The shop is no longer a mandatory post-combat screen. It is now an optional room on the dungeon map. Players access the shop by choosing to enter a Shop room; it is not presented automatically.

The shop SHALL open when the player enters a Shop room on the dungeon map. The shop SHALL NOT appear automatically after any combat room. After the player exits the shop, the dungeon map is shown (the Shop room is marked as cleared).

#### Scenario: Shop opens on entering a Shop room
- **WHEN** the player selects and enters a Shop room on the dungeon map
- **THEN** the shop screen opens

#### Scenario: Shop does not appear after combat
- **WHEN** a combat room is cleared
- **THEN** the dungeon map is shown (not the shop)

#### Scenario: Exiting the shop returns to dungeon map
- **WHEN** the player exits the shop from a Shop room
- **THEN** the dungeon map is shown and the Shop room is marked as cleared
