extends Node
@export var resource_node_tree : PackedScene

@export var active_nodes : Array[ResourceNode]

func spawn_node():
		var new_node : ResourceNode = resource_node_tree.instantiate()
		get_parent().add_child.call_deferred(new_node)
		new_node.depleted.connect( func(): active_nodes.remove_at( active_nodes.find(new_node) ) )
		new_node.position = Vector2.from_angle(randf_range(0,TAU)) * randf_range(Constants.spawn_min_radius, Constants.spawn_min_radius * pow(Constants.spawn_radius_multiplier, Constants.max_bubble_upgrades))
		active_nodes.append(new_node)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in Constants.starter_nodes:
		spawn_node()