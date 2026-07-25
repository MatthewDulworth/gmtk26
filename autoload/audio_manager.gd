extends Node

const POOL_RESIZE_FACTOR := 1.5

#var end_stream = preload("res://Audio/end_theme.tres")

enum SFX {
	GOOSE_ATTACK, 
}

const AUDIO_DICT := {
	SFX.GOOSE_ATTACK: preload("res://ASSets/Audio/placeholder_sfx.mp3"),
}

@onready var main_player: AudioStreamPlayer = $MainPlayer
@onready var main_playback: AudioStreamPlaybackInteractive
@onready var theme_stream: AudioStreamSynchronized
@onready var _audio_player_pool: Node = $AudioPlayerPool
@onready var _free_audio_player_queue: Array[AudioStreamPlayer] = []
var deboog = true

@export var falloff_curve: CurveTexture
var _last_vol 
func _ready() -> void:
	_add_pool_members_to_audio_queue()
	SignalBus.player_died.connect(func(): deboog = false)
	
	main_player.play()
	theme_stream = main_player.stream.get_clip_stream(0) as AudioStreamSynchronized
	main_playback = main_player.get_stream_playback() as AudioStreamPlaybackInteractive
	

func _process(_delta: float) -> void:
	pass
	#var cur_scene_ID = SceneManager.get_current_scene_ID()
	#var x = black_hole_distance
	#
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
