class_name Extrovert
extends Trait

# Thrives in larger groups - happiness increases with group size


func name():
	return "Extrovert"


func description():
	return "Loves crowds"


func tags():
	return ["personality"]


func can_affect_happiness() -> bool:
	return true


func calc_score(trait_set: TraitSet):
	# Count how many different people are represented (by counting unique age traits as proxy)
	var person_count = trait_set.get_traits_by_tag("age").size()

	if person_count <= 2:
		return -3  # Small group penalty
	elif person_count <= 4:
		return 2  # Medium group bonus
	else:
		return (person_count - 4) * 2 + 2  # Bonus for larger groups


func explain_score(trait_set: TraitSet, _all_people: Array[Person]) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var person_count = trait_set.get_traits_by_tag("age").size()
	
	if person_count <= 2:
		result.append({
			"reason": "Small group (%d people) - wants more company" % person_count,
			"score": -3,
			"triggered_by": null
		})
	elif person_count <= 4:
		result.append({
			"reason": "Medium group (%d people) - enjoying the party" % person_count,
			"score": 2,
			"triggered_by": null
		})
	else:
		result.append({
			"reason": "Large group (%d people) - thriving!" % person_count,
			"score": (person_count - 4) * 2 + 2,
			"triggered_by": null
		})
	
	return result
