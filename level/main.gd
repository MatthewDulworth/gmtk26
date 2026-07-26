extends Node2D

@export var master_weapon_catalog: Array[WeaponData]
@export var weapon_pool: Array[WeaponData]
@export var enemy_scene: PackedScene
@export var players: Array[PlayerController]
@export var item_scene: PackedScene
@export var enemy_data_types: Array[EnemyData]
var _time_since_last_spawn := 0.0
var _time_since_wave_start := 0.0
var _time_since_last_item_spawn := 0.0

var kills := 0 :
	set(v):
		%KillsLabel.text =  "Kills  %d" % v
		kills = v

var _current_item_spawn_rate := 2.0
var _current_enemy_spawn_rate: float = 1.0
var _current_wave_length: float = 10.0

var _current_enemy_count:
	set(v):
		if v == 0:
			_current_wave += 1
			weapon_pool.append(master_weapon_catalog.pick_random())
		
		%EnemyCount.text = "Enemies: %d" % v
		_current_enemy_count = v

var _current_wave = 0: 
	set(v):
		if v - _current_wave == 1:
			SignalBus.wave_started.emit()
			%WaveBanner.scale = Vector2(1.0, 1.0)
			await get_tree().create_timer(2).timeout
			%WaveLabel.text = "Wave: %d" % v
			var tween := create_tween()
			tween.tween_property(%WaveBanner, "scale", Vector2(0, 0), 0.1)
			_current_wave_length += 1
			_current_enemy_spawn_rate -= 0.1
			_time_since_wave_start = 0
			_time_since_last_spawn = 0
			_current_wave = v
			
			
	get:
		return _current_wave

var down_collected = 10:
	set(v):
		%Down.text = "Count Down: %d" % v
		count_down_rate = clamp(2.0 / (1.0 + down_collected * 0.05), 0.1, 2.0)
		down_collected = v

var count_down_rate = 1.0 
var time_since_last_count_down = 0
	
func _on_down_collected(val):
	down_collected += val

func _ready() -> void:
	_current_enemy_count = 0
	SignalBus.player_picked_up_feather.connect(_on_down_collected)
	players.append($Player)
	if AudioManager.two_players == true:
		players.append($Player2)
	else: 
		$Player2.queue_free()


func _process(delta: float) -> void:
	if _time_since_last_item_spawn > _current_item_spawn_rate:
		var new_item = item_scene.instantiate()
		# set item data here for different weapons etc.
		new_item.position = $ItemSpawners.get_children().pick_random().position
		print("new item!")
		_time_since_last_item_spawn = 0
		
		
		SignalBus.item_spawned.emit()
		add_child(new_item)
	if time_since_last_count_down > count_down_rate:
			down_collected -= 1
			time_since_last_count_down = 0
	
	time_since_last_count_down += delta
	_time_since_last_item_spawn += delta
	
	if _time_since_wave_start > _current_wave_length:
		return
		
	
	if _time_since_last_spawn > _current_enemy_spawn_rate:
		var new_enemy: EnemyController = enemy_scene.instantiate()
		new_enemy.enemy_data = enemy_data_types.pick_random()
		new_enemy.players = players
		new_enemy.health.died.connect(_on_enemy_death)
		new_enemy.position = $EnemySpawners.get_children().pick_random().position
		_current_enemy_count += 1
		
		SignalBus.enemy_spawned.emit()
		add_child(new_enemy)
		
		_time_since_last_spawn = 0

	_time_since_last_spawn += delta
	_time_since_wave_start += delta



	
func _on_enemy_death():
	_current_enemy_count -= 1
	kills += 1
