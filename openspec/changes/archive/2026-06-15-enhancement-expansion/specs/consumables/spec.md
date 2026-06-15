## ADDED Requirements

### Requirement: Random-enhancement consumable grants
`enhance_type = "random"` SHALL be a valid value for the `Consumable` resource's enhancement grant. Using such a consumable SHALL activate a timed grant of `enhance_pieces` pieces with type `"random"`. Per the piece-enhancements capability, each of those pieces independently resolves to one of `honed`, `amplified`, `gilded`, `reinforced` at spawn time.

#### Scenario: Lottery Ticket grants 3 independently-random pieces
- **WHEN** the player uses a consumable with `enhance_type = "random", enhance_pieces = 3`
- **THEN** a timed grant for 3 pieces of type `"random"` is activated
- **AND** each of the next 3 spawned pieces independently resolves to one of `honed`, `amplified`, `gilded`, `reinforced`

#### Scenario: Random grant follows the same precedence and extension rules as other grants
- **WHEN** a `"random"` grant is activated while another enhancement grant is already active
- **THEN** it follows the same replace/extend/queue rules as any other enhancement consumable grant
