class_name Gender
extends Trait

var identity: String


func _init(_identity: String):
	self.identity = _identity


func name():
	return "Gender"


func description():
	return self.identity.capitalize()


func tags():
	return ["gender"]
