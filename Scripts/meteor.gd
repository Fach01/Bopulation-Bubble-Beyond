extends Node2D

@export var min_value : float = 10 
@export var max_value : float = 30

@export var fall_duration : float = 5

@export var max_level_multiplier : float = 8

var value
var tween

func _ready() -> void:
	position = Vector2.from_angle(randf_range(0,TAU)) * randf_range(State.spawn_min_radius, State.spawn_min_radius * pow(State.spawn_radius_multiplier, State.bubble_level))
	var level = inverse_lerp(1,State.max_bubble_upgrades, State.bubble_level)
	scale = Vector2.ONE * lerp(3.0, max_level_multiplier, level)
	value = randf_range(min_value, max_value) * level * max_level_multiplier

	tween = create_tween()
	tween.finished.connect(func() :
		State.resource -= value
		queue_free()
		)
	tween.tween_property(self, "scale", Vector2.ONE, fall_duration)

func clicked(_viewport, event, _shape_idx):

	print("pressed!")
	if(event.is_pressed()):
		State.resource += value
		tween.kill()
		queue_free()
