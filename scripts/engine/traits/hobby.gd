class_name Hobby
extends Trait

var kind: String


func _init(_kind: String):
	self.kind = _kind


func name():
	return "Hobby"


func display_value():
	return self.kind


func description():
	return "What they enjoy doing"


func tags():
	return ["hobby"]
