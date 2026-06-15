## ADDED Requirements

### Requirement: Shield charges reduce incoming waves
When an enemy garbage wave is generated, shield charges earned from cleared reinforced cells SHALL reduce the wave's line count before the keystone `garbage_flush_reduction` and before packets are appended to the pending-garbage queue, consuming one charge per absorbed line. Waves reduced to zero lines SHALL NOT append a packet or trigger the enemy attack animation.

#### Scenario: Shield consumes before packet creation
- **WHEN** the shield has 2 charges and a 3-line wave fires
- **THEN** a 1-line packet is appended and the shield is 0

#### Scenario: Fully absorbed wave creates no packet
- **WHEN** the shield has 5 charges and a 3-line wave fires
- **THEN** no packet is appended, the attack animation does not fire, and 2 charges remain

### Requirement: Shield charge indicator
A `ShieldBar` control, mirroring `AttackBar`'s rendering pattern, SHALL render on the opposite side of the board from the attack bar. It SHALL draw one silver block per shield charge, stacked from the bottom, capped at 8 blocks; if the shield pool exceeds 8, the bar SHALL display "+N" overflow text above the filled blocks. RunManager SHALL call `update_charges(charges: int)` whenever the shield pool changes.

#### Scenario: Bar fills with silver blocks per charge
- **WHEN** the shield pool has 3 charges
- **THEN** the ShieldBar renders 3 silver blocks stacked from the bottom

#### Scenario: Overflow beyond cap shows as text
- **WHEN** the shield pool has 11 charges
- **THEN** the ShieldBar renders 8 filled silver blocks and "+3" overflow text

#### Scenario: Empty shield pool shows no blocks
- **WHEN** the shield pool has 0 charges
- **THEN** the ShieldBar renders no filled blocks
