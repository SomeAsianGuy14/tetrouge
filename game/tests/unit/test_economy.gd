extends GutTest

func before_each() -> void:
	Economy.reset()

# ── Interest ──────────────────────────────────────────────────────────────

func test_interest_on_12_coins_is_2() -> void:
	Economy.coins = 12
	var interest := Economy.apply_interest()
	assert_eq(interest, 2)
	assert_eq(Economy.coins, 14)

func test_interest_on_50_coins_capped_at_5() -> void:
	Economy.coins = 50
	var interest := Economy.apply_interest()
	assert_eq(interest, 5)
	assert_eq(Economy.coins, 55)

func test_interest_on_4_coins_is_0() -> void:
	Economy.coins = 4
	var interest := Economy.apply_interest()
	assert_eq(interest, 0)
	assert_eq(Economy.coins, 4)

func test_interest_cap_up_voucher_raises_cap() -> void:
	Economy.interest_cap = 8
	Economy.coins = 50
	var interest := Economy.apply_interest()
	assert_eq(interest, 8)

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
