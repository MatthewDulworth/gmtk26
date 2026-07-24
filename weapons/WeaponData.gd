extends Resource
class_name WeaponData

@export var name: String = "gun"

@export var full_auto: bool = false
@export var fire_rate: float = 1.0
@export var damage: float = 1.0

@export var mag_size: int = 10
@export var num_mags: int = 999_999_999

@export var hitscan: bool = true
@export var bullet_speed: float
@export var bullet_radius: float
