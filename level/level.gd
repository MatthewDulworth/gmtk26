extends Node2D

@export var enemy_scene: PackedScene
@export var players: Array[PlayerController]
@export var item_scene: PackedScene
var _time_since_last_spawn := 0.0
var _time_since_wave_start := 0.0
var _time_since_last_item_spawn := 0.0

var kills := 0 :
	set(v):
		$KillsLabel.text =  "Kills  %d" % v
		kills = v

var _current_item_spawn_rate := 2.0
var _current_enemy_spawn_rate: float = 1.0
var _current_wave_length: float = 10.0

var _current_enemy_count:
	set(v):
		if v == 0:
			_current_wave += 1
		
		$EnemyCount.text = "Enemies: %d" % v
		_current_enemy_count = v

var _current_wave = 0: 
	set(v):
		$WaveLabel.text = "Wave: %d" % v
		_current_wave_length += 1
		_current_enemy_spawn_rate -= 0.1
		_time_since_wave_start = 0
		_time_since_last_spawn = 0
		_current_wave = v
	get:
		return _current_wave

func _ready() -> void:
	_current_enemy_count = 0

func _process(delta: float) -> void:
	if _time_since_last_item_spawn > _current_item_spawn_rate:
		var new_item = item_scene.instantiate()
		# set item data here for different weapons etc.
		new_item.position = $ItemSpawners.get_children().pick_random().position
		print("new item!")
		_time_since_last_item_spawn = 0
		add_child(new_item)
		
	_time_since_last_item_spawn += delta
	
	if _time_since_wave_start > _current_wave_length:
		return
	
	if _time_since_last_spawn > _current_enemy_spawn_rate:
		var new_enemy: EnemyController = enemy_scene.instantiate()
		new_enemy.players = players
		new_enemy.health.died.connect(_on_enemy_death)
		new_enemy.position = $EnemySpawners.get_children().pick_random().position
		_current_enemy_count += 1
		add_child(new_enemy)
		
		_time_since_last_spawn = 0

	_time_since_last_spawn += delta
	_time_since_wave_start += delta


	
func _on_enemy_death():
	_current_enemy_count -= 1
	kills += 1
