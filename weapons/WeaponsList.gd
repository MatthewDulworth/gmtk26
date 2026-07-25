extends Node
class_name WeaponsList

@export var weapons: Array[WeaponData]
var weapons_ammo: Array[WeaponAmmo] = [];
var current_weapon: int = 0

func _ready() -> void:
	for weapon in weapons:
		weapons_ammo.push_back(WeaponAmmo.new(0, 0))

func initialize(_weapons: Array[WeaponData]) -> void:
	for weapon in _weapons:
		add_weapon(weapon)

func add_weapon(weapon: WeaponData) -> void:
	var index = weapons.find(weapon)
	if (index >= 0):
		weapons_ammo[index] = WeaponAmmo.new(weapon.num_mags, weapon.mag_size)

func switch_weapon(forwards: bool) -> WeaponSlot:
	var increment = 1 if forwards else -1
	var count = weapons_ammo.size()
	for i in range(1, count + 1):
		var index = (current_weapon + increment * i) % count
		if index < 0:
			index += count
		var ammo = weapons_ammo[index]
		if ammo.bullets_left > 0 or ammo.mags_left > 0:
			current_weapon = index
			return get_current_weapon()
	current_weapon = 0
	return get_current_weapon()

func get_current_weapon() -> WeaponSlot:
	return WeaponSlot.new(weapons[current_weapon], weapons_ammo[current_weapon])
