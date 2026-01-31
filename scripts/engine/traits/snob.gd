class_name Snob
extends Trait

# Snobs dislike people from lower social classes


func name():
	return "Snob"


func description():
	return "Looks down on lower social classes"


func tags():
	return ["personality"]


func can_affect_happiness() -> bool:
	return true


func calc_score(trait_set: TraitSet):
	var score = 0
	for t in trait_set.get_traits_by_tag("social_class"):
		if t is SocialClass:
			if t.tier == "lower":
				score -= 15
			elif t.tier == "middle":
				score -= 5

	return score


func explain_score(trait_set: TraitSet, all_people: Array[Person]) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	
	for t in trait_set.get_traits_by_tag("social_class"):
		if t is SocialClass:
			var owner = _find_trait_owner(t, all_people)
			if t.tier == "lower":
				result.append({
					"reason": "Disgusted by lower class",
					"score": -15,
					"triggered_by": owner
				})
			elif t.tier == "middle":
				result.append({
					"reason": "Looks down on middle class",
					"score": -5,
					"triggered_by": owner
				})
	
	return result
