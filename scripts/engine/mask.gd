class_name Mask
extends RefCounted

var color: String  # e.g., "gold", "silver", "grey", "blue", etc.
var decoration: String  # e.g., "deco1", "none", etc.

func _init(_color: String, _decoration: String):
	color = _color
	decoration = _decoration


func get_money_value() -> int:
	return 100