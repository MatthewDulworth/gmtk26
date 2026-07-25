extends Node2D
class_name FloatingText

@onready var label: Label = $Label
@onready var anim_player: AnimationPlayer = $AnimationPlayer

var display_amount: int = 1

func setup(value_to_display: int) -> void:
	display_amount = value_to_display

func _ready() -> void:
	label.text = "+" + str(display_amount)
	anim_player.play("popup")
	anim_player.animation_finished.connect(func(_anim_name): queue_free())
