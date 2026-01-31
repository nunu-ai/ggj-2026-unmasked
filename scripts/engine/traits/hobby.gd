class_name Hobby
extends Trait

var kind: String


func _init(_kind: String):
	self.kind = _kind


func name():
	return "Hobby"


func description():
	return "Enjoys %s" % self.kind


func tags():
	return ["hobby"]
