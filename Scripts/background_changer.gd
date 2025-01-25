extends TextureRect

@export var won_background : Texture2D

func _ready() -> void:
	if State.has_won:
		texture = won_background
