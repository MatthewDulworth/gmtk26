extends Node2D
class_name WeaponHUD

const PIP_SIZE := Vector2(6, 10)
const PIP_SPACING := 9.0
const PIP_LIT_COLOR := Color(1.0, 0.85, 0.1)
const PIP_EMPTY_COLOR := Color(0.3, 0.3, 0.3, 0.6)
const MAG_GAP := 8.0
const MAX_ROW_WIDTH := 100.0
const MAX_PIP_ROWS := 3
const MIN_PIP_SCALE := 0.5
const PIP_ROW_GAP := 4.0
const INFINITE_MAGS_THRESHOLD := 1_000_000
const RELOAD_TRACK_WIDTH := 60.0
const VISUAL_WINDOW_SHRINK := 0.7

@export var weapon: Weapon

@onready var weapon_name_label: Label = $WeaponNameLabel
@onready var pip_row: Node2D = $PipRow
@onready var mag_label: Label = $MagLabel
@onready var reload_bar: Node2D = $ReloadBar
@onready var reload_active_window: ColorRect = $ReloadBar/ActiveWindow
@onready var reload_cursor: ColorRect = $ReloadBar/Cursor

var current_slot: WeaponSlot
var pips: Array[ColorRect] = []
var _name_label_base_y: float

func _ready() -> void:
	weapon.ammo_changed.connect(_on_ammo_changed)
	weapon.reloaded.connect(_on_reloaded)
	reload_bar.visible = false
	_name_label_base_y = weapon_name_label.position.y

func bind(slot: WeaponSlot) -> void:
	current_slot = slot
	weapon_name_label.text = current_slot.weapon.name
	_rebuild_pips()
	_on_ammo_changed()
	_update_active_window()

func _rebuild_pips() -> void:
	for pip in pips:
		pip.queue_free()
	pips.clear()

	var mag_size = current_slot.weapon.mag_size
	pip_row.position = Vector2.ZERO

	var pips_per_row_at_full_size = max(int((MAX_ROW_WIDTH - PIP_SIZE.x) / PIP_SPACING) + 1, 1)
	var rows = clampi(int(ceil(float(mag_size) / pips_per_row_at_full_size)), 1, MAX_PIP_ROWS)

	var scale = 1.0
	if rows > 1 and MAX_PIP_ROWS > 1:
		scale = lerp(1.0, MIN_PIP_SCALE, float(rows - 1) / float(MAX_PIP_ROWS - 1))

	var columns = int(ceil(float(mag_size) / rows))

	var full_row_width = max(columns - 1, 0) * (PIP_SPACING * scale) + PIP_SIZE.x * scale
	if full_row_width > MAX_ROW_WIDTH:
		scale = max(scale * MAX_ROW_WIDTH / full_row_width, MIN_PIP_SCALE)

	var pip_size = PIP_SIZE * scale
	var spacing = PIP_SPACING * scale
	var row_height = pip_size.y + PIP_ROW_GAP

	var bottom_y = PIP_SIZE.y / 2.0

	var max_row_width = max(columns - 1, 0) * spacing + pip_size.x
	mag_label.position.x = max_row_width / 2.0 + MAG_GAP

	var index = 0
	for row in rows:
		var pips_in_row = min(columns, mag_size - index)
		var row_width = max(pips_in_row - 1, 0) * spacing + pip_size.x
		var start_x = -row_width / 2.0
		var row_center_y = bottom_y - pip_size.y / 2.0 - row * row_height
		for col in pips_in_row:
			var pip := ColorRect.new()
			pip.size = pip_size
			pip.position = Vector2(start_x + col * spacing, row_center_y)
			pip_row.add_child(pip)
			pips.append(pip)
			index += 1

	var block_top = bottom_y - rows * pip_size.y - (rows - 1) * PIP_ROW_GAP
	var single_row_top = bottom_y - PIP_SIZE.y
	var extra_rise = max(0.0, single_row_top - block_top)
	weapon_name_label.position.y = _name_label_base_y - extra_rise

func _on_ammo_changed() -> void:
	if current_slot == null: return
	for i in pips.size():
		pips[i].color = PIP_LIT_COLOR if i < current_slot.ammo.bullets_left else PIP_EMPTY_COLOR

	var infinite_mags = current_slot.ammo.mags_left >= INFINITE_MAGS_THRESHOLD
	mag_label.visible = not infinite_mags
	if not infinite_mags:
		mag_label.text = str(current_slot.ammo.mags_left)

func _on_reloaded(_active: bool) -> void:
	_on_ammo_changed()

func _update_active_window() -> void:
	var reload_time = current_slot.weapon.reload_time
	if reload_time <= 0: return

	var window_start_pct = clamp((reload_time - current_slot.weapon.active_reload_start) / reload_time, 0.0, 1.0)
	var window_end_pct = clamp((reload_time - current_slot.weapon.active_reload_end) / reload_time, 0.0, 1.0)


	var center_pct = (window_start_pct + window_end_pct) / 2.0
	var visual_width_pct = (window_end_pct - window_start_pct) * VISUAL_WINDOW_SHRINK

	reload_active_window.position.x = RELOAD_TRACK_WIDTH * (center_pct - visual_width_pct / 2.0)
	reload_active_window.size.x = RELOAD_TRACK_WIDTH * visual_width_pct

func _process(_delta: float) -> void:
	if current_slot == null: return

	reload_bar.visible = weapon.reloading
	pip_row.visible = not weapon.reloading
	if weapon.reloading:
		var reload_time = current_slot.weapon.reload_time
		var elapsed = reload_time - weapon.reload_timer.time_left
		var pct = clamp(elapsed / reload_time, 0.0, 1.0)
		reload_cursor.position.x = RELOAD_TRACK_WIDTH * pct
		reload_active_window.visible = not weapon.tried_active_reload
