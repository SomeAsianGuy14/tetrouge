## ADDED Requirements

### Requirement: InventoryPanel is visible during all run screens
The HUD's InventoryPanel (keystones, techniques, backpack) SHALL remain visible during combat, shop, encounter, and map screens. When `_hide_board_ui()` is called, only combat-specific elements (TopBar round/timer/modifier labels, InfoPanel) SHALL be hidden — the InventoryPanel SHALL NOT be hidden.

#### Scenario: InventoryPanel visible during encounter
- **WHEN** the player enters an encounter room (e.g., Wishing Well, Altar)
- **THEN** the InventoryPanel showing keystones, techniques, and backpack remains visible

#### Scenario: InventoryPanel hidden during shop
- **WHEN** the player enters the shop
- **THEN** the InventoryPanel is hidden because the shop has its own collection panel with sell functionality

#### Scenario: InventoryPanel visible during dungeon map
- **WHEN** the player is viewing the dungeon map
- **THEN** the InventoryPanel remains visible

#### Scenario: Combat-specific elements hidden during non-combat
- **WHEN** the player transitions from combat to a non-combat screen
- **THEN** the TopBar (round info, timer, modifier) and InfoPanel (B2B, combo) are hidden
- **THEN** the InventoryPanel is not hidden

### Requirement: Coin display is visible on the InventoryPanel during all screens
The InventoryPanel SHALL include a coin label that displays the current coin balance. This label SHALL update via the `Economy.coins_changed` signal. It SHALL be visible during all run screens including when combat-specific HUD elements are hidden.

#### Scenario: Coin balance shown during encounter
- **WHEN** the player is in an encounter room with 47 coins
- **THEN** the InventoryPanel displays "Coins: 47"

#### Scenario: Coin balance visible during encounter but not shop
- **WHEN** the player is in an encounter room
- **THEN** the InventoryPanel coin label is visible
- **WHEN** the player is in the shop
- **THEN** the InventoryPanel coin label is hidden (the shop has its own coin display)

### Requirement: InventoryPanel refreshes on screen transitions
When transitioning to a non-combat screen, the HUD SHALL refresh the InventoryPanel to reflect the current state of `RunState.keystones`, `RunState.techniques`, `RunState.consumables`, and `Economy.coins`.

#### Scenario: Inventory reflects new technique after shop
- **WHEN** the player buys a technique in the shop, leaves, and enters an encounter room
- **THEN** the InventoryPanel shows the newly purchased technique

#### Scenario: Inventory reflects Wishing Well award
- **WHEN** the Wishing Well awards a keystone
- **THEN** the InventoryPanel updates to include the new keystone (on next refresh or via signal)

### Requirement: Backpack slots are non-interactive during non-combat screens
The backpack slot buttons in the InventoryPanel SHALL be disabled (non-interactive) during shop, encounter, and map screens. Consumable activation is only permitted during combat pre-round and mid-round states as specified by existing requirements.

#### Scenario: Backpack slots disabled during encounter
- **WHEN** the player is in an encounter room
- **THEN** the backpack slots in the InventoryPanel are visible but cannot be clicked to activate

#### Scenario: Backpack slots re-enabled on combat entry
- **WHEN** the player enters a combat room
- **THEN** the backpack slots become interactive per existing activation timing rules
