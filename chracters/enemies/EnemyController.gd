extends CharacterBody2D
class_name EnemyController

@export var enemy_data: EnemyData
@export var health: Health
@export var hurtbox: HurtBox

const player_scan_time = 0.3 # Time in seconds until it scans for which player to chase

enum EnemyState {
	SPAWN,
	CHASE,
	ATTACK,
	DEAD,
}

func _ready() -> void:
	pass
	#health.initialize(enemy_data.max_health)

func _process(_delta: float) -> void:
	$AnimatedSprite2D.play("idle")

func _physics_process(_delta: float) ->  void:
	pass

func _spawn() -> void:
	pass
	
func _chase() -> void:
	pass
	
func _attack() -> void: 
	pass
	
func _dead() -> void:
	pass
