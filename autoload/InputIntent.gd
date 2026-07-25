extends RefCounted
class_name InputIntent

var move: Vector2
var facing: Vector2
var fire_held: bool
var fire_just_pressed: bool
var reload: bool
var next: bool
var prev: bool

func _init(
	_move: Vector2, 
	_facing: Vector2, 
	_fire_held: bool, 
	_fire_just_pressed, 
	_reload: bool, 
	_next: bool, 
	_prev: bool,
):
	move = _move
	fire_held = _fire_held
	fire_just_pressed = _fire_just_pressed
	facing = _facing
	reload = _reload
	next = _next
	prev = _prev
