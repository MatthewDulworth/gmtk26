extends CanvasLayer

@export var active_effect: int = -1:
	set(value):
		active_effect = value
		_apply()

var _effects: Array[ColorRect] = []

func _ready() -> void:
	for child in get_children():
		if child is ColorRect:
			_effects.append(child)
	_apply()

func _apply() -> void:
	for i in _effects.size():
		_effects[i].visible = i == active_effect

func _unhandled_key_input(event: InputEvent) -> void:
	if not event.pressed or event.echo:
		return

	if event.keycode == KEY_BRACKETRIGHT:
		active_effect = wrapi(active_effect + 1, -1, _effects.size())
	elif event.keycode == KEY_BRACKETLEFT:
		active_effect = wrapi(active_effect - 1, -1, _effects.size())
	elif event.keycode >= KEY_0 and event.keycode <= KEY_9:
		if event.keycode == KEY_0:
			active_effect = -1
		else:
			var index: int = int(event.keycode) - int(KEY_0) - 1
			if index < _effects.size():
				active_effect = index
