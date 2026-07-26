extends Resource
class_name EnemyData

@export var max_health: float = 1.0
@export var move_speed: float = 200.0
@export var count_down_value: int = 1 # Value of killing this goose
@export var mass: float = 1.0 # Higher number reduces knockback

@export var animation_name_move: String = "run"
@export var animation_name_die: String = "death"
@export var animation_name_attack: String = "attack"
@export var animation_name_feather: String = "down_feather"
@export var feather_bounce_till_despawn: int = 20

@export var attack_range: float = 1.0
@export var attack_damage: float = 1.0
@export var attack_cooldown: float = 1.0   # (seconds) Time between attack animations
@export var attack_duration: float = 0.5   # (seconds) Time of attack animation

@export var size_scale: float = 1.0

@export var item_drop_scene: PackedScene = preload("res://item/Item.tscn")
@export_range(0.0, 100.0, 1.0, "suffix:%") var drop_rate: float = 100.0 # 50% chance to drop
