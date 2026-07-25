class_name EnemySpawner
extends Marker2D

@export var enemy_scene: PackedScene

var _time_since_last_spawn = 0
var _time_since_wave_start = 0

@export var players: Array[PlayerController]

var enemy_count:
	set(v):
		if v == 0:
			current_wave += 1
		enemy_count = v

var current_spawn_rate: float = 1.0
var current_wave_length: float = 4.0
var current_wave = 0: 
	set(v):
		current_wave_length *= 1.1
		current_spawn_rate *= 0.9
		_time_since_wave_start = 0
		current_wave = v
	get:
		return current_wave


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	enemy_count = 0


func _process(delta: float) -> void:
	get_tree().create_timer(6).timeout.connect(_kill_all)
	print(enemy_count)
	if _time_since_wave_start > current_wave_length:
		#print("wave over")
		return
	
	#print("wave going")
	if _time_since_last_spawn > current_spawn_rate:
		var new_enemy: EnemyController = enemy_scene.instantiate()
		new_enemy.players = players
		new_enemy.position = Vector2(position.x + randf()*2, position.y + randf()*2)
		new_enemy.health.died.connect(_on_enemy_death)

		add_child(new_enemy)
		
		
		enemy_count += 1
		_time_since_last_spawn = 0

	_time_since_last_spawn += delta 
	_time_since_wave_start += delta
	

func _on_enemy_death():
	enemy_count -= 1
func _kill_all():
	for child in get_children():
		if child is EnemyController:
			child.health.take_damage(929348923)
			
