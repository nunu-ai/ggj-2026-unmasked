class_name Age
extends Trait

var age: int


func _init(_age: int):
	self.age = _age


func name():
	return "Age"


func display_value():
	return "%d years old" % self.age


func description():
	return "how old the person is"


func tags():
	return ["age"]
