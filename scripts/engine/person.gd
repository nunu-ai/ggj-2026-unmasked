class_name Person
extends RefCounted

var name: String
var mask  # Mask instance
var money: int
var rules: Array  # Optional personal rules (Rule instances)

func _init(_name: String, _mask, _rules: Array = []):
	name = _name
	mask = _mask
	money = _mask.get_money_value()
	rules = _rules
