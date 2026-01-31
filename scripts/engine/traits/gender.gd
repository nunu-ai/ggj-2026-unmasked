class_name Gender
extends Trait

var identity: String


func _init(_identity: String):
	self.identity = _identity


func name():
	return "Gender"


func display_value():
	return self.identity.capitalize()


func description():
	return "Their gender identity"


func tags():
	return ["gender"]
