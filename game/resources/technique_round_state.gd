class_name TechniqueRoundState
extends RefCounted

var clears_this_round: int = 0
var attack_events_this_round: int = 0
var total_garbage_sent: int = 0
var tspin_count: int = 0
var b2b_count: int = 0
var perfect_clear_count: int = 0
var pieces_placed: int = 0
var tetris_count: int = 0
var last_clear_was_tetris: bool = false

# One-shot pending flags (set by evaluator or RunManager, consumed on trigger)
var follow_up_pending: bool = false       # Follow-Up: next clear gets +1
var tetris_echo_pending: bool = false     # Tetris Echo: next non-tetris gets +1
var escalation_pending: bool = false      # Escalation: next attack gets +2
var after_receive_pending: bool = false   # Counter Strike: next attack after garbage +2
var patience_pending: bool = false        # Patience: next clear +1 after hold
var patience_cooldown_pieces: int = 0     # Patience cooldown counter
var constant_pressure_pending: bool = false  # Constant Pressure: locked within 1s
var flow_step_pending: bool = false       # Flow Step: 4 pieces without rotating
var no_rotate_streak: int = 0            # consecutive pieces placed without rotating
var good_planning_pending: bool = false   # Good Planning: 5 pieces without hold
var good_planning_consecutive_no_hold: int = 0  # consecutive pieces without hold
var switch_up_armed: bool = false         # Switch-Up: previous piece was hard-dropped

# Used flags (prevent double-triggering within a round)
var opening_blow_used: bool = false
var combo_payout_used: bool = false
