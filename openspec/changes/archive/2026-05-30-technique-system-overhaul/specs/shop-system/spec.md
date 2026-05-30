## ADDED Requirements

### Requirement: Technique slots use the same card layout as item slots
Technique slots in the shop SHALL use the same visual card layout as consumable and voucher item slots: a card showing the technique's name, description, and cost as distinct labelled elements, with a dedicated Buy button. The existing separate "Techniques" section header and row layout SHALL be retained, but each slot SHALL render as a full card matching the item slot appearance.

#### Scenario: Technique slot shows name, description, cost separately
- **WHEN** the shop opens and a technique slot contains a technique
- **THEN** the slot displays the technique name, description, and cost as distinct labelled elements — not a concatenated string — with a Buy button

#### Scenario: Technique slot visual matches item slot
- **WHEN** the shop is open
- **THEN** the technique card layout is visually consistent with the consumable and voucher card layout

### Requirement: Shop enforces technique capacity at purchase
The shop SHALL check `RunState.techniques.size() < RunState.technique_capacity` before allowing a Technique purchase. When the player is at capacity, all technique Buy buttons SHALL be disabled and a visible message SHALL indicate the player is at their technique limit.

#### Scenario: At capacity — buy button disabled
- **WHEN** `RunState.techniques.size() == RunState.technique_capacity`
- **THEN** all technique slot Buy buttons are disabled and a label reads "Technique slots full"

#### Scenario: Below capacity — normal affordability rules apply
- **WHEN** `RunState.techniques.size() < RunState.technique_capacity`
- **THEN** technique Buy buttons follow existing affordability rules (disabled if can't afford, enabled otherwise)

#### Scenario: Selling from collection re-enables purchase at capacity
- **WHEN** the player is at capacity, sells a technique from the collection panel, and now has one free slot
- **THEN** technique Buy buttons are re-evaluated (capacity check now passes)
