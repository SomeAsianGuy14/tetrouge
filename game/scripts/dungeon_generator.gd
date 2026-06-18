class_name DungeonGenerator
extends RefCounted

const GRID_COLS := 6
const GRID_ROWS := 6

# Visual sizes available for interior rooms (w, h)
const ROOM_SIZES := [
	Vector2i(1, 1),
	Vector2i(1, 1),  # weighted: 1×1 most common
	Vector2i(1, 1),
	Vector2i(2, 1),
	Vector2i(1, 2),
	Vector2i(2, 2),
]

# Room type pool for interior rooms (shops placed separately to guarantee 2 per floor)
const INTERIOR_TYPES := [
	DungeonRoom.TYPE_COMBAT_SMALL,
	DungeonRoom.TYPE_COMBAT_BIG,
	DungeonRoom.TYPE_COMBAT_ELITE,
	DungeonRoom.TYPE_ENCOUNTER,
	DungeonRoom.TYPE_ENCOUNTER,
	DungeonRoom.TYPE_ENCOUNTER,
]

# Fallback template: a minimal connected layout used when generation retries exceed limit.
# Rooms: start → combat_small → shop → combat_big → combat_elite → boss
# Grid positions chosen to form a valid orthogonal path.
static func _build_fallback(floor_number: int) -> DungeonFloor:
	var df := DungeonFloor.new()
	df.floor_number = floor_number

	# Path: start(0,5)→(1,5)→(2,5)→(3,5)→(4,5)→(4,4)→(4,3)→(4,2)→boss(4,0)-(5,1)
	# (4,2) is orthogonally adjacent to boss tile (4,1), ensuring full connectivity.
	var positions: Array[Array] = [
		[Vector2i(0, 5)],                                                    # 0: start
		[Vector2i(1, 5)],                                                    # 1: combat_small
		[Vector2i(2, 5)],                                                    # 2: shop
		[Vector2i(3, 5)],                                                    # 3: combat_big
		[Vector2i(4, 5)],                                                    # 4: combat_elite
		[Vector2i(4, 4)],                                                    # 5: encounter
		[Vector2i(4, 3)],                                                    # 6: encounter
		[Vector2i(4, 2)],                                                    # 7: encounter
		[Vector2i(4, 0), Vector2i(5, 0), Vector2i(4, 1), Vector2i(5, 1)],  # 8: boss
	]
	var types := [
		DungeonRoom.TYPE_START,
		DungeonRoom.TYPE_COMBAT_SMALL,
		DungeonRoom.TYPE_SHOP,
		DungeonRoom.TYPE_COMBAT_BIG,
		DungeonRoom.TYPE_COMBAT_ELITE,
		DungeonRoom.TYPE_ENCOUNTER,
		DungeonRoom.TYPE_ENCOUNTER,
		DungeonRoom.TYPE_ENCOUNTER,
		DungeonRoom.TYPE_BOSS,
	]
	var subtypes := ["", "", "", "", "", "wishing_well", "library", "museum", ""]

	for i in range(positions.size()):
		var room := DungeonRoom.new()
		room.room_type = types[i]
		room.encounter_subtype = subtypes[i]
		var fp: Array[Vector2i] = []
		for v in positions[i]:
			fp.append(v)
		room.tile_footprint = fp
		room.visual_size = Vector2i(1, 1) if fp.size() == 1 else Vector2i(2, 2)
		if room.room_type == DungeonRoom.TYPE_START:
			room.cleared = true
		df.rooms.append(room)

	_compute_adjacency(df)
	return df

static func generate(floor_number: int, rng: RandomNumberGenerator) -> DungeonFloor:
	for attempt in range(10):
		var df := _attempt_generate(floor_number, rng)
		if df != null:
			return df
		# Offset rng state slightly so next attempt differs
		rng.randi()

	push_warning("DungeonGenerator: all retries failed, using fallback layout")
	return _build_fallback(floor_number)

static func _attempt_generate(floor_number: int, rng: RandomNumberGenerator) -> DungeonFloor:
	var df := DungeonFloor.new()
	df.floor_number = floor_number

	# ── Fixed rooms ───────────────────────────────────────────────────────────

	var start_room := DungeonRoom.new()
	start_room.room_type = DungeonRoom.TYPE_START
	start_room.tile_footprint = [Vector2i(0, 5)]
	start_room.visual_size = Vector2i(1, 1)
	start_room.cleared = true
	df.rooms.append(start_room)

	var boss_room := DungeonRoom.new()
	boss_room.room_type = DungeonRoom.TYPE_BOSS
	boss_room.tile_footprint = [Vector2i(4, 0), Vector2i(5, 0), Vector2i(4, 1), Vector2i(5, 1)]
	boss_room.visual_size = Vector2i(2, 2)
	df.rooms.append(boss_room)

	var occupied := {}
	for tile in start_room.tile_footprint:
		occupied[tile] = 0
	for tile in boss_room.tile_footprint:
		occupied[tile] = 1

	# ── Type pools ────────────────────────────────────────────────────────────
	var type_pool := INTERIOR_TYPES.duplicate()
	_seeded_shuffle(type_pool, rng)
	var encounter_pool := DungeonRoom.ENCOUNTER_SUBTYPES.duplicate()
	_seeded_shuffle(encounter_pool, rng)
	var encounter_idx := 0
	var type_idx := 0

	# ── Dual spine: two diverging paths give the player a genuine route choice ──
	# Both spines start from (0,5) and walk toward different boss-adjacent tiles.
	# Near start they share tiles (a trunk); further out they diverge through
	# different grid regions, creating a diamond/Y shape.
	var boss_entries: Array[Vector2i] = [Vector2i(3, 0), Vector2i(3, 1), Vector2i(4, 2)]
	_seeded_shuffle(boss_entries, rng)
	var spine_targets: Array[Vector2i] = [boss_entries[0], boss_entries[1]]
	var spine_room_indices: Array[Array] = [[], []]

	for spine_idx in range(2):
		var target: Vector2i = spine_targets[spine_idx]
		var pos := Vector2i(0, 5)
		while pos != target:
			var dx := signi(target.x - pos.x)
			var dy := signi(target.y - pos.y)
			var step: Vector2i
			if dx == 0:
				step = Vector2i(0, dy)
			elif dy == 0:
				step = Vector2i(dx, 0)
			elif rng.randi() % 2 == 0:
				step = Vector2i(dx, 0)
			else:
				step = Vector2i(0, dy)
			pos += step
			if not occupied.has(pos):
				var room := DungeonRoom.new()
				var is_first_room := (df.rooms.size() == 2)
				if is_first_room:
					room.room_type = DungeonRoom.TYPE_COMBAT_SMALL
				else:
					room.room_type = type_pool[type_idx % type_pool.size()]
					type_idx += 1
				room.tile_footprint = [pos]
				room.visual_size = Vector2i(1, 1)
				if room.room_type == DungeonRoom.TYPE_ENCOUNTER:
					room.encounter_subtype = encounter_pool[encounter_idx % encounter_pool.size()]
					encounter_idx += 1
				occupied[pos] = df.rooms.size()
				spine_room_indices[spine_idx].append(df.rooms.size())
				df.rooms.append(room)

	# ── Guarantee one shop per spine ──────────────────────────────────────────
	for spine_idx in range(2):
		var candidates: Array = []
		for idx in spine_room_indices[spine_idx]:
			var r: DungeonRoom = df.rooms[idx]
			if r.room_type != DungeonRoom.TYPE_START and r.room_type != DungeonRoom.TYPE_COMBAT_SMALL:
				candidates.append(idx)
		if not candidates.is_empty():
			var pick: int = candidates[rng.randi_range(0, candidates.size() - 1)]
			df.rooms[pick].room_type = DungeonRoom.TYPE_SHOP
			df.rooms[pick].encounter_subtype = ""

	# ── Branch rooms: grown from existing rooms for extra variety ─────────────
	var branch_target := rng.randi_range(1, 2)
	var branch_placed := 0
	var branch_attempts := 100
	var offsets: Array[Vector2i] = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]

	while branch_placed < branch_target and branch_attempts > 0:
		branch_attempts -= 1

		var frontier: Array[Vector2i] = []
		for room in df.rooms:
			for tile: Vector2i in room.tile_footprint:
				for off: Vector2i in offsets:
					var nb: Vector2i = tile + off
					if nb.x >= 0 and nb.x < GRID_COLS and nb.y >= 0 and nb.y < GRID_ROWS \
							and not occupied.has(nb) and not (nb in frontier):
						frontier.append(nb)

		if frontier.is_empty():
			break

		var anchor: Vector2i = frontier[rng.randi_range(0, frontier.size() - 1)]

		var size_options := ROOM_SIZES.duplicate()
		_seeded_shuffle(size_options, rng)
		for size: Vector2i in size_options:
			var fp: Array[Vector2i] = []
			var conflict := false
			for dy in range(size.y):
				for dx in range(size.x):
					var tile: Vector2i = anchor + Vector2i(dx, dy)
					if tile.x >= GRID_COLS or tile.y >= GRID_ROWS or occupied.has(tile):
						conflict = true
						break
				if conflict:
					break
			if conflict:
				continue
			for dy in range(size.y):
				for dx in range(size.x):
					fp.append(anchor + Vector2i(dx, dy))
			var room := DungeonRoom.new()
			room.room_type = type_pool[type_idx % type_pool.size()]
			room.tile_footprint = fp
			room.visual_size = size
			if room.room_type == DungeonRoom.TYPE_ENCOUNTER:
				room.encounter_subtype = encounter_pool[encounter_idx % encounter_pool.size()]
				encounter_idx += 1
			for tile in fp:
				occupied[tile] = df.rooms.size()
			df.rooms.append(room)
			type_idx += 1
			branch_placed += 1
			break

	# ── Adjacency and validation ──────────────────────────────────────────────
	_compute_adjacency(df)
	_cull_unreachable_rooms(df)
	if not _bfs_connected(df):
		return null

	return df

static func _cull_unreachable_rooms(df: DungeonFloor) -> void:
	var start_idx := -1
	for i in range(df.rooms.size()):
		if df.rooms[i].room_type == DungeonRoom.TYPE_START:
			start_idx = i
			break
	if start_idx < 0:
		return

	var visited: Dictionary = {}
	var queue: Array = [start_idx]
	visited[start_idx] = true
	while not queue.is_empty():
		var current: int = queue.pop_front()
		for adj in df.rooms[current].adjacency:
			if not visited.has(adj):
				visited[adj] = true
				queue.append(adj)

	# Remove unreachable rooms in reverse order to keep valid indices while iterating.
	for i in range(df.rooms.size() - 1, -1, -1):
		if not visited.has(i):
			df.rooms.remove_at(i)

	# Rebuild adjacency from tile footprints with the new indices.
	_compute_adjacency(df)

static func _compute_adjacency(df: DungeonFloor) -> void:
	var n := df.rooms.size()
	for i in range(n):
		df.rooms[i].adjacency.clear()

	# Build tile → room index lookup
	var tile_to_room: Dictionary = {}
	for i in range(n):
		for tile in df.rooms[i].tile_footprint:
			tile_to_room[tile] = i

	var offsets: Array[Vector2i] = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]

	for i in range(n):
		for tile: Vector2i in df.rooms[i].tile_footprint:
			for off: Vector2i in offsets:
				var neighbor_tile: Vector2i = tile + off
				if tile_to_room.has(neighbor_tile):
					var j: int = tile_to_room[neighbor_tile]
					if j != i and not (j in df.rooms[i].adjacency):
						df.rooms[i].adjacency.append(j)
						if not (i in df.rooms[j].adjacency):
							df.rooms[j].adjacency.append(i)

static func _bfs_connected(df: DungeonFloor) -> bool:
	var start_idx := -1
	var boss_idx := -1
	for i in range(df.rooms.size()):
		if df.rooms[i].room_type == DungeonRoom.TYPE_START:
			start_idx = i
		elif df.rooms[i].room_type == DungeonRoom.TYPE_BOSS:
			boss_idx = i

	if start_idx < 0 or boss_idx < 0:
		return false

	var visited := {}
	var queue := [start_idx]
	visited[start_idx] = true

	while not queue.is_empty():
		var current: int = queue.pop_front()
		if current == boss_idx:
			return true
		for adj in df.rooms[current].adjacency:
			if not visited.has(adj):
				visited[adj] = true
				queue.append(adj)

	return false

static func _seeded_shuffle(arr: Array, rng: RandomNumberGenerator) -> void:
	var i := arr.size() - 1
	while i > 0:
		var j := rng.randi_range(0, i)
		var tmp = arr[i]
		arr[i] = arr[j]
		arr[j] = tmp
		i -= 1
