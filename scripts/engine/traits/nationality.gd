class_name Nationality
extends Trait

var country: String


func _init(_country: String):
	self.country = _country


func name():
	return "Nationality"


func description():
	return "Where they come from"


func tags():
	return ["nationality"]
