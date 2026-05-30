class_name AttackContext
extends Resource

@export var lines_cleared: int = 0
@export var combo: int = -1
@export var b2b: bool = false
@export var tspin: String = ""          # "", "mini", "single", "double", "triple"
@export var perfect_clear: bool = false
@export var garbage_sent: int = 0
@export var board_height: int = 0       # summit_height from TetrisBoard (0–20)
@export var held_this_piece: bool = false
@export var used_soft_drop: bool = false
@export var rotations_this_placement: int = 0
@export var locked_col: int = -1
@export var piece_placement_count: int = 0
@export var enemy_hp_pct: float = 1.0   # 0.0–1.0; used by Finisher
