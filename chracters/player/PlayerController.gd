extends CharacterBody2D
class_name PlayerController

@export var player_data: PlayerData
@export var health: Health

func _ready() -> void:
	health.initialize(player_data.max_health)

func _process(_delta: float) -> void:
	pass
	
func _physics_process(_delta: float) -> void:
	pass
	
