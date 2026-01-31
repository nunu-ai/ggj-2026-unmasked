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
	return "Rival of %ss" % self.rival_profession


func tags():
	return ["personality"]


func can_affect_happiness() -> bool:
	return true


func calc_score(trait_set: TraitSet):
	var score = 0
	for t in trait_set.get_traits_by_tag("profession"):
		if t is Profession:
			if self.rival_profession == t.kind:
				score -= 20  # Intense rivalry penalty

	return score


func explain_score(trait_set: TraitSet, all_people: Array[Person]) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	
	for t in trait_set.get_traits_by_tag("profession"):
		if t is Profession and self.rival_profession == t.kind:
			var owner = _find_trait_owner(t, all_people)
			result.append({
				"reason": "Bitter rivalry with %s!" % self.rival_profession,
				"score": -20,
				"triggered_by": owner
			})
	
	return result
