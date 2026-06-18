class_name DungeonMap
extends Control

signal room_selected(room: DungeonRoom)

const CELL_SIZE := 72
const CELL_GAP := 4
const GRID_COLS := 6
const GRID_ROWS := 6

const COLOR_FOG       := Color(0.15, 0.15, 0.15, 1.0)
const COLOR_ACCESSIBLE := Color(0.85, 0.85, 0.85, 1.0)
const COLOR_CLEARED   := Color(0.35, 0.55, 0.35, 1.0)
const COLOR_BOSS      := Color(0.9, 0.3, 0.2, 1.0)
const COLOR_SHOP      := Color(0.3, 0.6, 0.9, 1.0)
const COLOR_START     := Color(0.3, 0.85, 0.5, 1.0)

var _floor_data: DungeonFloor = null
var _room_buttons: Array = []   # Array[Button] parallel to _floor_data.rooms

func setup(floor_data: DungeonFloor) -> void:
	_floor_data = floor_data
	_build_ui()

func _build_ui() -> void:
	for child in get_children():
		child.queue_free()
	_room_buttons.clear()

	var grid_w := GRID_COLS * CELL_SIZE + (GRID_COLS - 1) * CELL_GAP
	var grid_h := GRID_ROWS * CELL_SIZE + (GRID_ROWS - 1) * CELL_GAP

	var bg := ColorRect.new()
	bg.color = Color(0.08, 0.08, 0.1, 1.0)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var header := Label.new()
	header.text = "Floor %d — Choose your next room" % (_floor_data.floor_number if _floor_data else 1)
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.add_theme_font_size_override("font_size", 20)
	header.set_anchor_and_offset(SIDE_TOP, 0.0, 20.0)
	header.set_anchor_and_offset(SIDE_LEFT, 0.0, 0.0)
	header.set_anchor_and_offset(SIDE_RIGHT, 1.0, 0.0)
	header.set_anchor_and_offset(SIDE_BOTTOM, 0.0, 60.0)
	add_child(header)

	var grid_anchor := Control.new()
	grid_anchor.size = Vector2(grid_w, grid_h)
	grid_anchor.set_anchors_preset(Control.PRESET_CENTER)
	grid_anchor.offset_left  = -grid_w * 0.5
	grid_anchor.offset_right = grid_w * 0.5
	grid_anchor.offset_top   = -grid_h * 0.5
	grid_anchor.offset_bottom = grid_h * 0.5
	add_child(grid_anchor)

	if _floor_data == null:
		return

	var accessible := _floor_data.get_accessible_rooms()

	for i in range(_floor_data.rooms.size()):
		var room: DungeonRoom = _floor_data.rooms[i]
		var btn := _create_room_button(room, accessible, grid_anchor)
		_room_buttons.append(btn)

func _create_room_button(room: DungeonRoom, accessible: Array, parent: Control) -> Button:
	if room.tile_footprint.is_empty():
		return Button.new()

	var origin: Vector2i = room.tile_footprint[0]
	var px := origin.x * (CELL_SIZE + CELL_GAP)
	var py := origin.y * (CELL_SIZE + CELL_GAP)
	var pw := room.visual_size.x * CELL_SIZE + (room.visual_size.x - 1) * CELL_GAP
	var ph := room.visual_size.y * CELL_SIZE + (room.visual_size.y - 1) * CELL_GAP

	var btn := Button.new()
	btn.position = Vector2(px, py)
	btn.size = Vector2(pw, ph)
	btn.clip_text = true
	btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	var is_accessible := room in accessible
	var is_boss := room.room_type == DungeonRoom.TYPE_BOSS
	var is_start := room.room_type == DungeonRoom.TYPE_START

	if is_start:
		btn.text = "START"
		_tint(btn, COLOR_START)
		btn.disabled = true
	elif room.cleared:
		btn.text = _cleared_label(room)
		_tint(btn, COLOR_CLEARED)
		btn.disabled = true
	elif is_boss:
		btn.text = "BOSS\n(Floor %d)" % _floor_data.floor_number
		_tint(btn, COLOR_BOSS)
		btn.disabled = not is_accessible
		if is_accessible:
			btn.connect("pressed", _on_room_pressed.bind(room))
	elif is_accessible:
		btn.text = _accessible_label(room)
		_tint(btn, _accessible_color(room))
		btn.disabled = false
		btn.connect("pressed", _on_room_pressed.bind(room))
	else:
		btn.text = "???"
		_tint(btn, COLOR_FOG)
		btn.disabled = true

	parent.add_child(btn)
	return btn

func _accessible_label(room: DungeonRoom) -> String:
	match room.room_type:
		DungeonRoom.TYPE_COMBAT_SMALL, DungeonRoom.TYPE_COMBAT_BIG, DungeonRoom.TYPE_COMBAT_ELITE:
			return "Combat"
		DungeonRoom.TYPE_SHOP:          return "Shop"
		DungeonRoom.TYPE_ENCOUNTER:     return "?"
	return "?"

func _cleared_label(room: DungeonRoom) -> String:
	match room.room_type:
		DungeonRoom.TYPE_COMBAT_SMALL, DungeonRoom.TYPE_COMBAT_BIG, DungeonRoom.TYPE_COMBAT_ELITE:
			return "✓ Combat"
		DungeonRoom.TYPE_SHOP:          return "✓ Shop"
		DungeonRoom.TYPE_ENCOUNTER:     return "✓ ?"
		DungeonRoom.TYPE_START:         return "START"
	return "✓"

func _accessible_color(room: DungeonRoom) -> Color:
	match room.room_type:
		DungeonRoom.TYPE_SHOP:
			return COLOR_SHOP
	return COLOR_ACCESSIBLE

func _tint(btn: Button, color: Color) -> void:
	btn.add_theme_color_override("font_color", Color.BLACK if color.get_luminance() > 0.5 else Color.WHITE)
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	btn.add_theme_stylebox_override("normal", style)
	var disabled_style := StyleBoxFlat.new()
	disabled_style.bg_color = color.darkened(0.15)
	disabled_style.corner_radius_top_left = 4
	disabled_style.corner_radius_top_right = 4
	disabled_style.corner_radius_bottom_left = 4
	disabled_style.corner_radius_bottom_right = 4
	btn.add_theme_stylebox_override("disabled", disabled_style)

func _on_room_pressed(room: DungeonRoom) -> void:
	emit_signal("room_selected", room)
