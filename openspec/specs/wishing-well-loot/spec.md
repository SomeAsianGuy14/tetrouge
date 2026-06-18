## ADDED Requirements

### Requirement: Wishing Well awards random items instead of gold
The Wishing Well encounter SHALL cost 1 coin per throw and use an incrementing probability mechanic (starting at 1%, increasing by 1% per miss). On a successful throw, the well SHALL award a random item instead of gold: 60% chance consumable, 30% chance technique, 10% chance keystone. Items SHALL be drawn from `ResourceRegistry` pools, excluding techniques and keystones the player already owns.

#### Scenario: Successful throw awards a consumable
- **WHEN** the player throws a coin and the RNG roll succeeds and the category roll is <= 0.6
- **THEN** a random consumable from `ResourceRegistry.all_consumables` is added to the player's backpack

#### Scenario: Successful throw awards a technique
- **WHEN** the player throws a coin and the RNG roll succeeds and the category roll is > 0.6 and <= 0.9
- **THEN** a random unowned technique from `ResourceRegistry.get_available_techniques()` is added to `RunState.techniques`

#### Scenario: Successful throw awards a keystone
- **WHEN** the player throws a coin and the RNG roll succeeds and the category roll is > 0.9
- **THEN** a random keystone not in `RunState.used_keystone_ids` is added to `RunState.keystones`

#### Scenario: Throw cost is 1 coin
- **WHEN** the player clicks the throw button
- **THEN** 1 coin is deducted from the balance via `Economy.spend_coins(1)`

#### Scenario: Probability increments on miss
- **WHEN** the player throws and the roll fails
- **THEN** the success probability increases by 1% (0.01) for the next throw, up to 100%

### Requirement: Wishing Well rewards are capped at 3 per visit
The Wishing Well SHALL award a maximum of 3 items per encounter visit. After 3 successful drops, further throws SHALL be disabled.

#### Scenario: Third reward disables further throws
- **WHEN** the player has received 3 items from the Wishing Well in the current visit
- **THEN** the throw button is disabled and a message indicates the well has run dry

#### Scenario: Fewer than 3 rewards allows continued throwing
- **WHEN** the player has received fewer than 3 items
- **THEN** the throw button remains enabled (subject to coin balance)

### Requirement: Wishing Well handles pool exhaustion gracefully
When a category is rolled but its pool is exhausted (e.g., player owns all techniques), the well SHALL reroll into the remaining non-exhausted categories. If all pools are exhausted, the throw SHALL still consume the coin but display a message that the well has nothing left to offer.

#### Scenario: Technique pool exhausted rerolls to consumable or keystone
- **WHEN** the category roll selects technique but the player owns all available techniques
- **THEN** the well rerolls between consumable (60/70 weight) and keystone (10/70 weight)

#### Scenario: All pools exhausted
- **WHEN** all item pools are exhausted (player owns all techniques and keystones, and backpack is full)
- **THEN** the coin is consumed, no item is awarded, and a message indicates the well has nothing left

### Requirement: Wishing Well respects capacity limits
Technique grants SHALL respect `RunState.technique_capacity`. Consumable grants SHALL respect `RunState.consumable_capacity`. If the player is at capacity for a rolled category, that category SHALL be treated as exhausted for reroll purposes.

#### Scenario: Technique capacity full treats technique pool as exhausted
- **WHEN** the category roll selects technique but `RunState.techniques.size() >= RunState.technique_capacity`
- **THEN** the well rerolls into remaining categories

#### Scenario: Backpack full treats consumable pool as exhausted
- **WHEN** the category roll selects consumable but the player's backpack is full
- **THEN** the well rerolls into remaining categories
