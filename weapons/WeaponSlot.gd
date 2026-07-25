extends RefCounted
class_name WeaponSlot

var weapon: WeaponData
var ammo: WeaponAmmo

func _init(_weapon: WeaponData, _ammo: WeaponAmmo):
	weapon = _weapon
	ammo = _ammo
