## MODIFIED Requirements

### Requirement: Technique resource schema includes tags and effect_type
Each Technique resource SHALL include:
- `id: String` — unique identifier
- `display_name: String`
- `description: String`
- `cost: int`
- `tags: Array[String]` — one or more from: `general`, `quad`, `tspin`, `combo`, `speed`, `precision`, `risk`, `economy`, `utility`, `garbage`
- `effect_type: String` — one of the defined effect type identifiers
- `params: Dictionary` — numeric parameters for the effect type

The tag value `"tetris"` is renamed to `"quad"`. No technique SHALL use the tag `"tetris"`.

#### Scenario: Technique resource has required fields
- **WHEN** a Technique `.tres` is loaded
- **THEN** it exposes `id`, `display_name`, `description`, `cost`, `tags`, `effect_type`, and `params` fields

#### Scenario: No technique uses the tetris tag
- **WHEN** all technique resources are loaded
- **THEN** none has `"tetris"` in its `tags` array; quad-category techniques use `"quad"` instead

### Requirement: 52 techniques available in the pool
The following techniques SHALL be present as `.tres` files and available to the shop's random draw pool. All descriptions and display names use "Quad" (not "Tetris").

**General:**
| Name | Effect | Tags |
|------|--------|------|
| Brass Knuckles | All line clears send +1 attack. | general |
| Clean Strike | Clearing 2+ lines sends +1 bonus attack. | general, precision |
| Sharpen | Quads send +2 attack. | general, quad |
| Follow-Up | After any line clear, your next line clear sends +1 attack. | general, combo |
| Attack Battery | Every 4 line clears, send +3 attack. | general |
| Opening Blow | Your first line clear each round sends +3 attack. | general |
| Finisher | If the enemy is below 25% HP, line clears send +1 attack. | general |
| Escalation | Every 10 pieces placed, your next attack gains +2. | general, speed |

**Quad:**
| Name | Effect | Tags |
|------|--------|------|
| Back-to-Back Pressure | Back-to-back Quads send +2 attack. | quad |
| Side Strike | If a Quad clear uses the far-left or far-right column, send +1 extra attack. | quad, precision |
| Delayed Cannon | Every second Quad sends +5 attack instead of the usual bonus. | quad, burst |
| Reckless Assault | If your board is above 60% height, Quads send +4 attack. | quad, risk |
| Quad Echo | After a Quad, your next single/double/triple sends +1 attack. | quad, general |
| Four Disciplines | Other line clears send -1 attack, but Quads send +5 attack. | quad, risk |

**T-Spin:**
| Name | Effect | Tags |
|------|--------|------|
| Spinning Strike | T-spins send +2 attack. | tspin |
| Mini Spark | T-spin minis send +1 attack. | tspin |
| Back-to-Back Spin | Back-to-back T-spins send +2 attack. | tspin |
| Dualcasting | T-spin doubles send +3 extra attack. | tspin |
| Compact Setup | T-spins performed while your board is below 50% height send +3 attack. | tspin, precision |
| Aggressive Positioning | T-spins performed above 60% board height send +4 attack. | tspin, risk |

**Combo:**
| Name | Effect | Tags |
|------|--------|------|
| Chain Starter | Your second consecutive line clear sends +1 attack. | combo |
| Combo Spark | Every combo step sends +1 attack. | combo |
| Chain Battery | Every 4 combo clears, send +3 attack. | combo |
| Flurry | Singles during a combo send +1 attack. | combo |
| Combo Spike | Every 5th combo clear sends +5 attack. | combo, burst |

**Speed:**
| Name | Effect | Tags |
|------|--------|------|
| Constant Pressure | If a piece locks within 1 second of spawning, your next clear sends +1 attack. | speed |
| Flash Step | After clearing at least 2 lines, gain 0 ARR for your next piece only. | speed |
| Flow Step | Placing 4 pieces without rotating grants +2 attack on your next clear. | speed, precision |
| Switch-Up | After a hard drop, your next soft-drop placement sends +1 attack if it clears a line. | speed |

**Precision:**
| Name | Effect | Tags |
|------|--------|------|
| Flatline | If your board height is 2 or less after a clear, gain +2 attack. | precision |
| Perfect Spark | Perfect clears send +6 attack. | precision, burst |
| Low Pressure | While your board is below 40% height, line clears send +1 attack. | precision |
| Discipline | Attacks gain +2 if you did not use hold on that piece. | precision, risk |

**Risk:**
| Name | Effect | Tags |
|------|--------|------|
| Redzone | While above 70% board height, attacks send +3. | risk |
| Glass Cannon | All attacks send +4, but incoming garbage is +2. | risk |
| Adrenaline Rush | Line clears in the top 4 lines send +5 attack. | risk |
| Gambler's Blade | Attacks have a 25% chance to send +4 and a 25% chance to send -2. | risk |
| Burning Board | All attacks send +3, but every 5 seconds take 1 damage. | risk |
| Greedy Hands | Gain an additional 2 coins every round, but enemies gain +1 attack. | risk, economy |

**Economy:**
| Name | Effect | Tags |
|------|--------|------|
| Coupon | Techniques cost 10% less. | economy |
| Specialist Discount | Techniques matching keystone tags cost 25% less. | economy |
| Smooth Haggling | Selling a technique refunds more currency. | economy |
| Bounty List | Gain 10 coins after defeating bosses. | economy |
| Combo Payout | Gain 5 coins the first time you reach 5+ combo each round. | economy, combo |
| Green Thumb | Gain 1 coin for every 5 garbage rows cleared. | economy, garbage |

**Utility:**
| Name | Effect | Tags |
|------|--------|------|
| Patience | After using hold, your next line clear gains +1 attack. Cooldown: 5 pieces. | utility |
| Controlled Drop | Soft-dropped pieces that clear lines send +1 attack. | utility, speed |
| Rotation Training | Rotating a piece 2+ times before a clear sends +1 attack. | utility, tspin |
| Good Planning | If you do not use hold for 5 pieces, gain +2 attack on next clear. | utility, precision |

**Garbage:**
| Name | Effect | Tags |
|------|--------|------|
| Recycling | T-spins that clear garbage send +3 attack. | tspin, garbage |
| Whirl | T-spins count as two combo steps. | tspin, combo |
| Counter Strike | Canceling garbage while below 40% height sends +2 attack. | precision, garbage |

#### Scenario: Quad Echo display name is "Quad Echo"
- **WHEN** the Quad Echo technique is displayed in the shop or HUD
- **THEN** the displayed name is "Quad Echo" (not "Tetris Echo")

#### Scenario: Side Strike uses column check
- **WHEN** the player clears 4 lines with the I-piece placed in a position that does not touch column 0 or column 9
- **THEN** Side Strike does not grant bonus attack
