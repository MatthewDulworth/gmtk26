extends RefCounted
class_name WeaponAmmo

var bullets_left: int
var mags_left: int

func _init(_mags_left: int, _bullets_left: int):
	mags_left = _mags_left
	bullets_left = _bullets_left
