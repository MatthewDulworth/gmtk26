extends Resource
class_name EnemyData

@export var max_health: float = 1.0
@export var move_speed: float = 200.0
@export var move_animation_name: String = "run"

@export var attack_range: float = 1.0
@export var attack_damage: float = 1.0
@export var attack_cooldown: float = 1.0   # (seconds) Time between attack animations
@export var attack_duration: float = 0.5   # (seconds) Time of attack animation

@export var size_scale: float = 1.0
