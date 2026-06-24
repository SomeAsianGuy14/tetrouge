## Context

Encounters are subtypes of `TYPE_ENCOUNTER` rooms, built via `EncounterRoom._build_panel()` which switches on `_subtype`. New encounter types add a branch to this match statement and a `_build_<name>()` method. The encounter pool in `DungeonRoom.ENCOUNTER_SUBTYPES` feeds the dungeon generator.

Enemies are `.tres` resources (`Enemy` class) with `tier` (Small/Big/Elite/Boss), loaded by `ResourceRegistry`. Boss enemies have a `BossModifier` resource attached via the `ability` field, which applies effects to `RoundConfig` and filters attack types.

The dungeon generator places rooms along two spines with guaranteed shops. Boss rooms are always at the top-right corner.

## Goals / Non-Goals

**Goals:**
- Add 7 new encounter types with player-choice mechanics
- Rework Museum → Treasure Chest, Pickpocket revenge fight, Head Trauma speed dodge
- Add 8 new general/encounter-specific enemies with renames for 7 existing
- Add 5 new normal bosses with unique boss modifiers
- Add a final boss pool for floor 4 with 4 escalated bosses
- Mimic room disguise on dungeon map

**Non-Goals:**
- New visual assets (enemies use initial-letter placeholders)
- Animated encounter scenes (text + buttons only, matching current pattern)
- Sound effects or music changes

## Decisions

### 1. New encounter subtypes follow the existing pattern

Each new encounter adds a string to `ENCOUNTER_SUBTYPES`, a branch in `EncounterRoom._build_panel()`, and a `_build_<name>()` method. The existing encounter room infrastructure handles setup, signals, and overlay management.

### 2. Encounter-specific enemies use a flag, not a separate pool

Encounter-specific enemies (Pickpocket, Robbers, Mimic) have `tier = "Small"` or `"Elite"` but an `encounter_only: bool = true` flag on the `Enemy` resource. The general `_load_enemy_pool()` filters these out. When an encounter triggers combat, it manually creates the enemy instance rather than drawing from the pool.

Alternative: Separate enemy pool. Rejected because it adds complexity for only 3 enemies that are already tied to specific encounters.

### 3. Mimic disguises as treasure_chest on the map

The Mimic room has `encounter_subtype = "mimic"` but displays as "treasure_chest" on the dungeon map (same icon/label). When the player enters and tries to claim the treasure, a combat trigger fires instead. The map tile reveals its true nature after the encounter is resolved.

### 4. Pickpocket revenge combat uses a deferred room insertion

When the player hits a Pickpocket encounter, the generator marks a future uncleared combat room on the same floor as a "pickpocket_revenge" room. The stolen gold amount is stored on `RunState`. When the player enters that room, a Pickpocket enemy spawns with the stored gold as its drop. If no suitable room exists (all cleared), the revenge room is skipped.

Implementation: `RunState` stores `pickpocket_stolen_gold: int` and `pickpocket_revenge_room_idx: int`. The Pickpocket encounter sets both. When entering the revenge room, `RunManager` checks for the flag and uses the Pickpocket enemy.

### 5. Head Trauma speed dodge checks technique/keystone tags

If the player owns any technique with "speed" tag or any keystone with `instant_arr` or `instant_soft_drop`, the Head Trauma encounter displays a "You dodge the falling rock!" message instead of removing a technique.

### 6. Final boss pool: floor 4 draws from a separate tier

A new tier `"FinalBoss"` is added. On floor 4, `_draw_enemy()` draws from `"FinalBoss"` instead of `"Boss"`. Final bosses have unique BossModifier effects:
- **The Mutant**: Two random normal boss modifiers applied simultaneously. The `BossModifier` resource has a `composite: bool` flag, and RunManager applies two randomly-selected normal boss modifiers.
- **The Titan**: `hp_multiplier: float = 2.0` and `attack_multiplier: float = 2.0` on BossModifier, applied to quota and garbage lines.
- **The Klepto**: `mastery_drain: int = 5` on BossModifier, applied at round start to reduce all mastery levels.
- **The Origin**: `scaling_per_kill: float` on BossModifier, applied as a quota multiplier based on `RunState.enemies_killed` (new counter).

### 7. New normal boss modifiers use existing BossModifier properties

- **The Ram**: `ignore_shields: bool = true` — garbage bypasses shield charges
- **The Jester**: `suppress_same_clear: bool = true` — if clear type matches previous, damage is zeroed
- **The Berserker**: `scaling_interval: bool = true` — garbage interval decreases as HP drops
- **The Forgotten**: `hidden_ui: bool = true` — HP bar, attack bar, and windup animation are hidden
- **The Furnace**: `fixed_interval: float = 5.0` — overrides garbage interval to a fixed 5 seconds

### 8. Enemy renames are display_name-only changes

Same as the balance pass pattern: `id` stays the same, `display_name` is updated. No legacy aliases needed since enemy IDs aren't saved.

### 9. Encounter UI text: hint at rewards, don't spell them out

Player-facing encounter descriptions SHALL use suggestive, atmospheric wording rather than explicit reward statements. The goal is discovery — the player learns what encounters do by experiencing them.

Examples:
- **Tutor**: *"A wise figure offers to share their knowledge..."* (not "Gain +2 in a random mastery")
- **Sleeping Beast**: *"A powerful creature slumbers nearby. You see the glint of treasure poking out behind them. Disturb it?"* (not "Fight for a technique and coins")
- **Laboratory**: *"Vials of strange substances line the shelves..."* (not "Take up to 3 consumables")
- **Demonic Deal**: *"A dark presence offers a bargain..."* (not "Trade 3 mastery levels for 150 coins")
- **Beggar**: *"A ragged figure holds out their hand..."* (not "Pay 50 gold for a random technique")
- **Map Room**: *"An old cartographer's desk, covered in dusty maps..."* (not "Reveal all fogged rooms")
- **Mimic**: Displays as a treasure chest — *"A gleaming chest sits in the center of the room..."*

Button labels follow the same principle: "Offer gold" not "Pay 50 for technique", "Investigate" not "Take consumables", "Accept" not "Gain +2 mastery".

### 10. Tutor grants +2 to a random mastery track

The Tutor encounter does not let the player choose a track. Instead it selects a random mastery track and grants +2 levels to it. The player sees which track was boosted after accepting.

## Risks / Trade-offs

**Pickpocket revenge room insertion** → Modifying the floor layout after generation adds complexity. If all rooms are cleared before the revenge room, the gold is simply lost. This is acceptable — the player made a choice.

**Mimic disguise** → The map rendering needs to check for the "mimic" subtype and display it as "treasure_chest". If the player has the Map Room encounter (reveals all fog), mimics are also revealed — this is intentional and rewarding.

**Composite boss (The Mutant)** → Stacking two boss modifiers could create broken combinations (e.g. The Reflection + The Blitz). Some combinations may need to be excluded. Start with all combinations allowed and tune later.

**The Origin scaling** → Requires a kill counter that doesn't currently exist. Simple to add to RunState, but the scaling factor needs tuning so it doesn't make the boss impossible for thorough explorers.
