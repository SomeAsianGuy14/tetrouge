extends GutTest

# ── Standard 7-bag ────────────────────────────────────────────────────────

func test_all_7_types_appear_in_first_7_draws() -> void:
	var bag := BagRandomizer.new()
	var drawn := {}
	for _i in 7:
		drawn[bag.next()] = true
	for piece in PieceData.ALL_TYPES:
		assert_true(drawn.has(piece), "Missing piece type: " + piece)

func test_14_draws_each_type_appears_exactly_twice() -> void:
	var bag := BagRandomizer.new()
	var counts := {}
	for piece in PieceData.ALL_TYPES:
		counts[piece] = 0
	for _i in 14:
		counts[bag.next()] += 1
	for piece in PieceData.ALL_TYPES:
		assert_eq(counts[piece], 2, piece + " should appear exactly twice in 14 draws")

func test_peek_does_not_consume_pieces() -> void:
	var bag := BagRandomizer.new()
	var peeked := bag.peek(3)
	var first := bag.next()
	assert_eq(first, peeked[0], "First draw should match first peeked piece")

# ── Bag Shift (interval=5) ────────────────────────────────────────────────

func test_bag_shift_refills_after_5_draws() -> void:
	var bag := BagRandomizer.new(5)
	for _i in 5:
		bag.next()
	# After 5 draws the internal bag should be empty; 6th draw triggers refill
	assert_eq(bag._bag.size(), 0, "Bag should be empty after 5 draws with interval=5")
	var sixth := bag.next()  # triggers refill
	assert_true(sixth in PieceData.ALL_TYPES, "6th draw should be a valid piece type")

func test_standard_bag_has_7_items_after_init() -> void:
	var bag := BagRandomizer.new(7)
	# After init, bag has 7 items (or fewer if some were drawn during _refill)
	# peek forces the bag to be full
	bag.peek(7)
	assert_true(bag._bag.size() >= 7)

# ── Seeded determinism ────────────────────────────────────────────────────

func test_seeded_bag_produces_deterministic_sequence() -> void:
	var rng_a := RandomNumberGenerator.new()
	rng_a.seed = 42
	var rng_b := RandomNumberGenerator.new()
	rng_b.seed = 42

	var bag_a := BagRandomizer.new(7, rng_a)
	var bag_b := BagRandomizer.new(7, rng_b)

	var seq_a := []
	var seq_b := []
	for _i in 14:
		seq_a.append(bag_a.next())
		seq_b.append(bag_b.next())

	assert_eq(seq_a, seq_b, "Same-seeded bags should produce identical 14-draw sequences")
