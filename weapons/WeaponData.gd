extends Resource
class_name WeaponData

@export var name: String = "gun"

@export var full_auto: bool = false
@export var fire_rate: float = 1.0
@export var damage: float = 1.0

@export var reload_time: float = 2.0
@export var active_reload_start: float = 1.25
@export var active_reload_end: float = 0.75

@export var num_bullets: int = 1
@export var bullet_spread: float = 0.0

@export var mag_size: int = 10
@export var num_mags: int = 999_999_999

@export var hitscan: bool = true
@export var hitscan_range: float = 1000.0
@export var bullet_speed: float
@export var bullet_radius: float
@export var bullet_lifetime: float = 2.0

@export var hit_explosion: bool = false
@export var hit_explosion_radius: float = 10.0
