extends CharacterBody2D
class_name EnemyController

@export var enemy_data: EnemyData
@export var health: Health
@export var hurtbox: HurtBox
@export var players: Array[PlayerController]

var target: Vector2

const player_scan_time = 0.3 # Time in seconds until it scans for which player to chase

@onready var nav_agent_2d = $NavigationAgent2D

enum EnemyState {
	SPAWN,
	CHASE,
	ATTACK,
	DEAD,
}

func _ready() -> void:
	targetPlayer()
	scale = scale * enemy_data.size_scale;
	health.died.connect(func(): queue_free())
	health.initialize(enemy_data.max_health)

func _process(_delta: float) -> void:
	targetPlayer()
	facePlayer()
	if (position.distance_to(target)) <= 1.0:
		velocity = Vector2(0, 0)
		position = target
		$AnimatedSprite2D.play("flap")
	
func _physics_process(_delta: float) ->  void:
	if (position.distance_to(target)) > 0.5:
		$AnimatedSprite2D.play("run")
		var pos = global_transform.origin
		var new_pos = nav_agent_2d.get_next_path_position()
		var new_vel = (new_pos - pos).normalized() * enemy_data.move_speed; # speed
		velocity = new_vel
		move_and_slide()
		
func targetPlayer():
	target = Vector2(getClosestPlayer().position)
	nav_agent_2d.set_target_position(target)
	
func chooseAnimation():
	if velocity == Vector2(0, 0):
		$AnimatedSprite2D.play("flap")

func getClosestPlayer():
	var closestPlayer
	var closestPlayerDistance = INF
	for player: PlayerController in players:
		var distance_to_player = position.distance_to(player.position)
		if distance_to_player < closestPlayerDistance:
			closestPlayerDistance = distance_to_player
			closestPlayer = player
	return closestPlayer

func getIsClosestPlayerToTheRight() -> bool:
	var player = getClosestPlayer()
	return player.position.x > position.x

func facePlayer():
	if getIsClosestPlayerToTheRight():
		$AnimatedSprite2D.flip_h = 0
	else:
		$AnimatedSprite2D.flip_h = -1

func _spawn() -> void:
	pass
	
func _chase() -> void:
	pass
	
func _attack() -> void: 
	pass
	
func _dead() -> void:
	pass
