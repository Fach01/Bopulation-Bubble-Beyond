class_name Home_Base
extends Sprite2D

@export_category("Runtime Values")
@export var unit_cost : float
@export var bubble_upgrade_cost : float
@export var storage_upgrade_cost : float
@export var depletion_speed : float = 5

@export var shield : Node2D
@export var camera : Camera2D
@export var UI_parent : Control
@export var lose_screen : PackedScene

var dead : bool


signal changed_storage(max_storage : float)
signal changed_resource(resources : float)
signal pop


@export var unit_scene : PackedScene

func _process(delta: float) -> void:
	if dead : return
	State.resource = min(State.resource, State.max_resource)
	State.resource -= depletion_speed * (State.bubble_level * .8) * delta
	changed_resource.emit(State.resource)
	if State.resource <= 0:
		pop.emit()
		summon_lose_screen()
		dead = true

func summon_lose_screen():
	var node = lose_screen.instantiate()
	UI_parent.add_child(node)

func upgrade_shield(amount : int) -> bool:
	var _final_cost = bubble_upgrade_cost * pow(State.upgrade_cost_increment, amount)
	if _final_cost > State.resource:
		return false
	State.bubble_level += amount
	State.resource -= _final_cost
	recalc_camera_zoom()
	return true


func recalc_bubble_scale():
	shield.scale = Vector2.ONE * State.bubble_init_scale * pow(State.spawn_radius_multiplier, State.bubble_level)

func recalc_camera_zoom():
	camera.zoom = Vector2.ONE / pow(State.spawn_radius_multiplier, State.bubble_level)

func _ready() -> void:
	changed_storage.emit(State.max_resource)
	recalc_bubble_scale()
	recalc_camera_zoom()

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

func upgrade_storage():
	if storage_upgrade_cost > State.resource:
		return

	State.max_resource *= 1.2
	storage_upgrade_cost *= 1.2
	changed_storage.emit(State.max_resource)
