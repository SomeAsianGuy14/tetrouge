## 1. Enemy renames (data-only)

- [x] 1.1 `iron_shambler.tres`: display_name → "Armored Skeleton"
- [x] 1.2 `rock_crawler.tres`: display_name → "Stone Crab"
- [x] 1.3 `the_warden.tres`: display_name → "Dungeon Warden"
- [x] 1.4 `void_knight.tres`: display_name → "Fallen Knight"
- [x] 1.5 `crimson_drake.tres`: display_name → "Lesser Drake"
- [x] 1.6 `rust_golem.tres`: display_name → "Rusty Golem"
- [x] 1.7 `slimeling.tres`: display_name → "Slime"

## 2. New general enemies

- [x] 2.1 Create `corrupted_mage.tres` (tier: Big, color: purple)
- [x] 2.2 Create `venomous_archer.tres` (tier: Small, color: green)
- [x] 2.3 Create `possessed_blade.tres` (tier: Elite, color: dark red)
- [x] 2.4 Create `insane_adventurer.tres` (tier: Big, color: brown)
- [x] 2.5 Create `giant_frog.tres` (tier: Small, color: green)
- [x] 2.6 Create `unstable_construct.tres` (tier: Elite, color: orange)
- [x] 2.7 Add all 6 new enemy `.tres` files to ResourceRegistry preload list

## 3. Encounter-specific enemies

- [x] 3.1 Add `encounter_only: bool = false` property to `enemy.gd`
- [x] 3.2 Create `pickpocket_enemy.tres` (tier: Elite, encounter_only: true)
- [x] 3.3 Create `robbers_enemy.tres` (tier: Elite, encounter_only: true)
- [x] 3.4 Create `mimic_enemy.tres` (tier: Elite, encounter_only: true)
- [x] 3.5 Add 3 encounter enemy `.tres` files to ResourceRegistry preload list
- [x] 3.6 Update `_load_enemy_pool()` in RunManager to filter out `encounter_only` enemies

## 4. New encounter subtypes

- [x] 4.1 Add "tutor", "sleeping_beast", "laboratory", "demonic_deal", "mimic", "beggar", "map_room", "treasure_chest" to `ENCOUNTER_SUBTYPES` in `dungeon_room.gd`. Remove "museum" and replace with "treasure_chest"
- [x] 4.2 Add match branches in `EncounterRoom._build_panel()` for all new subtypes
- [x] 4.3 Implement `_build_tutor()`: select a random mastery track, show atmospheric text with Accept (grants +2 levels to the random track, reveals which track after) and Leave buttons
- [x] 4.4 Implement `_build_sleeping_beast()`: show Fight (starts elite-tier combat) or Leave buttons
- [x] 4.5 Implement `_build_laboratory()`: show 3 random consumable take buttons (disabled if backpack full), plus Leave
- [x] 4.6 Implement `_build_demonic_deal()`: show eligible mastery tracks (3+ levels) with trade buttons (grants 150 coins, removes 3 levels), plus Leave
- [x] 4.7 Implement `_build_mimic()`: show treasure chest UI with "Claim" button that triggers Mimic combat
- [x] 4.8 Implement `_build_beggar()`: show "Offer 50 Gold" button (disabled if <50 coins, grants random common/rare technique), plus Leave
- [x] 4.9 Implement `_build_map_room()`: show "Examine Map" button (reveals all fog on current floor), plus Leave
- [x] 4.10 Rename `_build_museum()` to `_build_treasure_chest()`, update match branch

## 5. Encounter reworks

- [x] 5.1 Pickpocket revenge: add `pickpocket_stolen_gold: int` and `pickpocket_revenge_room_idx: int` to RunState. In `_build_pickpocket()`, after stealing gold, find an uncleared combat room on the current floor and mark it for revenge
- [x] 5.2 When entering the revenge room, spawn the Pickpocket enemy and award stored gold on victory
- [x] 5.3 Head Trauma speed dodge: in `_build_head_trauma()`, check if player has any technique with "speed" tag or keystone with `instant_arr`/`instant_soft_drop`. If so, show dodge message instead of removing technique
- [x] 5.4 Demonic Deal availability: add logic in dungeon generator to only include "demonic_deal" in the encounter pool if any mastery track has 3+ levels

## 6. Dungeon map mimic disguise

- [x] 6.1 In dungeon map rendering, display rooms with `encounter_subtype == "mimic"` as "Treasure Chest" (same icon/label as treasure_chest rooms)
- [x] 6.2 After mimic encounter is resolved, update the map tile to show the true "Mimic" label

## 7. New normal bosses

- [x] 7.1 Add `ignore_shields: bool = false`, `suppress_same_clear: bool = false`, `scaling_interval: bool = false`, `hidden_ui: bool = false`, `fixed_interval: float = 0.0` properties to `boss_modifier.gd`
- [x] 7.2 Create `boss_ram.tres` with BossModifier (ignore_shields: true), add to ResourceRegistry
- [x] 7.3 Create `boss_jester.tres` with BossModifier (suppress_same_clear: true), add to ResourceRegistry
- [x] 7.4 Create `boss_berserker.tres` with BossModifier (scaling_interval: true), add to ResourceRegistry
- [x] 7.5 Create `boss_forgotten.tres` with BossModifier (hidden_ui: true), add to ResourceRegistry
- [x] 7.6 Create `boss_furnace.tres` with BossModifier (fixed_interval: 5.0), add to ResourceRegistry
- [x] 7.7 Implement `ignore_shields` in RunManager garbage flush — bypass shield charges when flag is set
- [x] 7.8 Implement `suppress_same_clear` in RunManager — zero damage when event_type matches previous clear type (use TechniqueRoundState.last_clear_type)
- [x] 7.9 Implement `scaling_interval` in RunManager garbage timer — multiply interval by remaining HP percentage
- [x] 7.10 Implement `hidden_ui` in enemy_display.gd — hide HP bar, attack bar, and windup animation when flag is set
- [x] 7.11 Implement `fixed_interval` in RunManager — override garbage interval min/max with fixed value when set

## 8. Final boss pool

- [x] 8.1 Add `enemies_killed: int = 0` to RunState, increment in `RunFlow.resolve_combat()` for non-boss wins, reset in `RunState.reset()`
- [x] 8.2 Add `hp_multiplier: float = 1.0`, `attack_multiplier: float = 1.0`, `mastery_drain: int = 0`, `scaling_per_kill: float = 0.0`, `composite: bool = false` properties to `boss_modifier.gd`
- [x] 8.3 Create `boss_mutant.tres` (tier: FinalBoss, composite: true), create `boss_titan.tres` (hp_multiplier: 2.0, attack_multiplier: 2.0), create `boss_klepto.tres` (mastery_drain: 5), create `boss_origin.tres` (scaling_per_kill: TBD)
- [x] 8.4 Add all 4 final boss `.tres` files to ResourceRegistry
- [x] 8.5 Update `_draw_enemy()` to use tier "FinalBoss" when `RunState.floor == RunState.TOTAL_FLOORS`
- [x] 8.6 Apply `hp_multiplier` and `attack_multiplier` in `_build_round_config()` to quota and garbage lines
- [x] 8.7 Apply `mastery_drain` at round start — reduce all mastery levels by the drain amount (min 0)
- [x] 8.8 Apply `scaling_per_kill` — multiply quota by `(1.0 + scaling_per_kill * RunState.enemies_killed)`
- [x] 8.9 Implement composite boss — select 2 random normal boss modifiers and apply both to the round config

## 9. Testing

- [x] 9.1 Add test: `encounter_only` enemies excluded from `_load_enemy_pool()`
- [x] 9.2 Add test: enemy kill counter increments on non-boss combat win and resets on run start
- [x] 9.3 Add test: Head Trauma dodge when player has speed-tagged technique
- [x] 9.4 Add test: Head Trauma removes technique when no speed items
- [x] 9.5 Add test: `ignore_shields` bypasses shield charges on garbage flush
- [x] 9.6 Add test: `suppress_same_clear` zeros damage when clear type matches previous
- [x] 9.7 Add test: `hp_multiplier` doubles quota in round config
- [x] 9.8 Add test: `mastery_drain` reduces all mastery levels at round start
- [x] 9.9 Add test: `scaling_per_kill` increases quota based on enemies_killed
- [x] 9.10 Add test: floor 4 draws from FinalBoss tier, floors 1-3 draw from Boss tier
- [x] 9.11 Run full test suite and fix any remaining failures
