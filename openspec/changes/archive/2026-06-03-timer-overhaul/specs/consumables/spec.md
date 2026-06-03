## REMOVED Requirements

### Requirement: Time Shard adds seconds to the round timer
**Reason:** Without the timer as a failure condition, adding time has no survival value. The consumable is vestigial.
**Migration:** Remove `time_shard.tres` from the data folder and remove its preload entry from `ResourceRegistry.all_consumables`. Any save file referencing `time_shard` in the consumable inventory will silently drop it on next load (the `_load_by_ids` helper already handles missing ids gracefully).
