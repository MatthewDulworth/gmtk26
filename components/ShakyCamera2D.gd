extends Camera2D
class_name ShakyCamera2D

var _shake_amount: float = 0.0
var _shake_duration: float = 0.0
var _shake_time_left: float = 0.0

func shake(amount: float, duration: float = 0.3) -> void:
	_shake_amount = amount
	_shake_duration = duration
	_shake_time_left = duration

func _process(delta: float) -> void:
	if _shake_time_left <= 0.0:
		offset = Vector2.ZERO
		return

	_shake_time_left -= delta
	var pct = _shake_time_left / _shake_duration
	offset = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * _shake_amount * pct
