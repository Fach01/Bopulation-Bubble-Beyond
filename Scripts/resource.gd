class_name ResourceNode
extends Sprite2D

@export var min_count : int = 20
@export var max_count : int = 40
@export var min_value : int = 10
@export var max_value : int = 50

@export var min_scale : float = 2
@export var max_scale : float = 4

@export var resource_count : int
@export var resource_value : float

signal depleted

func _ready():
    var rando = pow(randf(),2)
    resource_count = lerp(max_count,min_count,rando)
    resource_value = lerp(min_value, max_value, rando)
    rotate(randf() * TAU)
    scale = Vector2.ONE * lerp(min_scale, max_scale, rando)

func Peak_Resources() -> int :
    return resource_count

func Peak_Value() -> float :
    return resource_value

func Take_Resource() -> float:
    if is_queued_for_deletion():
        return 0
    resource_count -= 1
    if resource_count <= 0:
        queue_free()
        depleted.emit()
    return resource_value