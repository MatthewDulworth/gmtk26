extends Node2D
class_name FloatingText

@onready var label: Label = $Label
@onready var anim_player: AnimationPlayer = $AnimationPlayer

var display: String = ""

func setup(new_display: String) -> void:
	display = new_display

func _ready() -> void:
	label.text = display
	anim_player.play("popup")
	anim_player.animation_finished.connect(func(_anim_name): queue_free())
