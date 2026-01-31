class_name Rival
extends Trait

# Has a personal rivalry with someone of a specific profession
# More intense than simple dislike

var rival_profession: String


func _init(_rival_profession: String):
	self.rival_profession = _rival_profession


func name():
	return "Rival"


func description():
	return "Has a bitter rivalry with certain professionals"


func tags():
	return ["personality"]


func calc_score(trait_set: TraitSet):
	var score = 0
	for t in trait_set.get_traits_by_tag("profession"):
		if t is Profession:
			if self.rival_profession == t.kind:
				score -= 20  # Intense rivalry penalty

	return score
