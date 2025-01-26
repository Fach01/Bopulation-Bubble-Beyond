extends Node
@export var resource_node_tree : PackedScene

@export var active_nodes : Array[ResourceNode]
@export var meteor : PackedScene

func spawn_node():
		var new_node : ResourceNode = resource_node_tree.instantiate()
		add_child.call_deferred(new_node)
		new_node.depleted.connect( func(): active_nodes.remove_at( active_nodes.find(new_node) ) )
		new_node.position = Vector2.from_angle(randf_range(0,TAU)) * randf_range(State.spawn_min_radius, State.spawn_min_radius * pow(State.spawn_radius_multiplier, State.max_bubble_upgrades + 2))
		active_nodes.append(new_node)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in State.starter_nodes:
		spawn_node()
	
	do_meteors()

func do_meteors():
	while true:
		await get_tree().create_timer(randf_range(3, 20)).timeout
		var new_meteor = meteor.instantiate()
		add_child(new_meteor)
