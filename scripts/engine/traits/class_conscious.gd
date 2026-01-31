class_name ClassConscious
extends Trait

# Prefers people of their own social class, dislikes other classes

var own_class: String


func _init(_own_class: String):
	self.own_class = _own_class


func name():
	return "Class Conscious"


func description():
	return "%s class only" % self.own_class.capitalize()


func tags():
	return ["personality"]


func can_affect_happiness() -> bool:
	return true


func calc_score(trait_set: TraitSet):
	var score = 0
	for t in trait_set.get_traits_by_tag("social_class"):
		if t is SocialClass:
			if t.tier == self.own_class:
				score += 3
			else:
				score -= 8

	return score
