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


func can_affect_happiness() -> bool:
	return true


func calc_score(trait_set: TraitSet):
	var score = 0
	for t in trait_set.get_traits_by_tag("nationality"):
		if t is Nationality:
			if t.country != self.own_nationality:
				score -= 10

	return score


func explain_score(trait_set: TraitSet, all_people: Array[Person]) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	
	for t in trait_set.get_traits_by_tag("nationality"):
		if t is Nationality and t.country != self.own_nationality:
			var owner = _find_trait_owner(t, all_people)
			result.append({
				"reason": "Dislikes foreigner (%s)" % t.country,
				"score": -10,
				"triggered_by": owner
			})
	
	return result
