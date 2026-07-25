extends Node2D
class_name WeaponHUD

const PIP_SIZE := Vector2(6, 10)
const PIP_SPACING := 9.0
const PIP_LIT_COLOR := Color(1.0, 0.85, 0.1)
const PIP_EMPTY_COLOR := Color(0.3, 0.3, 0.3, 0.6)
const MAG_GAP := 8.0
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

func _ready() -> void:
	weapon.ammo_changed.connect(_on_ammo_changed)
	weapon.reloaded.connect(_on_reloaded)
	reload_bar.visible = false

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

	var pip_row_width = max(current_slot.weapon.mag_size - 1, 0) * PIP_SPACING + PIP_SIZE.x
	pip_row.position.x = -pip_row_width / 2.0
	mag_label.position.x = pip_row_width / 2.0 + MAG_GAP

	for i in current_slot.weapon.mag_size:
		var pip := ColorRect.new()
		pip.size = PIP_SIZE
		pip.position = Vector2(i * PIP_SPACING, 0)
		pip_row.add_child(pip)
		pips.append(pip)

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

	# Draw the highlight a bit narrower than the real accept window (VISUAL_WINDOW_SHRINK),
	# centered on the same midpoint, so success feels slightly more generous than it looks.
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
