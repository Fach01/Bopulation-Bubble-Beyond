class_name Unit
extends Node2D

@export var speed : float
@export var resource_manager : Node
@export var home_base : Home_Base

var current_target : Node2D
var carrying : float

var tween : Tween

func _ready() -> void:
	select_new_node()
	

func select_new_node():
	if tween != null :
		tween.kill()
	print("selecting new node")
	current_target = null
	var dist : float = TYPE_MAX

	for a in resource_manager.get_children():
		if a.is_queued_for_deletion() || pow(State.bubble_init_scale * pow(State.spawn_radius_multiplier, State.bubble_level),2) * 1024 < Vector2.ZERO.distance_squared_to(a.global_position): continue

		if current_target == null:
			current_target = a
			dist = global_position.distance_squared_to(a.global_position) + randf_range(-30,30)
		else:
			var new_dist = global_position.distance_squared_to(a.global_position)
			if dist > new_dist:
				current_target = a
				dist = new_dist
	
	if current_target == null:
		await get_tree().create_timer(randf() * 0.5).timeout
		select_new_node()
		return
	

	current_target.tree_exiting.connect(func() : 
		tween.kill()
		select_new_node.call_deferred()
	)

	fetch_resource()

func fetch_resource():
	if current_target == null:
		return
	look_at(current_target.global_position)

	tween = create_tween()
	tween.finished.connect(grab_resource)

	tween.tween_property(self, "global_position", current_target.global_position, global_position.distance_to(current_target.global_position)/speed)



func grab_resource():
	if tween != null:
		tween.kill()

	print("grabbing resource")
	if current_target == null:
		await get_tree().process_frame
		select_new_node()
		return
	carrying = (current_target as ResourceNode).Take_Resource()

	look_at(home_base.global_position)

	print("returning to base")

	await get_tree().create_timer(randf_range(0,0.5)).timeout

	tween = create_tween()

	tween.finished.connect(
		func() :
			State.resource += carrying
			carrying = 0
			fetch_resource.call_deferred()
	)

	tween.tween_property(self, "global_position", home_base.global_position, global_position.distance_to(home_base.global_position)/speed)
