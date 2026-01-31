class_name Xenophobe
extends Trait

# Dislikes people from other nationalities

var own_nationality: String


func _init(_own_nationality: String):
	self.own_nationality = _own_nationality


func name():
	return "Xenophobe"


func description():
	return "Dislikes foreigners"


func tags():
	return ["personality"]


func calc_score(trait_set: TraitSet):
	var score = 0
	for t in trait_set.get_traits_by_tag("nationality"):
		if t is Nationality:
			if t.country != self.own_nationality:
				score -= 10

	return score
