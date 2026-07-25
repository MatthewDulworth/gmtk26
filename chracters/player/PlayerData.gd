extends Resource
class_name PlayerData

@export var max_health: float = 20.0
@export var move_speed: float = 200.0
@export var starting_weapons: Array[WeaponData]

@export var animation_name_die: String = "die"
@export var animation_name_move: String = "glide"
@export var animation_name_idle: String = "levitate"
