extends GutTest

func before_each() -> void:
	Economy.reset()

# ── Base values ──────────────────────────────────────────────────────────

func test_starting_coins_is_30() -> void:
	assert_eq(RunState.STARTING_COINS, 30)

func test_base_payout_is_15() -> void:
	Economy.coins = 0
	Economy.pay_round(15)
	assert_eq(Economy.coins, 15)

# ── Spending ──────────────────────────────────────────────────────────────

func test_spend_coins_sufficient_balance_succeeds() -> void:
	Economy.coins = 10
	var result := Economy.spend_coins(7)
	assert_true(result)
	assert_eq(Economy.coins, 3)

func test_spend_coins_insufficient_balance_fails() -> void:
	Economy.coins = 7
	var result := Economy.spend_coins(10)
	assert_false(result)
	assert_eq(Economy.coins, 7)

func test_spend_exact_balance_succeeds() -> void:
	Economy.coins = 5
	var result := Economy.spend_coins(5)
	assert_true(result)
	assert_eq(Economy.coins, 0)

# ── pay_round ─────────────────────────────────────────────────────────────

func test_pay_round_credits_base_amount() -> void:
	Economy.coins = 0
	Economy.pay_round(7)
	assert_eq(Economy.coins, 7)

func test_pay_round_adds_to_existing_balance() -> void:
	Economy.coins = 10
	Economy.pay_round(4)
	assert_eq(Economy.coins, 14)
