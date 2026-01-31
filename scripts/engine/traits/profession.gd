class_name Profession
extends Trait

var kind: String


func _init(_kind: String):
	self.kind = _kind


func name():
	return "Profession"


func description():
	return "profession"


func tags():
	return ["profession"]
