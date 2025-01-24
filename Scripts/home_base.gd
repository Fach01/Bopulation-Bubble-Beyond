extends Sprite2D

@export_category("Runtime Values")
@export var resource : float
@export var unit_cost : float
@export var bubble_level : float
@export var upgrade_cost : float

@export var shield : Node2D


func upgrade_shield(amount : int) -> bool:
	var _final_cost = upgrade_cost * pow(Constants.upgrade_cost_increment, amount)
	if _final_cost > resource:
		return false
	bubble_level += amount
	resource -= _final_cost
	recalc_bubble_scale()
	return true


func recalc_bubble_scale():
	shield.scale = Vector2.ONE * Constants.bubble_init_scale * Constants.bubble_scale_increase * bubble_level