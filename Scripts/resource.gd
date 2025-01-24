extends Sprite2D

@export var min_count : int
@export var max_count : int
@export var min_value : int
@export var max_value : int

@export var resource_count : int
@export var resource_value : float

signal depleted

func _ready():
    resource_count = randi_range(min_count,max_count) 
    resource_value = randi_range(min_value,max_value)

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