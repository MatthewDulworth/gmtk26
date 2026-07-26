extends Node

const POOL_RESIZE_FACTOR := 3.0

#var end_stream = preload("res://Audio/end_theme.tres")

enum SFX {
	PLAYER_WALKING,
	PLAYER_DIED,
	PLAYER_FIRED_WEAPON,
	PLAYER_DAMAGED, 
	PLAYER_RELOADED, 
	PLAYER_SWITCHED_GUN, 
	PLAYER_PICKED_UP_GUN,
	PLAYER_PICKED_UP_FEATHER, 
	RELOADING,
	PICKED_UP_FEATHER,
	
	ENEMY_DIED,
	ENEMY_ATTACKED, 
	ENEMY_DAMAGED,
	ENEMY_WALKING, 
	ENEMY_SPAWNED,
	
	ENEMY_WAVE_STARTED,  
	ENEMY_WAVE_ENDED,
	
	ITEM_SPAWNED,
}

const AUDIO_DICT := {
	SFX.PLAYER_WALKING: preload("res://ASSets/Audio/placeholder/u_3x9ga8wevj-walking-sound-effect-272246.mp3"), 
	SFX.PLAYER_DIED: preload("res://ASSets/Audio/placeholder/universfield-male-scream-121085.mp3"),
	SFX.PLAYER_FIRED_WEAPON: preload("res://ASSets/Audio/placeholder/universfield-gunshot-352466.mp3"),
	SFX.PLAYER_DAMAGED: preload("res://ASSets/Audio/placeholder/frosted_52-ow-480197.mp3"),
	SFX.PLAYER_RELOADED: preload("res://ASSets/Audio/placeholder/chieuk-coin-257878.mp3"),
	SFX.PLAYER_SWITCHED_GUN: preload("res://ASSets/Audio/placeholder/freesound_community-pistol-gun-cock-89523.mp3"),
	SFX.PLAYER_PICKED_UP_GUN: preload("res://ASSets/Audio/placeholder/freesound_community-pistol-gun-cock-89523.mp3"),
	SFX.PLAYER_PICKED_UP_FEATHER: preload("res://ASSets/Audio/placeholder/chieuk-coin-257878.mp3"),
	SFX.RELOADING: preload("res://ASSets/Audio/placeholder/dragon-studio-gun-reload-511309.mp3"),
	
	SFX.ENEMY_DIED: preload("res://ASSets/Audio/placeholder/dragon-studio-car-honk-386166.mp3"),
	SFX.ENEMY_ATTACKED: preload("res://ASSets/Audio/placeholder/sumaga123-knife-432147.mp3"),
	SFX.ENEMY_DAMAGED: preload("res://ASSets/Audio/placeholder/dragon-studio-punch-431475.mp3"),
	SFX.ENEMY_WALKING: preload("res://ASSets/Audio/placeholder/freesound_community-duck-quacking-37392.mp3"),
	SFX.ENEMY_SPAWNED: preload("res://ASSets/Audio/placeholder_sfx.mp3"),
	
	SFX.ENEMY_WAVE_STARTED: preload("res://ASSets/Audio/placeholder/freesound_community-angry-elephant-40916.mp3"),
	SFX.ENEMY_WAVE_ENDED: preload("res://ASSets/Audio/placeholder/freesound_community-success-1-6297.mp3"),
	
	SFX.ITEM_SPAWNED: preload("res://ASSets/Audio/placeholder_sfx.mp3"),
	SFX.PICKED_UP_FEATHER: preload("res://ASSets/Audio/placeholder/chieuk-coin-257878.mp3"),
}

@onready var main_player: AudioStreamPlayer = $MainPlayer
@onready var main_playback: AudioStreamPlaybackInteractive
@onready var theme_stream: AudioStreamSynchronized
@onready var _audio_player_pool: Node = $AudioPlayerPool
@onready var _free_audio_player_queue: Array[AudioStreamPlayer] = []
var deboog = true

var player_walking_streams = {}
var enemy_walking_streams = {}
var reloading_stream: AudioStreamPlayer

func _ready() -> void:
	_add_pool_members_to_audio_queue()
	SignalBus.enemy_damaged.connect(func(current_health): play(SFX.ENEMY_DAMAGED))
	SignalBus.enemy_died.connect(_on_enemy_died)
	SignalBus.enemy_attacked.connect(func(): play(SFX.ENEMY_ATTACKED))
	SignalBus.enemy_spawned.connect(_on_enemy_spawn)
	SignalBus.player_picked_up_feather.connect(func(): play(SFX.PICKED_UP_FEATHER))
	
	SignalBus.player_damaged.connect(func(current_health): play(SFX.PLAYER_DAMAGED))
	SignalBus.player_died.connect(_on_player_died)
	
	SignalBus.player_fired_weapon.connect(_on_player_fired_weapon)
	SignalBus.started_reload.connect(_on_started_reload)
	SignalBus.reloaded.connect(_on_reloaded)
	
	SignalBus.player_switched_weapon.connect(func(): play(SFX.PLAYER_SWITCHED_GUN))
	
	SignalBus.player_started_walking.connect(_on_player_started_walking)
	SignalBus.player_stopped_walking.connect(_on_player_stopped_walking)
	SignalBus.enemy_started_walking.connect(_on_enemy_started_walking)
	SignalBus.enemy_stopped_walking.connect(_on_enemy_stopped_walking)
	
	SignalBus.wave_started.connect(func(): play(SFX.ENEMY_WAVE_STARTED))
	SignalBus.wave_ended.connect(func(): play(SFX.ENEMY_WAVE_ENDED))
	

	main_player.play()
	theme_stream = main_player.stream.get_clip_stream(0) as AudioStreamSynchronized
	main_playback = main_player.get_stream_playback() as AudioStreamPlaybackInteractive

# add weapon sfx types here
func _on_player_fired_weapon(weapon_data):
	play(SFX.PLAYER_FIRED_WEAPON)

func _on_enemy_started_walking(enemy):
	enemy_walking_streams[enemy] = play_loop(SFX.ENEMY_WALKING)

func _on_enemy_stopped_walking(enemy):
	stop_loop(enemy_walking_streams[enemy])

func _on_player_died(player):
	if player in player_walking_streams and player_walking_streams[player]: stop_loop(player_walking_streams[player])
	play(SFX.PLAYER_DIED)

func _on_enemy_spawn ():
	play(SFX.ENEMY_SPAWNED)
	#play_loop(SFX.ENEMY_WALKING)

func _on_enemy_died(enemy):
	if enemy_walking_streams[enemy]: 
		stop_loop(enemy_walking_streams[enemy])
	play(SFX.ENEMY_DIED)

func _on_started_reload(weapon_data: WeaponData):
	reloading_stream = play_loop(SFX.RELOADING)
	
func _on_reloaded(active: bool):
	stop_loop(reloading_stream)

func _on_player_started_walking(player):
	player_walking_streams[player] = play_loop(SFX.PLAYER_WALKING)
	
func _on_player_stopped_walking(player):
	stop_loop(player_walking_streams[player])


func _process(_delta: float) -> void:
	pass
	#var cur_scene_ID = SceneManager.get_current_scene_ID()
	#var x = black_hole_distance
	
	#if cur_scene_ID in SceneManager.LEVELS:
		#var cur_vol = falloff_curve.curve.sample(x)
		#
		#print(_last_vol, " : ", cur_vol)
		#if _last_vol and abs(_last_vol - cur_vol) > 10: 
			#print("too big")
			#if _last_vol < cur_vol:
				#cur_vol = _last_vol + 0.5
			#else: 
				#cur_vol = _last_vol - 0.5
#
		##theme_stream.set_sync_stream_volume(2, clampf(cur_vol, -80, 5))
		#theme_stream.set_sync_stream_volume(1, clampf(cur_vol, -80, 5))
		##theme_stream.set_sync_stream_volume(0, clampf(-cur_vol, -80, 5))
		#_last_vol = cur_vol
		##theme_stream.set_sync_stream_volume(1, dist)
		

## Plays the audio clip of the given name, optionally applies the given AudioPlayer params
func play(clip_name: SFX, params: Dictionary = {}) -> void:
	var audio_player = _get_and_start_audio_player(clip_name, params)
	
	await audio_player.finished
	_free_audio_player_queue.append(audio_player)

func play_loop(clip_name: SFX, params: Dictionary = {}) -> AudioStreamPlayer:
	return _get_and_start_audio_player(clip_name, params)
	
func stop_loop(player: AudioStreamPlayer)->void:
	player.stop()
	_free_audio_player_queue.append(player)
	
func _get_and_start_audio_player(clip_name: SFX, params: Dictionary = {})->AudioStreamPlayer:
	var audio_player: AudioStreamPlayer = _free_audio_player_queue.pop_front()
	
	if audio_player == null:
		push_warning("Tried playing audio with empty audio queue on frame %s. Perhaps increase the initial size of the audio player pool?" % Engine.get_frames_drawn())
		_increase_audio_player_pool_size()
		audio_player = _free_audio_player_queue.pop_front()
		
	var stream: AudioStream = AUDIO_DICT.get(clip_name)
	audio_player.stream = stream 
#
	## ----- Set Params then Play----- #
	if params.has("pitch"):
		audio_player.pitch_scale = params.pitch
		
	if params.has("volume"):
		audio_player.set_volume_db(params.volume)
	audio_player.play()
	
	return audio_player

func _increase_audio_player_pool_size()->void:
	var pool_size = _audio_player_pool.get_child_count()
	
	var num_new_audio_players: int = roundi((POOL_RESIZE_FACTOR * pool_size) - pool_size) + 1
	for i in range(num_new_audio_players):
		var new_audio_player := AudioStreamPlayer.new()
		_audio_player_pool.add_child(new_audio_player)
		_free_audio_player_queue.append(new_audio_player)
	
	push_warning("Audio player pool now has %s members!" % str(pool_size + num_new_audio_players))

func _add_pool_members_to_audio_queue():
	for i in range(_audio_player_pool.get_child_count()):
		var child = _audio_player_pool.get_child(i)
		if child is AudioStreamPlayer:
			_free_audio_player_queue.append(child)
		else: 
			push_error("AudioPlayerPool has a child %s node." % child.name)
