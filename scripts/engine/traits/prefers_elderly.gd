class_name PrefersElderly
extends Trait

# Prefers older, more experienced people


func name():
	return "Prefers Elderly"


func description():
	return "Prefers mature company"


func tags():
	return ["personality"]


func can_affect_happiness() -> bool:
	return true


func calc_score(trait_set: TraitSet):
	var score = 0
	for t in trait_set.get_traits_by_tag("age"):
		if t is Age:
			if t.age >= 50:
				score += 5

	return score


func explain_score(trait_set: TraitSet, all_people: Array[Person]) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	
	for t in trait_set.get_traits_by_tag("age"):
		if t is Age and t.age >= 50:
			var owner = _find_trait_owner(t, all_people)
			result.append({
				"reason": "Appreciates mature company (age %d)" % t.age,
				"score": 5,
				"triggered_by": owner
			})
	
	return result
