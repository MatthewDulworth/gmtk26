extends CharacterBody2D
class_name EnemyController

@export var enemy_data: EnemyData
@export var health: Health
@export var hurtbox: HurtBox

@onready var nav_agent_2d = $NavigationAgent2D

var players: Array[PlayerController]

var target: Vector2

const player_scan_time = 0.3 # Time in seconds until it scans for which player to chase

enum EnemyState {
	SPAWN,
	CHASE,
	ATTACK,
	DEAD,
}

func _ready() -> void:
	target = Vector2(100, 100)
	nav_agent_2d.set_target_position(target)
	#health.initialize(enemy_data.max_health)

func _process(_delta: float) -> void:
	if (position.distance_to(target)) <= 1.0:
		velocity = Vector2(0, 0)
		position = target
		$AnimatedSprite2D.play("flap")
	
func _physics_process(_delta: float) ->  void:
	if (position.distance_to(target)) > 0.5:
		$AnimatedSprite2D.play("run")
		var pos = global_transform.origin
		var new_pos = nav_agent_2d.get_next_path_position()
		var new_vel = (new_pos - pos).normalized() * 100; # speed
		velocity = new_vel
		move_and_slide()
		

func _spawn() -> void:
	pass
	
func _chase() -> void:
	pass
	
func _attack() -> void: 
	pass
	
func _dead() -> void:
	pass
