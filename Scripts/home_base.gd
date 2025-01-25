class_name Home_Base
extends Sprite2D

@export_category("Runtime Values")
@export var unit_cost : float
@export var upgrade_cost : float

@export var shield : Node2D
@export var camera : Camera2D

@export var unit_scene : PackedScene


func upgrade_shield(amount : int) -> bool:
	var _final_cost = upgrade_cost * pow(State.upgrade_cost_increment, amount)
	if _final_cost > State.resource:
		return false
	State.bubble_level += amount
	State.resource -= _final_cost
	recalc_bubble_scale()
	return true


func recalc_bubble_scale():
	shield.scale = Vector2.ONE * State.bubble_init_scale * pow(State.spawn_radius_multiplier, State.bubble_level)
	camera.zoom = Vector2.ONE * 2 / pow(State.spawn_radius_multiplier, State.bubble_level)

func _ready() -> void:
	recalc_bubble_scale()
	spawn_units(10)

func spawn_units(amount : int):
	for i in amount:
		var new_unit : Unit = unit_scene.instantiate()
		new_unit.home_base = self
		new_unit.resource_manager = get_parent().find_child("Resource Manager")
		get_parent().add_child.call_deferred(new_unit)

func buy_units(amount : int, buy_max : bool = true):
	if buy_max:
		for i in amount:
			if unit_cost > State.resource:
				return
			else:
				State.resource -= unit_cost
				spawn_units(1)
	else:
		if unit_cost * amount > State.resource:
			return
		spawn_units(amount)
		State.resource -= unit_cost*amount
