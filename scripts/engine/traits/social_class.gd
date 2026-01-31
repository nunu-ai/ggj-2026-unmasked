class_name SocialClass
extends Trait

var tier: String  # "upper", "middle", "lower"


func _init(_tier: String):
	self.tier = _tier


func name():
	return "Social Class"


func description():
	return "%s class" % self.tier.capitalize()


func tags():
	return ["social_class"]
