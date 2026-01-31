class_name Person
extends RefCounted

var name: String
var traits: Array  # Trait instances (for future use)
var mask: Mask
var money: int
var rules: Array  # Optional personal rules (Rule instances)


func _init(_name: String, _traits: Array = [], _mask: Mask = null, _rules: Array = []):
	self.name = _name
	self.traits = _traits
	self.mask = _mask
	self.money = _mask.get_money_value() if _mask != null else 0
	self.rules = _rules
