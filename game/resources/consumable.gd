class_name Consumable
extends Resource

enum UseTiming { ROUND_START, DURING_ROUND, ANYTIME }

@export var id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var cost: int = 4
@export var use_timing: UseTiming = UseTiming.ANYTIME

# Effect flags (RunManager/TetrisBoard reads these on use)
@export var clears_board: bool = false         # Clean Slate
@export var guarantees_next_t: bool = false    # Piece Lock
@export var adds_time: float = 0.0            # Time Shard (seconds)
@export var adds_coins: int = 0               # Coin Purse
@export var attack_surge_clears: int = 0      # Attack Surge (next N clears double)
