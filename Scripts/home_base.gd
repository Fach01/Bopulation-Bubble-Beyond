class_name Home_Base
extends Node2D

@export_category("Runtime Values")
@export var unit_cost : float
@export var bubble_upgrade_cost : float
@export var storage_upgrade_cost : float
@export var depletion_speed : float = 5

@export var shield : Node2D
@export var camera : Camera2D
@export var UI_parent : Control
@export var unit_parent : Node
@export var lose_screen : PackedScene
@export var win_screen : PackedScene

@export var dead_unit_texture : Texture2D
@export var mars_green_texture : Texture2D

var units : Array[Unit]

@export var unit_instancer : MultiMeshInstance2D

var dead : bool

var time_in_bubble : float = 1

signal changed_storage(max_storage : float)
signal changed_resource(resources : float)
signal changed_resource_text(new_text : String)
signal pop
signal bubble_upgraded(new_price : float)
signal unit_upgraded(new_price : float)
signal win


@export var unit_scene : PackedScene

func _process(delta: float) -> void:
	if dead || State.has_won : return
	time_in_bubble += delta
	State.resource = min(State.resource, State.max_resource)
	State.resource -= depletion_speed * (State.bubble_level) * (time_in_bubble * 0.1) * delta 
	changed_resource.emit(State.resource)
	update_text()
	if State.resource <= 0:
		pop.emit()
		summon_lose_screen()
		unit_instancer.texture = dead_unit_texture
		units.clear()
		dead = true
		return

	for i in unit_instancer.multimesh.instance_count:
		unit_instancer.multimesh.set_instance_transform_2d(i, units[i].transform)

func update_text():
	var new_text : String = str(int(State.resource)) + "/" + str(int(State.max_resource))
	changed_resource_text.emit(new_text)

func summon_lose_screen():
	var node = lose_screen.instantiate()
	UI_parent.add_child(node)

func summon_win_screen():
	get_parent().find_child("Mars").texture = mars_green_texture
	var node = win_screen.instantiate()
	UI_parent.add_child(node)

func upgrade_shield(amount : int = 1) -> bool:
	var _final_cost = lerp(bubble_upgrade_cost, State.max_bubble_cost, pow(inverse_lerp(1,State.max_bubble_upgrades, State.bubble_level), 2))
	if _final_cost > State.resource:
		return false
	State.bubble_level += amount
	State.resource -= _final_cost
	time_in_bubble = 1
	recalc_bubble_scale()
	recalc_camera_zoom()
	bubble_upgraded.emit(bubble_upgrade_cost)
	if State.bubble_level > State.max_bubble_upgrades:
		win.emit()
		State.has_won = true
		summon_win_screen()
	return true


func recalc_bubble_scale():
	var tween = create_tween()
	tween.tween_property(shield, "scale", Vector2.ONE * State.bubble_init_scale * pow(State.spawn_radius_multiplier, State.bubble_level), 0.5).set_trans(tween.TRANS_ELASTIC)

func recalc_camera_zoom():
	camera.zoom = Vector2.ONE / pow(State.spawn_radius_multiplier, State.bubble_level)

func _ready() -> void:
	State.resource = State.init_resource
	State.max_resource = State.init_max_resource
	State.bubble_level = State.init_bubble_level

	changed_storage.emit(State.max_resource)
	recalc_bubble_scale()
	recalc_camera_zoom()

	tree_exited.connect(func() : unit_instancer.multimesh.instance_count = 0)

	spawn_units(1)

func spawn_units(amount : int):
	for i in amount:
		var new_unit : Unit = unit_scene.instantiate()
		new_unit.home_base = self
		new_unit.resource_manager = get_parent().find_child("Resource Manager")
		unit_parent.add_child.call_deferred(new_unit)
		units.append(new_unit)
		unit_instancer.multimesh.instance_count += 1

func buy_units(amount : int = 1, buy_max : bool = true):
	if buy_max:
		for i in amount:
			if unit_cost > State.resource:
				return
			else:
				State.resource -= unit_cost
				unit_cost *= State.unit_cost_increment
				spawn_units(1)
				unit_upgraded.emit(unit_cost)
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
