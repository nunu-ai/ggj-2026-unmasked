class_name Age
extends Trait

var age: int


func _init(_age: int):
	self.age = _age


func name():
	return "Age"


func description():
	return "%d years old" % self.age


func tags():
	return ["age"]
