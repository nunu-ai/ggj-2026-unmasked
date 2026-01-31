class_name SocialClass
extends Trait

var tier: String  # "upper", "middle", "lower"


func _init(_tier: String):
	self.tier = _tier


func name():
	return "Social Class"


func display_value():
	return "%s class" % self.tier.capitalize()


func description():
	return "Their social standing"


func tags():
	return ["social_class"]
