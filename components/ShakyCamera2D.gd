extends Camera2D
class_name ShakyCamera2D

@export var players: Array[PlayerController]

@export var single_player_zoom: float = 1.0 # Zoom level when following a single player
@export var max_zoom_out: float = 0.5 # Smallest zoom value allowed (how far out the camera can go)
@export var zoom_margin: float = 250.0 # Padding (px) kept around the players' bounding box
@export var follow_smoothing_speed: float = 5.0
@export var follow_zoom_smoothing_speed: float = 3.0

var _shake_amount: float = 0.0
var _shake_duration: float = 0.0
var _shake_time_left: float = 0.0

func shake(amount: float, duration: float = 0.3) -> void:
	_shake_amount = amount
	_shake_duration = duration
	_shake_time_left = duration

func _process(delta: float) -> void:
	_follow_players(delta)
	_update_shake(delta)

func _follow_players(delta: float) -> void:
	var alive_players = players.filter(func(p): return p.state == PlayerController.PlayerState.ALIVE)
	if alive_players.is_empty():
		return

	var target_position: Vector2
	var target_zoom: float

	if alive_players.size() == 1:
		target_position = alive_players[0].global_position
		target_zoom = single_player_zoom
	else:
		var bounds = Rect2(alive_players[0].global_position, Vector2.ZERO)
		for player in alive_players:
			bounds = bounds.expand(player.global_position)

		target_position = bounds.get_center()

		var viewport_size = get_viewport_rect().size
		var zoom_to_fit_x = viewport_size.x / (bounds.size.x + zoom_margin * 2.0)
		var zoom_to_fit_y = viewport_size.y / (bounds.size.y + zoom_margin * 2.0)
		target_zoom = clamp(min(zoom_to_fit_x, zoom_to_fit_y), max_zoom_out, single_player_zoom)

	global_position = global_position.lerp(target_position, follow_smoothing_speed * delta)
	zoom = zoom.lerp(Vector2.ONE * target_zoom, follow_zoom_smoothing_speed * delta)

func _update_shake(delta: float) -> void:
	if _shake_time_left <= 0.0:
		offset = Vector2.ZERO
		return

	_shake_time_left -= delta
	var pct = _shake_time_left / _shake_duration
	offset = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * _shake_amount * pct
