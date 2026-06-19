## MODIFIED Requirements

### Requirement: Multiple Techniques stack additively on flat bonuses, multiplicatively on multipliers
When multiple Techniques modify the same event type, flat bonuses SHALL be summed. Multipliers SHALL be applied after all additive bonuses. The order of application SHALL be: base attack + mastery bonus + sum(flat bonuses with mastery amplification) × product(multipliers).

#### Scenario: Two flat bonus Techniques stack with mastery
- **WHEN** two Techniques each add +1 to T-spin Double attack and tspin_double mastery is level 4
- **THEN** a T-spin Double generates base attack + mastery(4) + technique1(1 + floor(4/2)) + technique2(1 + floor(4/2))
